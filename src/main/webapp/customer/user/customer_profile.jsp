<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Profile - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <!-- Remix Icon CDN -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        /* Inherit basic styles */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
            color: #333;
            display: flex;
        }

        /* Background Blobs - Orange Theme */
        .background-blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
            opacity: 1;
            filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        }

        .blob-red {
            width: 750px; height: 650px; top: -200px; left: -200px;
            transform: rotate(-10deg);
            background: #ffffff;
            box-shadow: none;
        }

        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: #ffffff;
            box-shadow: none;
        }

        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ffad33, #e68a00);
            box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
        }

        /* Sidebar */
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
            color: #e68a00;
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

        .nav-item:hover, .nav-item.active {
            background: linear-gradient(45deg, #FF9500, #FFCC00);
            color: white;
            box-shadow: 0 5px 15px rgba(255, 149, 0, 0.3);
        }

        .nav-item span { margin-left: 10px; }

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
        .btn-logout:hover { background: #555; }

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
            color: #e68a00; 
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
        .tab-content { display: none; animation: fadeIn 0.5s; }
        .tab-content.active { display: block; }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Glass Panel Style */
        .glass-panel {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 30px;
            margin-bottom: 30px;
        }

        /* Avatar Card Styles */
        .avatar-card {
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .avatar-circle {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #FF9500, #FFCC00);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            color: white;
            font-weight: bold;
            box-shadow: 0 10px 20px rgba(255, 149, 0, 0.3);
        }

        .user-details h2 { margin-bottom: 5px; color: #2d3436; }
        .user-details p { color: #636e72; margin-bottom: 5px; }
        .user-details .role-badge {
            display: inline-block;
            padding: 4px 12px;
            background: #fff3e0;
            color: #e68a00;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-top: 5px;
        }

        /* Order Status Grid */
        .order-status-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            text-align: center;
        }

        .status-item {
            padding: 20px;
            border-radius: 15px;
            transition: 0.3s;
            cursor: pointer;
        }
        .status-item:hover {
            background: rgba(255, 255, 255, 0.5);
            transform: translateY(-5px);
        }

        .status-icon { font-size: 2rem; margin-bottom: 10px; display: block; }
        .status-label { font-weight: 600; color: #555; }
        .status-count { 
            display: inline-block; 
            background: #ff3b30; 
            color: white; 
            border-radius: 10px; 
            padding: 2px 8px; 
            font-size: 0.8rem; 
            margin-left: 5px; 
            vertical-align: middle;
        }

        .btn-edit {
            padding: 10px 25px;
            background: #e68a00;
            color: white;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-weight: 600;
            transition: 0.3s;
            margin-top: 15px;
        }
        .btn-edit:hover { background: #d35400; }

    </style>
</head>
<body>
    <div class="background-blob blob-red"></div>
    <div class="background-blob blob-yellow"></div>
    <div class="background-blob blob-orange"></div>

    <!-- Sidebar -->
    <div class="sidebar">
        <h2>My Account</h2>
        <div class="nav-item active" onclick="switchTab('profile', this)">
            <i class="ri-user-line"></i><span>Profile Info</span>
        </div>
        <div class="nav-item" onclick="switchTab('orders', this)">
            <i class="ri-shopping-bag-3-line"></i><span>My Orders</span>
        </div>
        <div class="nav-item" onclick="switchTab('settings', this)">
            <i class="ri-settings-3-line"></i><span>Settings</span>
        </div>
        
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-logout" style="margin-bottom: 10px; background: #555;">
                <i class="ri-home-4-line" style="margin-right: 5px;"></i>Back to Home
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
                <i class="ri-logout-box-line" style="margin-right: 5px;"></i>Logout
            </a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        
        <!-- Tab 1: Profile Info -->
        <div id="profile" class="tab-content active">
            <div class="header-section">
                <h1>Profile Information</h1>
            </div>

            <!-- 1. Avatar Card -->
            <div class="glass-panel avatar-card">
                <div class="avatar-circle">
                    ${sessionScope.user.username.charAt(0).toString().toUpperCase()}
                </div>
                <div class="user-details">
                    <h2>${sessionScope.user.username}</h2>
                    <p>${profile.email}</p>
                    <span class="role-badge">Customer Account</span>
                    <br>
                    <button class="btn-edit">Edit Profile</button>
                </div>
            </div>

            <!-- 2. My Orders Status Card -->
            <div class="glass-panel">
                <h3 style="margin-bottom: 20px; color: #e68a00;">My Orders</h3>
                <div class="order-status-grid">
                    <div class="status-item">
                        <i class="ri-wallet-3-line status-icon"></i>
                        <span class="status-label">Pending Payment</span>
                        <!-- <span class="status-count">2</span> -->
                    </div>
                    <div class="status-item">
                        <i class="ri-box-3-line status-icon"></i>
                        <span class="status-label">To Ship</span>
                        <!-- <span class="status-count">1</span> -->
                    </div>
                    <div class="status-item">
                        <i class="ri-truck-line status-icon"></i>
                        <span class="status-label">To Receive</span>
                    </div>
                    <div class="status-item">
                        <i class="ri-message-2-line status-icon"></i>
                        <span class="status-label">To Review</span>
                    </div>
                </div>
            </div>

            <!-- 3. Detailed Info -->
            <div class="glass-panel">
                <h3 style="margin-bottom: 20px; color: #e68a00;">Contact Details</h3>
                <div class="profile-info">
                    <c:if test="${not empty profile}">
                        <p><strong>Full Name:</strong> ${profile.fullName}</p>
                        <p><strong>Phone:</strong> ${profile.phone}</p>
                        <p><strong>Address:</strong> ${profile.address}</p>
                    </c:if>
                    <c:if test="${empty profile}">
                        <p>No additional contact details found.</p>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Tab 2: My Orders (Full List) -->
        <div id="orders" class="tab-content">
            <div class="header-section">
                <h1>Order History</h1>
            </div>
            <div class="glass-panel">
                <p>You haven't placed any orders yet.</p>
                <a href="${pageContext.request.contextPath}/index.jsp" style="color: #e68a00; font-weight: 600;">Start Shopping</a>
            </div>
        </div>

        <!-- Tab 3: Settings (Placeholder) -->
        <div id="settings" class="tab-content">
            <div class="header-section">
                <h1>Account Settings</h1>
            </div>
            <div class="glass-panel">
                <p>Change Password</p>
                <p>Notification Preferences</p>
            </div>
        </div>

    </div>

    <script>
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
    </script>
</body>
</html>
