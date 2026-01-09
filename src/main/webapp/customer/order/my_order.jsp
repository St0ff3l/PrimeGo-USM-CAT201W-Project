<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Orders - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_profile.css">

    <style>
        /* Modal Styles for Refund */
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

        .modal-overlay.active {
            display: flex;
        }

        .modal-box {
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 20px;
            width: 450px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.8);
        }

        .form-textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 12px;
            margin: 10px 0;
            font-family: inherit;
            resize: vertical;
            background: rgba(255, 255, 255, 0.9);
        }

        .btn-submit-refund {
            background: #e74c3c;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            width: 100%;
            transition: 0.3s;
        }
        .btn-submit-refund:hover {
            background: #c0392b;
        }
    </style>
</head>

<body>
<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>

<jsp:include page="/common/layout/customer_profile_sidebar.jsp">
    <jsp:param name="active" value="orders" />
</jsp:include>

<div class="main-content">
    <div class="header-section">
        <h1>Order History</h1>
    </div>

    <c:if test="${not empty sessionScope.message}">
        <div style="padding: 15px; border-radius: 10px; margin-bottom: 20px;
            ${sessionScope.messageType == 'success' ? 'background: #d4edda; color: #155724;' : 'background: #f8d7da; color: #721c24;'}">
                ${sessionScope.message}
        </div>
        <c:remove var="message" scope="session" />
        <c:remove var="messageType" scope="session" />
    </c:if>

    <div class="order-tabs">
        <a href="${pageContext.request.contextPath}/customer/orders?status=ALL" class="order-tab ${param.status == 'ALL' || param.status == null ? 'active' : ''}">All</a>
        <a href="${pageContext.request.contextPath}/customer/orders?status=PAID" class="order-tab ${param.status == 'PAID' ? 'active' : ''}">To Ship</a>
        <a href="${pageContext.request.contextPath}/customer/orders?status=SHIPPED" class="order-tab ${param.status == 'SHIPPED' ? 'active' : ''}">To Receive</a>
        <a href="${pageContext.request.contextPath}/customer/orders?status=COMPLETED" class="order-tab ${param.status == 'COMPLETED' ? 'active' : ''}">Completed</a>
        <a href="${pageContext.request.contextPath}/customer/orders?status=RETURN_REQUESTED" class="order-tab ${param.status == 'RETURN_REQUESTED' ? 'active' : ''}">Returns</a>
        <a href="${pageContext.request.contextPath}/customer/orders?status=CANCELLED" class="order-tab ${param.status == 'CANCELLED' ? 'active' : ''}">Cancelled</a>
    </div>

    <c:choose>
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

        <c:otherwise>
            <div style="display: flex; flex-direction: column; gap: 20px;">
                <c:forEach var="order" items="${orderList}">

                    <%-- 7-Day Return Logic Calculation (SHIPPED only) --%>
                    <%
                        com.primego.order.model.Order currentOrder = (com.primego.order.model.Order) pageContext.getAttribute("order");
                        boolean canReturn = false;
                        if ("SHIPPED".equals(currentOrder.getOrderStatus())) {
                            long now = new Date().getTime();
                            long baseTime = (currentOrder.getCreatedAt() != null) ? currentOrder.getCreatedAt().getTime() : now;
                            long diffDays = (now - baseTime) / (1000 * 60 * 60 * 24);
                            if (diffDays <= 7) {
                                canReturn = true;
                            }
                        }
                        request.setAttribute("canReturn", canReturn);
                    %>

                    <div class="glass-panel" style="padding: 25px; border-left: 5px solid #e68a00;">
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px; border-bottom: 1px solid rgba(0,0,0,0.05); padding-bottom: 10px;">
                            <div>
                                <h3 style="color: #2d3436; font-size: 1.1rem;">Order #${order.ordersId}</h3>
                                <span style="font-size: 0.85rem; color: #888;">Placed on: ${order.createdAt}</span>
                            </div>
                            <div style="text-align: right;">
                                <span style="padding: 5px 12px; border-radius: 15px; font-size: 0.8rem; font-weight: 600;
                                    ${order.orderStatus == 'COMPLETED' ? 'background: #d4edda; color: #155724;' :
                                      order.orderStatus == 'PENDING' ? 'background: #fff3cd; color: #856404;' :
                                      order.orderStatus == 'SHIPPED' ? 'background: #dbeafe; color: #1e40af;' :
                                      order.orderStatus == 'RETURN_REQUESTED' ? 'background: #ffeaa7; color: #d35400;' :
                                      order.orderStatus == 'REFUNDED' ? 'background: #fab1a0; color: #c0392b;' :
                                      order.orderStatus == 'CANCELLED' ? 'background: #f8d7da; color: #721c24;' :
                                      'background: #e2e3e5; color: #383d41;'}">
                                        ${order.orderStatus.replace('_', ' ')}
                                </span>

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

                                    <div style="font-weight: 600; color: #e68a00;">$${item.subtotal}</div>
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
                                <div style="font-size: 1.3rem; color: #e68a00; font-weight: bold; margin-bottom: 10px;">$${order.totalAmount}</div>

                                <div style="display: flex; gap: 10px; justify-content: flex-end">

                                    <%-- PAID -> CANCELLED --%>
                                    <c:if test="${order.orderStatus == 'PAID'}">
                                        <form action="${pageContext.request.contextPath}/customer/orders" method="post">
                                            <input type="hidden" name="action" value="cancelOrder">
                                            <input type="hidden" name="orderId" value="${order.ordersId}">
                                            <input type="hidden" name="status" value="${param.status}">
                                            <button type="submit"
                                                    onclick="return confirm('Cancel this order?')"
                                                    style="background: transparent; border: 1px solid #ff6b6b; color: #ff6b6b; padding: 8px 15px; border-radius: 10px; cursor: pointer; font-weight: 600;">
                                                <i class="ri-close-circle-line"></i> Cancel Order
                                            </button>
                                        </form>
                                    </c:if>

                                    <%-- SHIPPED -> RETURN_REQUESTED (7 days) --%>
                                    <c:if test="${canReturn}">
                                        <button onclick="openRefundModal('${order.ordersId}')"
                                                style="background: transparent; border: 1px solid #e74c3c; color: #e74c3c; padding: 8px 15px; border-radius: 10px; cursor: pointer; font-weight: 600;">
                                            <i class="ri-refund-line"></i> Return (7 Days)
                                        </button>
                                    </c:if>

                                    <%-- SHIPPED -> COMPLETED --%>
                                    <c:if test="${order.orderStatus == 'SHIPPED'}">
                                        <form action="${pageContext.request.contextPath}/customer/orders" method="post">
                                            <input type="hidden" name="action" value="confirmReceipt">
                                            <input type="hidden" name="orderId" value="${order.ordersId}">
                                            <input type="hidden" name="status" value="${param.status}">
                                            <button type="submit"
                                                    onclick="return confirm('Confirm that you have received the order?')"
                                                    style="background: #2d3436; color: white; border: none; padding: 8px 15px; border-radius: 10px; cursor: pointer; font-size: 0.85rem; font-weight: 600; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                                                <i class="ri-check-double-line"></i> Confirm Receipt
                                            </button>
                                        </form>
                                    </c:if>

                                    <%-- RETURN_REQUESTED state --%>
                                    <c:if test="${order.orderStatus == 'RETURN_REQUESTED'}">
                                        <button disabled style="background: #eee; color: #888; border: none; padding: 8px 15px; border-radius: 10px; cursor: not-allowed; font-size: 0.85rem;">
                                            <i class="ri-time-line"></i> Wait for Approval
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="modal-overlay" id="refundModal">
    <div class="modal-box">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h3 style="color: #2d3436;">Request Refund</h3>
            <button onclick="closeRefundModal()" style="background:none; border:none; font-size:1.5rem; cursor:pointer; color: #666;">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/customer/orders" method="post">
            <input type="hidden" name="action" value="processRefundRequest">
            <input type="hidden" name="orderId" id="refundOrderId">
            <input type="hidden" name="status" value="${param.status}">

            <label style="font-size: 0.9rem; color: #666; font-weight: 500;">Return Reason (Optional):</label>
            <textarea name="reason" class="form-textarea" rows="4" placeholder="e.g. Item not as described..."></textarea>

            <div style="background: #fff3cd; color: #856404; padding: 10px; border-radius: 8px; font-size: 0.8rem; margin-bottom: 20px;">
                <i class="ri-information-fill"></i> This return request is allowed within 7 days of shipping.
            </div>

            <button type="submit" class="btn-submit-refund">Submit Request</button>
        </form>
    </div>
</div>

<script>
    function openRefundModal(orderId) {
        document.getElementById('refundOrderId').value = orderId;
        document.getElementById('refundModal').classList.add('active');
    }
    function closeRefundModal() {
        document.getElementById('refundModal').classList.remove('active');
    }

    // Close modal if clicked outside
    window.onclick = function(event) {
        var modal = document.getElementById('refundModal');
        if (event.target == modal) {
            closeRefundModal();
        }
    }
</script>

</body>
</html>
