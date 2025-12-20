<%@ page import="com.primego.user.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ==========================================
    // 1. 权限检查
    // ==========================================
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    String roleStr = user.getRole().toString();

    if (!"MERCHANT".equals(roleStr) && !"ADMIN".equals(roleStr)) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Manager - Seller Center</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

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

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
        }

        /* Navbar */
        .navbar {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            padding: 15px 40px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 1000;
            border-bottom: 1px solid rgba(255,255,255,0.5);
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
        }
        .logo { font-weight: 800; font-size: 1.5rem; color: var(--secondary); display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .logo span { color: var(--text-dark); }
        .logo-img { width: 35px; height: 35px; object-fit: contain; }

        .nav-actions { display: flex; align-items: center; gap: 20px; }
        .nav-btn { border: none; background: transparent; font-weight: 600; color: var(--text-gray); cursor: pointer; font-size: 0.95rem; transition: 0.3s; }
        .nav-btn:hover { color: var(--primary); }

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

        /* Sidebar */
        .sidebar-card {
            background: white; border-radius: var(--card-radius);
            padding: 25px 20px; box-shadow: var(--card-shadow);
            position: sticky; top: 100px; height: calc(100vh - 130px);
            display: flex; flex-direction: column;
        }
        .menu-group-title { font-size: 0.8rem; color: #b2bec3; font-weight: 700; margin-bottom: 10px; margin-top: 20px; text-transform: uppercase; letter-spacing: 1px; }
        .menu-group-title:first-child { margin-top: 0; }

        .menu-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 15px; margin-bottom: 5px;
            color: var(--text-dark); text-decoration: none;
            border-radius: 12px; transition: all 0.3s ease; font-weight: 500; font-size: 0.95rem;
            cursor: pointer; border: none; background: transparent; width: 100%; text-align: left;
        }
        .menu-item:hover { background: #FFF4E6; color: var(--primary); transform: translateX(5px); }
        .menu-item.active { background: linear-gradient(45deg, #FF9500, #FF5E55); color: white; box-shadow: 0 5px 15px rgba(255, 94, 85, 0.3); }
        .menu-item i { font-size: 1.2rem; }

        /* Main Content */
        .main-content { display: flex; flex-direction: column; gap: 25px; }

        /* Page Header */
        .page-header {
            background: white;
            border-radius: var(--card-radius);
            padding: 25px 30px;
            box-shadow: var(--card-shadow);
            margin-bottom: 20px;
        }
        .page-header h1 {
            font-size: 1.8rem;
            color: var(--text-dark);
            margin-bottom: 10px;
        }
        .page-header p {
            color: var(--text-gray);
            font-size: 0.95rem;
        }

        /* Product Grid */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .product-card {
            background: white;
            border-radius: var(--card-radius);
            overflow: hidden;
            box-shadow: var(--card-shadow);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.1);
        }

        .product-image {
            height: 200px;
            background: #f1f2f6;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        .product-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .product-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: var(--primary);
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .product-info {
            padding: 20px;
        }
        .product-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 8px;
            color: var(--text-dark);
        }
        .product-id {
            font-size: 0.8rem;
            color: #b2bec3;
            margin-bottom: 10px;
        }
        .product-price {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 5px;
        }
        .product-stock {
            font-size: 0.9rem;
            color: var(--text-gray);
            margin-bottom: 15px;
        }

        .product-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .status-active {
            background: #e17055;
            color: white;
        }
        .status-inactive {
            background: #dfe6e9;
            color: var(--text-gray);
        }
        .status-draft {
            background: #ffeaa7;
            color: #d35400;
        }

        .product-actions {
            display: flex;
            gap: 8px;
        }
        .btn-action {
            padding: 6px 12px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.2s;
        }
        .btn-edit {
            background: #dfe6e9;
            color: var(--text-dark);
        }
        .btn-edit:hover {
            background: #b2bec3;
        }
        .btn-delete {
            background: #ff7675;
            color: white;
        }
        .btn-delete:hover {
            background: #d63031;
        }
        .btn-view {
            background: #74b9ff;
            color: white;
        }
        .btn-view:hover {
            background: #0984e3;
        }

        /* Table View */
        .table-container {
            background: white;
            border-radius: var(--card-radius);
            padding: 25px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
        }

        .view-switch {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .view-btn {
            padding: 8px 20px;
            border: 2px solid var(--border-color);
            background: transparent;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            color: var(--text-gray);
            transition: all 0.3s;
        }
        .view-btn.active {
            border-color: var(--primary);
            background: var(--primary);
            color: white;
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        .search-box {
            position: relative;
            width: 300px;
        }
        .search-box input {
            width: 100%;
            padding: 10px 15px 10px 40px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 0.95rem;
        }
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #b2bec3;
        }

        .action-buttons {
            display: flex;
            gap: 10px;
        }
        .btn-primary {
            background: var(--primary);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background 0.3s;
        }
        .btn-primary:hover {
            background: var(--primary-hover);
        }
        .btn-secondary {
            background: white;
            color: var(--text-dark);
            border: 1px solid var(--border-color);
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        .btn-secondary:hover {
            background: #f8f9fa;
        }

        .custom-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 10px;
        }
        .custom-table th {
            text-align: left;
            color: var(--text-gray);
            font-weight: 500;
            padding: 15px 20px;
            background: #f8f9fa;
            border-bottom: 2px solid var(--border-color);
        }
        .custom-table td {
            background: white;
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
        }
        .custom-table tr {
            transition: transform 0.2s;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
        }
        .custom-table tr:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }

        .table-image {
            width: 50px;
            height: 50px;
            background: #dfe6e9;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: #636e72;
        }

        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }
        .page-btn {
            width: 36px;
            height: 36px;
            border: 1px solid var(--border-color);
            background: white;
            border-radius: 6px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }
        .page-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
        }
        .page-btn.active {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        /* Stats Cards */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            border-radius: var(--card-radius);
            padding: 25px;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            background: #FFF4E6;
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        .stat-content h3 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        .stat-content p {
            color: var(--text-gray);
            font-size: 0.9rem;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: var(--card-radius);
            box-shadow: var(--card-shadow);
        }
        .empty-icon {
            font-size: 4rem;
            color: #dfe6e9;
            margin-bottom: 20px;
        }
        .empty-state h3 {
            font-size: 1.5rem;
            color: var(--text-dark);
            margin-bottom: 10px;
        }
        .empty-state p {
            color: var(--text-gray);
            margin-bottom: 25px;
            max-width: 500px;
            margin-left: auto;
            margin-right: auto;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .layout-container { grid-template-columns: 80px 1fr; }
            .sidebar-card { align-items: center; }
            .menu-item span, .menu-group-title { display: none; }
            .product-grid { grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); }
        }

        @media (max-width: 768px) {
            .product-grid { grid-template-columns: 1fr; }
            .stats-cards { grid-template-columns: 1fr; }
            .table-header { flex-direction: column; gap: 15px; align-items: stretch; }
            .search-box { width: 100%; }
            .action-buttons { justify-content: space-between; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>

<nav class="navbar">
    <a href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp" class="logo">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="Logo" class="logo-img">
        <span>Seller Center</span>
    </a>
    <div class="nav-actions">
        <button class="nav-btn" onclick="location.href='${pageContext.request.contextPath}/index.jsp'">
            <i class="ri-store-2-line"></i> Back to Shop
        </button>
        <div style="width: 1px; height: 20px; background: #ddd;"></div>
        <div style="display: flex; align-items: center; gap: 10px;">
            <span style="font-weight: 600; font-size: 0.9rem;"><%= user.getUsername() %></span>
            <div style="width: 35px; height: 35px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold;">
                <%= user.getUsername().substring(0, 1).toUpperCase() %>
            </div>
        </div>
    </div>
</nav>

<div class="layout-container">
    <aside class="sidebar-card">
        <div class="menu-group-title">Main</div>
        <a href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp" class="menu-item">
            <i class="ri-dashboard-3-line"></i> <span>Dashboard</span>
        </a>

        <div class="menu-group-title">Management</div>
        <a href="${pageContext.request.contextPath}/merchant/product/product_manager.jsp" class="menu-item active">
            <i class="ri-box-3-line"></i> <span>Product Manager</span>
        </a>
        <a href="#" class="menu-item" onclick="alert('Order module coming soon!')">
            <i class="ri-list-check-2"></i> <span>Orders</span>
        </a>
        <a href="#" class="menu-item" onclick="alert('Wallet module coming soon!')">
            <i class="ri-wallet-3-line"></i> <span>Finance</span>
        </a>

        <div style="margin-top: auto;">
            <div class="menu-group-title">System</div>
            <a href="${pageContext.request.contextPath}/logout" class="menu-item" style="color: #FF5E55;">
                <i class="ri-logout-box-r-line"></i> <span>Log Out</span>
            </a>
        </div>
    </aside>

    <main class="main-content">
        <div class="page-header">
            <h1><i class="ri-box-3-line" style="margin-right: 10px;"></i>Product Manager</h1>
            <p>Manage your products, inventory, and listings in one place</p>
        </div>

        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="ri-box-3-line"></i>
                </div>
                <div class="stat-content">
                    <h3>24</h3>
                    <p>Total Products</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #d1f7c4; color: #00b894;">
                    <i class="ri-checkbox-circle-line"></i>
                </div>
                <div class="stat-content">
                    <h3>18</h3>
                    <p>Active</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #ffeaa7; color: #d35400;">
                    <i class="ri-error-warning-line"></i>
                </div>
                <div class="stat-content">
                    <h3>3</h3>
                    <p>Low Stock</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon" style="background: #dfe6e9; color: #636e72;">
                    <i class="ri-pause-circle-line"></i>
                </div>
                <div class="stat-content">
                    <h3>6</h3>
                    <p>Inactive</p>
                </div>
            </div>
        </div>

        <div class="table-container">
            <div class="table-header">
                <div class="search-box">
                    <i class="ri-search-line"></i>
                    <input type="text" placeholder="Search products..." id="searchInput">
                </div>
                <div class="action-buttons">
                    <button class="btn-secondary" onclick="filterProducts('all')">
                        <i class="ri-filter-line"></i> Filter
                    </button>
                    <button class="btn-primary" onclick="location.href='${pageContext.request.contextPath}/merchant/product/publish.jsp'">
                        <i class="ri-add-line"></i> Add Product
                    </button>
                </div>
            </div>

            <div class="view-switch">
                <button class="view-btn active" onclick="switchView('table')">
                    <i class="ri-list-check"></i> Table View
                </button>
                <button class="view-btn" onclick="switchView('grid')">
                    <i class="ri-layout-grid-line"></i> Grid View
                </button>
            </div>

            <!-- Table View -->
            <div id="tableView">
                <table class="custom-table">
                    <thead>
                    <tr>
                        <th style="width: 50px;">#</th>
                        <th>Product</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody id="productsTable">
                    <!-- Products will be loaded here via JavaScript -->
                    </tbody>
                </table>

                <div class="pagination">
                    <button class="page-btn" onclick="changePage(-1)"><i class="ri-arrow-left-s-line"></i></button>
                    <button class="page-btn active">1</button>
                    <button class="page-btn">2</button>
                    <button class="page-btn">3</button>
                    <button class="page-btn" onclick="changePage(1)"><i class="ri-arrow-right-s-line"></i></button>
                </div>
            </div>

            <!-- Grid View -->
            <div id="gridView" style="display: none;">
                <div class="product-grid" id="productsGrid">
                    <!-- Products will be loaded here via JavaScript -->
                </div>

                <div class="pagination">
                    <button class="page-btn" onclick="changePage(-1)"><i class="ri-arrow-left-s-line"></i></button>
                    <button class="page-btn active">1</button>
                    <button class="page-btn">2</button>
                    <button class="page-btn">3</button>
                    <button class="page-btn" onclick="changePage(1)"><i class="ri-arrow-right-s-line"></i></button>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    // Sample product data
    const products = [
        {
            id: "PRD-001",
            name: "Wireless Keyboard",
            price: "RM 159.00",
            stock: 120,
            status: "active",
            category: "Electronics",
            image: "keyboard",
            color: "#74b9ff"
        },
        {
            id: "PRD-002",
            name: "Gaming Mouse",
            price: "RM 89.00",
            stock: 45,
            status: "active",
            category: "Gaming",
            image: "mouse",
            color: "#fd79a8"
        },
        {
            id: "PRD-003",
            name: "Bluetooth Speaker",
            price: "RM 249.00",
            stock: 8,
            status: "low",
            category: "Audio",
            image: "speaker",
            color: "#55efc4"
        },
        {
            id: "PRD-004",
            name: "USB-C Cable",
            price: "RM 29.00",
            stock: 200,
            status: "active",
            category: "Accessories",
            image: "cable",
            color: "#ffeaa7"
        },
        {
            id: "PRD-005",
            name: "Phone Case",
            price: "RM 45.00",
            stock: 0,
            status: "inactive",
            category: "Accessories",
            image: "case",
            color: "#a29bfe"
        },
        {
            id: "PRD-006",
            name: "Monitor Stand",
            price: "RM 129.00",
            stock: 15,
            status: "active",
            category: "Office",
            image: "stand",
            color: "#fab1a0"
        }
    ];

    // Initialize products
    document.addEventListener('DOMContentLoaded', function() {
        loadProducts();
        setupSearch();
    });

    function loadProducts() {
        const tableBody = document.getElementById('productsTable');
        const gridBody = document.getElementById('productsGrid');

        tableBody.innerHTML = '';
        gridBody.innerHTML = '';

        products.forEach((product, index) => {
            // Determine status class based on product status
            let statusClass = '';
            let statusText = '';

            if (product.status === 'active') {
                statusClass = 'status-active';
                statusText = 'Active';
            } else if (product.status === 'low') {
                statusClass = 'status-draft';
                statusText = 'Low Stock';
            } else {
                statusClass = 'status-inactive';
                statusText = 'Inactive';
            }

            // Table row
            const tableRow = `
                <tr>
                    <td>${index + 1}</td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <div class="table-image" style="background: ${product.color}20; color: ${product.color};">
                                <i class="ri-${product.image}-line"></i>
                            </div>
                            <div>
                                <strong>${product.name}</strong><br>
                                <span style="font-size: 0.8rem; color: #b2bec3;">${product.id}</span>
                            </div>
                        </div>
                    </td>
                    <td><strong>${product.price}</strong></td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span>${product.stock}</span>
                            ${product.stock < 10 ? '<i class="ri-error-warning-line" style="color: #e17055;"></i>' : ''}
                        </div>
                    </td>
                    <td>
                        <span class="status-badge ${statusClass}">
                            ${statusText}
                        </span>
                    </td>
                    <td>
                        <div class="product-actions">
                            <button class="btn-action btn-view" onclick="viewProduct('${product.id}')">
                                <i class="ri-eye-line"></i>
                            </button>
                            <button class="btn-action btn-edit" onclick="editProduct('${product.id}')">
                                <i class="ri-edit-line"></i>
                            </button>
                            <button class="btn-action btn-delete" onclick="deleteProduct('${product.id}')">
                                <i class="ri-delete-bin-line"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
            tableBody.innerHTML += tableRow;

            // Grid card
            const lowStockBadge = product.stock < 10 ? '<div class="product-badge">Low Stock</div>' : '';

            const gridCard = `
                <div class="product-card">
                    <div class="product-image" style="background: ${product.color}20;">
                        <i class="ri-${product.image}-line" style="font-size: 3rem; color: ${product.color};"></i>
                        ${lowStockBadge}
                    </div>
                    <div class="product-info">
                        <h3 class="product-title">${product.name}</h3>
                        <div class="product-id">${product.id}</div>
                        <div class="product-price">${product.price}</div>
                        <div class="product-stock">
                            <i class="ri-box-3-line" style="margin-right: 5px;"></i>
                            ${product.stock} in stock
                        </div>
                        <div class="product-meta">
                            <span class="status-badge ${statusClass}">
                                ${statusText}
                            </span>
                            <div class="product-actions">
                                <button class="btn-action btn-view" onclick="viewProduct('${product.id}')">
                                    <i class="ri-eye-line"></i>
                                </button>
                                <button class="btn-action btn-edit" onclick="editProduct('${product.id}')">
                                    <i class="ri-edit-line"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            gridBody.innerHTML += gridCard;
        });
    }

    function setupSearch() {
        const searchInput = document.getElementById('searchInput');
        searchInput.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            filterProducts(searchTerm);
        });
    }

    function filterProducts(filter) {
        // Simple client-side filtering
        const filteredProducts = products.filter(product =>
            product.name.toLowerCase().includes(filter) ||
            product.id.toLowerCase().includes(filter) ||
            product.category.toLowerCase().includes(filter)
        );

        // Update display with filtered products
        const tableBody = document.getElementById('productsTable');
        const gridBody = document.getElementById('productsGrid');

        tableBody.innerHTML = '';
        gridBody.innerHTML = '';

        filteredProducts.forEach((product, index) => {
            // Determine status class based on product status
            let statusClass = '';
            let statusText = '';

            if (product.status === 'active') {
                statusClass = 'status-active';
                statusText = 'Active';
            } else if (product.status === 'low') {
                statusClass = 'status-draft';
                statusText = 'Low Stock';
            } else {
                statusClass = 'status-inactive';
                statusText = 'Inactive';
            }

            // Table row
            const tableRow = `
                <tr>
                    <td>${index + 1}</td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 15px;">
                            <div class="table-image" style="background: ${product.color}20; color: ${product.color};">
                                <i class="ri-${product.image}-line"></i>
                            </div>
                            <div>
                                <strong>${product.name}</strong><br>
                                <span style="font-size: 0.8rem; color: #b2bec3;">${product.id}</span>
                            </div>
                        </div>
                    </td>
                    <td><strong>${product.price}</strong></td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span>${product.stock}</span>
                            ${product.stock < 10 ? '<i class="ri-error-warning-line" style="color: #e17055;"></i>' : ''}
                        </div>
                    </td>
                    <td>
                        <span class="status-badge ${statusClass}">
                            ${statusText}
                        </span>
                    </td>
                    <td>
                        <div class="product-actions">
                            <button class="btn-action btn-view" onclick="viewProduct('${product.id}')">
                                <i class="ri-eye-line"></i>
                            </button>
                            <button class="btn-action btn-edit" onclick="editProduct('${product.id}')">
                                <i class="ri-edit-line"></i>
                            </button>
                            <button class="btn-action btn-delete" onclick="deleteProduct('${product.id}')">
                                <i class="ri-delete-bin-line"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
            tableBody.innerHTML += tableRow;

            // Grid card
            const lowStockBadge = product.stock < 10 ? '<div class="product-badge">Low Stock</div>' : '';

            const gridCard = `
                <div class="product-card">
                    <div class="product-image" style="background: ${product.color}20;">
                        <i class="ri-${product.image}-line" style="font-size: 3rem; color: ${product.color};"></i>
                        ${lowStockBadge}
                    </div>
                    <div class="product-info">
                        <h3 class="product-title">${product.name}</h3>
                        <div class="product-id">${product.id}</div>
                        <div class="product-price">${product.price}</div>
                        <div class="product-stock">
                            <i class="ri-box-3-line" style="margin-right: 5px;"></i>
                            ${product.stock} in stock
                        </div>
                        <div class="product-meta">
                            <span class="status-badge ${statusClass}">
                                ${statusText}
                            </span>
                            <div class="product-actions">
                                <button class="btn-action btn-view" onclick="viewProduct('${product.id}')">
                                    <i class="ri-eye-line"></i>
                                </button>
                                <button class="btn-action btn-edit" onclick="editProduct('${product.id}')">
                                    <i class="ri-edit-line"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            gridBody.innerHTML += gridCard;
        });
    }

    function switchView(view) {
        const tableView = document.getElementById('tableView');
        const gridView = document.getElementById('gridView');
        const viewBtns = document.querySelectorAll('.view-btn');

        viewBtns.forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');

        if (view === 'table') {
            tableView.style.display = 'block';
            gridView.style.display = 'none';
        } else {
            tableView.style.display = 'none';
            gridView.style.display = 'block';
        }
    }

    function changePage(direction) {
        // Implement pagination logic here
        console.log('Changing page:', direction);
    }

    function viewProduct(productId) {
        alert(`View product: ${productId}`);
        // Implement view product logic
    }

    function editProduct(productId) {
        alert(`Edit product: ${productId}`);
        // Implement edit product logic
    }

    function deleteProduct(productId) {
        if (confirm(`Are you sure you want to delete product ${productId}?`)) {
            alert(`Product ${productId} deleted`);
            // Implement delete product logic
        }
    }
</script>

</body>
</html>