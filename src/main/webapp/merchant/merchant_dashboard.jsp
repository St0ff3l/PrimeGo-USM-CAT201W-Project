<%@ page import="com.primego.user.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seller Center - PrimeGo</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
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
        .todo-left { display: flex; gap: 15px; align-items: center; }
        .todo-icon { width: 40px; height: 40px; background: #FFF4E6; color: var(--primary); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1.2rem; }
        .todo-text h4 { font-size: 1rem; margin-bottom: 2px; }
        .todo-text p { font-size: 0.85rem; color: #b2bec3; }
        .todo-action { color: var(--primary); text-decoration: none; font-weight: 600; font-size: 0.9rem; }

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
                <button class="shop-btn" onclick="location.href='${pageContext.request.contextPath}/search_result.jsp?seller_id=<%= user.getId() %>'">View My Shop</button>
            </div>

            <div class="metrics-bar" style="margin-bottom: 30px;">
                <div class="metric-card">
                    <div class="metric-val">12</div>
                    <div class="metric-label">To Pay</div>
                </div>
                <div class="metric-card">
                    <div class="metric-val">5</div>
                    <div class="metric-label">To Ship</div>
                </div>
                <div class="metric-card">
                    <div class="metric-val">2</div>
                    <div class="metric-label">Refunds</div>
                </div>
                <div class="metric-card">
                    <div class="metric-val">RM 4.5k</div>
                    <div class="metric-label">Month Revenue</div>
                </div>
            </div>

            <div class="todo-section">
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">Live Data</div>
                        <select style="padding: 5px; border: 1px solid #ddd; border-radius: 8px;">
                            <option>Today</option>
                            <option>Yesterday</option>
                        </select>
                    </div>

                    <div class="data-grid">
                        <div class="data-box">
                            <h5>Visitors</h5>
                            <h3>842</h3>
                            <div class="trend up"><i class="ri-arrow-up-line"></i> 12%</div>
                        </div>
                        <div class="data-box">
                            <h5>Orders</h5>
                            <h3>32</h3>
                            <div class="trend up"><i class="ri-arrow-up-line"></i> 5%</div>
                        </div>
                        <div class="data-box">
                            <h5>Conversion</h5>
                            <h3>3.8%</h3>
                            <div class="trend down"><i class="ri-arrow-down-line"></i> 0.4%</div>
                        </div>
                        <div class="data-box">
                            <h5>Revenue</h5>
                            <h3>1,240</h3>
                            <div class="trend up"><i class="ri-arrow-up-line"></i> 8%</div>
                        </div>
                    </div>

                    <div style="height: 250px;">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title">To-Do List</div>
                    </div>

                    <div class="todo-item">
                        <div class="todo-left">
                            <div class="todo-icon"><i class="ri-error-warning-line"></i></div>
                            <div class="todo-text">
                                <h4>Stock Warning</h4>
                                <p>3 items are low in stock</p>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/merchant/product/product_management.jsp" class="todo-action">Restock</a>
                    </div>

                    <div class="todo-item">
                        <div class="todo-left">
                            <div class="todo-icon"><i class="ri-message-3-line"></i></div>
                            <div class="todo-text">
                                <h4>Unread Messages</h4>
                                <p>5 customers are waiting</p>
                            </div>
                        </div>
                        <a href="#" class="todo-action">Reply</a>
                    </div>

                    <div class="todo-item">
                        <div class="todo-left">
                            <div class="todo-icon"><i class="ri-star-line"></i></div>
                            <div class="todo-text">
                                <h4>New Reviews</h4>
                                <p>You got 2 new 5-star reviews!</p>
                            </div>
                        </div>
                        <a href="#" class="todo-action">View</a>
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



