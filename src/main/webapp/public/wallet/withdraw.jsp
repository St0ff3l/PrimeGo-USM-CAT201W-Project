<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="java.math.BigDecimal" %>

<%
    /* Authenticate user and ensure session is valid */
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    /* Retrieve current wallet balance for the authenticated user */
    WalletDAO dao = new WalletDAO();
    BigDecimal balance = dao.getBalance(user.getId());
    if (balance == null) balance = BigDecimal.ZERO;
    request.setAttribute("currentBalance", balance);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Withdraw Funds - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/images_uploader.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Poppins',sans-serif; }
        body { min-height:100vh; display:flex; justify-content:center; align-items:center; color:#333; position: relative; }

        .glass-panel {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 30px;
            padding: 50px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.08);
            width: 100%;
            max-width: 500px;
            position: relative;
            z-index: 10;
        }

        .back-row { margin-bottom: 20px; }
        .back-btn { display:inline-flex; align-items:center; justify-content:center; width:40px; height:40px; border-radius:50%; background:rgba(255,255,255,0.5); border:1px solid rgba(0,0,0,0.05); text-decoration:none; color:#666; font-size:1.1rem; transition:all .3s ease; }
        .back-btn:hover { width:110px; border-radius:20px; background:rgba(0,0,0,.05); color:#2d3436; }
        .back-text { max-width:0; opacity:0; margin-left:0; transition:all .3s ease; font-size:.9rem; font-weight:600; white-space:nowrap; overflow:hidden; }
        .back-btn:hover .back-text { max-width:100px; opacity:1; margin-left:8px; }

        h2 { margin-bottom: 30px; color: #2d3436; font-size: 1.8rem; text-align: center; font-weight: 700; }

        .balance-info { text-align: center; margin-bottom: 30px; padding: 25px; background: linear-gradient(135deg, #ffffff, #f8f9fa); border-radius: 20px; border: 1px solid rgba(255,255,255,0.8); box-shadow: 0 10px 30px rgba(0,0,0,0.03); }
        .balance-label { font-size: 0.85rem; color: #666; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; font-weight: 600; }
        .balance-amount { font-size: 2.2rem; font-weight: 800; color: #2d3436; letter-spacing: -1px; }

        .form-group { margin-bottom: 25px; }
        .form-label { display: block; margin-bottom: 10px; font-weight: 600; color: #444; font-size: 0.95rem; }
        .form-control { width: 100%; padding: 15px 20px; border-radius: 15px; border: 2px solid transparent; background: rgba(255,255,255,0.9); font-size: 1rem; transition: all 0.3s ease; box-shadow: 0 4px 15px rgba(0,0,0,0.02); }
        .form-control:focus { border-color: #6c5ce7; outline: none; background: #fff; box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.1); }

        .upload-container {
            width: 100%;
            height: 180px;
            border: 2px dashed #3498db; /* Signature border for the drop zone */
            border-radius: 20px;
            background: linear-gradient(180deg, rgba(235, 248, 255, 0.5) 0%, rgba(255, 255, 255, 0.8) 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            text-align: center;
        }

        .upload-container:hover {
            background: rgba(235, 248, 255, 0.8);
            border-color: #2980b9;
        }

        .upload-icon {
            font-size: 3rem;
            color: #3498db;
            margin-bottom: 10px;
        }

        .upload-text-main {
            font-size: 1rem;
            font-weight: 600;
            color: #555;
            margin-bottom: 5px;
        }

        .upload-text-sub {
            font-size: 0.85rem;
            color: #999;
        }

        /* Hide the native file input to utilize custom UI */
        input[type="file"] {
            display: none;
        }

        /* Display for the selected file's metadata */
        .file-name-display {
            font-weight: 700;
            color: #2ecc71;
            margin-top: 10px;
            display: none;
        }

        .btn-submit { width: 100%; padding: 16px; border-radius: 50px; border: none; background: linear-gradient(45deg, #3498db, #2980b9); color: white; font-size: 1.1rem; font-weight: 600; cursor: pointer; transition: all 0.3s ease; box-shadow: 0 10px 20px rgba(52, 152, 219, 0.3); margin-top: 10px; }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 15px 25px rgba(52, 152, 219, 0.4); }

        .error-msg { color: #e74c3c; font-size: 0.9rem; margin-top: 5px; display: none; font-weight: 500; }
    </style>
    <script>
        /* Validate the withdrawal request before submission */
        function validateForm() {
            var amount = parseFloat(document.getElementById("amount").value);
            var maxBalance = parseFloat("${currentBalance}");
            var errorDiv = document.getElementById("error-msg");

            /* Check for valid numeric input */
            if (isNaN(amount) || amount <= 0) {
                errorDiv.innerText = "Please enter a valid amount greater than 0.";
                errorDiv.style.display = "block";
                return false;
            }

            /* Ensure the amount does not exceed the available balance */
            if (amount > maxBalance) {
                errorDiv.innerText = "Withdrawal amount exceeds your available balance.";
                errorDiv.style.display = "block";
                return false;
            }
            return true;
        }

        function handleFileSelect(event) {
            const file = event.target.files[0];
            if (file) {
                // Clear the default placeholder UI
                document.getElementById('upload-placeholder').style.display = 'none';
                
                // Present the chosen file name to the user
                const display = document.getElementById('file-name-display');
                display.style.display = 'block';
                display.innerText = "Selected: " + file.name;
                
                // Update icon to reflect successful selection
                document.querySelector('.upload-icon').style.color = '#2ecc71';
                document.querySelector('.upload-icon').className = 'ri-checkbox-circle-line upload-icon';
            }
        }
    </script>
</head>
<body>

<c:choose>
    <c:when test="${sessionScope.user.role == 'MERCHANT'}">
        <jsp:include page="/common/background_merchant.jsp" />
    </c:when>
    <c:when test="${sessionScope.user.role == 'ADMIN'}">
        <jsp:include page="/common/background_admin.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/common/background_customer.jsp" />
    </c:otherwise>
</c:choose>

<div class="glass-panel">
    <div class="back-row">
        <a href="wallet.jsp" class="back-btn" title="Back to Wallet">
            <span>←</span><span class="back-text">Back</span>
        </a>
    </div>

    <h2>
        <c:choose>
            <c:when test="${sessionScope.user.role == 'MERCHANT'}">Withdraw Revenue</c:when>
            <c:otherwise>Withdraw Funds</c:otherwise>
        </c:choose>
    </h2>

    <div class="balance-info">
        <div class="balance-label">Available Balance</div>
        <div class="balance-amount">RM ${currentBalance}</div>
    </div>

    <c:if test="${not empty requestScope.error}">
        <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 15px; margin-bottom: 25px; text-align: center; font-size: 0.95rem; border: 1px solid #f5c6cb; display: flex; align-items: center; justify-content: center; gap: 8px;">
            <i class="ri-error-warning-line"></i> ${requestScope.error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/WithdrawServlet" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
        <div class="form-group">
            <label class="form-label">Amount (RM)</label>
            <input type="number" id="amount" name="amount" class="form-control" step="0.01" placeholder="e.g. 50.00" required>
            <div id="error-msg" class="error-msg"></div>
        </div>

        <div class="form-group">
            <label class="form-label">Upload QR Code (DuitNow / TnG)</label>
            <div id="qr-uploader"></div>
        </div>

        <button type="submit" class="btn-submit">Confirm Withdraw</button>
    </form>
</div>

<script src="${pageContext.request.contextPath}/assets/js/images_uploader.js"></script>
<script>
    // Initialize the specialized image uploader component
    new ImagesUploader('#qr-uploader', {
        inputName: 'receiptImage'
    });
</script>

</body>
</html>
