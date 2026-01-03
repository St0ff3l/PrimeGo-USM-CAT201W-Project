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
    
    // 2. Fetch Data
    ProductDAO productDAO = new ProductDAO();
    List<ProductDTO> productList = new ArrayList<>();
    String resultTitle = "All Products";
    
    if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
        try {
            int categoryId = Integer.parseInt(categoryIdStr);
            productList = productDAO.getProductsByCategoryId(categoryId);
            // Ideally fetch category name here, but for now we can infer or just say "Category Results"
            resultTitle = "Category Results"; 
        } catch (NumberFormatException e) {
            productList = productDAO.getAllProducts();
        }
    } else if (keyword != null && !keyword.isEmpty()) {
        productList = productDAO.searchProducts(keyword);
        resultTitle = "Search Results for \"" + keyword + "\"";
    } else {
        productList = productDAO.getAllProducts();
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

        /* Header styles are handled by header_bar.jsp */

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

        /* 商品网格 (Match index.jsp style) */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 25px;
        }

        .product-card {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            overflow: hidden;
            transition: transform 0.3s;
            display: flex;
            flex-direction: column;
            text-decoration: none;
            color: inherit;
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
            padding: 10px;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .product-name {
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .product-price {
            font-size: 1.1rem;
            color: #FF3B30;
            font-weight: 700;
            margin-bottom: 5px;
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
        <div style="display:flex; gap:5px;">
            <input type="number" placeholder="Min" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
            <input type="number" placeholder="Max" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
        </div>
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
            <a href="#" class="product-card">
                <% if (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty()) { %>
                    <div class="product-img-container">
                        <img src="<%= request.getContextPath() + "/" + p.getPrimaryImageUrl() %>" 
                             alt="<%= p.getProductName() %>">
                    </div>
                <% } else { %>
                    <div class="product-img-placeholder">�</div>
                <% } %>
                
                <div class="product-details">
                    <h4 class="product-name"><%= p.getProductName() %></h4>
                    <p class="product-price">RM <%= String.format("%.2f", p.getProductPrice()) %></p>
                    <p style="font-size: 0.85rem; color:#666; margin-bottom:8px; line-height: 1.3;">
                        <%= (p.getProductDescription() != null && p.getProductDescription().length() > 50) 
                            ? p.getProductDescription().substring(0, 50) + "..." 
                            : (p.getProductDescription() != null ? p.getProductDescription() : "") %>
                    </p>
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