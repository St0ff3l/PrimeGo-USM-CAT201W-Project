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
            // 1. 获取基本信息
            int productId = Integer.parseInt(request.getParameter("productId"));

            // ⭐ 关键逻辑：先获取数据库中的旧数据，用于对比
            Product oldProduct = productDAO.getProductById(productId);
            if (oldProduct == null) {
                // 防止空指针，如果找不到商品直接返回
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=notfound");
                return;
            }

            String name = request.getParameter("productName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            BigDecimal price = new BigDecimal(request.getParameter("productPrice"));
            int stock = Integer.parseInt(request.getParameter("productStock"));
            // 注意：这里先获取前端传来的状态，后面可能会被逻辑覆盖
            String status = request.getParameter("productStatus");
            String description = request.getParameter("productDescription");
            String whatsapp = request.getParameter("contactWhatsapp");

            // ==========================================
            // ⭐ 关键逻辑：检测敏感字段是否发生变更
            // ==========================================
            boolean needsAudit = false;

            // 1. 检测描述是否改变
            if (isStringChanged(oldProduct.getProductDescription(), description)) {
                needsAudit = true;
            }
            // 2. 检测 WhatsApp 是否改变
            if (isStringChanged(oldProduct.getContactWhatsapp(), whatsapp)) {
                needsAudit = true;
            }

            // ⭐⭐ 3. 新增：检测商品名称是否改变
            if (isStringChanged(oldProduct.getProductName(), name)) {
                needsAudit = true;
            }

            // 4. 检测是否删除了图片
            String deleteIds = request.getParameter("deleteImageIds");
            if (deleteIds != null && !deleteIds.trim().isEmpty()) {
                needsAudit = true;
            }

            // 5. 检测是否上传了新图片 (需要遍历 Part)
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getName().equals("newImages") && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    needsAudit = true;
                    break;
                }
            }

            // ==========================================
            // 组装新对象
            // ==========================================
            Product product = new Product();
            product.setProductId(productId);
            product.setMerchantId(user.getId());
            product.setProductName(name);
            product.setCategoryId(categoryId);
            product.setProductPrice(price);
            product.setProductStockQuantity(stock);
            product.setContactWhatsapp(whatsapp);
            product.setProductDescription(description);

            // 根据变更检测结果设置状态
            if (needsAudit) {
                // ⚠️ 触发了敏感修改：强制下架并重置为待审核
                product.setProductStatus("OFF_SALE");
                product.setAuditStatus("PENDING");
                product.setAuditMessage(null); // 清空之前的审核消息
                System.out.println("Product ID " + productId + " triggered re-audit due to content changes.");
            } else {
                // ✅ 未修改敏感信息：保留原有的审核状态，状态使用前端传来的（比如用户只是改了价格或手动上下架）
                product.setProductStatus(status);
                product.setAuditStatus(oldProduct.getAuditStatus());
                product.setAuditMessage(oldProduct.getAuditMessage());
            }

            // 执行更新
            boolean updateSuccess = productDAO.updateProduct(product);

            if (updateSuccess) {
                // ==========================================
                // 2. 处理图片删除
                // ==========================================
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
                // 3. 处理新图片上传
                // ==========================================
                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

                String sourceDir = PathUtil.getUploadDir(getServletContext(), "products");
                File sourceDirFile = new File(sourceDir);
                if (!sourceDirFile.exists()) sourceDirFile.mkdirs();

                // 重新遍历 Parts 保存文件 (前面只是检查，这里是实际保存)
                for (Part part : parts) {
                    if (part.getName().equals("newImages") && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {

                        String fileName = UUID.randomUUID().toString() + "_" + getFileName(part);
                        String filePath = uploadDir + File.separator + fileName;
                        part.write(filePath);

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

                        String dbImageUrl = "assets/images/products/" + fileName;
                        ProductImage img = new ProductImage(productId, dbImageUrl, false);
                        imageDAO.insertImage(img);
                    }
                }

                // ==========================================
                // 4. 处理图片排序
                // ==========================================
                String sortOrder = request.getParameter("imageSortOrder");
                if (sortOrder != null && !sortOrder.trim().isEmpty()) {
                    String[] ids = sortOrder.split(",");
                    if (ids.length > 0) {
                        try {
                            int newPrimaryId = Integer.parseInt(ids[0]);
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
                imageDAO.deleteImagesByProductId(productId);
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

    // 辅助方法：比较两个字符串是否不同 (处理 null 和空字符串的情况)
    private boolean isStringChanged(String oldVal, String newVal) {
        String o = (oldVal == null) ? "" : oldVal.trim();
        String n = (newVal == null) ? "" : newVal.trim();
        return !o.equals(n);
    }
}