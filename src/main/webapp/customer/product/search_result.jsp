<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.product.dao.CategoryDAO" %>
<%@ page import="com.primego.product.model.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    // 1. Get Parameters
    String categoryIdStr = request.getParameter("categoryId");
    String keyword = request.getParameter("keyword");
    String minPriceStr = request.getParameter("minPrice");
    String maxPriceStr = request.getParameter("maxPrice");

    Integer categoryId = null;
    Double minPrice = null;
    Double maxPrice = null;

    if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
        try {
            categoryId = Integer.parseInt(categoryIdStr);
        } catch (NumberFormatException e) {}
    }
    if (minPriceStr != null && !minPriceStr.isEmpty()) {
        try {
            minPrice = Double.parseDouble(minPriceStr);
        } catch (NumberFormatException e) {}
    }
    if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
        try {
            maxPrice = Double.parseDouble(maxPriceStr);
        } catch (NumberFormatException e) {}
    }

    // 2. Fetch Data
    ProductDAO productDAO = new ProductDAO();
    List<ProductDTO> productList = productDAO.searchProductsWithFilter(keyword, categoryId, minPrice, maxPrice);

    String resultTitle = "All Products";
    if (keyword != null && !keyword.isEmpty()) {
        resultTitle = "Search Results for \"" + keyword + "\"";
    } else if (categoryId != null) {
        resultTitle = "Category Results";
    }

    if (minPrice != null || maxPrice != null) {
        resultTitle += " (Filtered)";
    }

    // Fetch Categories for Sidebar
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categories = categoryDAO.findAll();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= resultTitle %> - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; }

        /* 搜索栏区域 */
        .search-bar-container { margin: 140px auto 30px; text-align: center; max-width: 800px; padding: 0 20px; }
        .search-input { width: 70%; padding: 15px 25px; border-radius: 30px; border: none; background: rgba(255,255,255,0.8); backdrop-filter: blur(10px); box-shadow: 0 5px 15px rgba(0,0,0,0.05); outline: none; font-size: 1rem; }
        .btn-search { padding: 15px 30px; border-radius: 30px; border: none; background: #333; color: white; cursor: pointer; margin-left: 10px; font-weight: 600; }

        .main-layout { max-width: 1200px; margin: 0 auto 50px; padding: 0 20px; display: grid; grid-template-columns: 250px 1fr; gap: 30px; align-items: start; }

        /* 侧边栏 */
        .sidebar { background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(20px); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.6); }
        .filter-title { font-weight: 700; margin-bottom: 15px; display: block; }
        .filter-option { display: block; margin-bottom: 10px; cursor: pointer; color: #555; text-decoration: none; transition: 0.2s; }
        .filter-option:hover { color: #FF3B30; padding-left: 5px; }
        .filter-option.active { color: #FF3B30; font-weight: 600; }

        /* 商品网格 */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 25px;
        }

        /* 修改：确保 a 标签作为卡片容器时的样式 */
        .product-card {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            display: flex;
            flex-direction: column;
            text-decoration: none; /* 移除超链接下划线 */
            color: inherit;       /* 继承文字颜色 */
            height: 100%;
        }

        .product-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .product-img-container {
            width: 100%;
            aspect-ratio: 1 / 1;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f5f6fa;
        }

        .product-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-img-placeholder {
            width: 100%;
            aspect-ratio: 1 / 1;
            background-color: rgba(245, 246, 250, 0.6);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 4rem;
        }

        .product-details {
            padding: 15px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .product-name {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .product-price {
            font-size: 1.1rem;
            color: #FF3B30;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .btn-add-cart {
            margin-top: auto;
            background-color: transparent;
            border: 2px solid #333;
            color: #333;
            width: 100%;
            padding: 8px;
            border-radius: 20px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
            text-align: center;
            text-decoration: none;
            display: block;
        }
        .btn-add-cart:hover {
            background-color: #333;
            color: white;
        }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="search-bar-container">
    <form action="search_result.jsp" method="get">
        <input type="text" name="keyword" class="search-input" placeholder="Search for treasures..." value="<%= keyword != null ? keyword : "" %>">
        <button type="submit" class="btn-search">Search</button>
    </form>
</div>

<div class="main-layout">
    <aside class="sidebar">
        <span class="filter-title">Categories</span>
        <a href="search_result.jsp" class="filter-option <%= (categoryIdStr == null) ? "active" : "" %>">All Categories</a>
        <% for(Category c : categories) {
            boolean isActive = categoryIdStr != null && categoryIdStr.equals(String.valueOf(c.getCategoryId()));
        %>
        <a href="search_result.jsp?categoryId=<%= c.getCategoryId() %>" class="filter-option <%= isActive ? "active" : "" %>">
            <%= c.getCategoryName() %>
        </a>
        <% } %>

        <hr style="border:0; border-top:1px solid rgba(0,0,0,0.1); margin: 20px 0;">

        <span class="filter-title">Price Range</span>
        <form action="search_result.jsp" method="get">
            <% if(keyword != null && !keyword.isEmpty()) { %>
            <input type="hidden" name="keyword" value="<%= keyword %>">
            <% } %>
            <% if(categoryIdStr != null && !categoryIdStr.isEmpty()) { %>
            <input type="hidden" name="categoryId" value="<%= categoryIdStr %>">
            <% } %>
            <div style="display:flex; gap:5px; margin-bottom: 10px;">
                <input type="number" name="minPrice" placeholder="Min" value="<%= minPriceStr != null ? minPriceStr : "" %>" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
                <input type="number" name="maxPrice" placeholder="Max" value="<%= maxPriceStr != null ? maxPriceStr : "" %>" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
            </div>
            <button type="submit" style="width:100%; padding:8px; background:#333; color:white; border:none; border-radius:10px; cursor:pointer; font-weight:600;">Apply</button>
        </form>
    </aside>

    <main>
        <h3 style="margin-bottom:20px; color:#555;"><%= resultTitle %></h3>

        <div class="product-grid">
            <% if (productList == null || productList.isEmpty()) { %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                <h3>No products found.</h3>
                <p>Try adjusting your search or category.</p>
            </div>
            <% } else {
                for (ProductDTO p : productList) {
            %>
            <%-- 修改点：将整个 card 包装在指向 product_detail.jsp 的 a 标签中 --%>
            <a href="product_detail.jsp?id=<%= p.getProductId() %>" class="product-card">
                <% if (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty()) { %>
                <div class="product-img-container">
                    <img src="<%= request.getContextPath() + "/" + p.getPrimaryImageUrl() %>"
                         alt="<%= p.getProductName() %>">
                </div>
                <% } else { %>
                <div class="product-img-placeholder">📦</div>
                <% } %>

                <div class="product-details">
                    <h4 class="product-name"><%= p.getProductName() %></h4>
                    <p class="product-price">RM <%= String.format("%.2f", p.getProductPrice()) %></p>
                    <p style="font-size: 0.85rem; color:#666; margin-bottom:8px; line-height: 1.3;">
                        <%= (p.getProductDescription() != null && p.getProductDescription().length() > 50)
                                ? p.getProductDescription().substring(0, 50) + "..."
                                : (p.getProductDescription() != null ? p.getProductDescription() : "") %>
                    </p>
                    <%-- 注意：为了防止点击按钮也触发卡片的跳转，可以加上 stopPropagation --%>
                    <div onclick="event.preventDefault(); window.location.href='${pageContext.request.contextPath}/cart_action?action=add&productId=<%= p.getProductId() %>';" class="btn-add-cart">
                        Add to Cart
                    </div>
                </div>
            </a>
            <%
                    }
                }
            %>
        </div>
    </main>
</div>

</body>
</html>