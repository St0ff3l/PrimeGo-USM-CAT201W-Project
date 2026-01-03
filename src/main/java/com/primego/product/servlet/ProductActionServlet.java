package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.product.model.Product;
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

// 1. 对应 JSP form 中的 action="product_action"
@WebServlet("/product_action")
// 2. 必须加这个注解才能接收图片文件
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductActionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 防止中文乱码
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("update".equals(action)) {
            handleUpdate(request, response);
        } else if ("delete".equals(action)) {
            // 你以后可以在这里加删除逻辑
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 安全检查：只有商家能操作
        if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        try {
            // 1. 获取普通字段
            String idStr = request.getParameter("productId");
            if(idStr == null || idStr.isEmpty()) {
                throw new ServletException("Product ID is missing");
            }
            int productId = Integer.parseInt(idStr);

            String name = request.getParameter("productName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            BigDecimal price = new BigDecimal(request.getParameter("productPrice"));
            int stock = Integer.parseInt(request.getParameter("productStock"));
            String status = request.getParameter("productStatus");
            String description = request.getParameter("productDescription");

            // 2. 构建 Product 对象
            Product product = new Product();
            product.setProductId(productId);
            product.setMerchantId(user.getId()); // 关键：用于 DAO 层校验权限
            product.setProductName(name);
            product.setCategoryId(categoryId);
            product.setProductPrice(price);
            product.setProductStockQuantity(stock);
            product.setProductStatus(status);
            product.setProductDescription(description);

            ProductDAO dao = new ProductDAO();

            // 3. 更新基本信息
            boolean success = dao.updateProduct(product);

            // 4. 处理图片上传 (如果有新文件)
            Part filePart = request.getPart("primaryImage");
            if (success && filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                // 生成唯一文件名防止覆盖
                String uniqueName = UUID.randomUUID().toString() + "_" + fileName;

                // 定义保存路径
                String uploadDir = getServletContext().getRealPath("/assets/images/products");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                // 保存文件到服务器
                filePart.write(uploadDir + File.separator + uniqueName);

                // 更新数据库中的图片路径 (相对路径)
                String dbImagePath = "assets/images/products/" + uniqueName;
                dao.updateProductPrimaryImage(productId, dbImagePath);
            }

            if (success) {
                // ⚡️修改：成功后跳转回 product_manager.jsp
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp?msg=updated");
            } else {
                // ⚡️修改：失败后跳转回 product_manager.jsp
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp?error=exception");
        }
    }
}