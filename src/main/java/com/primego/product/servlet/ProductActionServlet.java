package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.product.dao.ProductImageDAO;
import com.primego.product.model.Product;
import com.primego.product.model.ProductImage;
import com.primego.user.model.User;
import com.primego.common.util.PathUtil;

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

@WebServlet("/product_action")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductActionServlet extends HttpServlet {

    // 实例化两个 DAO
    private ProductDAO productDAO = new ProductDAO();
    private ProductImageDAO imageDAO = new ProductImageDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("update".equals(action)) {
            handleUpdate(request, response);
        } else if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        try {
            // 1. 获取并更新基本信息
            int productId = Integer.parseInt(request.getParameter("productId"));
            String name = request.getParameter("productName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            BigDecimal price = new BigDecimal(request.getParameter("productPrice"));
            int stock = Integer.parseInt(request.getParameter("productStock"));
            String status = request.getParameter("productStatus");
            String description = request.getParameter("productDescription");

            // ⭐ 获取 WhatsApp 联系方式
            String whatsapp = request.getParameter("contactWhatsapp");

            Product product = new Product();
            product.setProductId(productId);
            product.setMerchantId(user.getId());
            product.setProductName(name);
            product.setCategoryId(categoryId);
            product.setProductPrice(price);
            product.setProductStockQuantity(stock);

            // ⭐ 设置 WhatsApp 到对象中
            product.setContactWhatsapp(whatsapp);

            product.setProductStatus(status);
            product.setProductDescription(description);

            boolean updateSuccess = productDAO.updateProduct(product);

            if (updateSuccess) {
                // ==========================================
                // 2. 处理图片删除 (接收逗号分隔的 ID 字符串)
                // ==========================================
                String deleteIds = request.getParameter("deleteImageIds");
                if (deleteIds != null && !deleteIds.trim().isEmpty()) {
                    String[] ids = deleteIds.split(",");
                    for (String idStr : ids) {
                        try {
                            int imgId = Integer.parseInt(idStr);
                            imageDAO.deleteImageById(imgId);
                        } catch (NumberFormatException e) {
                            e.printStackTrace();
                        }
                    }
                }

                // ==========================================
                // 3. 处理新图片上传 (多图)
                // ==========================================
                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

                // 使用 PathUtil 获取源码目录
                String sourceDir = PathUtil.getUploadDir(getServletContext(), "products");
                
                // DEBUG LOGGING
                System.out.println("[ProductActionServlet] Upload Dir (Runtime): " + uploadDir);
                System.out.println("[ProductActionServlet] Source Dir (Local): " + sourceDir);
                
                File sourceDirFile = new File(sourceDir);
                if (!sourceDirFile.exists()) sourceDirFile.mkdirs();

                Collection<Part> parts = request.getParts();
                for (Part part : parts) {
                    if (part.getName().equals("newImages") && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {

                        String fileName = UUID.randomUUID().toString() + "_" + getFileName(part);

                        // 保存到 Tomcat 运行目录
                        String filePath = uploadDir + File.separator + fileName;
                        part.write(filePath);

                        // 保存到本地源码目录 (如果不同)
                        if (!new File(uploadDir).getAbsolutePath().equals(new File(sourceDir).getAbsolutePath())) {
                            try {
                                java.nio.file.Files.copy(
                                        new File(filePath).toPath(),
                                        new File(sourceDir + File.separator + fileName).toPath(),
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                );
                            } catch (Exception e) {
                                System.err.println("Local copy failed: " + e.getMessage());
                            }
                        }

                        // 插入数据库 (新上传的默认为非主图 false)
                        String dbImageUrl = "assets/images/products/" + fileName;
                        ProductImage img = new ProductImage(productId, dbImageUrl, false);
                        imageDAO.insertImage(img);
                    }
                }

                // ==========================================
                // ⭐ 4. 处理图片排序与主图更新 (新增逻辑)
                // ==========================================
                String sortOrder = request.getParameter("imageSortOrder"); // 获取前端 "105,102,101"
                if (sortOrder != null && !sortOrder.trim().isEmpty()) {
                    String[] ids = sortOrder.split(",");
                    if (ids.length > 0) {
                        try {
                            // 列表中的第一个 ID 就是用户拖拽到第一位的图片
                            int newPrimaryId = Integer.parseInt(ids[0]);

                            // 调用 DAO 更新：把这个ID设为主图，其他的设为非主图
                            imageDAO.updatePrimaryImage(productId, newPrimaryId);
                        } catch (NumberFormatException e) {
                            e.printStackTrace();
                        }
                    }
                }

                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?msg=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=exception");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int productId = Integer.parseInt(idStr);
                // 1. 先删图片
                imageDAO.deleteImagesByProductId(productId);
                // 2. 再删商品 (需要你在 ProductDAO 加这个方法，或者逻辑删除)
                // productDAO.deleteProduct(productId);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp");
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