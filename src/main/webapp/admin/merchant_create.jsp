<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Create Merchant - PrimeGo Admin</title>
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap"
                rel="stylesheet">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: 'Poppins', sans-serif;
                }

                body {
                    background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #333;
                }

                .background-blob {
                    position: fixed;
                    border-radius: 50%;
                    z-index: -1;
                    opacity: 1;
                    filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
                }

                .blob-red {
                    width: 700px;
                    height: 700px;
                    top: -200px;
                    left: -200px;
                    background: linear-gradient(145deg, #ff5e55, #d92e25);
                }

                .container {
                    background: rgba(255, 255, 255, 0.85);
                    backdrop-filter: blur(20px);
                    padding: 40px;
                    border-radius: 20px;
                    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
                    width: 500px;
                    max-width: 90%;
                    border: 1px solid rgba(255, 255, 255, 0.6);
                }

                h1 {
                    color: #d63031;
                    margin-bottom: 30px;
                    text-align: center;
                    font-size: 1.8rem;
                }

                .form-group {
                    margin-bottom: 20px;
                }

                label {
                    display: block;
                    margin-bottom: 8px;
                    color: #555;
                    font-weight: 500;
                }

                input,
                textarea {
                    width: 100%;
                    padding: 12px 15px;
                    border-radius: 10px;
                    border: 1px solid rgba(0, 0, 0, 0.1);
                    background: rgba(255, 255, 255, 0.9);
                    outline: none;
                    transition: 0.3s;
                    font-size: 0.95rem;
                }

                input:focus,
                textarea:focus {
                    border-color: #d63031;
                    box-shadow: 0 0 0 3px rgba(214, 48, 49, 0.1);
                }

                .btn-submit {
                    width: 100%;
                    padding: 12px;
                    background: #d63031;
                    color: white;
                    border: none;
                    border-radius: 10px;
                    cursor: pointer;
                    font-weight: 600;
                    font-size: 1rem;
                    transition: 0.3s;
                    margin-top: 10px;
                }

                .btn-submit:hover {
                    background: #c0392b;
                    transform: translateY(-2px);
                    box-shadow: 0 5px 15px rgba(214, 48, 49, 0.3);
                }

                .btn-cancel {
                    display: block;
                    text-align: center;
                    margin-top: 15px;
                    color: #666;
                    text-decoration: none;
                    font-size: 0.9rem;
                }

                .btn-cancel:hover {
                    text-decoration: underline;
                }

                .error-msg {
                    background: #ffebee;
                    color: #c62828;
                    padding: 10px;
                    border-radius: 8px;
                    margin-bottom: 20px;
                    border: 1px solid #ffcdd2;
                    text-align: center;
                    font-size: 0.9rem;
                }
            </style>
        </head>

        <body>
            <div class="background-blob blob-red"></div>

            <div class="container">
                <h1>Create Merchant Account</h1>

                <c:if test="${not empty error}">
                    <div class="error-msg">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/admin/merchant/create" method="post">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" required>
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="password" required>
                    </div>

                    <div class="form-group">
                        <label>Contact Info</label>
                        <textarea name="contactInfo" rows="3" placeholder="Phone, Email, Address..."></textarea>
                    </div>

                    <button type="submit" class="btn-submit">Create Merchant</button>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-cancel">Cancel & Back to
                        Dashboard</a>
                </form>
            </div>
        </body>

        </html>