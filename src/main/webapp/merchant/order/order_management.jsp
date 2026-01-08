<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="com.primego.order.model.Order" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // 权限检查 (双重保险)
    User user = (User) session.getAttribute("user");
    if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management - PrimeGo Seller</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        /* 复用 Merchant Dashboard 的核心样式 */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --card-radius: 16px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
            padding-top: 90px;
        }

        .layout-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 30px;
            align-items: start;
        }

        .main-content {
            display: flex;
            flex-direction: column;
            gap: 25px;
        }

        /* 玻璃拟态卡片样式 */
        .glass-panel {
            background: rgba(255, 255, 255, 0.55);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-radius: var(--card-radius);
            padding: 25px;
        }

        /* 订单卡片样式 */
        .order-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 5px solid var(--primary);
            box-shadow: 0 4px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }

        .order-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.08);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }

        .order-id { font-weight: 700; font-size: 1.1rem; color: var(--text-dark); }
        .order-date { font-size: 0.85rem; color: var(--text-gray); }

        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .status-paid { background: #fff3cd; color: #856404; }
        .status-shipped { background: #d1e7dd; color: #0f5132; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-pending { background: #f8d7da; color: #721c24; }

        /* 地址部分重点样式 */
        .address-box {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 15px 0;
            font-size: 0.9rem;
            color: #444;
            display: flex;
            gap: 10px;
            align-items: flex-start;
        }
        .address-icon {
            color: var(--primary);
            font-size: 1.2rem;
            margin-top: 2px;
        }

        /* 按钮样式 */
        .btn-ship {
            background: var(--text-dark);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: 0.3s;
        }
        .btn-ship:hover {
            background: var(--primary);
            transform: translateY(-2px);
        }

        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            font-size: 0.95rem;
            border-bottom: 1px dashed #eee;
        }
        .item-row:last-child { border-bottom: none; }

        /* ⭐ 新增：弹窗样式 */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;
        }
        .modal-content {
            background: white; padding: 30px; border-radius: 16px; width: 400px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2); animation: popIn 0.3s ease;
        }
        @keyframes popIn { from { transform: scale(0.8); opacity: 0; } to { transform: scale(1); opacity: 1; } }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #333; }
        .form-control {
            width: 100%; padding: 10px; border: 2px solid #eee; border-radius: 8px; font-size: 1rem;
        }
        .modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
        .btn-cancel { background: #eee; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
        .btn-confirm { background: #FF9500; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="layout-container">

    <% request.setAttribute("activeMenu", "order"); %>
    <jsp:include page="../layout/merchant_sidebar.jsp" />

    <main class="main-content">

        <div class="glass-panel">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h2 style="font-size: 1.5rem; color: var(--text-dark);">Order Management</h2>
                <div style="font-size: 0.9rem; color: var(--text-gray);">
                    Manage shipments and view customer details
                </div>
            </div>

            <%-- If orders is not set, this page was likely accessed directly instead of via the servlet. --%>
            <c:if test="${orders == null}">
                <div class="glass-panel" style="margin-bottom: 20px; border-left: 5px solid #ff9500;">
                    <div style="display:flex; gap:12px; align-items:flex-start;">
                        <i class="ri-information-line" style="font-size: 1.3rem; color: #ff9500; margin-top: 2px;"></i>
                        <div>
                            <div style="font-weight: 700; margin-bottom: 6px;">Orders didn’t load</div>
                            <div style="color: #666; font-size: 0.95rem; line-height: 1.5;">
                                You’re opening this JSP directly, so the backend didn’t fetch orders.
                                Please enter this page via the Orders menu (servlet) or click
                                    <%-- 【修改点1】 修复 Reload 链接 --%>
                                <a href="${pageContext.request.contextPath}/merchant/order/order_management" style="color:#ff9500; font-weight: 600;">reload orders</a>.
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty orders}">
                <div style="text-align: center; padding: 50px; color: #999;">
                    <i class="ri-inbox-line" style="font-size: 3rem; margin-bottom: 10px; display: block;"></i>
                    No orders found yet.
                </div>
            </c:if>

            <c:forEach var="order" items="${orders}">
                <div class="order-card">

                    <div class="order-header">
                        <div>
                            <div class="order-id">Order #${order.ordersId}</div>
                            <div class="order-date">
                                <i class="ri-time-line" style="vertical-align: middle;"></i>
                                    ${order.createdAt}
                            </div>
                        </div>
                        <div>
                            <span class="status-badge
                                ${order.orderStatus == 'PAID' ? 'status-paid' :
                                  order.orderStatus == 'SHIPPED' ? 'status-shipped' :
                                  order.orderStatus == 'COMPLETED' ? 'status-completed' : 'status-pending'}">
                                    ${order.orderStatus}
                            </span>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <h4 style="font-size: 0.9rem; color: #888; margin-bottom: 8px;">Items Ordered</h4>
                        <c:forEach var="item" items="${order.orderItems}">
                            <div class="item-row">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 30px; height: 30px; background: #eee; border-radius: 5px; overflow: hidden;">
                                        <img src="${pageContext.request.contextPath}${empty item.productImageUrl ? '/assets/images/product-placeholder.svg' : '/' += item.productImageUrl}"
                                             style="width: 100%; height: 100%; object-fit: cover;"
                                             onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
                                    </div>
                                    <span>${item.productName} <span style="color: #999;">x${item.quantity}</span></span>
                                </div>
                                <span style="font-weight: 600;">$${item.subtotal}</span>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="address-box">
                        <i class="ri-map-pin-user-fill address-icon"></i>
                        <div>
                            <div style="font-weight: 600; margin-bottom: 3px; color: var(--text-dark);">Shipping Address</div>
                            <div style="line-height: 1.4; word-break: break-all;">
                                    ${order.address}
                            </div>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 15px; padding-top: 15px; border-top: 1px solid #f0f0f0;">
                        <div>
                            <span style="color: #666; font-size: 0.9rem;">Total Earnings:</span>
                            <span style="font-size: 1.2rem; font-weight: 700; color: var(--primary);">
                                $${order.totalAmount}
                            </span>
                        </div>

                        <c:if test="${order.orderStatus == 'PAID'}">
                            <button type="button" class="btn-ship" onclick="openShipModal('${order.ordersId}')">
                                <i class="ri-truck-line"></i> Ship Order
                            </button>
                        </c:if>

                        <c:if test="${order.orderStatus == 'SHIPPED'}">
                            <div style="text-align:right;">
                                <span style="color: #0f5132; font-weight: 500; font-size: 0.9rem; display:block;">
                                    <i class="ri-check-line"></i> Shipped
                                </span>
                                <span style="font-size: 0.8rem; color: #666;">
                                    Tracking: ${order.trackingNumber}
                                </span>
                            </div>
                        </c:if>
                    </div>

                </div>
            </c:forEach>

        </div>
    </main>
</div>

<div id="shipModal" class="modal-overlay">
    <div class="modal-content">
        <h3 style="margin-bottom: 15px;">Ship Order</h3>
        <p style="margin-bottom: 20px; color: #666;">Enter tracking number to confirm shipment.</p>

        <%-- 【修改点2】 修复表单提交路径 --%>
        <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post">
            <input type="hidden" name="action" value="shipOrder">
            <input type="hidden" id="modalOrderId" name="orderId" value="">

            <div class="form-group">
                <label>Tracking Number</label>
                <input type="text" name="trackingNumber" class="form-control" placeholder="e.g. JNT-12345678" required>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeShipModal()">Cancel</button>
                <button type="submit" class="btn-confirm">Confirm Ship</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openShipModal(orderId) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('shipModal').style.display = 'flex';
    }

    function closeShipModal() {
        document.getElementById('shipModal').style.display = 'none';
    }

    // 点击背景关闭
    document.getElementById('shipModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeShipModal();
        }
    });
</script>

</body>
</html>