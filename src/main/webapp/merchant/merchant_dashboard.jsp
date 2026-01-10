<%@ page import="com.primego.user.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.primego.order.dao.OrderDAO" %>
<%@ page import="com.primego.order.model.Order" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="java.util.List" %>
<%
    // ==========================================
    // 1. 权限检查
    // ==========================================
    User user = (User) session.getAttribute("user");

    // 调试代码：如果你还进不去，取消下面这行的注释，看看控制台打印了什么
    // System.out.println("Dashboard Check: User=" + user + ", Role=" + (user!=null?user.getRole():"null"));

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    // 🔥 核心修复点：将 Enum 强转为 String 再比较 🔥
    String roleStr = user.getRole().toString();

    // 如果不是 MERCHANT 且不是 ADMIN，踢回登录页
    if (!"MERCHANT".equals(roleStr) && !"ADMIN".equals(roleStr)) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    // ==========================================
    // 2. Dashboard 数据（参照数据库 Orders / Order_Item / Product）
    // ==========================================
    int toShipCount = 0;      // Orders_Order_Status = 'PAID'
    int shippedCount = 0;     // Orders_Order_Status = 'SHIPPED'
    int completedCount = 0;   // Orders_Order_Status = 'COMPLETED'

    int lowStockCount = 0;    // Product_Stock_Quantity <= LOW_STOCK_THRESHOLD
    final int LOW_STOCK_THRESHOLD = 5;

    // Low stock product info (id/name/stock) for dashboard list
    class LowStockItem {
        final int productId;
        final String name;
        final int stock;
        LowStockItem(int productId, String name, int stock) {
            this.productId = productId;
            this.name = name;
            this.stock = stock;
        }
    }

    java.util.List<LowStockItem> lowStockItems = new java.util.ArrayList<>();

    try {
        OrderDAO orderDAO = new OrderDAO();
        List<Order> orders = orderDAO.getOrdersByMerchantId(user.getId());
        for (Order o : orders) {
            String st = o.getOrderStatus();
            if ("PAID".equalsIgnoreCase(st)) {
                toShipCount++;
            } else if ("SHIPPED".equalsIgnoreCase(st)) {
                shippedCount++;
            } else if ("COMPLETED".equalsIgnoreCase(st)) {
                completedCount++;
            }
        }

        ProductDAO productDAO = new ProductDAO();
        List<ProductDTO> products = productDAO.getProductsByMerchantId(user.getId());
        for (ProductDTO p : products) {
            if (p.getProductStockQuantity() <= LOW_STOCK_THRESHOLD) {
                lowStockCount++;

                String name = (p.getProductName() != null) ? p.getProductName().trim() : "";
                if (!name.isEmpty()) {
                    lowStockItems.add(new LowStockItem(p.getProductId(), name, p.getProductStockQuantity()));
                }
            }
        }
    } catch (Exception e) {
        // dashboard 上不阻断页面渲染
        e.printStackTrace();
    }

    // Prepare display list (avoid too-long list)
    final int LOW_STOCK_PREVIEW_LIMIT = 5;
    java.util.List<LowStockItem> lowStockPreview;
    if (lowStockItems.isEmpty()) {
        lowStockPreview = java.util.Collections.emptyList();
    } else {
        int limit = Math.min(LOW_STOCK_PREVIEW_LIMIT, lowStockItems.size());
        lowStockPreview = lowStockItems.subList(0, limit);
    }
    boolean hasMoreLowStock = lowStockItems.size() > LOW_STOCK_PREVIEW_LIMIT;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Center - PrimeGo</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <style>
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --secondary: #FF5E55;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --glass-bg: rgba(255, 255, 255, 0.95);
            --card-radius: 16px;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --border-color: #dfe6e9;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        /* Ensure page can scroll (defensive override for background/layout styles) */
        html, body {
            overflow-y: auto;
            overflow-x: hidden;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
            position: relative;
            padding-top: 90px;
        }

        /* Layout */
        .layout-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 30px;
            align-items: start;
        }

        /* Content */
        .main-content { display: flex; flex-direction: column; gap: 25px; }

        .view-section { display: none; animation: slideUp 0.4s ease; }
        .view-section.active { display: block; }
        @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        /* Shop Info */
        .shop-header-card {
            background: rgba(255, 255, 255, 0.55);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow:
                    0 10px 30px rgba(0, 0, 0, 0.1),
                    0 4px 6px rgba(0, 0, 0, 0.05);
            border-radius: var(--card-radius);
            padding: 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .shop-profile { display: flex; align-items: center; gap: 20px; }
        .shop-avatar { width: 80px; height: 80px; border-radius: 50%; background: #ffeaa7; color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 2.5rem; font-weight: bold; }
        .shop-meta h2 { font-size: 1.5rem; margin-bottom: 5px; }
        .shop-tags span { background: #f1f2f6; padding: 4px 10px; border-radius: 6px; font-size: 0.85rem; color: #636e72; margin-right: 8px; }
        .shop-btn { padding: 10px 25px; border-radius: 30px; border: 2px solid var(--text-dark); background: transparent; font-weight: 600; cursor: pointer; transition: 0.3s; }
        .shop-btn:hover { background: var(--text-dark); color: white; }

        /* Metrics */
        .metrics-bar {
            display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;
        }
        .metric-card {
            background: linear-gradient(135deg, #6c5ce7, #a29bfe);
            border-radius: var(--card-radius); padding: 25px; color: white;
            text-align: center; position: relative; overflow: hidden;
            box-shadow: 0 10px 20px rgba(108, 92, 231, 0.2); transition: transform 0.3s;
        }
        .metric-card:hover { transform: translateY(-5px); }
        .metric-card:nth-child(2) { background: linear-gradient(135deg, #0984e3, #74b9ff); box-shadow: 0 10px 20px rgba(9, 132, 227, 0.2); }
        .metric-card:nth-child(3) { background: linear-gradient(135deg, #00b894, #55efc4); box-shadow: 0 10px 20px rgba(0, 184, 148, 0.2); }
        .metric-card:nth-child(4) { background: linear-gradient(135deg, #fdcb6e, #ffeaa7); color: #d35400; box-shadow: 0 10px 20px rgba(253, 203, 110, 0.2); }

        .metric-val { font-size: 2.5rem; font-weight: 700; margin-bottom: 5px; line-height: 1; }
        .metric-label { font-size: 0.95rem; opacity: 0.9; font-weight: 500; }

        /* Todo Grid */
        .todo-section {
            display: grid; grid-template-columns: 1.5fr 1fr; gap: 25px;
        }
        .panel {
            background: rgba(255, 255, 255, 0.55);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow:
                    0 10px 30px rgba(0, 0, 0, 0.1),
                    0 4px 6px rgba(0, 0, 0, 0.05);
            border-radius: var(--card-radius);
            padding: 25px;
        }
        .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .panel-title { font-size: 1.2rem; font-weight: 700; color: var(--text-dark); }

        .todo-item { display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #f1f2f6; }
        .todo-item:last-child { border-bottom: none; }
        .todo-left { display: flex; gap: 15px; align-items: center; flex: 1; }
        .todo-icon { width: 40px; height: 40px; background: #FFF4E6; color: var(--primary); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; }
        .todo-text { flex: 1 1 auto; min-width: 0; }
        .todo-text h4 { font-size: 1rem; margin-bottom: 2px; }
        .todo-text p { font-size: 0.85rem; color: #b2bec3; }
        .todo-action { color: var(--primary); text-decoration: none; font-weight: 600; font-size: 0.9rem; }

        /* Stock warning row: stack content so the low-stock list can use full panel width */
        .todo-item.stock-warning {
            flex-direction: column;
            align-items: flex-start;
        }
        .todo-item.stock-warning .todo-left {
            width: 100%;
            align-items: flex-start;
        }
        .todo-item.stock-warning .todo-text {
            width: 100%;
        }

        /* Data */
        .data-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
        .data-box h5 { color: var(--text-gray); font-weight: 500; margin-bottom: 8px; }
        .data-box h3 { font-size: 1.8rem; font-weight: 700; margin-bottom: 5px; }
        .trend { font-size: 0.85rem; display: flex; align-items: center; gap: 5px; }
        .trend.up { color: #ff7675; }
        .trend.down { color: #00b894; }

        /* Table */
        .custom-table { width: 100%; border-collapse: separate; border-spacing: 0 10px; }
        .custom-table th { text-align: left; color: var(--text-gray); font-weight: 500; padding: 10px 20px; }
        .custom-table td { background: white; padding: 15px 20px; }
        .custom-table tr td:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; }
        .custom-table tr td:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; }
        .custom-table tr { transition: transform 0.2s; box-shadow: 0 2px 10px rgba(0,0,0,0.02); }
        .custom-table tr:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.05); }

        .btn-small { padding: 6px 15px; border-radius: 20px; font-size: 0.85rem; font-weight: 600; border: none; cursor: pointer; margin-right: 5px; }
        .btn-edit { background: #dfe6e9; color: var(--text-dark); }
        .btn-del { background: #ffeaa7; color: #d35400; }

        /* Low stock mini cards inside Stock Warning */
        .low-stock-list {
            margin-top: 10px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            max-width: none;
            width: 100%;
        }

        .low-stock-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 12px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 6px 14px rgba(0,0,0,0.06);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            width: 100%;
        }

        .low-stock-left {
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 0;
        }

        .low-stock-name {
            font-weight: 600;
            color: var(--text-dark);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: none;
            text-decoration: none;
        }

        .low-stock-meta {
            font-size: 0.85rem;
            color: var(--text-gray);
        }

        .low-stock-stock {
            font-weight: 800;
            color: var(--primary);
        }

        .low-stock-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 0 0 auto;
        }

        .btn-restock-mini {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 12px;
            border-radius: 999px;
            background: #111;
            color: #fff;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.85rem;
            transition: transform 0.2s ease, background 0.2s ease;
            white-space: nowrap;
        }

        .btn-restock-mini:hover {
            background: var(--primary);
            transform: translateY(-1px);
        }

        .stock-zero { color: #ef4444; }

        @media (max-width: 1024px) {
            .layout-container { grid-template-columns: 80px 1fr; }
            .metrics-bar { grid-template-columns: 1fr 1fr; }
            .todo-section { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="../common/background_merchant.jsp" %>

<%@ include file="../common/layout/header_bar.jsp" %>

<div class="layout-container">

    <% request.setAttribute("activeMenu", "dashboard"); %>
    <%@ include file="../common/layout/merchant_sidebar.jsp" %>

    <main class="main-content">
        <!-- Dashboard View - 这个页面只显示dashboard内容 -->
        <div id="view-dashboard" class="view-section active">
            <div class="shop-header-card" style="margin-bottom: 30px;">
                <div class="shop-profile">
                    <div class="shop-avatar">S</div>
                    <div class="shop-meta">
                        <h2><%= user.getUsername() %>'s Store</h2>
                        <div class="shop-tags">
                            <span>⭐ Level 3 Seller</span>
                            <span>✅ Verified</span>
                            <span>📍 Penang, MY</span>
                        </div>
                    </div>
                </div>
                <button class="shop-btn" onclick="location.href='${pageContext.request.contextPath}/merchant/product/product_management.jsp'">Manage Products</button>
            </div>

            <div class="metrics-bar" style="margin-bottom: 30px;">
                <div class="metric-card" onclick="location.href='${pageContext.request.contextPath}/merchant/order/order_management?filter=to_ship'" style="cursor:pointer;">
                    <div class="metric-val"><%= toShipCount %></div>
                    <div class="metric-label">To Ship</div>
                </div>
                <div class="metric-card" onclick="location.href='${pageContext.request.contextPath}/merchant/order/order_management?filter=shipped'" style="cursor:pointer;">
                    <div class="metric-val"><%= shippedCount %></div>
                    <div class="metric-label">Shipped</div>
                </div>
                <div class="metric-card" onclick="location.href='${pageContext.request.contextPath}/merchant/order/order_management?filter=completed'" style="cursor:pointer;">
                    <div class="metric-val"><%= completedCount %></div>
                    <div class="metric-label">Completed</div>
                </div>
                <div class="metric-card" onclick="location.href='${pageContext.request.contextPath}/merchant/product/product_management.jsp'" style="cursor:pointer;">
                    <div class="metric-val"><%= lowStockCount %></div>
                    <div class="metric-label">Low Stock</div>
                </div>
            </div>

            <div class="todo-section">
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Quick Actions</div>
                    </div>

                    <div class="todo-item stock-warning">
                        <div class="todo-left">
                            <div class="todo-icon"><i class="ri-error-warning-line"></i></div>
                            <div class="todo-text">
                                <h4>Stock Warning</h4>
                                <p>
                                    <%= lowStockCount %> items are low in stock (≤ <%= LOW_STOCK_THRESHOLD %>)
                                </p>

                                <% if (!lowStockPreview.isEmpty()) { %>
                                    <div class="low-stock-list">
                                        <% for (LowStockItem item : lowStockPreview) { %>
                                            <div class="low-stock-item">
                                                <div class="low-stock-left">
                                                    <a class="low-stock-name"
                                                       href="<%= request.getContextPath() %>/merchant/product/product_edit.jsp?id=<%= item.productId %>"
                                                       title="Edit <%= item.name %>">
                                                        <%= item.name %>
                                                    </a>
                                                    <div class="low-stock-meta">
                                                        Stock: <span class="low-stock-stock <%= (item.stock <= 0 ? "stock-zero" : "") %>"><%= item.stock %></span>
                                                    </div>
                                                </div>

                                                <div class="low-stock-actions">
                                                    <a class="btn-restock-mini"
                                                       href="<%= request.getContextPath() %>/merchant/product/product_edit.jsp?id=<%= item.productId %>">
                                                        <i class="ri-edit-line"></i> Restock
                                                    </a>
                                                </div>
                                            </div>
                                        <% } %>

                                        <% if (hasMoreLowStock) { %>
                                            <div style="margin-top:2px; font-size:0.85rem; color: var(--text-gray);">...and more</div>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>

                        <!-- 右侧总按钮：批量查看/补货 -->
                        <!-- <a href="<%= request.getContextPath() %>/merchant/product/product_management.jsp" class="todo-action">Restock</a> -->
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Shortcuts</div>
                    </div>

                    <div class="todo-item" style="border-bottom:none;">
                        <div class="todo-left">
                            <div class="todo-icon"><i class="ri-add-circle-line"></i></div>
                            <div class="todo-text">
                                <h4>Publish Product</h4>
                                <p>Add a new product to your store</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/merchant/product/publish.jsp" class="todo-action">Publish</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['8am', '10am', '12pm', '2pm', '4pm', '6pm', '8pm'],
                datasets: [{
                    label: 'Sales (RM)',
                    data: [120, 190, 300, 500, 450, 700, 850],
                    borderColor: '#FF9500',
                    backgroundColor: 'rgba(255, 149, 0, 0.1)',
                    borderWidth: 3,
                    tension: 0.4,
                    fill: true,
                    pointRadius: 4,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#FF9500',
                    pointBorderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f1f2f6' }, border: { display: false } },
                    x: { grid: { display: false }, border: { display: false } }
                }
            }
        });
    });
</script>

</body>
</html>



