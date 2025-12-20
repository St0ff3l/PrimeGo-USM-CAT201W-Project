<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile - PrimeGo</title>
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

        /* Background Blobs - Admin Logic: Red Only, others White */
        .background-blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
            opacity: 1;
            filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        }

        /* RED BLOB - KEPT AS IS */
        .blob-red {
            width: 750px; height: 650px; top: -200px; left: -200px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ff5e55, #d92e25);
            box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
        }

        /* YELLOW BLOB - TURNED WHITE */
        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: #ffffff; /* Changed to White */
            /* Removed colored box-shadow, kept minimal or removed */
            box-shadow: none; 
        }

        /* ORANGE BLOB - TURNED WHITE */
        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: #ffffff; /* Changed to White */
            box-shadow: none;
        }

        /* Glass Panel */
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

        h1 { margin-bottom: 20px; color: #d63031; } /* Red theme for Admin text */
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
        <h1>Admin Profile</h1>
        <div class="profile-info">
            <p><strong>Username:</strong> ${sessionScope.user.username}</p>
            <c:if test="${not empty profile}">
                <p><strong>Department:</strong> ${profile.department}</p>
                <p><strong>Access Level:</strong> ${profile.level}</p>
            </c:if>
            <c:if test="${empty profile}">
                <p>No additional profile details found.</p>
            </c:if>
        </div>
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">Back to Home</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-back" style="background: #d63031;">Logout</a>
    </div>
</body>
</html>
