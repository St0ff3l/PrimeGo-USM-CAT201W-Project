<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Success - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; height: 100vh; display: flex; align-items: center; justify-content: center; }

        .card {
            width: 400px;
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
        p { color: #666; margin-bottom: 30px; }

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
    <p>Your order has been placed. The seller will contact you shortly.</p>

    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-primary">Continue Shopping</a>

    <a href="${pageContext.request.contextPath}/profile?tab=orders" class="btn btn-outline">View Order</a>
</div>

</body>
</html>