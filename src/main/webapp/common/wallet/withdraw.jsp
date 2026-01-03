<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.math.BigDecimal" %>

<%
    // 在页面加载时查询一次真实余额
    User user = (User) session.getAttribute("user");
    if (user != null) {
        WalletDAO dao = new WalletDAO();
        BigDecimal balance = dao.getBalance(user.getId());
        request.setAttribute("currentBalance", balance);
    } else {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>USM SHOP - Withdraw</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <!-- 图标库 -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        /* ===== 全局样式 ===== */
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Poppins',sans-serif; }
        body{ background: linear-gradient(to bottom, #f0f2f5, #e0e5ec); min-height:100vh; overflow-x:hidden; position:relative; color:#333; }

        .glass-panel{
            background: rgba(255,255,255,0.72);
            backdrop-filter: blur(22px);
            border: 1px solid rgba(255,255,255,0.65);
            border-radius: 24px;
            box-shadow: 0 10px 35px rgba(0,0,0,0.10), inset 0 0 0 1px rgba(255,255,255,0.5);
        }

        .page{ max-width:1200px; margin:110px auto 60px; padding:0 20px; }
        .top-bar{ display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; }
        .back-btn{
            display:inline-flex; gap:8px; align-items:center; text-decoration:none; font-weight:600; color:#444;
            padding:10px 16px; border-radius:999px; background: rgba(255,255,255,0.85);
            border: 1px solid rgba(255,255,255,0.9); transition:.25s;
        }
        .back-btn:hover{ transform: translateX(-4px); }
        .title{ font-size:1.8rem; font-weight:800; color:#2d3436; }

        .board{ padding:34px; display:grid; grid-template-columns: 2fr 1fr; gap:20px; }

        .badge{
            display:inline-block; padding:10px 14px; border-radius:14px;
            background: rgba(231,76,60,0.12); border: 1px solid rgba(231,76,60,0.2);
            color:#c0392b; font-weight:900; margin-bottom:10px;
        }

        label{ display:block; margin:10px 0 6px; font-weight:700; color:#555; font-size:.92rem; }
        input, select{
            width:100%; padding:12px 14px; border-radius:14px; border: 1px solid rgba(0,0,0,0.12);
            background: rgba(255,255,255,0.85); outline:none; font-size:1rem;
        }
        input:focus, select:focus{ border-color: rgba(231,76,60,0.55); box-shadow: 0 0 0 3px rgba(231,76,60,0.12); }

        .btn-submit{
            margin-top:16px; width:100%; padding:14px 18px; border:none; border-radius:16px; cursor:pointer;
            font-weight:900; font-size:1.05rem; color:#fff;
            background: linear-gradient(135deg,#ff4757,#ff6b81);
            box-shadow: 0 12px 22px rgba(255,71,87,0.22); transition:.25s;
        }
        .btn-submit:hover{ transform: translateY(-3px); }

        .hint{ padding:18px; border-radius:18px; background: rgba(255,255,255,0.65); border: 1px solid rgba(0,0,0,0.04); color:#666; font-size:.92rem; line-height:1.6; }
        @media (max-width:900px){ .board{ grid-template-columns: 1fr; } }
    </style>
</head>

<body>
<!-- 根据用户角色加载背景 -->
<jsp:include page="/common/background_customer.jsp" />

<div class="page">
    <div class="top-bar">
        <a class="back-btn" href="wallet.jsp">← Back</a>
        <div class="title">Withdraw</div>
        <div style="width:80px"></div>
    </div>

    <!-- 错误提示 -->
    <c:if test="${not empty requestScope.error}">
        <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
            <i class="ri-error-warning-line"></i> ${requestScope.error}
        </div>
    </c:if>

    <div class="board glass-panel">
        <div>
            <!-- 显示真实余额 -->
            <div class="badge">Available: RM <span>${currentBalance}</span></div>

            <form action="${pageContext.request.contextPath}/WithdrawServlet" method="post" onsubmit="return validate(event)">
                <label>Withdraw Amount (RM)</label>
                <!-- max 属性设为当前余额，防止前端直接输超额 -->
                <input type="number" name="amount" id="amount" min="10" max="${currentBalance}" step="0.01" placeholder="e.g. 50.00" required>

                <label>Bank</label>
                <select name="bank" required>
                    <option>Maybank</option>
                    <option>CIMB</option>
                    <option>Public Bank</option>
                    <option>RHB</option>
                </select>

                <label>Account Number</label>
                <input type="text" name="accNum" placeholder="e.g. 1122334455" required>

                <label>Account Holder Name</label>
                <input type="text" name="accName" placeholder="Full name" required>

                <button class="btn-submit" type="submit">Confirm Withdraw</button>
            </form>
        </div>

        <div class="hint">
            <b>Note:</b><br>
            - Minimum withdrawal amount is RM 10.00.<br>
            - Processing time: 1-3 business days.<br>
            - Please ensure your bank details are correct.
        </div>
    </div>
</div>

<script>
    function validate(e){
        // 获取后端传来的余额 (作为字符串转浮点)
        const balance = parseFloat("${currentBalance}");
        const amount = parseFloat(document.getElementById('amount').value);

        if(amount > balance){
            alert("Insufficient balance! You only have RM " + balance.toFixed(2));
            return false;
        }
        return true;
    }
</script>
</body>
</html>
