<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Merchant Profile - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <style>
        /* Inherit basic styles */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
            color: #333;
        }

        .background-blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
            opacity: 1;
            filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        }

        /* RED BLOB - TURNED WHITE */
        .blob-red {
            width: 750px; height: 650px; top: -200px; left: -200px;
            transform: rotate(-10deg);
            background: #ffffff; /* Changed to White */
            box-shadow: none;
        }

        /* YELLOW BLOB - KEPT AS IS */
        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: linear-gradient(145deg, #ffdb4d, #e6b800);
            box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
        }

        /* ORANGE BLOB - TURNED WHITE */
        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: #ffffff; /* Changed to White */
            box-shadow: none;
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 800px;
            margin: 100px auto;
        }

        h1 { margin-bottom: 20px; color: #e6b800; } /* Yellow/Gold theme */
        .profile-info p { margin-bottom: 15px; font-size: 1.1rem; }
        .btn-back {
            display: inline-block; padding: 10px 20px; background: #333; color: white;
            text-decoration: none; border-radius: 20px; margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="background-blob blob-red"></div>
    <div class="background-blob blob-yellow"></div>
    <div class="background-blob blob-orange"></div>

    <div class="glass-panel">
        <h1>Merchant Profile</h1>
        <div class="profile-info">
            <p><strong>Username:</strong> ${sessionScope.user.username}</p>
            <c:if test="${not empty profile}">
                <p><strong>Store Name:</strong> ${profile.storeName}</p>
                <p><strong>Business License:</strong> ${profile.businessLicense}</p>
                <p><strong>Contact Info:</strong> ${profile.contactInfo}</p>
            </c:if>
            <c:if test="${empty profile}">
                <p>No additional profile details found.</p>
            </c:if>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn-back" style="background: #e6b800;">Logout</a>
    </div>
</body>
</html>
