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

    // DAO instances for product and product image operations.
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
            // 1) Read input fields.
            int productId = Integer.parseInt(request.getParameter("productId"));

            // Load the current product from the database so we can compare changes.
            Product oldProduct = productDAO.getProductById(productId);
            if (oldProduct == null) {
                // If the product cannot be found, stop to avoid null references.
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=notfound");
                return;
            }

            String name = request.getParameter("productName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            BigDecimal price = new BigDecimal(request.getParameter("productPrice"));
            int stock = Integer.parseInt(request.getParameter("productStock"));
            // Read the UI-provided status first; it may be overridden by the audit rule below.
            String status = request.getParameter("productStatus");
            String description = request.getParameter("productDescription");
            String whatsapp = request.getParameter("contactWhatsapp");

            // --------------------------------------------------
            // Detect whether sensitive fields have changed.
            // If they did, force the product into re-audit.
            // --------------------------------------------------
            boolean needsAudit = false;

            // Check whether the description changed.
            if (isStringChanged(oldProduct.getProductDescription(), description)) {
                needsAudit = true;
            }
            // Check whether WhatsApp contact changed.
            if (isStringChanged(oldProduct.getContactWhatsapp(), whatsapp)) {
                needsAudit = true;
            }

            // Check whether the product name changed.
            if (isStringChanged(oldProduct.getProductName(), name)) {
                needsAudit = true;
            }

            // Check whether any images were removed.
            String deleteIds = request.getParameter("deleteImageIds");
            if (deleteIds != null && !deleteIds.trim().isEmpty()) {
                needsAudit = true;
            }

            // Check whether any new images were uploaded.
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getName().equals("newImages") && part.getSize() > 0 && part.getSubmittedFileName() != null && !part.getSubmittedFileName().isEmpty()) {
                    needsAudit = true;
                    break;
                }
            }

            // --------------------------------------------------
            // Build the updated product object.
            // --------------------------------------------------
            Product product = new Product();
            product.setProductId(productId);
            product.setMerchantId(user.getId());
            product.setProductName(name);
            product.setCategoryId(categoryId);
            product.setProductPrice(price);
            product.setProductStockQuantity(stock);
            product.setContactWhatsapp(whatsapp);
            product.setProductDescription(description);

            // Apply status/audit fields based on the change detection.
            if (needsAudit) {
                // Sensitive content changed: force the product off-sale and set audit status to pending.
                product.setProductStatus("OFF_SALE");
                product.setAuditStatus("PENDING");
                product.setAuditMessage(null);
                System.out.println("Product ID " + productId + " triggered re-audit due to content changes.");
            } else {
                // No sensitive content change: keep existing audit fields; use the UI-provided product status.
                product.setProductStatus(status);
                product.setAuditStatus(oldProduct.getAuditStatus());
                product.setAuditMessage(oldProduct.getAuditMessage());
            }

            // Persist the update.
            boolean updateSuccess = productDAO.updateProduct(product);

            if (updateSuccess) {
                // 2) Delete selected images.
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

                // 3) Save newly uploaded images.
                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "products";
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

                String sourceDir = PathUtil.getUploadDir(getServletContext(), "products");
                File sourceDirFile = new File(sourceDir);
                if (!sourceDirFile.exists()) sourceDirFile.mkdirs();

                // Iterate parts again to actually write files (the first pass was only for validation).
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

                // 4) Apply image ordering (the first ID is treated as the primary image).
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
                } else {
                    // If the merchant deleted all existing images, the frontend sort order will be empty
                    // (new uploads don't have DB ids yet). In that case, enforce a primary image if any
                    // images remain after deletes/inserts.
                    Integer fallbackPrimaryId = imageDAO.getFirstImageIdByProductId(productId);
                    if (fallbackPrimaryId != null) {
                        imageDAO.updatePrimaryImage(productId, fallbackPrimaryId);
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

    // Helper: compare two strings safely (handles nulls and leading/trailing whitespace).
    private boolean isStringChanged(String oldVal, String newVal) {
        String o = (oldVal == null) ? "" : oldVal.trim();
        String n = (newVal == null) ? "" : newVal.trim();
        return !o.equals(n);
    }
}

