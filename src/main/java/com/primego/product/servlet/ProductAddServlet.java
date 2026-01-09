package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.product.dao.ProductImageDAO; // 1. 引入类
import com.primego.product.model.Product;
import com.primego.product.model.ProductImage;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collection;
import java.util.UUID;

@WebServlet("/product_add_action")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductAddServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductImageDAO productImageDAO = new ProductImageDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        try {
            // 1. Retrieve form data
            String productName = request.getParameter("productName");
            String categoryIdStr = request.getParameter("categoryId");
            String priceStr = request.getParameter("price");
            String stockStr = request.getParameter("stock");
            String whatsapp = request.getParameter("contactWhatsapp");
            String description = request.getParameter("description");

            // 2. Validate and Parse
            BigDecimal price = new BigDecimal(priceStr);
            int stock = Integer.parseInt(stockStr);
            int categoryId = Integer.parseInt(categoryIdStr);

            // 3. Create Product Object
            Product product = new Product();
            product.setMerchantId(user.getId());
            product.setCategoryId(categoryId);
            product.setProductName(productName);
            product.setProductDescription(description);
            product.setProductPrice(price);
            product.setProductStockQuantity(stock);
            product.setContactWhatsapp(whatsapp);

            // ✅ DB schema note:
            // Product_Status is enum('ON_SALE','OFF_SALE'), so we can’t store PENDING here.
            // Use Audit_Status to control admin review.
            product.setProductStatus("OFF_SALE");
            product.setAuditStatus("PENDING");
            product.setAuditMessage(null);

            // 4. Insert Product first to get the ID
            int productId = productDAO.insertProduct(product);

            if (productId > 0) {
                // ============================================================
                // 5. Handle MULTIPLE Image Uploads
                // ============================================================

                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

                // Use a portable source dir inside project instead of hard-coded user path
                String sourceDir = request.getServletContext().getRealPath("/") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File sourceDirFile = new File(sourceDir);
                if (!sourceDirFile.exists()) sourceDirFile.mkdirs();

                Collection<Part> parts = request.getParts();

                boolean isFirstImage = true;

                for (Part part : parts) {
                    if (part.getName().equals("productImage") && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {

                        String fileName = UUID.randomUUID().toString() + "_" + getFileName(part);

                        // A. Save to Tomcat
                        String filePath = uploadDir + File.separator + fileName;
                        part.write(filePath);

                        // B. Save to Source
                        try {
                            java.nio.file.Files.copy(
                                    new File(filePath).toPath(),
                                    new File(sourceDir + File.separator + fileName).toPath(),
                                    java.nio.file.StandardCopyOption.REPLACE_EXISTING
                            );
                        } catch (Exception e) {
                            System.err.println("Failed to copy to local source dir: " + e.getMessage());
                        }

                        // C. Insert into DB
                        String dbImageUrl = "assets/images/products/" + fileName;

                        ProductImage image = new ProductImage(productId, dbImageUrl, isFirstImage);

                        // ✅ 3. 使用实例变量调用方法，而不是类名
                        productImageDAO.insertImage(image);

                        isFirstImage = false;
                    }
                }

                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?msg=pending_review");
            } else {
                request.setAttribute("errorMessage", "Failed to insert product record.");
                request.getRequestDispatcher("/merchant/product/publish.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System Error: " + e.getMessage());
            request.getRequestDispatcher("/merchant/product/publish.jsp").forward(request, response);
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}