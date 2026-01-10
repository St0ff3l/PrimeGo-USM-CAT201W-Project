<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <style>
        /* Inherit basic styles from index.jsp */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
            color: #333;
        }

        /* Background Blobs - Same as Login/Index */
        .background-blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
            opacity: 1;
            filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        }

        .blob-red {
            width: 750px; height: 650px; top: -200px; left: -200px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ff5e55, #d92e25);
            box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
        }

        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: linear-gradient(145deg, #ffdb4d, #e6b800);
            box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
        }

        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ffad33, #e68a00);
            box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
        }

        /* Signup Card */
        .signup-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
            border: 1px solid rgba(255, 255, 255, 0.6);
            margin: 20px;
        }

        h2 { text-align: center; margin-bottom: 30px; color: #2d3436; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #636e72; font-weight: 600; }
        .form-group input {
            width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 10px;
            font-size: 1rem; transition: 0.3s;
        }
        .form-group input:focus { outline: none; border-color: #FF9500; box-shadow: 0 0 0 3px rgba(255, 149, 0, 0.1); }

        .btn-signup {
            width: 100%; padding: 12px; background: linear-gradient(45deg, #FF3B30, #FF9500);
            color: white; border: none; border-radius: 10px; font-size: 1.1rem; font-weight: 600;
            cursor: pointer; transition: 0.3s; margin-top: 10px;
        }
        .btn-signup:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 59, 48, 0.3); }

        .error-msg { color: #ff3b30; text-align: center; margin-bottom: 15px; font-size: 0.9rem; }
        .back-link { display: block; text-align: center; margin-top: 20px; color: #636e72; text-decoration: none; }
        .back-link:hover { color: #2d3436; }
    </style>
    <script>
        function validateForm() {
            var email = document.getElementById("email").value;
            var confirmEmail = document.getElementById("confirmEmail").value;
            var password = document.getElementById("password").value;
            var confirmPassword = document.getElementById("confirmPassword").value;

            if (email !== confirmEmail) {
                alert("Emails do not match!");
                return false;
            }
            if (password !== confirmPassword) {
                alert("Passwords do not match!");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="background-blob blob-red"></div>
    <div class="background-blob blob-yellow"></div>
    <div class="background-blob blob-orange"></div>

    <div class="signup-card">
        <h2>Create Account</h2>
        <c:if test="${not empty error}">
            <div class="error-msg">${error}</div>
        </c:if>
        <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required placeholder="Choose a username">
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required placeholder="Enter your email">
            </div>
            <div class="form-group">
                <label for="confirmEmail">Confirm Email</label>
                <input type="email" id="confirmEmail" name="confirmEmail" required placeholder="Re-enter your email">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required placeholder="Create a password">
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter your password">
            </div>

            <button type="submit" class="btn-signup">Sign Up</button>
        </form>
        <div style="text-align: center; margin-top: 15px;">
            <span style="color: #636e72;">Already have an account? </span>
            <a href="${pageContext.request.contextPath}/public/login.jsp" style="color: #FF9500; text-decoration: none; font-weight: 600;">Login</a>
        </div>
        <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">← Back to Home</a>
    </div>
</body>
</html>

