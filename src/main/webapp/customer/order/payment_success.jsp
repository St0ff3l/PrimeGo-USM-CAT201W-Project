<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ⭐ 获取 orderIds 参数 (可能是逗号分隔的字符串，如 "1001,1002")
    String orderIdsStr = request.getParameter("orderIds");

    // 兼容旧逻辑：如果没有 orderIds，尝试获取 orderId
    if (orderIdsStr == null || orderIdsStr.isEmpty()) {
        orderIdsStr = request.getParameter("orderId");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Success - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; height: 100vh; display: flex; align-items: center; justify-content: center; }

        .card {
            width: 450px; /* 稍微宽一点以容纳长订单号 */
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 30px;
            padding: 50px 30px;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
        }

        .icon-circle {
            width: 80px; height: 80px;
            background: #d1fae5; color: #10b981;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 40px; margin: 0 auto 20px;
        }

        h1 { margin-bottom: 10px; color: #2d3436; }
        p { color: #666; margin-bottom: 20px; line-height: 1.5; }

        .note {
            font-size: 0.85rem;
            color: #666;
            background: #eef2f7;
            padding: 12px;
            border-radius: 10px;
            margin-bottom: 30px;
            border-left: 4px solid #3498db;
            text-align: left;
        }

        .btn { display: block; width: 100%; padding: 15px; border-radius: 15px; text-decoration: none; font-weight: 600; margin-bottom: 10px; transition: 0.2s; }

        .btn-primary {
            background: linear-gradient(45deg, #10b981, #34d399);
            color: white;
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.3);
        }
        .btn-primary:hover { transform: translateY(-2px); }

        .btn-outline { border: 2px solid #ccc; color: #555; }
        .btn-outline:hover { background: rgba(255,255,255,0.5); }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>

<div class="card">
    <div class="icon-circle">✓</div>
    <h1>Payment Successful!</h1>

    <p>
        <% if (orderIdsStr != null && orderIdsStr.contains(",")) { %>
        The following orders have been placed successfully:<br>
        <strong style="font-size: 1.1rem; color: #2d3436;">#<%= orderIdsStr.replace(",", ", #") %></strong>
        <% } else if (orderIdsStr != null) { %>
        Order <strong>#<%= orderIdsStr %></strong> has been placed successfully.
        <% } else { %>
        Your order has been placed successfully.
        <% } %>
        <br>The sellers will process your items shortly.
    </p>

    <% if (orderIdsStr != null && orderIdsStr.contains(",")) { %>
    <div class="note">
        <div style="font-weight: 600; margin-bottom: 4px; color:#333;">
            <i class="ri-information-fill" style="color:#3498db;"></i> Multiple Shipments
        </div>
        Since you purchased items from different merchants, your order has been split into separate shipments automatically.
    </div>
    <% } %>

    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Continue Shopping</a>

    <a href="${pageContext.request.contextPath}/customer/orders?status=ALL" class="btn btn-outline">View My Orders</a>
</div>

</body>
</html>