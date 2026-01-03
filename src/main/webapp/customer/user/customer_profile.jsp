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
            grid-template-columns: repeat(2, 1fr);
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

        /* PIN Input Styles */
        .pin-container {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin: 10px 0;
        }

        .pin-digit {
            width: 45px;
            height: 50px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.5);
            background: rgba(255, 255, 255, 0.8);
            /* Slightly more opaque */
            backdrop-filter: blur(10px);
            text-align: center;
            font-size: 1.2rem;
            font-weight: bold;
            color: #333;
            outline: none;
            transition: 0.3s;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            /* Added Shadow */
        }

        .pin-digit:focus {
            background: rgba(255, 255, 255, 1);
            box-shadow: 0 0 0 3px rgba(230, 138, 0, 0.2), 0 8px 20px rgba(230, 138, 0, 0.15);
            /* Enhanced Focus Shadow */
            border-color: #e68a00;
            transform: translateY(-2px);
            /* Subtle lift on focus */
        }
    </style>
</head>

<body>
<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>

<div class="sidebar">
    <h2>My Account</h2>
    <div class="nav-item active" onclick="switchTab('profile', this)">
        <i class="ri-user-line"></i><span>Profile Info</span>
    </div>
    <div class="nav-item" onclick="switchTab('orders', this)">
        <i class="ri-shopping-bag-3-line"></i><span>My Orders</span>
    </div>
    <div class="nav-item" onclick="switchTab('addresses', this)">
        <i class="ri-map-pin-line"></i><span>Addresses</span>
    </div>
    <div class="nav-item"
         onclick="window.location.href='${pageContext.request.contextPath}/common/wallet/wallet.jsp'">
        <i class="ri-wallet-line"></i><span>Wallet</span>
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

