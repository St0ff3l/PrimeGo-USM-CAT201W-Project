package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
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
import java.util.UUID;

@WebServlet("/product_add_action")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductAddServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        // 1. Retrieve form data
        String productName = request.getParameter("productName");
        String categoryIdStr = request.getParameter("categoryId");
        String priceStr = request.getParameter("price");
        String stockStr = request.getParameter("stock");
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
        product.setProductStatus("ON_SALE");

        // 5. Insert Product
        int productId = productDAO.insertProduct(product);
        
        if (productId > 0) {
            // 6. Handle Image Upload
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
                
                // A. Save to Deployment Directory (Target) - for immediate display
                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                }
                
                String filePath = uploadDir + File.separator + fileName;
                filePart.write(filePath);
                
                // B. Save to Source Directory (Local Project) - for persistence
                // NOTE: This path is specific to your local machine environment
                String sourceDir = "/Users/zhangyifei/IdeaProjects/PrimeGo-USM-CAT201W-Project/src/main/webapp/assets/images/products";
                File sourceDirFile = new File(sourceDir);
                if (!sourceDirFile.exists()) {
                    sourceDirFile.mkdirs();
                }
                
                try {
                    java.nio.file.Files.copy(
                        new File(filePath).toPath(), 
                        new File(sourceDir + File.separator + fileName).toPath(),
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace(); // Log error but don't fail the request if local copy fails
                }
                
                // Save Image to DB
                String imageUrl = "assets/images/products/" + fileName;
                ProductImage image = new ProductImage(productId, imageUrl, true);
                productDAO.insertProductImage(image);
            }
            
            // Success
            response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp");
        } else {
            // Failure
            request.setAttribute("errorMessage", "Failed to publish product.");
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
