<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.product.dao.CategoryDAO" %>
<%@ page import="com.primego.product.model.Category" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // ==========================================
    // 1. 权限与身份验证 (安全性检查)
    // ==========================================
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"MERCHANT".equals(currentUser.getRole().toString())) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    // ==========================================
    // 2. 获取产品数据
    // ==========================================
    String productIdStr = request.getParameter("id");
    ProductDTO product = null;
    List<Category> categoryList = null;

    if (productIdStr != null && !productIdStr.trim().isEmpty()) {
        try {
            int pid = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            product = productDAO.getProductById(pid);

            // 安全检查：确保当前商家只能编辑自己的商品
            if (product != null && product.getMerchantId() != currentUser.getId()) {
                // 修改跳转路径
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp?error=unauthorized");
                return;
            }

            // 获取分类列表用于下拉框
            CategoryDAO categoryDAO = new CategoryDAO();
            categoryList = categoryDAO.findAll();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (product == null) {
        // 修改跳转路径
        response.sendRedirect(request.getContextPath() + "/merchant/product/product_manager.jsp?error=notfound");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - PrimeGo Merchant</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.bootcdn.net/ajax/libs/remixicon/3.5.0/remixicon.css" rel="stylesheet">

    <style>
        /* --- 复用之前的样式 --- */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --input-bg: rgba(255, 255, 255, 0.9);
            --card-radius: 20px;
            --pg-glass-bg: rgba(255, 255, 255, 0.7);
            --pg-glass-border: rgba(255, 255, 255, 0.9);
            --pg-glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --pg-glass-blur: 20px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            padding-top: 100px;
        }

        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }

        .product-wrapper {
            display: grid;
            grid-template-columns: 1fr 1.2fr;
            gap: 40px;
        }

        .main-image-container {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            height: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 20px;
            position: relative;
        }

        .main-image-container img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .image-edit-overlay {
            position: absolute;
            bottom: 20px;
            background: rgba(0,0,0,0.6);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            cursor: pointer;
            backdrop-filter: blur(4px);
        }

        .edit-section {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            padding: 40px;
        }

        .form-group { margin-bottom: 20px; }
        .form-label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-dark); font-size: 0.9rem; }
        .form-control { width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 12px; background: var(--input-bg); font-size: 1rem; color: #333; outline: none; transition: all 0.3s; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(255, 149, 0, 0.1); }
        textarea.form-control { resize: vertical; min-height: 120px; line-height: 1.6; }
        .row-group { display: flex; gap: 20px; }
        .row-group .form-group { flex: 1; }

        .action-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn-action { flex: 1; padding: 15px; border-radius: 12px; font-size: 1rem; font-weight: 700; cursor: pointer; text-align: center; border: none; display: flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; transition: all 0.3s; }
        .btn-save { background: var(--primary); color: white; box-shadow: 0 10px 20px rgba(255, 149, 0, 0.2); }
        .btn-save:hover { background: var(--primary-hover); transform: translateY(-2px); }
        .btn-cancel { background: #e0e0e0; color: #555; }
        .btn-cancel:hover { background: #d0d0d0; }

        .header-title { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; padding-bottom: 15px; border-bottom: 1px solid rgba(0,0,0,0.05); }
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
        .badge-edit { background: #E3F2FD; color: #1976D2; }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="container">
    <form action="${pageContext.request.contextPath}/product_action" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="productId" value="<%= product.getProductId() %>">

        <div class="product-wrapper">

            <div class="gallery-section">
                <div class="main-image-container">
                    <img src="<%= (product.getPrimaryImageUrl() != null) ? request.getContextPath() + "/" + product.getPrimaryImageUrl() : "https://via.placeholder.com/600" %>" alt="Product Image">
                    <div class="image-edit-overlay" onclick="document.getElementById('imageUpload').click()">
                        <i class="ri-camera-line"></i> Change Image
                    </div>
                </div>
                <input type="file" id="imageUpload" name="primaryImage" style="display: none;" accept="image/*">
                <p style="text-align: center; color: var(--text-gray); font-size: 0.9rem;">
                    Click the image to upload a new one.
                </p>
            </div>

            <div class="edit-section">
                <div class="header-title">
                    <h2 style="font-size: 1.8rem;">Edit Product</h2>
                    <span class="badge badge-edit">ID: <%= product.getProductId() %></span>
                </div>

                <div class="form-group">
                    <label class="form-label">Product Name</label>
                    <input type="text" name="productName" class="form-control" value="<%= product.getProductName() %>" required>
                </div>

                <div class="form-group">
                    <label class="form-label">Category</label>
                    <select name="categoryId" class="form-control">
                        <% if (categoryList != null) {
                            for (Category c : categoryList) {
                                boolean isSelected = c.getCategoryId() == product.getCategoryId();
                        %>
                        <option value="<%= c.getCategoryId() %>" <%= isSelected ? "selected" : "" %>>
                            <%= c.getCategoryName() %>
                        </option>
                        <%  }
                        } %>
                    </select>
                </div>

                <div class="row-group">
                    <div class="form-group">
                        <label class="form-label">Price (RM)</label>
                        <input type="number" name="productPrice" class="form-control" step="0.01" min="0" value="<%= product.getProductPrice() %>" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Stock Quantity</label>
                        <input type="number" name="productStock" class="form-control" step="1" min="0" value="<%= product.getProductStockQuantity() %>" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="productStatus" class="form-control">
                        <option value="ON_SALE" <%= "ON_SALE".equals(product.getProductStatus()) ? "selected" : "" %>>On Sale (Visible)</option>
                        <option value="OFF_SALE" <%= "OFF_SALE".equals(product.getProductStatus()) ? "selected" : "" %>>Off Sale (Hidden)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Description</label>
                    <textarea name="productDescription" class="form-control"><%= product.getProductDescription() != null ? product.getProductDescription() : "" %></textarea>
                </div>

                <div class="action-group">
                    <a href="${pageContext.request.contextPath}/merchant/product/product_manager.jsp" class="btn-action btn-cancel">
                        Cancel
                    </a>
                    <button type="submit" class="btn-action btn-save">
                        <i class="ri-save-line"></i> Save Changes
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>

</body>
</html>