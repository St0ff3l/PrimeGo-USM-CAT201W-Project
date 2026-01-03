<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // ==========================================
    // 1. 获取产品 ID 与 数据
    // ==========================================
    String productIdStr = request.getParameter("id");

    ProductDTO product = null;
    String statusDisplay = ""; // 用于前端显示的格式化状态

    if (productIdStr != null && !productIdStr.trim().isEmpty()) {
        try {
            int pid = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            product = productDAO.getProductById(pid);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // --- 处理状态显示 (去除下划线，改为易读格式) ---
    if (product.getProductStatus() != null) {
        if ("ON_SALE".equals(product.getProductStatus())) {
            statusDisplay = "On Sale";
        } else if ("OFF_SALE".equals(product.getProductStatus())) {
            statusDisplay = "Off Sale"; // 或者 "Sold Out"
        } else {
            // 如果有其他状态，直接把下划线换成空格
            statusDisplay = product.getProductStatus().replace("_", " ");
        }
    }

    // 获取当前登录用户
    User currentUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getProductName() %> - PrimeGo</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        /* --- 1. Global Styles --- */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --dark-btn: #2d3436;
            --dark-btn-hover: #000000;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --success: #10B981;
            --card-radius: 20px;

            /* Glass tokens */
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

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* --- 2. Layout & Animation --- */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .product-wrapper {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 40px;
            animation: fadeInUp 0.6s ease forwards;
        }

        /* --- 3. Gallery --- */
        .gallery-section {
            position: sticky;
            top: 120px;
        }

        .main-image-container {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            height: 500px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 20px;
        }

        .main-image-container img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        /* --- 4. Info --- */
        .info-section {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            padding: 40px;
        }

        .condition-tag {
            display: inline-block;
            padding: 6px 16px;
            background: #FFF4E5;
            color: var(--primary);
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .product-title {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 10px;
            line-height: 1.2;
        }

        .price-tag {
            font-size: 2.4rem;
            color: var(--primary);
            font-weight: 800;
            margin-bottom: 25px;
        }

        .description-box {
            margin: 30px 0;
            padding-top: 20px;
            border-top: 1px solid rgba(0,0,0,0.05);
        }

        .description-box h3 { margin-bottom: 10px; font-size: 1.1rem; }
        .description-box p { color: var(--text-gray); line-height: 1.7; }

        /* --- 5. Seller Card --- */
        .seller-card {
            display: flex;
            align-items: center;
            gap: 15px;
            background: rgba(255,255,255,0.4);
            padding: 15px;
            border-radius: 15px;
            margin-bottom: 30px;
        }

        .seller-avatar {
            width: 50px; height: 50px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
        }

        /* --- 6. Buttons --- */
        .action-group {
            display: flex;
            gap: 15px;
        }

        .btn-action {
            flex: 1;
            padding: 18px;
            border-radius: 16px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border: none;
        }

        /* Add to Cart - 深色风格 */
        .btn-cart {
            background: var(--dark-btn);
            color: white;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        .btn-cart:hover {
            background: var(--dark-btn-hover);
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(0, 0, 0, 0.15);
        }

        /* Buy Now - 橙色风格 */
        .btn-buy {
            background: var(--primary);
            color: white;
            box-shadow: 0 10px 20px rgba(255, 149, 0, 0.2);
        }
        .btn-buy:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(255, 149, 0, 0.3);
        }

        @media (max-width: 768px) {
            .product-wrapper { grid-template-columns: 1fr; }
            .gallery-section { position: static; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>
<%@ include file="../../common/login_check_modal.jsp" %>

<div class="container">
    <div class="product-wrapper">

        <div class="gallery-section">
            <div class="main-image-container">
                <img src="<%= (product.getPrimaryImageUrl() != null) ? request.getContextPath() + "/" + product.getPrimaryImageUrl() : "https://via.placeholder.com/600" %>" alt="Product Image">
            </div>
        </div>

        <div class="info-section">
                <span class="condition-tag">
                    <i class="ri-shield-check-line"></i> <%= statusDisplay %>
                </span>

            <h1 class="product-title"><%= product.getProductName() %></h1>

            <div class="price-tag">
                RM <%= String.format("%.2f", product.getProductPrice()) %>
            </div>

            <div class="seller-card">
                <div class="seller-avatar">
                    <%= (product.getMerchantName() != null && product.getMerchantName().length() > 0) ? product.getMerchantName().substring(0,1).toUpperCase() : "S" %>
                </div>
                <div>
                    <div style="font-weight: 600;"><%= product.getMerchantName() %></div>
                    <div style="font-size: 0.8rem; color: var(--text-gray);">Official Merchant</div>
                </div>
            </div>

            <div class="description-box">
                <h3>Description</h3>
                <p><%= (product.getProductDescription() != null) ? product.getProductDescription() : "No description provided." %></p>
            </div>

            <div class="action-group">
                <% if (currentUser != null) { %>
                    <a href="${pageContext.request.contextPath}/cart_action?action=add&productId=<%= product.getProductId() %>" class="btn-action btn-cart">
                        <i class="ri-shopping-cart-2-line"></i> Add to Cart
                    </a>

                    <a href="${pageContext.request.contextPath}/customer/order/order_confirmation.jsp?productId=<%= product.getProductId() %>" class="btn-action btn-buy">
                        Buy Now
                    </a>
                <% } else { %>
                    <button onclick="showLoginModal()" class="btn-action btn-cart">
                        <i class="ri-shopping-cart-2-line"></i> Add to Cart
                    </button>

                    <button onclick="showLoginModal()" class="btn-action btn-buy">
                        Buy Now
                    </button>
                <% } %>
            </div>

            <div style="margin-top: 30px; font-size: 0.85rem; color: var(--text-gray); display: flex; align-items: center; gap: 8px;">
                <i class="ri-shield-flash-line" style="color: var(--success); font-size: 1.2rem;"></i>
                PrimeGo Verified Listing
            </div>
        </div>
    </div>
</div>

</body>
</html>