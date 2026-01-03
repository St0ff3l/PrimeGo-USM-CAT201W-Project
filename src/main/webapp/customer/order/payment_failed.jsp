<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Failed - PrimeGo</title>
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

        /* 红色图标样式 */
        .icon-circle {
            width: 80px; height: 80px;
            background: #fee2e2; color: #ef4444; /* 红色背景和图标 */
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 40px; margin: 0 auto 20px;
        }

        h1 { margin-bottom: 10px; color: #2d3436; }
        p { color: #666; margin-bottom: 30px; }

        .btn { display: block; width: 100%; padding: 15px; border-radius: 15px; text-decoration: none; font-weight: 600; margin-bottom: 10px; transition: 0.2s; }

        /* 红色按钮渐变 */
        .btn-primary {
            background: linear-gradient(45deg, #ef4444, #f87171);
            color: white;
            box-shadow: 0 5px 15px rgba(239, 68, 68, 0.3);
        }
        .btn-primary:hover { transform: translateY(-2px); }

        .btn-outline { border: 2px solid #ccc; color: #555; }
        .btn-outline:hover { background: rgba(255,255,255,0.5); }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>

<div class="card">
    <div class="icon-circle">✕</div> <h1>Payment Failed</h1>
    <p>Something went wrong with your order processing. Please try again.</p>

    <a href="<%= request.getContextPath() %>/customer/order/order_confirmation.jsp" class="btn btn-primary">Try Again</a>
    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline">Back to Home</a>
</div>

</body>
</html>