<div class="main-content">

    <div id="profile" class="tab-content active">
        <div class="header-section">
            <h1>Profile Information</h1>
        </div>

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

        <div class="modal-overlay" id="editProfileModal">
            <div class="modal-dialog">
                <div class="modal-header">
                    <h3>Edit Profile</h3>
                    <button class="btn-close" onclick="closeModal()">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/profile" method="post">
                    <input type="hidden" name="action" value="updateCustomerProfile">

                    <div style="display: flex; flex-direction: column; gap: 18px;">

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
                                <input type="text" name="phoneNumber" value="${profile.phoneNumberOnly}" required
                                       class="form-input">
                            </div>
                        </div>

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

        <div class="glass-panel">
            <h3 style="margin-bottom: 20px; color: #e68a00;">My Orders</h3>
            <div class="order-status-grid">
                <div class="status-item">
                    <i class="ri-box-3-line status-icon"></i>
                    <span class="status-label">To Ship</span>
                </div>
                <div class="status-item">
                    <i class="ri-truck-line status-icon"></i>
                    <span class="status-label">To Receive</span>
                </div>
            </div>
        </div>

        <div class="glass-panel">
            <h3 style="margin-bottom: 20px; color: #e68a00;">Contact Details</h3>
            <div class="profile-info">
                <c:if test="${not empty profile}">
                    <p><strong>Full Name:</strong> ${profile.fullName}</p>
                    <p><strong>Phone:</strong> ${profile.phone}</p>
                    <p><strong>Address:</strong> ${profile.formattedAddress}</p>
                    <p>(Manage your addresses in the "Addresses" tab)</p>
                </c:if>
                <c:if test="${empty profile}">
                    <p>No additional contact details found.</p>
                </c:if>
            </div>
        </div>
    </div>

    <div id="addresses" class="tab-content">
        <div class="header-section">
            <h1>My Addresses</h1>
            <button class="btn-edit" onclick="openAddressModal('add')" style="margin: 0; padding: 10px 20px;">
                <i class="ri-add-line"></i> Add New Address
            </button>
        </div>

        <c:if test="${not empty sessionScope.message}">
            <div
                    style="padding: 15px; border-radius: 10px; margin-bottom: 20px;
                            ${sessionScope.messageType == 'success' ? 'background: #d4edda; color: #155724;' : 'background: #f8d7da; color: #721c24;'}">
                    ${sessionScope.message}
            </div>
            <c:remove var="message" scope="session" />
            <c:remove var="messageType" scope="session" />
        </c:if>

        <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px;">
            <c:if test="${empty addresses}">
                <div class="glass-panel" style="text-align: center; color: #666; grid-column: 1 / -1;">
                    No addresses saved yet.
                </div>
            </c:if>
            <c:forEach var="addr" items="${addresses}">
                <div class="glass-panel"
                     style="position: relative; border: ${addr.defaultAddress ? '2px solid #e68a00' : '1px solid rgba(255,255,255,0.6)'};">
                    <c:if test="${addr.defaultAddress}">
                            <span
                                    style="position: absolute; top: 15px; right: 15px; background: #e68a00; color: white; padding: 4px 10px; border-radius: 15px; font-size: 0.8rem; font-weight: bold;">Default</span>
                    </c:if>

                    <h3 style="margin-bottom: 5px;">${addr.recipientName}</h3>
                    <p style="color: #666; font-size: 0.9rem; margin-bottom: 10px;">${addr.phone}</p>
                    <p style="margin-bottom: 15px;">
                            ${addr.detail}<br>
                            ${not empty addr.district ? addr.district : ''} ${not empty addr.district ? ',' :
                            ''} ${addr.city}<br>
                            ${addr.province}
                    </p>

                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <button class="btn-edit-addr" data-id="${addr.id}" data-name="${addr.recipientName}"
                                data-phone="${addr.phone}" data-province="${addr.province}" data-city="${addr.city}"
                                data-district="${addr.district}" data-detail="${addr.detail}"
                                data-default="${addr.defaultAddress}" onclick="openAddressModal('update', this)"
                                style="background: transparent; border: 1px solid #ccc; padding: 5px 15px; border-radius: 15px; cursor: pointer;">Edit</button>

                        <form action="${pageContext.request.contextPath}/user/address" method="post"
                              style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="addressId" value="${addr.id}">
                            <button type="submit" onclick="return confirm('Are you sure?')"
                                    style="background: transparent; border: 1px solid #ff6b6b; color: #ff6b6b; padding: 5px 15px; border-radius: 15px; cursor: pointer;">Delete</button>
                        </form>

                        <c:if test="${!addr.defaultAddress}">
                            <form action="${pageContext.request.contextPath}/user/address" method="post"
                                  style="display:inline;">
                                <input type="hidden" name="action" value="setDefault">
                                <input type="hidden" name="addressId" value="${addr.id}">
                                <button type="submit"
                                        style="background: transparent; border: 1px solid #e68a00; color: #e68a00; padding: 5px 15px; border-radius: 15px; cursor: pointer;">Set
                                    Default</button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div class="modal-overlay" id="addressModal">
            <div class="modal-dialog">
                <div class="modal-header">
                    <h3 id="addrModalTitle">Add Address</h3>
                    <button class="btn-close" onclick="closeAddressModal()">&times;</button>
                </div>
                <form action="${pageContext.request.contextPath}/user/address" method="post" id="addrForm">
                    <input type="hidden" name="action" id="addrAction" value="add">
                    <input type="hidden" name="addressId" id="addrId" value="">

                    <div style="display: flex; flex-direction: column; gap: 15px;">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                            <div>
                                <label
                                        style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">Receiver
                                    Name</label>
                                <input type="text" name="recipientName" id="addrName" required class="form-input">
                            </div>
                            <div>
                                <label
                                        style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">Phone</label>
                                <input type="text" name="phone" id="addrPhone" required class="form-input">
                            </div>
                        </div>

                        <div>
                            <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">Province/State</label>
                            <input type="text" name="province" id="addrProvince" class="form-input">
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                            <div>
                                <label
                                        style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">City</label>
                                <input type="text" name="city" id="addrCity" class="form-input">
                            </div>
                            <div>
                                <label
                                        style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">District
                                    (Optional)</label>
                                <input type="text" name="district" id="addrDistrict" class="form-input">
                            </div>
                        </div>

                        <div>
                            <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 6px;">Detailed
                                Address</label>
                            <textarea name="detail" id="addrDetail" rows="3" required class="form-input"
                                      style="border-radius: 15px;"></textarea>
                        </div>

                        <div style="display: flex; align-items: center; gap: 10px;">
                            <input type="checkbox" name="isDefault" id="addrDefault" value="true">
                            <label for="addrDefault" style="font-size: 0.9rem; color: #555;">Set as Default
                                Address</label>
                        </div>
                    </div>

                    <div style="margin-top: 25px; display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="submit" class="btn-edit"
                                style="margin-top: 0; padding: 10px 25px;">Save Address</button>
                        <button type="button" class="btn-edit" onclick="closeAddressModal()"
                                style="margin-top: 0; padding: 10px 25px; background: #999;">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openAddressModal(mode, btn) {
                var modal = document.getElementById('addressModal');
                var title = document.getElementById('addrModalTitle');
                var action = document.getElementById('addrAction');
                var idField = document.getElementById('addrId');

                if (mode === 'update' && btn) {
                    title.innerText = 'Update Address';
                    action.value = 'update';
                    idField.value = btn.getAttribute('data-id');
                    document.getElementById('addrName').value = btn.getAttribute('data-name');
                    document.getElementById('addrPhone').value = btn.getAttribute('data-phone');
                    document.getElementById('addrProvince').value = btn.getAttribute('data-province');
                    document.getElementById('addrCity').value = btn.getAttribute('data-city');
                    document.getElementById('addrDistrict').value = btn.getAttribute('data-district');
                    document.getElementById('addrDetail').value = btn.getAttribute('data-detail');
                    document.getElementById('addrDefault').checked = btn.getAttribute('data-default') === 'true';
                } else {
                    title.innerText = 'Add Address';
                    action.value = 'add';
                    idField.value = '';
                    document.getElementById('addrForm').reset();
                }
                modal.classList.add('active');
            }

            function closeAddressModal() {
                document.getElementById('addressModal').classList.remove('active');
            }
        </script>
    </div>

    <div id="orders" class="tab-content">
        <div class="header-section">
            <h1>Order History</h1>
        </div>

        <c:choose>
            <%-- Case 1: 没有订单 --%>
            <c:when test="${empty orderList}">
                <div class="glass-panel" style="text-align: center; padding: 40px;">
                    <div style="font-size: 3rem; color: #ddd; margin-bottom: 10px;">
                        <i class="ri-shopping-cart-line"></i>
                    </div>
                    <p style="color: #666; font-size: 1.1rem;">You haven't placed any orders yet.</p>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="btn-edit"
                       style="display: inline-block; text-decoration: none; margin-top: 20px;">
                        Start Shopping
                    </a>
                </div>
            </c:when>

            <%-- Case 2: 有订单，遍历显示 --%>
            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 20px;">
                    <c:forEach var="order" items="${orderList}">

                        <div class="glass-panel" style="padding: 25px; border-left: 5px solid #e68a00;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; border-bottom: 1px solid rgba(0,0,0,0.05); padding-bottom: 10px;">
                                <div>
                                    <h3 style="color: #2d3436; font-size: 1.1rem;">Order #${order.ordersId}</h3>
                                    <span style="font-size: 0.85rem; color: #888;">
                                            Placed on: ${order.createdAt}
                                        </span>
                                </div>
                                <div style="text-align: right;">
                                        <span style="padding: 5px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 600;
                                            ${order.orderStatus == 'COMPLETED' ? 'background: #d4edda; color: #155724;' :
                                              order.orderStatus == 'PENDING' ? 'background: #fff3cd; color: #856404;' :
                                              order.orderStatus == 'CANCELLED' ? 'background: #f8d7da; color: #721c24;' :
                                              'background: #e2e3e5; color: #383d41;'}">
                                                ${order.orderStatus}
                                        </span>

                                        <%-- ⭐ 新增：显示快递单号 --%>
                                    <c:if test="${not empty order.trackingNumber}">
                                        <div style="margin-top: 8px; font-size: 0.85rem; color: #555;">
                                            <i class="ri-truck-line" style="vertical-align: middle;"></i>
                                            Tracking: <strong>${order.trackingNumber}</strong>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <div style="background: rgba(255,255,255,0.5); border-radius: 10px; padding: 10px; margin-bottom: 15px;">
                                <c:forEach var="item" items="${order.orderItems}">
                                    <a href="${pageContext.request.contextPath}/customer/product/product_detail.jsp?id=${item.productId}"
                                       style="display: flex; align-items: center; gap: 15px; text-decoration: none; color: inherit; padding: 10px; border-bottom: 1px solid rgba(0,0,0,0.05); transition: 0.2s;"
                                       onmouseover="this.style.background='rgba(255,255,255,0.8)'"
                                       onmouseout="this.style.background='transparent'">

                                        <img src="${pageContext.request.contextPath}/${not empty item.productImageUrl ? item.productImageUrl : 'assets/images/no-image.png'}"
                                             alt="${item.productName}"
                                             style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 1px solid #eee;">

                                        <div style="flex: 1;">
                                            <div style="font-weight: 600; font-size: 0.95rem; color: #333;">${item.productName}</div>
                                            <div style="font-size: 0.8rem; color: #888;">x${item.quantity}</div>
                                        </div>

                                        <div style="font-weight: 600; color: #e68a00;">
                                            $${item.subtotal}
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-top: 10px;">

                                <div style="max-width: 60%;">
                                    <span style="color: #666; font-size: 0.9rem;">Shipping to:</span>
                                    <div style="font-size: 0.9rem; color: #333; font-weight: 500; margin-top: 5px; line-height: 1.4; white-space: normal; word-wrap: break-word;">
                                            ${order.address}
                                    </div>
                                </div>

                                <div style="text-align: right;">
                                    <span style="font-size: 0.9rem; color: #666;">Total Amount</span>
                                    <div style="font-size: 1.3rem; color: #e68a00; font-weight: bold; margin-bottom: 10px;">
                                        $${order.totalAmount}
                                    </div>

                                    <c:if test="${order.orderStatus == 'SHIPPED' || order.orderStatus == 'PAID'}">
                                        <form action="${pageContext.request.contextPath}/profile" method="post">
                                            <input type="hidden" name="action" value="confirmReceipt">
                                            <input type="hidden" name="orderId" value="${order.ordersId}">
                                            <button type="submit"
                                                    onclick="return confirm('Confirm that you have received the order?')"
                                                    style="background: #2d3436; color: white; border: none; padding: 8px 15px; border-radius: 10px; cursor: pointer; font-size: 0.85rem; font-weight: 600; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                                                <i class="ri-check-double-line"></i> Confirm Receipt
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div id="settings" class="tab-content">
        <div class="header-section">
            <h1>Account Settings</h1>
        </div>

        <div style="display: flex; flex-wrap: wrap; gap: 20px;">

            <div class="glass-panel" style="flex: 1; min-width: 300px; max-width: 500px;">
                <h3 style="margin-bottom: 25px; color: #e68a00;">Change Password</h3>

                <c:if test="${not empty settingsMessage && empty param.pinAction}">
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

                    <button type="submit" class="btn-edit" style="width: 100%; padding: 12px; margin-top: 5px;">Update
                        Password</button>
                </form>
            </div>

            <div class="glass-panel" style="flex: 1; min-width: 380px; max-width: 500px;">
                <h3 style="margin-bottom: 25px; color: #e68a00;">
                    <c:choose>
                        <c:when test="${empty profile.paymentPin}">Set Payment PIN</c:when>
                        <c:otherwise>Change Payment PIN</c:otherwise>
                    </c:choose>
                </h3>

                <c:if test="${not empty settingsMessage && not empty param.pinAction}">
                    <div
                            style="padding: 15px; border-radius: 10px; margin-bottom: 20px;
                                    ${settingsMessageType == 'success' ? 'background: rgba(46, 204, 113, 0.2); color: #27ae60;' : 'background: rgba(231, 76, 60, 0.2); color: #c0392b;'}">
                            ${settingsMessage}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/profile?pinAction=true" method="post">
                    <input type="hidden" name="action" value="updatePin">

                    <c:if test="${not empty profile.paymentPin}">
                        <div style="margin-bottom: 20px;">
                            <label
                                    style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">Current
                                PIN</label>
                            <div class="pin-container">
                                <c:forEach begin="1" end="6" var="i">
                                    <input type="password" name="oldPin${i}" maxlength="1" class="pin-digit old-pin"
                                           required oninput="moveToNext(this, 'old-pin')"
                                           onkeydown="handleBackspace(event, this, 'old-pin')">
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <div style="margin-bottom: 20px;">
                        <label
                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">New
                            PIN (6 digits)</label>
                        <div class="pin-container">
                            <c:forEach begin="1" end="6" var="i">
                                <input type="password" name="pin${i}" maxlength="1" class="pin-digit new-pin"
                                       required oninput="moveToNext(this, 'new-pin')"
                                       onkeydown="handleBackspace(event, this, 'new-pin')">
                            </c:forEach>
                        </div>
                    </div>

                    <div style="margin-bottom: 25px;">
                        <label
                                style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">Confirm
                            New PIN</label>
                        <div class="pin-container">
                            <c:forEach begin="1" end="6" var="i">
                                <input type="password" name="confirmPin${i}" maxlength="1"
                                       class="pin-digit confirm-pin" required
                                       oninput="moveToNext(this, 'confirm-pin')"
                                       onkeydown="handleBackspace(event, this, 'confirm-pin')">
                            </c:forEach>
                        </div>
                    </div>

                    <button type="submit" class="btn-edit" style="width: 100%; padding: 12px; margin-top: 5px;">
                        <c:choose>
                            <c:when test="${empty profile.paymentPin}">Set PIN</c:when>
                            <c:otherwise>Update PIN</c:otherwise>
                        </c:choose>
                    </button>
                </form>
            </div>
        </div>
    </div>

</div>

<script>
    function switchTab(tabId, element) {
        document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
        document.getElementById(tabId).classList.add('active');

        document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
        if (element) element.classList.add('active');
    }

    // Auto switch tab logic based on URL param
    window.onload = function () {
        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        if (tab) {
            const navItem = document.querySelector(".nav-item[onclick*='" + tab + "']");
            if (navItem) switchTab(tab, navItem);
        }
    };
    function moveToNext(input, className) {
        if (input.value.length >= 1) {
            let next = input.nextElementSibling;
            if (next && next.classList.contains(className)) {
                next.focus();
            }
        }
    }

    function handleBackspace(event, input, className) {
        if (event.key === 'Backspace' && input.value.length === 0) {
            let prev = input.previousElementSibling;
            if (prev && prev.classList.contains(className)) {
                prev.focus();
            }
        }
    }
</script>
</body>

</html>