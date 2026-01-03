<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Customer Profile - PrimeGo</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap"
                rel="stylesheet">
            <!-- Remix Icon CDN -->
            <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
            <style>
                /* Inherit basic styles */
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

                /* Background Blobs - Orange Theme */
                .background-blob {
                    position: fixed;
                    border-radius: 50%;
                    z-index: -1;
                    opacity: 1;
                    filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
                }

                .blob-red {
                    width: 750px;
                    height: 650px;
                    top: -200px;
                    left: -200px;
                    transform: rotate(-10deg);
                    background: #ffffff;
                    box-shadow: none;
                }

                .blob-yellow {
                    width: 900px;
                    height: 700px;
                    top: -250px;
                    right: -100px;
                    transform: rotate(30deg);
                    background: #ffffff;
                    box-shadow: none;
                }

                .blob-orange {
                    width: 1800px;
                    height: 950px;
                    bottom: -650px;
                    left: -600px;
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

                .nav-item:hover,
                .nav-item.active {
                    background: linear-gradient(45deg, #FF9500, #FFCC00);
                    color: white;
                    box-shadow: 0 5px 15px rgba(255, 149, 0, 0.3);
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

                .user-details h2 {
                    margin-bottom: 5px;
                    color: #2d3436;
                }

                .user-details p {
                    color: #636e72;
                    margin-bottom: 5px;
                }

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

                .status-icon {
                    font-size: 2rem;
                    margin-bottom: 10px;
                    display: block;
                }

                .status-label {
                    font-weight: 600;
                    color: #555;
                }

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

                .btn-edit:hover {
                    background: #d35400;
                }
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
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn-logout"
                        style="margin-bottom: 10px; background: #555;">
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

                    <!-- Modal Styles -->
                    <style>
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
                            animation: fadeIn 0.3s;
                        }

                        .modal-overlay.active {
                            display: flex;
                        }

                        .modal-dialog {
                            background: rgba(255, 255, 255, 0.9);
                            backdrop-filter: blur(20px);
                            padding: 30px;
                            border-radius: 20px;
                            width: 500px;
                            max-width: 90%;
                            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
                            border: 1px solid rgba(255, 255, 255, 0.8);
                            transform: scale(0.9);
                            opacity: 0;
                            transition: 0.3s;
                        }

                        .modal-overlay.active .modal-dialog {
                            transform: scale(1);
                            opacity: 1;
                        }

                        /* Form Input Styles - Rounded Minimalist */
                        .form-input {
                            width: 100%;
                            padding: 12px 20px;
                            border-radius: 25px;
                            /* Fully rounded */
                            border: 1px solid rgba(255, 255, 255, 0.5);
                            background: rgba(255, 255, 255, 0.6);
                            backdrop-filter: blur(10px);
                            outline: none;
                            transition: 0.3s;
                            box-shadow: inset 2px 2px 5px rgba(0, 0, 0, 0.05);
                            color: #333;
                            font-size: 0.9rem;
                            appearance: none;
                            /* Removes default arrow for selects on some browsers */
                        }

                        .form-input:focus {
                            background: rgba(255, 255, 255, 0.9);
                            box-shadow: 0 0 0 3px rgba(230, 138, 0, 0.2);
                            /* Orange glow */
                            border-color: #e68a00;
                        }

                        /* Custom dropdown arrow for select */
                        select.form-input {
                            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23e68a00%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E");
                            background-repeat: no-repeat;
                            background-position: right 15px top 50%;
                            background-size: 12px auto;
                            padding-right: 40px;
                        }

                        .modal-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 25px;
                            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
                            padding-bottom: 10px;
                        }
                    </style>

                    <!-- 1. Avatar Card (Normal View) -->
                    <div class="glass-panel avatar-card">
                        <div class="avatar-circle">
                            ${sessionScope.user.username.charAt(0).toString().toUpperCase()}
                        </div>
                        <div class="user-details">
                            <h2>${sessionScope.user.username}</h2>
                            <p>${profile.email}</p>
                            <span class="role-badge">Customer Account</span>
                            <br>
                            <button class="btn-edit" onclick="openModal()">Edit Profile</button>
                        </div>
                    </div>

                    <!-- Edit Profile Modal -->
                    <div class="modal-overlay" id="editProfileModal">
                        <div class="modal-dialog">
                            <div class="modal-header">
                                <h3>Edit Profile</h3>
                                <button class="btn-close" onclick="closeModal()">&times;</button>
                            </div>
                            <form action="${pageContext.request.contextPath}/profile" method="post">
                                <input type="hidden" name="action" value="updateCustomerProfile">

                                <div style="display: flex; flex-direction: column; gap: 18px;">

                                    <!-- Row 1: Name -->
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">First
                                                Name *</label>
                                            <input type="text" name="firstName" value="${profile.firstName}" required
                                                class="form-input">
                                        </div>
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Last
                                                Name *</label>
                                            <input type="text" name="lastName" value="${profile.lastName}" required
                                                class="form-input">
                                        </div>
                                    </div>

                                    <!-- Row 2: Phone -->
                                    <div style="display: grid; grid-template-columns: 0.4fr 1fr; gap: 15px;">
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Area
                                                Code</label>
                                            <select name="phoneAreaCode" class="form-input">
                                                <option value="+1" ${profile.phoneAreaCode=='+1' ? 'selected' : '' }>+1
                                                    (US)</option>
                                                <option value="+60" ${profile.phoneAreaCode=='+60' ? 'selected' : '' }>
                                                    +60 (MY)</option>
                                                <option value="+86" ${profile.phoneAreaCode=='+86' ? 'selected' : '' }>
                                                    +86 (CN)</option>
                                                <option value="+44" ${profile.phoneAreaCode=='+44' ? 'selected' : '' }>
                                                    +44 (UK)</option>
                                            </select>
                                        </div>
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Phone
                                                Number *</label>
                                            <input type="text" name="phoneNumber" value="${profile.phoneNumberOnly}"
                                                required class="form-input">
                                        </div>
                                    </div>

                                    <!-- Row 3: Address Line 1 -->
                                    <div>
                                        <label
                                            style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Address
                                            (Street, P.O. box) *</label>
                                        <input type="text" name="street" value="${profile.street}" required
                                            class="form-input">
                                    </div>

                                    <!-- Row 4: Address Line 2 -->
                                    <div>
                                        <label
                                            style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Address
                                            line 2 (Apartment, suite, unit)</label>
                                        <input type="text" name="unit" value="${profile.unit}" class="form-input">
                                    </div>

                                    <!-- Row 5: City -->
                                    <div>
                                        <label
                                            style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">City
                                            *</label>
                                        <input type="text" name="city" value="${profile.city}" required
                                            class="form-input">
                                    </div>

                                    <!-- Row 6: Country -->
                                    <div>
                                        <label
                                            style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Country/Region
                                            *</label>
                                        <select name="country" class="form-input">
                                            <option value="United States" ${profile.country=='United States'
                                                ? 'selected' : '' }>United States</option>
                                            <option value="Malaysia" ${profile.country=='Malaysia' ? 'selected' : '' }>
                                                Malaysia</option>
                                            <option value="China" ${profile.country=='China' ? 'selected' : '' }>China
                                            </option>
                                            <option value="Singapore" ${profile.country=='Singapore' ? 'selected' : ''
                                                }>Singapore</option>
                                        </select>
                                    </div>

                                    <!-- Row 7: State & Zip -->
                                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">State/Province</label>
                                            <input type="text" name="state" value="${profile.state}" class="form-input">
                                        </div>
                                        <div>
                                            <label
                                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px; font-weight: 500;">Postal/Zip
                                                code</label>
                                            <input type="text" name="zip" value="${profile.zip}"
                                                placeholder="e.g. 12345" class="form-input">
                                        </div>
                                    </div>

                                    <!-- Note: Username is hidden/readonly or removed from here as per new request focusing on address details, 
                                         but if you want to keep Username editing, add it back or assume it's not part of this specific address update request. 
                                         The request asked for Name, Phone, Address fields specifically. I will add a hidden username field to keep the controller happy if it expects it, 
                                         or just let the controller handle null username if I modified it to be optional. 
                                         Wait, my controller logic checks `if (newUsername != null ...)` so it's optional. I'll omit username editing here to focus on the requested layout. -->

                                </div>

                                <div style="margin-top: 25px; display: flex; gap: 10px; justify-content: flex-end;">
                                    <button type="submit" class="btn-edit"
                                        style="margin-top: 0; padding: 10px 25px;">Save information</button>
                                    <button type="button" class="btn-edit" onclick="closeModal()"
                                        style="margin-top: 0; padding: 10px 25px; background: #999;">Cancel</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openModal() {
                            document.getElementById('editProfileModal').classList.add('active');
                        }
                        function closeModal() {
                            document.getElementById('editProfileModal').classList.remove('active');
                            // Close when clicking outside
                            document.getElementById('editProfileModal').addEventListener('click', function (e) {
                                if (e.target === this) {
                                    closeModal();
                                }
                            });
                        }
                    </script>

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
                                <p><strong>Address:</strong> ${profile.street}</p>
                                <p><strong>City:</strong> ${profile.city}</p>
                                <p><strong>Country:</strong> ${profile.country}</p>
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
                        <a href="${pageContext.request.contextPath}/index.jsp"
                            style="color: #e68a00; font-weight: 600;">Start Shopping</a>
                    </div>
                </div>

                <!-- Tab 3: Settings (Change Password) -->
                <div id="settings" class="tab-content">
                    <div class="header-section">
                        <h1>Account Settings</h1>
                    </div>
                    <div class="glass-panel" style="max-width: 500px;">
                        <h3 style="margin-bottom: 25px; color: #e68a00;">Change Password</h3>

                        <c:if test="${not empty settingsMessage}">
                            <div
                                style="padding: 15px; border-radius: 10px; margin-bottom: 20px; 
                                ${settingsMessageType == 'success' ? 'background: rgba(46, 204, 113, 0.2); color: #27ae60;' : 'background: rgba(231, 76, 60, 0.2); color: #c0392b;'}">
                                ${settingsMessage}
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="action" value="changePassword">

                            <div style="margin-bottom: 20px;">
                                <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">Current
                                    Password</label>
                                <input type="password" name="oldPassword" required class="form-input">
                            </div>

                            <div style="margin-bottom: 20px;">
                                <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">New
                                    Password</label>
                                <input type="password" name="newPassword" required class="form-input">
                            </div>

                            <div style="margin-bottom: 25px;">
                                <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">Confirm
                                    New Password</label>
                                <input type="password" name="confirmPassword" required class="form-input">
                            </div>

                            <button type="submit" class="btn-edit"
                                style="width: 100%; padding: 12px; margin-top: 5px;">Update Password</button>
                        </form>
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