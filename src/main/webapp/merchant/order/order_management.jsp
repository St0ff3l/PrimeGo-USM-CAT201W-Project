<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="com.primego.order.model.Order" %>
<%@ page import="com.primego.order.model.OrderItem" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // 权限检查
    User user = (User) session.getAttribute("user");
    if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    // 统计数字
    int toShipCount = 0;
    int shippedCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;
    int returnCount = 0; // ⭐ 新增：售后/退款单数量

    List<Order> ordersForCount = (List<Order>) request.getAttribute("orders");
    request.setAttribute("orders", ordersForCount);

    if (ordersForCount != null) {
        for (Order o : ordersForCount) {
            String st = o.getOrderStatus();
            if ("PAID".equalsIgnoreCase(st)) {
                toShipCount++;
            } else if ("SHIPPED".equalsIgnoreCase(st)) {
                shippedCount++;
            } else if ("COMPLETED".equalsIgnoreCase(st)) {
                completedCount++;
            } else if ("CANCELLED".equalsIgnoreCase(st)) {
                cancelledCount++;
            } else if ("RETURN_REQUESTED".equalsIgnoreCase(st) || "REFUNDED".equalsIgnoreCase(st)) {
                // ⭐ 新增：统计售后单
                returnCount++;
            }
        }
    }

    String initialFilter = request.getParameter("filter");
    if (initialFilter == null || initialFilter.trim().isEmpty()) {
        initialFilter = "all";
    } else {
        initialFilter = initialFilter.trim().toLowerCase();
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
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --card-radius: 16px;
            --danger: #e74c3c;
            --success: #2ecc71;
            --warning: #f1c40f;
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

        .main-content { display: flex; flex-direction: column; gap: 25px; }

        .glass-panel {
            background: rgba(255, 255, 255, 0.55);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            border-radius: var(--card-radius);
            padding: 25px;
        }

        .order-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 5px solid var(--primary);
            box-shadow: 0 4px 10px rgba(0,0,0,0.03);
            transition: transform 0.2s;
        }
        /* ⭐ 不同状态给不同颜色的边框，增强识别度 */
        .order-card[data-status="RETURN_REQUESTED"] { border-left-color: var(--danger); }
        .order-card[data-status="REFUNDED"] { border-left-color: var(--text-gray); }

        .order-card:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); }

        .order-header { display: flex; justify-content: space-between; border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; }
        .order-id { font-weight: 700; font-size: 1.1rem; color: var(--text-dark); }
        .order-date { font-size: 0.85rem; color: var(--text-gray); }

        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 600; }
        .status-paid { background: #fff3cd; color: #856404; }
        .status-shipped { background: #d1e7dd; color: #0f5132; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-pending { background: #f8d7da; color: #721c24; }
        .status-cancelled { background: #e2e3e5; color: #41464b; }
        /* ⭐ 新增状态样式 */
        .status-return { background: #ffeaa7; color: #d35400; }
        .status-refunded { background: #fab1a0; color: #c0392b; }

        .address-box {
            background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 15px 0;
            font-size: 0.9rem; color: #444; display: flex; gap: 10px; align-items: flex-start;
        }
        .address-icon { color: var(--primary); font-size: 1.2rem; margin-top: 2px; }

        .btn-ship {
            background: var(--text-dark); color: white; border: none; padding: 10px 20px;
            border-radius: 8px; cursor: pointer; font-weight: 600; display: flex; align-items: center; gap: 5px; transition: 0.3s;
        }
        .btn-ship:hover { background: var(--primary); transform: translateY(-2px); }

        /* ⭐ 处理退款按钮 */
        .btn-handle-refund {
            background: white; border: 1px solid var(--danger); color: var(--danger);
            padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600;
            display: flex; align-items: center; gap: 5px; transition: 0.3s;
        }
        .btn-handle-refund:hover { background: var(--danger); color: white; }

        .item-row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 0.95rem; border-bottom: 1px dashed #eee; }
        .item-row:last-child { border-bottom: none; }

        /* Modal Styles */
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;
        }
        .modal-content {
            background: white; padding: 30px; border-radius: 16px; width: 450px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2); animation: popIn 0.3s ease;
        }
        @keyframes popIn { from { transform: scale(0.8); opacity: 0; } to { transform: scale(1); opacity: 1; } }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; color: #333; }
        .form-control { width: 100%; padding: 10px; border: 2px solid #eee; border-radius: 8px; font-size: 1rem; }
        .form-textarea { width: 100%; padding: 10px; border: 2px solid #eee; border-radius: 8px; font-size: 0.95rem; resize: vertical; min-height: 80px;}

        .modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
        .btn-cancel { background: #eee; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
        .btn-confirm { background: var(--primary); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }

        .btn-approve { background: var(--success); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }
        .btn-reject { background: var(--danger); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; font-weight: 600; }

        .metrics-bar {
            display: grid;
            /* ⭐ 自动适应宽度，适配增加的按钮 */
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 14px; margin: 0 0 20px 0;
        }
        .metric-card {
            background: white; border-radius: 14px; padding: 14px 16px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.03); border: 1px solid #f1f2f6; cursor: pointer;
            transition: all 0.2s ease; user-select: none;
        }
        .metric-card:hover { transform: translateY(-2px); border-color: rgba(255,149,0,0.15); }
        .metric-card.active { border-color: rgba(255,149,0,0.8); box-shadow: 0 10px 24px rgba(255,149,0,0.18); }
        .metric-val { font-size: 1.6rem; font-weight: 800; color: var(--text-dark); line-height: 1.1; }
        .metric-label { font-size: 0.9rem; color: var(--text-gray); margin-top: 4px; }
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
            </div>

            <div class="metrics-bar" id="orderMetrics">
                <div class="metric-card active" data-filter="all" role="button" tabindex="0">
                    <%
                        int allNonPendingCount = 0;
                        if (ordersForCount != null) {
                            for (Order o : ordersForCount) {
                                String st = o.getOrderStatus();
                                if (st != null && !"PENDING".equalsIgnoreCase(st)) {
                                    allNonPendingCount++;
                                }
                            }
                        }
                    %>
                    <div class="metric-val"><%= allNonPendingCount %></div>
                    <div class="metric-label">All Orders</div>
                </div>
                <div class="metric-card" data-filter="to_ship" role="button" tabindex="0">
                    <div class="metric-val"><%= toShipCount %></div>
                    <div class="metric-label">To Ship</div>
                </div>
                <div class="metric-card" data-filter="shipped" role="button" tabindex="0">
                    <div class="metric-val"><%= shippedCount %></div>
                    <div class="metric-label">Shipped</div>
                </div>
                <div class="metric-card" data-filter="completed" role="button" tabindex="0">
                    <div class="metric-val"><%= completedCount %></div>
                    <div class="metric-label">Completed</div>
                </div>
                <div class="metric-card" data-filter="return" role="button" tabindex="0">
                    <div class="metric-val" style="color: <%= returnCount > 0 ? "#e74c3c" : "inherit" %>"><%= returnCount %></div>
                    <div class="metric-label">Returns</div>
                </div>
                <div class="metric-card" data-filter="cancelled" role="button" tabindex="0">
                    <div class="metric-val"><%= cancelledCount %></div>
                    <div class="metric-label">Cancelled</div>
                </div>
            </div>

            <c:if test="${empty orders}">
                <div style="text-align: center; padding: 50px; color: #999;">
                    <i class="ri-inbox-line" style="font-size: 3rem; margin-bottom: 10px; display: block;"></i>
                    No orders found.
                </div>
            </c:if>

            <c:forEach var="order" items="${orders}">
                <div class="order-card" data-status="${order.orderStatus}">

                    <div class="order-header">
                        <div>
                            <div class="order-id">Order #${order.ordersId}</div>
                            <div class="order-date"><i class="ri-time-line"></i> ${order.createdAt}</div>
                        </div>
                        <div>
                            <span class="status-badge
                                ${order.orderStatus == 'PAID' ? 'status-paid' :
                                  order.orderStatus == 'SHIPPED' ? 'status-shipped' :
                                  order.orderStatus == 'COMPLETED' ? 'status-completed' :
                                  order.orderStatus == 'RETURN_REQUESTED' ? 'status-return' :
                                  order.orderStatus == 'REFUNDED' ? 'status-refunded' :
                                  order.orderStatus == 'CANCELLED' ? 'status-cancelled' : 'status-pending'}">
                                    ${order.orderStatus.replace('_', ' ')}
                            </span>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <c:forEach var="item" items="${order.orderItems}">
                            <div class="item-row">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 30px; height: 30px; background: #eee; border-radius: 5px; overflow: hidden;">
                                        <img src="${pageContext.request.contextPath}/${not empty item.productImageUrl ? item.productImageUrl : 'assets/images/product-placeholder.svg'}"
                                             style="width: 100%; height: 100%; object-fit: cover;"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/product-placeholder.svg'">
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
                            <div style="font-weight: 600; margin-bottom: 3px;">Shipping Address</div>
                            <div style="line-height: 1.4;">${order.address}</div>
                        </div>
                    </div>

                        <%-- ⭐ 如果用户填写了退款理由，在这里显示一下，方便快速查看 --%>
                    <c:if test="${not empty order.refundReason}">
                        <div style="background: #fff3cd; color: #856404; padding: 10px; border-radius: 8px; font-size: 0.9rem; margin-bottom: 15px;">
                            <strong>Customer's Reason:</strong> ${order.refundReason}
                        </div>
                    </c:if>

                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 15px; padding-top: 15px; border-top: 1px solid #f0f0f0;">
                        <div>
                            <span style="color: #666; font-size: 0.9rem;">Total:</span>
                            <span style="font-size: 1.2rem; font-weight: 700; color: var(--primary);">$${order.totalAmount}</span>
                        </div>

                            <%-- 发货按钮 --%>
                        <c:if test="${order.orderStatus == 'PAID'}">
                            <button type="button" class="btn-ship" onclick="openShipModal('${order.ordersId}')">
                                <i class="ri-truck-line"></i> Ship Order
                            </button>
                        </c:if>

                            <%-- ⭐ 处理售后按钮 --%>
                        <c:if test="${order.orderStatus == 'RETURN_REQUESTED'}">
                            <button type="button" class="btn-handle-refund"
                                    onclick="openRefundModal('${order.ordersId}', '${order.refundReason != null ? order.refundReason.replace('\'', '\\\'') : ''}')">
                                <i class="ri-customer-service-2-line"></i> Handle Refund
                            </button>
                        </c:if>

                        <c:if test="${order.orderStatus == 'SHIPPED'}">
                            <div style="text-align:right;">
                                <span style="color: #0f5132; font-weight: 500; font-size: 0.9rem;"><i class="ri-check-line"></i> Shipped</span>
                                <div style="font-size: 0.8rem; color: #666;">Trk: ${order.trackingNumber}</div>
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
        <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post">
            <input type="hidden" name="action" value="shipOrder">
            <input type="hidden" id="shipModalOrderId" name="orderId" value="">
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

<div id="refundModal" class="modal-overlay">
    <div class="modal-content" style="width: 500px;">
        <h3 style="margin-bottom: 10px; color: #d35400;">Handle Refund Request</h3>

        <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post" id="refundForm">
            <input type="hidden" name="action" value="processRefund">
            <input type="hidden" id="refundModalOrderId" name="orderId" value="">
            <input type="hidden" id="refundDecision" name="decision" value=""> <%-- approve or reject --%>

            <div class="form-group">
                <label style="color: #666;">Customer's Reason:</label>
                <div id="displayCustomerReason" style="background: #f8f9fa; padding: 10px; border-radius: 8px; font-style: italic; color: #555;">
                </div>
            </div>

            <div class="form-group">
                <label>Your Response / Rejection Reason</label>
                <textarea name="merchantReason" id="merchantReason" class="form-textarea" placeholder="If rejecting, please explain why (e.g. item damaged by user)..."></textarea>
            </div>

            <div class="modal-actions" style="justify-content: space-between;">
                <button type="button" class="btn-cancel" onclick="closeRefundModal()">Cancel</button>
                <div style="display: flex; gap: 10px;">
                    <button type="button" class="btn-reject" onclick="submitRefund('reject')">Reject</button>
                    <button type="button" class="btn-approve" onclick="submitRefund('approve')">Approve Refund</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    // --- Ship Modal ---
    function openShipModal(orderId) {
        document.getElementById('shipModalOrderId').value = orderId;
        document.getElementById('shipModal').style.display = 'flex';
    }
    function closeShipModal() {
        document.getElementById('shipModal').style.display = 'none';
    }

    // --- ⭐ Refund Modal ---
    function openRefundModal(orderId, customerReason) {
        document.getElementById('refundModalOrderId').value = orderId;
        document.getElementById('displayCustomerReason').innerText = customerReason || "No specific reason provided.";
        document.getElementById('merchantReason').value = ""; // clear previous input
        document.getElementById('refundModal').style.display = 'flex';
    }

    function closeRefundModal() {
        document.getElementById('refundModal').style.display = 'none';
    }

    function submitRefund(decision) {
        document.getElementById('refundDecision').value = decision;

        // 简单的客户端校验
        if (decision === 'reject') {
            const reason = document.getElementById('merchantReason').value.trim();
            if (!reason) {
                alert("Please provide a reason for rejection.");
                return;
            }
        }

        if (confirm("Are you sure you want to " + decision.toUpperCase() + " this refund?")) {
            document.getElementById('refundForm').submit();
        }
    }

    // --- Filtering Logic ---
    function setActiveMetric(filter) {
        document.querySelectorAll('#orderMetrics .metric-card').forEach(card => {
            card.classList.toggle('active', card.getAttribute('data-filter') === filter);
        });
    }

    function applyOrderFilter(filter) {
        const cards = document.querySelectorAll('.order-card');
        cards.forEach(card => {
            const st = (card.getAttribute('data-status') || '').toUpperCase();

            // 默认隐藏 PENDING
            if (st === 'PENDING') {
                card.style.display = 'none';
                return;
            }

            let show = true;
            if (filter === 'all') show = true;
            else if (filter === 'to_ship') show = (st === 'PAID');
            else if (filter === 'shipped') show = (st === 'SHIPPED');
            else if (filter === 'completed') show = (st === 'COMPLETED');
            else if (filter === 'cancelled') show = (st === 'CANCELLED');
            // ⭐ return 过滤器：显示申请中 OR 已退款
            else if (filter === 'return') show = (st === 'RETURN_REQUESTED' || st === 'REFUNDED');

            card.style.display = show ? 'block' : 'none';
        });
    }

    document.querySelectorAll('#orderMetrics .metric-card').forEach(card => {
        const filter = card.getAttribute('data-filter');
        card.addEventListener('click', () => {
            setActiveMetric(filter);
            applyOrderFilter(filter);
            // Optional: Update URL without reload to keep state on refresh
            const url = new URL(window.location);
            url.searchParams.set('filter', filter);
            window.history.pushState({}, '', url);
        });
    });

    // Close modals on outside click
    window.onclick = function(event) {
        if (event.target.classList.contains('modal-overlay')) {
            event.target.style.display = "none";
        }
    }

    // Initial Load
    const INITIAL_FILTER = '<%= initialFilter %>';
    setActiveMetric(INITIAL_FILTER);
    applyOrderFilter(INITIAL_FILTER);
</script>

</body>
</html>