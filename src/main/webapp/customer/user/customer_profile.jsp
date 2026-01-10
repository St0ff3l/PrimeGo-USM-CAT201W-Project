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
            <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
            <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_profile.css">
            <style>
                /* Page-specific styles only (moved shared layout styles to customer_profile.css) */

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
                    backdrop-filter: blur(10px);
                    text-align: center;
                    font-size: 1.2rem;
                    font-weight: bold;
                    color: #333;
                    outline: none;
                    transition: 0.3s;
                    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                }

                .pin-digit:focus {
                    background: rgba(255, 255, 255, 1);
                    box-shadow: 0 0 0 3px rgba(230, 138, 0, 0.2), 0 8px 20px rgba(230, 138, 0, 0.15);
                    border-color: #e68a00;
                    transform: translateY(-2px);
                }

                /* Order Tabs */
                .order-tabs {
                    display: flex;
                    gap: 10px;
                    margin-bottom: 20px;
                    overflow-x: auto;
                    padding-bottom: 5px;
                }

                .order-tab {
                    padding: 8px 20px;
                    border-radius: 20px;
                    background: rgba(255, 255, 255, 0.5);
                    color: #555;
                    text-decoration: none;
                    font-weight: 600;
                    font-size: 0.9rem;
                    transition: 0.3s;
                    white-space: nowrap;
                    border: 1px solid transparent;
                }

                .order-tab:hover {
                    background: rgba(255, 255, 255, 0.8);
                }

                .order-tab.active {
                    background: #e68a00;
                    color: white;
                    box-shadow: 0 4px 10px rgba(230, 138, 0, 0.3);
                }
            </style>
        </head>

        <body>
            <div class="background-blob blob-red"></div>
            <div class="background-blob blob-yellow"></div>
            <div class="background-blob blob-orange"></div>

            <jsp:include page="/common/layout/customer_profile_sidebar.jsp">
                <jsp:param name="active" value="profile" />
            </jsp:include>

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
                            border: 1px solid rgba(255, 255, 255, 0.5);
                            background: rgba(255, 255, 255, 0.6);
                            backdrop-filter: blur(10px);
                            outline: none;
                            transition: 0.3s;
                            box-shadow: inset 2px 2px 5px rgba(0, 0, 0, 0.05);
                            color: #333;
                            font-size: 0.9rem;
                            appearance: none;
                        }

                        .form-input:focus {
                            background: rgba(255, 255, 255, 0.9);
                            box-shadow: 0 0 0 3px rgba(230, 138, 0, 0.2);
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
                                            <input type="text" name="phoneNumber" value="${profile.phoneNumberOnly}"
                                                required class="form-input">
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
                            <div class="status-item"
                                onclick="window.location.href='${pageContext.request.contextPath}/customer/orders?status=PAID'">
                                <i class="ri-box-3-line status-icon"></i>
                                <span class="status-label">To Ship</span>
                            </div>
                            <div class="status-item"
                                onclick="window.location.href='${pageContext.request.contextPath}/customer/orders?status=SHIPPED'">
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
                        <button class="btn-edit" onclick="openAddressModal('add')"
                            style="margin: 0; padding: 10px 20px;">
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

                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px;">
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
                                        data-phone="${addr.phone}" data-province="${addr.province}"
                                        data-city="${addr.city}" data-district="${addr.district}"
                                        data-detail="${addr.detail}" data-default="${addr.defaultAddress}"
                                        onclick="openAddressModal('update', this)"
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
                                            <input type="text" name="recipientName" id="addrName" required
                                                class="form-input">
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

                    <div class="order-tabs">
                        <a href="${pageContext.request.contextPath}/profile?tab=orders&status=ALL"
                            class="order-tab ${currentStatus == 'ALL' || currentStatus == null ? 'active' : ''}">All</a>
                        <a href="${pageContext.request.contextPath}/profile?tab=orders&status=PAID"
                            class="order-tab ${currentStatus == 'PAID' ? 'active' : ''}">To Ship</a>
                        <a href="${pageContext.request.contextPath}/profile?tab=orders&status=SHIPPED"
                            class="order-tab ${currentStatus == 'SHIPPED' ? 'active' : ''}">To Receive</a>
                        <a href="${pageContext.request.contextPath}/profile?tab=orders&status=COMPLETED"
                            class="order-tab ${currentStatus == 'COMPLETED' ? 'active' : ''}">Completed</a>
                        <a href="${pageContext.request.contextPath}/profile?tab=orders&status=CANCELLED"
                            class="order-tab ${currentStatus == 'CANCELLED' ? 'active' : ''}">Cancelled</a>
                    </div>

                    <div class="glass-panel" style="text-align: center;">
                        <p style="color: #666; margin-bottom: 15px;">For the full order list, open the standalone My
                            Orders page.</p>
                        <a class="btn-edit" style="display: inline-block; text-decoration: none;"
                            href="${pageContext.request.contextPath}/customer/orders?status=${empty currentStatus ? 'ALL' : currentStatus}">
                            Go to My Orders
                        </a>
                    </div>
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

                            <form action="${pageContext.request.contextPath}/profile?tab=settings" method="post">
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
                                    style="width: 100%; padding: 12px; margin-top: 5px;">Update
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

                            <form action="${pageContext.request.contextPath}/profile?pinAction=true&tab=settings"
                                method="post">
                                <input type="hidden" name="action" value="updatePin">

                                <c:if test="${not empty profile.paymentPin}">
                                    <div style="margin-bottom: 20px;">
                                        <label
                                            style="display: block; font-size: 0.85rem; color: #555; margin-bottom: 8px; font-weight: 500;">Current
                                            PIN</label>
                                        <div class="pin-container">
                                            <c:forEach begin="1" end="6" var="i">
                                                <input type="password" name="oldPin${i}" maxlength="1"
                                                    class="pin-digit old-pin" required
                                                    oninput="moveToNext(this, 'old-pin')"
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
                                            <input type="password" name="pin${i}" maxlength="1"
                                                class="pin-digit new-pin" required oninput="moveToNext(this, 'new-pin')"
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

                                <button type="submit" class="btn-edit"
                                    style="width: 100%; padding: 12px; margin-top: 5px;">
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
                    const tabEl = document.getElementById(tabId);
                    if (tabEl) tabEl.classList.add('active');

                    // Sidebar items are links now; don't rely on onclick attributes.
                    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
                    if (element) element.classList.add('active');
                }

                // Auto switch tab logic based on URL param
                window.onload = function () {
                    const urlParams = new URLSearchParams(window.location.search);
                    const tab = urlParams.get('tab');
                    if (tab) {
                        // Only switch content panels; sidebar highlighting is handled by server-side include param.
                        switchTab(tab, null);
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

