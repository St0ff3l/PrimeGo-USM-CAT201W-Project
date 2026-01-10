<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Admin Dashboard - PrimeGo</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap"
                rel="stylesheet">
            <!-- Chart.js loaded from a CDN -->
            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
            <style>
                /* Global reset and base typography */
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: 'Poppins', sans-serif;
                }

                body {
                    background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
                    min-height: 100vh;
                    position: relative;
                    overflow-x: hidden;
                    color: #333;
                    display: flex;
                }

                /* Decorative background shapes (admin theme uses a red primary shape) */
                .background-blob {
                    position: fixed;
                    border-radius: 50%;
                    z-index: -1;
                    opacity: 1;
                    filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
                }

                /* Primary (red) background shape */
                .blob-red {
                    width: 750px;
                    height: 650px;
                    top: -200px;
                    left: -200px;
                    transform: rotate(-10deg);
                    background: linear-gradient(145deg, #ff5e55, #d92e25);
                    box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
                }

                /* Neutral (white) background shape */
                .blob-yellow {
                    width: 900px;
                    height: 700px;
                    top: -250px;
                    right: -100px;
                    transform: rotate(30deg);
                    background: #ffffff;
                    box-shadow: none;
                }

                /* Neutral (white) background shape */
                .blob-orange {
                    width: 1800px;
                    height: 950px;
                    bottom: -650px;
                    left: -600px;
                    transform: rotate(-10deg);
                    background: #ffffff;
                    box-shadow: none;
                }

                /* Left sidebar navigation */
                .sidebar {
                    width: 250px;
                    background: rgba(255, 255, 255, 0.8);
                    backdrop-filter: blur(20px);
                    border-right: 1px solid rgba(255, 255, 255, 0.6);
                    height: 100vh;
                    position: fixed;
                    top: 0;
                    left: 0;
                    padding: 30px 20px;
                    display: flex;
                    flex-direction: column;
                    z-index: 100;
                }

                .sidebar h2 {
                    color: #d63031;
                    margin-bottom: 40px;
                    font-size: 1.5rem;
                    text-align: center;
                }

                .nav-item {
                    padding: 15px 20px;
                    margin-bottom: 10px;
                    border-radius: 15px;
                    cursor: pointer;
                    transition: 0.3s;
                    color: #555;
                    font-weight: 600;
                    display: flex;
                    align-items: center;
                }

                .nav-item:hover,
                .nav-item.active {
                    background: linear-gradient(45deg, #FF3B30, #FF9500);
                    color: white;
                    box-shadow: 0 5px 15px rgba(255, 59, 48, 0.3);
                }

                .nav-item span {
                    margin-left: 10px;
                }

                .sidebar-footer {
                    margin-top: auto;
                }

                .btn-logout {
                    display: block;
                    width: 100%;
                    padding: 12px;
                    text-align: center;
                    background: #333;
                    color: white;
                    text-decoration: none;
                    border-radius: 15px;
                    transition: 0.3s;
                }

                .btn-logout:hover {
                    background: #555;
                }

                /* Main Content */
                .main-content {
                    margin-left: 250px;
                    flex-grow: 1;
                    padding: 40px;
                    width: calc(100% - 250px);
                }

                .header-section {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 30px;
                }

                .header-section h1 {
                    color: #d63031;
                    font-size: 2.5rem;
                    background: rgba(255, 255, 255, 0.6);
                    backdrop-filter: blur(10px);
                    -webkit-backdrop-filter: blur(10px);
                    padding: 10px 30px;
                    border-radius: 50px;
                    border: 1px solid rgba(255, 255, 255, 0.5);
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                    display: inline-block;
                }

                /* Tab Content */
                .tab-content {
                    display: none;
                    animation: fadeIn 0.5s;
                }

                .tab-content.active {
                    display: block;
                }

                @keyframes fadeIn {
                    from {
                        opacity: 0;
                        transform: translateY(10px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                /* Frosted-glass card styling used across sections */
                .glass-panel {
                    background: rgba(255, 255, 255, 0.7);
                    backdrop-filter: blur(20px);
                    border: 1px solid rgba(255, 255, 255, 0.6);
                    border-radius: 20px;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                    padding: 25px;
                    margin-bottom: 30px;
                }

                /* Key metrics layout */
                .metrics-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                    gap: 20px;
                    margin-bottom: 30px;
                }

                .metric-card {
                    display: flex;
                    flex-direction: column;
                    align-items: flex-start;
                }

                .metric-title {
                    font-size: 0.9rem;
                    color: #666;
                    margin-bottom: 5px;
                }

                .metric-value {
                    font-size: 2rem;
                    font-weight: 700;
                    color: #2d3436;
                }

                .metric-trend {
                    font-size: 0.8rem;
                    color: #27ae60;
                    font-weight: 600;
                }

                /* Charts layout */
                .charts-grid {
                    display: grid;
                    grid-template-columns: 2fr 1fr;
                    gap: 20px;
                    margin-bottom: 30px;
                }

                .chart-container {
                    position: relative;
                    height: 300px;
                    width: 100%;
                }

                /* Logs & Tables */
                .table-container {
                    overflow-x: auto;
                }

                .data-table {
                    width: 100%;
                    border-collapse: collapse;
                }

                .data-table th,
                .data-table td {
                    text-align: left;
                    padding: 15px;
                    border-bottom: 1px solid rgba(0, 0, 0, 0.05);
                }

                .data-table th {
                    color: #666;
                    font-weight: 600;
                }

                .data-table tr:last-child td {
                    border-bottom: none;
                }

                .log-level {
                    padding: 4px 8px;
                    border-radius: 4px;
                    font-size: 0.8rem;
                    font-weight: 600;
                }

                .level-INFO {
                    background: #e3f2fd;
                    color: #1976d2;
                }

                .level-WARN {
                    background: #fff3e0;
                    color: #f57c00;
                }

                .level-ERROR {
                    background: #ffebee;
                    color: #d32f2f;
                }

                .role-badge {
                    padding: 5px 10px;
                    border-radius: 15px;
                    font-size: 0.85rem;
                    font-weight: 600;
                }

                .role-ADMIN {
                    background: #ffebee;
                    color: #d32f2f;
                }

                .role-MERCHANT {
                    background: #fff8e1;
                    color: #fbc02d;
                }

                .role-CUSTOMER {
                    background: #e3f2fd;
                    color: #1976d2;
                }

                /* User Detail Modal */
                .modal-overlay {
                    display: none;
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(5px);
                    z-index: 1000;
                    justify-content: center;
                    align-items: center;
                }

                .modal-content {
                    background: rgba(255, 255, 255, 0.95);
                    padding: 30px;
                    border-radius: 20px;
                    width: 400px;
                    max-width: 90%;
                    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
                    position: relative;
                    backdrop-filter: blur(10px);
                    border: 1px solid rgba(255, 255, 255, 0.5);
                    animation: modalPop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
                }

                @keyframes modalPop {
                    0% {
                        transform: scale(0.8);
                        opacity: 0;
                    }

                    100% {
                        transform: scale(1);
                        opacity: 1;
                    }
                }

                .modal-lg {
                    width: 900px;
                    max-height: 85vh;
                    overflow-y: auto;
                }

                .close-btn {
                    position: absolute;
                    top: 20px;
                    right: 25px;
                    background: rgba(0, 0, 0, 0.05);
                    border: none;
                    width: 32px;
                    height: 32px;
                    border-radius: 50%;
                    font-size: 1.2rem;
                    cursor: pointer;
                    color: #555;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    transition: 0.2s;
                }

                .close-btn:hover {
                    background: #ff5e55;
                    color: white;
                    transform: rotate(90deg);
                }

                /* Transaction Modal Specifics */
                .modal-header {
                    margin-bottom: 25px;
                    padding-bottom: 15px;
                    border-bottom: 1px solid rgba(0, 0, 0, 0.05);
                }

                .modal-header h2 {
                    color: #2c3e50;
                    font-weight: 700;
                }

                .transaction-section {
                    background: white;
                    border-radius: 15px;
                    padding: 20px;
                    margin-bottom: 25px;
                    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
                    border: 1px solid rgba(0, 0, 0, 0.02);
                }

                .section-title {
                    font-size: 1.1rem;
                    color: #333;
                    margin-bottom: 15px;
                    padding-bottom: 8px;
                    display: flex;
                    align-items: center;
                    font-weight: 600;
                }

                .section-title::before {
                    content: '';
                    display: inline-block;
                    width: 4px;
                    height: 18px;
                    margin-right: 10px;
                    border-radius: 2px;
                }

                .title-paid {
                    color: #27ae60;
                    border-bottom: 2px solid rgba(39, 174, 96, 0.1);
                }

                .title-paid::before {
                    background: #27ae60;
                }

                .title-shipped {
                    color: #2980b9;
                    border-bottom: 2px solid rgba(41, 128, 185, 0.1);
                }

                .title-shipped::before {
                    background: #2980b9;
                }

                .title-completed {
                    color: #8e44ad;
                    border-bottom: 2px solid rgba(142, 68, 173, 0.1);
                }

                .title-completed::before {
                    background: #8e44ad;
                }

                .title-cancelled {
                    color: #c0392b;
                    border-bottom: 2px solid rgba(192, 57, 43, 0.1);
                }

                .title-cancelled::before {
                    background: #c0392b;
                }
            </style>
        </head>

        <body>
            <div class="background-blob blob-red"></div>
            <div class="background-blob blob-yellow"></div>
            <div class="background-blob blob-orange"></div>

            <!-- Sidebar navigation -->
            <div class="sidebar">
                <h2>PrimeGo Admin</h2>
                <div class="nav-item active" onclick="switchTab('dashboard', this)">
                    <span>Dashboard</span>
                </div>
                <div class="nav-item" onclick="switchTab('users', this)">
                    <span>User Management</span>
                </div>
                <div class="nav-item" onclick="switchTab('settings', this)">
                    <span>Settings</span>
                </div>

                <!-- Admin: product review queue -->
                <a class="nav-item" style="text-decoration:none;"
                    href="${pageContext.request.contextPath}/admin/product/review/list">
                    <span>Product Review</span>
                </a>

                <!-- Admin: wallet top-up/withdraw approval -->
                <a class="nav-item" style="text-decoration:none;"
                    href="${pageContext.request.contextPath}/admin/wallet/admin_approval.jsp">
                    <span>Funds Approval</span>
                </a>

                <!-- Admin: create merchant accounts -->
                <a class="nav-item" style="text-decoration:none;"
                    href="${pageContext.request.contextPath}/admin/merchant/create">
                    <span>Merchant Create</span>
                </a>

                <div class="sidebar-footer">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn-logout"
                        style="margin-bottom: 10px; background: #555;">Back to Home</a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
                </div>
            </div>

            <!-- Main page content -->
            <div class="main-content">

                <!-- Dashboard overview tab -->
                <div id="dashboard" class="tab-content active">
                    <div class="header-section">
                        <h1>Dashboard Overview</h1>
                    </div>

                    <!-- Metrics -->
                    <div class="metrics-grid">
                        <div class="glass-panel metric-card">
                            <span class="metric-title">Total Users</span>
                            <span class="metric-value">${totalUsers}</span>
                            <span class="metric-trend">↑ 12% vs last week</span>
                        </div>
                        <div class="glass-panel metric-card">
                            <span class="metric-title">Active Sessions</span>
                            <span class="metric-value">${activeSessions}</span>
                            <span class="metric-trend">Currently Online</span>
                        </div>
                        <div class="glass-panel metric-card">
                            <span class="metric-title">Daily Visits</span>
                            <span class="metric-value">${dailyVisits}</span>
                            <span class="metric-trend">↑ 5% vs yesterday</span>
                        </div>
                        <div class="glass-panel metric-card" onclick="openTransactionsModal()" style="cursor: pointer;">
                            <span class="metric-title">Total Transactions</span>
                            <span class="metric-value">${revenue}</span>
                            <span class="metric-trend">↑ 8% vs last month</span>
                        </div>
                    </div>

                    <!-- Charts -->
                    <div class="charts-grid">
                        <div class="glass-panel">
                            <h3>Traffic Overview</h3>
                            <div class="chart-container">
                                <canvas id="trafficChart"></canvas>
                            </div>
                        </div>
                        <div class="glass-panel">
                            <h3>User Distribution</h3>
                            <div class="chart-container">
                                <canvas id="userChart"></canvas>
                            </div>
                        </div>
                    </div>

                    <!-- Logs -->
                    <div class="glass-panel logs-section">
                        <h3>System Logs</h3>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Level</th>
                                        <th>Message</th>
                                        <th>Time</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="log" items="${logs}">
                                        <tr>
                                            <td><span class="log-level level-${log.level}">${log.level}</span></td>
                                            <td>${log.message}</td>
                                            <td>${log.time}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- User management tab -->
                <div id="users" class="tab-content">
                    <div class="header-section">
                        <h1>User Management</h1>
                    </div>

                    <div class="glass-panel">
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Username</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Created At</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="u" items="${userList}">
                                        <tr>
                                            <td>#${u.id}</td>
                                            <td>
                                                <div style="display: flex; align-items: center;">
                                                    <div
                                                        style="width: 30px; height: 30px; background: #eee; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 10px; font-weight: bold; color: #555;">
                                                        ${u.username.charAt(0).toString().toUpperCase()}
                                                    </div>
                                                    ${u.username}
                                                </div>
                                            </td>
                                            <td><span class="role-badge role-${u.role}">${u.role}</span></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${u.status == 1}"><span style="color: #27ae60;">●
                                                            Active</span></c:when>
                                                    <c:otherwise><span style="color: #d63031;">● Inactive</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${u.createdAt}</td>
                                            <td>

                                                <button
                                                    onclick="viewUserDetails('${u.id}', '${u.username}', '${u.role}', ${u.status}, '${u.createdAt}')"
                                                    style="padding: 5px 10px; border: 1px solid #0984e3; background: #e3f2fd; color: #0984e3; border-radius: 5px; cursor: pointer; margin-left: 5px;">Detail</button>
                                                <button
                                                    style="padding: 5px 10px; border: 1px solid #ffcccc; background: #fff5f5; color: #d63031; border-radius: 5px; cursor: pointer; margin-left: 5px;">Delete</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Settings tab -->
                <div id="settings" class="tab-content">
                    <div class="header-section">
                        <h1>System Settings</h1>
                    </div>

                    <c:if test="${not empty settingsMessage}">
                        <div style="padding: 15px; margin-bottom: 20px; border-radius: 10px; 
                            background: ${settingsMessageType eq 'success' ? '#e8f5e9' : '#ffebee'}; 
                            color: ${settingsMessageType eq 'success' ? '#2e7d32' : '#c62828'};
                            border: 1px solid ${settingsMessageType eq 'success' ? '#c8e6c9' : '#ffcdd2'};">
                            ${settingsMessage}
                        </div>
                    </c:if>

                    <div class="glass-panel">
                        <h3 style="margin-bottom: 20px; color: #333;">Profile Settings</h3>
                        <form action="${pageContext.request.contextPath}/admin/dashboard" method="post">
                            <input type="hidden" name="action" value="updateProfile">
                            <div style="margin-bottom: 20px;">
                                <label
                                    style="display: block; margin-bottom: 8px; color: #666; font-weight: 500;">Department</label>
                                <input type="text" name="department" value="${adminProfile.department}"
                                    style="width: 100%; padding: 12px; border: 1px solid rgba(0,0,0,0.1); border-radius: 8px; background: rgba(255,255,255,0.8); outline: none;">
                            </div>
                            <button type="submit"
                                style="padding: 12px 30px; background: #333; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; transition: 0.3s;">
                                Save Changes
                            </button>
                        </form>
                    </div>

                    <div class="glass-panel">
                        <h3 style="margin-bottom: 20px; color: #333;">Security Settings</h3>
                        <form action="${pageContext.request.contextPath}/admin/dashboard" method="post">
                            <input type="hidden" name="action" value="changePassword">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                                <div style="margin-bottom: 20px; grid-column: span 2;">
                                    <label
                                        style="display: block; margin-bottom: 8px; color: #666; font-weight: 500;">Current
                                        Password</label>
                                    <input type="password" name="currentPassword" required
                                        style="width: 100%; padding: 12px; border: 1px solid rgba(0,0,0,0.1); border-radius: 8px; background: rgba(255,255,255,0.8); outline: none;">
                                </div>
                                <div style="margin-bottom: 20px;">
                                    <label
                                        style="display: block; margin-bottom: 8px; color: #666; font-weight: 500;">New
                                        Password</label>
                                    <input type="password" name="newPassword" required
                                        style="width: 100%; padding: 12px; border: 1px solid rgba(0,0,0,0.1); border-radius: 8px; background: rgba(255,255,255,0.8); outline: none;">
                                </div>
                                <div style="margin-bottom: 20px;">
                                    <label
                                        style="display: block; margin-bottom: 8px; color: #666; font-weight: 500;">Confirm
                                        New Password</label>
                                    <input type="password" name="confirmPassword" required
                                        style="width: 100%; padding: 12px; border: 1px solid rgba(0,0,0,0.1); border-radius: 8px; background: rgba(255,255,255,0.8); outline: none;">
                                </div>
                            </div>
                            <button type="submit"
                                style="padding: 12px 30px; background: #d63031; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600; transition: 0.3s;">
                                Change Password
                            </button>
                        </form>
                    </div>
                </div>

            </div>

            <!-- User details modal -->
            <div id="userDetailModal" class="modal-overlay">
                <div class="modal-content">
                    <button class="close-btn" onclick="closeUserModal()">&times;</button>
                    <h2 style="margin-bottom: 20px; color: #333;">User Details</h2>
                    <div id="modalBody">
                        <p style="color: #666;">Loading...</p>
                    </div>
                </div>
            </div>

            <!-- Global message modal (success dialog) -->
            <c:if test="${not empty sessionScope.globalMessage}">
                <div id="globalMessageModal" class="modal-overlay" style="display: flex;">
                    <div class="modal-content" style="text-align: center; width: 350px;">
                        <button class="close-btn" onclick="closeGlobalModal()">&times;</button>
                        <div style="margin-bottom: 15px;">
                            <i class="ri-checkbox-circle-fill" style="font-size: 3rem; color: #2ecc71;"></i>
                        </div>
                        <h2 style="margin-bottom: 10px; color: #333;">Success!</h2>
                        <p style="color: #666; font-size: 1rem; margin-bottom: 20px;">${sessionScope.globalMessage}</p>
                        <button onclick="closeGlobalModal()"
                            style="padding: 10px 25px; background: #2ecc71; color: white; border: none; border-radius: 10px; cursor: pointer; font-weight: 600; transition: 0.3s;">
                            OK, Got it
                        </button>
                    </div>
                </div>
                <script>
                    function closeGlobalModal() {
                        document.getElementById('globalMessageModal').style.display = 'none';
                    }
                </script>
                <c:remove var="globalMessage" scope="session" />
                <c:remove var="globalMessageType" scope="session" />
            </c:if>

            <!-- Transactions detail modal -->
            <div id="transactionsModal" class="modal-overlay">
                <div class="modal-content modal-lg">
                    <button class="close-btn" onclick="closeTransactionsModal()">&times;</button>
                    <div class="modal-header">
                        <h2>Total Transactions Detail</h2>
                    </div>

                    <div class="transaction-section">
                        <h3 class="section-title title-paid">PAID Orders</h3>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer ID</th>
                                        <th>Amount</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty paidOrders}">
                                            <tr>
                                                <td colspan="4">No PAID orders found.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="o" items="${paidOrders}">
                                                <tr>
                                                    <td>#${o.ordersId}</td>
                                                    <td>User #${o.customerId}</td>
                                                    <td>RM ${o.totalAmount}</td>
                                                    <td>${o.createdAt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="transaction-section">
                        <h3 class="section-title title-shipped">SHIPPED Orders</h3>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer ID</th>
                                        <th>Amount</th>
                                        <th>Tracking</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty shippedOrders}">
                                            <tr>
                                                <td colspan="5">No SHIPPED orders found.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="o" items="${shippedOrders}">
                                                <tr>
                                                    <td>#${o.ordersId}</td>
                                                    <td>User #${o.customerId}</td>
                                                    <td>RM ${o.totalAmount}</td>
                                                    <td>${o.trackingNumber}</td>
                                                    <td>${o.createdAt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="transaction-section">
                        <h3 class="section-title title-completed">COMPLETED Orders</h3>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer ID</th>
                                        <th>Amount</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty completedOrders}">
                                            <tr>
                                                <td colspan="4">No COMPLETED orders found.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="o" items="${completedOrders}">
                                                <tr>
                                                    <td>#${o.ordersId}</td>
                                                    <td>User #${o.customerId}</td>
                                                    <td>RM ${o.totalAmount}</td>
                                                    <td>${o.createdAt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div class="transaction-section">
                        <h3 class="section-title title-cancelled">CANCELLED Orders</h3>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Customer ID</th>
                                        <th>Amount</th>
                                        <th>Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${empty cancelledOrders}">
                                            <tr>
                                                <td colspan="4">No CANCELLED orders found.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="o" items="${cancelledOrders}">
                                                <tr>
                                                    <td>#${o.ordersId}</td>
                                                    <td>User #${o.customerId}</td>
                                                    <td>RM ${o.totalAmount}</td>
                                                    <td>${o.createdAt}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </div>

            <script>
                // Switch between tab panels and update the active sidebar item
                function switchTab(tabId, navElement) {
                    // Hide all tabs
                    document.querySelectorAll('.tab-content').forEach(tab => {
                        tab.classList.remove('active');
                    });
                    // Show selected tab
                    document.getElementById(tabId).classList.add('active');

                    // Update sidebar active state
                    document.querySelectorAll('.nav-item').forEach(item => {
                        item.classList.remove('active');
                    });
                    navElement.classList.add('active');
                }

                // Charts initialization (Traffic: line chart, Users: doughnut chart)
                const ctxTraffic = document.getElementById('trafficChart').getContext('2d');
                new Chart(ctxTraffic, {
                    type: 'line',
                    data: {
                        labels: [${ chartLabels }],
                        datasets: [{
                            label: 'Visitors',
                            data: [${ chartData }],
                            borderColor: '#FF3B30',
                            backgroundColor: 'rgba(255, 59, 48, 0.1)',
                            tension: 0.4,
                            fill: true
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: { y: { beginAtZero: true } }
                    }
                });

                const ctxUser = document.getElementById('userChart').getContext('2d');
                new Chart(ctxUser, {
                    type: 'doughnut',
                    data: {
                        labels: ['Customers', 'Merchants', 'Admins'],
                        datasets: [{
                            data: [${ userChartData }],
                            backgroundColor: ['#FF9500', '#FFCC00', '#FF3B30'],
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { position: 'bottom' } }
                    }
                });

                // User details modal: render basic info and then fetch extended profile data
                function viewUserDetails(id, username, role, status, createdAt) {
                    const modal = document.getElementById('userDetailModal');
                    const body = document.getElementById('modalBody');

                    modal.style.display = 'flex';

                    let statusHtml = status === 1 ?
                        '<span style="color: #27ae60; font-weight:bold;">Active</span>' :
                        '<span style="color: #d63031; font-weight:bold;">Inactive</span>';

                    let basicInfo = '';
                    basicInfo += '<div style="margin-bottom: 10px; border-bottom: 2px solid #eee; padding-bottom: 8px;">';
                    basicInfo += '<h3 style="margin: 0 0 10px 0; font-size: 1rem; color: #333;">Account Info</h3>';
                    basicInfo += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">User ID:</strong> #' + id + '</div>';
                    basicInfo += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Username:</strong> ' + username + '</div>';
                    basicInfo += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Role:</strong> ' + role + '</div>';
                    basicInfo += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Status:</strong> ' + statusHtml + '</div>';
                    basicInfo += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Created At:</strong> ' + createdAt + '</div>';
                    basicInfo += '</div>';

                    // Placeholder for extended info
                    let extendedId = 'extendedInfo-' + id;
                    let extendedInfo = '<div id="' + extendedId + '" style="margin-top: 15px;">';
                    extendedInfo += '<p style="color: #666; font-style: italic;">Loading extended profile details...</p>';
                    extendedInfo += '</div>';

                    body.innerHTML = basicInfo + extendedInfo;

                    // Fetch extended details
                    fetch('${pageContext.request.contextPath}/admin/api/user-details?userId=' + id + '&role=' + role)
                        .then(response => {
                            if (!response.ok) {
                                return response.text().then(text => { throw new Error('Server error: ' + response.status) });
                            }
                            const contentType = response.headers.get("content-type");
                            if (!contentType || !contentType.includes("application/json")) {
                                throw new Error('Invalid response format');
                            }
                            return response.json();
                        })
                        .then(data => {
                            let content = '';
                            if (data.error) {
                                content = '<p style="color: #999; font-style: italic;">' + data.error + '</p>';
                            } else {
                                if (role === 'CUSTOMER') {
                                    content += '<h3 style="margin: 0 0 10px 0; font-size: 1rem; color: #333;">Customer Profile</h3>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Full Name:</strong> ' + (data.fullName || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Email:</strong> ' + (data.email || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Phone:</strong> ' + (data.phone || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px; margin-top: 10px; background: #f9f9f9; padding: 10px; border-radius: 8px;">';
                                    content += '<strong style="display:block; margin-bottom:5px; color:#555;">Default Address:</strong> ' + (data.address || 'No address set');
                                    content += '</div>';
                                } else if (role === 'MERCHANT') {
                                    content += '<h3 style="margin: 0 0 10px 0; font-size: 1rem; color: #333;">Merchant Profile</h3>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Store Name:</strong> ' + (data.storeName || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">License:</strong> ' + (data.license || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Contact:</strong> ' + (data.contact || '-') + '</div>';
                                } else if (role === 'ADMIN') {
                                    content += '<h3 style="margin: 0 0 10px 0; font-size: 1rem; color: #333;">Admin Profile</h3>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Department:</strong> ' + (data.department || '-') + '</div>';
                                    content += '<div style="margin-bottom: 5px;"><strong style="display:inline-block; width: 120px; color:#555;">Level:</strong> ' + (data.level || '-') + '</div>';
                                }
                            }
                            const container = document.getElementById(extendedId);
                            if (container) container.innerHTML = content;
                        })
                        .catch(err => {
                            const container = document.getElementById(extendedId);
                            if (container) container.innerHTML = '<p style="color: #ecf0f1; background: #e74c3c; padding: 5px; border-radius: 4px; display: inline-block;">Error: ' + err.message + '</p>';
                            console.error('Extended details fetch error:', err);
                        });
                }

                function closeUserModal() {
                    document.getElementById('userDetailModal').style.display = 'none';
                }

                // Transactions modal
                function openTransactionsModal() {
                    document.getElementById('transactionsModal').style.display = 'flex';
                }

                function closeTransactionsModal() {
                    document.getElementById('transactionsModal').style.display = 'none';
                }

                // Close modals when clicking on the overlay
                window.onclick = function (event) {
                    const uModal = document.getElementById('userDetailModal');
                    const tModal = document.getElementById('transactionsModal');
                    if (event.target == uModal) {
                        uModal.style.display = "none";
                    }
                    if (event.target == tModal) {
                        tModal.style.display = "none";
                    }
                }
            </script>
        </body>

        </html>
