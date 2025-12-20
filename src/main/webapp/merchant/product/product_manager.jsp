<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
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

    // ==========================================
    // 2. 模拟数据
    // ==========================================
    class ProductMock {
        int id; String title; double price; String img; String category; String status; int stock;
        public ProductMock(int id, String t, double p, String c, String s, int st) { this.id=id; title=t; price=p; category=c; status=s; stock=st; }
    }
    List<ProductMock> productList = new ArrayList<>();
    productList.add(new ProductMock(1, "iPhone 15 Pro Max", 1199.00, "Electronics", "active", 12));
    productList.add(new ProductMock(2, "Java Programming", 45.50, "Books", "active", 5));
    productList.add(new ProductMock(3, "Sony Headphones", 89.90, "Electronics", "inactive", 0));
    productList.add(new ProductMock(4, "Vintage Camera", 350.00, "Electronics", "active", 1));
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
        /* =========================================
           1. Dashboard 通用布局样式
           ========================================= */
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
            position: relative;
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
        .menu-item.active-view { background: linear-gradient(45deg, #FF9500, #FF5E55); color: white; box-shadow: 0 5px 15px rgba(255, 94, 85, 0.3); }
        .menu-item i { font-size: 1.2rem; }

        /* Content Base */
        .main-content { display: flex; flex-direction: column; gap: 25px; }

        /* =========================================
           2. Product Manager 样式 + 全局入场动画
           ========================================= */

        /* 定义动画关键帧 */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 1. 顶部标题栏动画 */
        .page-header {
            background: white; border-radius: var(--card-radius); padding: 25px 30px;
            box-shadow: var(--card-shadow); display: flex; justify-content: space-between; align-items: center;

            /* 新增动画属性 */
            opacity: 0;
            animation: fadeInUp 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            animation-delay: 0s; /* 立即执行 */
        }
        .page-header h1 { font-size: 1.5rem; margin-bottom: 5px; display: flex; align-items: center; gap: 10px; }
        .page-header p { color: var(--text-gray); font-size: 0.9rem; }

        /* 2. 搜索工具栏动画 */
        .toolbar {
            background: white; padding: 15px 20px; border-radius: var(--card-radius);
            box-shadow: var(--card-shadow); display: flex; gap: 15px; align-items: center;

            /* 新增动画属性 */
            opacity: 0;
            animation: fadeInUp 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            animation-delay: 0.1s; /* 稍微延迟，等标题出来后再出来 */
        }

        .btn-publish {
            background: var(--text-dark); color: white; padding: 10px 24px;
            border-radius: 30px; border: none; font-weight: 600; cursor: pointer;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15); transition: transform 0.2s;
            display: flex; align-items: center; gap: 8px; text-decoration: none;
        }
        .btn-publish:hover { transform: translateY(-2px); background: black; }

        .search-box { flex: 1; position: relative; }
        .search-box input {
            width: 100%; padding: 12px 15px 12px 40px; border: 1px solid var(--border-color);
            border-radius: 10px; outline: none; transition: 0.3s;
        }
        .search-box input:focus { border-color: var(--primary); }
        .search-box i { position: absolute; left: 15px; top: 50%; transform: translateY(-50%); color: #b2bec3; }

        .product-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 20px;
        }

        /* 3. 商品卡片动画 */
        .product-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            position: relative;
            cursor: pointer;
            border: 2px solid transparent;
            display: flex;
            flex-direction: column;

            /* 默认隐藏 */
            opacity: 0;
            /* 入场动画 */
            animation: fadeInUp 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            /* Hover 过渡 */
            transition: transform 0.3s ease, box-shadow 0.3s ease, border-color 0.3s ease;
        }

        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            border-color: rgba(255, 149, 0, 0.1);
        }

        .card-img-container {
            height: 180px; background: #f8f9fa; display: flex; align-items: center; justify-content: center;
            overflow: hidden; position: relative;
        }
        .card-img-container img { width: 100%; height: 100%; object-fit: cover; }

        .status-badge {
            position: absolute; top: 10px; right: 10px; padding: 4px 10px;
            border-radius: 12px; font-weight: 600; font-size: 0.75rem; z-index: 2;
        }
        .status-active { background: #ECFDF5; color: #10B981; }
        .status-inactive { background: #FEF2F2; color: #EF4444; }

        .card-info { padding: 15px; flex-grow: 1; display: flex; flex-direction: column; }
        .card-category { font-size: 0.8rem; color: var(--text-gray); margin-bottom: 5px; }
        .card-title { font-size: 1rem; font-weight: 600; margin-bottom: 10px; line-height: 1.4; flex-grow: 1; }

        .card-footer {
            display: flex; justify-content: space-between; align-items: center;
            padding-top: 10px; border-top: 1px solid #f1f2f6; margin-top: auto;
        }
        .card-price { color: var(--primary); font-size: 1.2rem; font-weight: 700; }

        .btn-edit {
            width: 36px; height: 36px; border-radius: 50%; border: none; cursor: pointer;
            display: flex; align-items: center; justify-content: center; font-size: 1.1rem;
            background: #F3F4F6; color: var(--text-dark); transition: 0.2s;
        }
        .btn-edit:hover { background: var(--primary); color: white; }

        .empty-state { text-align: center; padding: 60px 20px; color: var(--text-gray); grid-column: 1 / -1; }
        .empty-icon { font-size: 4rem; opacity: 0.5; margin-bottom: 15px; display: block;}

        @media (max-width: 1024px) {
            .layout-container { grid-template-columns: 80px 1fr; }
            .sidebar-card { align-items: center; }
            .menu-item span, .menu-group-title { display: none; }
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
        <a href="${pageContext.request.contextPath}/merchant/product/product_manager.jsp" class="menu-item active-view">
            <i class="ri-box-3-line"></i> <span>Product Manager</span>
        </a>
        <button class="menu-item" onclick="alert('Order module coming soon!')">
            <i class="ri-list-check-2"></i> <span>Orders</span>
        </button>
        <button class="menu-item" onclick="alert('Wallet module coming soon!')">
            <i class="ri-wallet-3-line"></i> <span>Finance</span>
        </button>
        <div style="margin-top: auto;">
            <div class="menu-group-title">System</div>
            <a href="${pageContext.request.contextPath}/logout" class="menu-item" style="color: #FF5E55;">
                <i class="ri-logout-box-r-line"></i> <span>Log Out</span>
            </a>
        </div>
    </aside>

    <main class="main-content">

        <div class="page-header">
            <div>
                <h1><i class="ri-box-3-fill" style="color: var(--primary);"></i> My Products</h1>
                <p>Manage your inventory, prices and listings.</p>
            </div>
            <a href="${pageContext.request.contextPath}/merchant/product/publish.jsp" class="btn-publish">
                <i class="ri-add-line"></i> Publish New
            </a>
        </div>

        <div class="toolbar">
            <div class="search-box">
                <i class="ri-search-line"></i>
                <input type="text" id="searchInput" placeholder="Search by name, ID or category...">
            </div>
            <select style="padding: 10px; border-radius: 10px; border: 1px solid #dfe6e9; outline: none; cursor: pointer;">
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
                <option value="review">Under Review</option>
            </select>
        </div>

        <div class="product-grid" id="productGrid">
            <%
                if (productList == null || productList.isEmpty()) {
            %>
            <div class="empty-state">
                <span class="empty-icon">📦</span>
                <h3>No products yet</h3>
                <p>Click "Publish New" to start selling!</p>
            </div>
            <%
            } else {
                // 🔥 调整：商品卡片从 0.2s 开始入场，接在搜索栏后面
                int index = 0;
                for (ProductMock p : productList) {
                    String statusClass = "active".equals(p.status) ? "status-active" : "status-inactive";

                    // 初始延迟 0.2s + 每个卡片递增 0.1s
                    String delayStyle = String.format("animation-delay: %.1fs;", 0.2 + (index * 0.1));
            %>
            <div class="product-card"
                 style="<%= delayStyle %>"
                 onclick="window.location.href='publish.jsp?id=<%= p.id %>'">

                <span class="status-badge <%= statusClass %>">
                    <%= p.status.substring(0, 1).toUpperCase() + p.status.substring(1) %>
                </span>

                <div class="card-img-container">
                    <img src="<%= (p.img != null && !p.img.isEmpty()) ? p.img : "../../assets/images/default_product.png" %>"
                         onerror="this.src='https://via.placeholder.com/300?text=No+Image'"
                         alt="<%= p.title %>">
                </div>

                <div class="card-info">
                    <div class="card-category"><%= p.category %></div>
                    <h3 class="card-title"><%= p.title %></h3>

                    <div class="card-footer">
                        <span class="card-price">RM <%= String.format("%.2f", p.price) %></span>
                        <div class="card-actions" onclick="event.stopPropagation()">
                            <button class="btn-edit" onclick="window.location.href='publish.jsp?id=<%= p.id %>'" title="Edit">
                                <i class="ri-edit-line"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <%
                        index++;
                    }
                }
            %>
        </div>

    </main>
</div>

<script>
    document.getElementById('searchInput').addEventListener('input', function(e) {
        const term = e.target.value.toLowerCase();
        const cards = document.querySelectorAll('.product-card');

        cards.forEach(card => {
            const title = card.querySelector('.card-title').innerText.toLowerCase();
            const category = card.querySelector('.card-category').innerText.toLowerCase();

            if (title.includes(term) || category.includes(term)) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    });
</script>

</body>
</html>