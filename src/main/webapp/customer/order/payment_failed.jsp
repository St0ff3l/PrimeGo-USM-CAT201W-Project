<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String errorMsg = (String) request.getAttribute("errorMessage");
    if (errorMsg == null || errorMsg.isEmpty()) {
        errorMsg = "Something went wrong with your order processing. Please try again.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Payment Failed - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; height: 100vh; display: flex; align-items: center; justify-content: center; overflow: hidden;}

        .card {
            width: 400px;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 30px;
            padding: 50px 30px;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            z-index: 10;
        }

        .icon-circle {
            width: 80px; height: 80px;
            background: #fee2e2; color: #ef4444;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 40px; margin: 0 auto 20px;
        }

        h1 { margin-bottom: 10px; color: #2d3436; font-size: 24px; }
        p { color: #666; margin-bottom: 30px; font-size: 14px; line-height: 1.6; }

        .btn { display: block; width: 100%; padding: 15px; border-radius: 15px; text-decoration: none; font-weight: 600; margin-bottom: 15px; transition: 0.3s; cursor: pointer;}

        .btn-primary {
            background: linear-gradient(45deg, #ef4444, #f87171);
            color: white;
            box-shadow: 0 5px 15px rgba(239, 68, 68, 0.3);
            border: none;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(239, 68, 68, 0.4); }

        .btn-outline { border: 2px solid #ccc; color: #555; background: transparent; }
        .btn-outline:hover { background: rgba(255,255,255,0.8); border-color: #bbb; color: #333; }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>

<div class="card">
    <div class="icon-circle">✕</div>

    <h1>Payment Failed</h1>
    <p><%= errorMsg %></p>

    <a href="javascript:history.back()" class="btn btn-primary">Try Again</a>

    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline">Back to Home</a>
</div>

</body>
</html>