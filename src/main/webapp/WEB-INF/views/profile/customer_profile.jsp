<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Profile - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
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

        /* YELLOW BLOB - TURNED WHITE */
        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: #ffffff; /* Changed to White */
            box-shadow: none;
        }

        /* ORANGE BLOB - KEPT AS IS */
        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ffad33, #e68a00);
            box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
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

        h1 { margin-bottom: 20px; color: #e68a00; } /* Orange theme */
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
        <h1>Customer Profile</h1>
        <div class="profile-info">
            <p><strong>Username:</strong> ${sessionScope.user.username}</p>
            <c:if test="${not empty profile}">
                <p><strong>Full Name:</strong> ${profile.fullName}</p>
                <p><strong>Email:</strong> ${profile.email}</p>
                <p><strong>Phone:</strong> ${profile.phone}</p>
                <p><strong>Address:</strong> ${profile.address}</p>
            </c:if>
            <c:if test="${empty profile}">
                <p>No additional profile details found.</p>
            </c:if>
        </div>
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">Back to Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-back" style="background: #e68a00;">Logout</a>
    </div>
</body>
</html>
