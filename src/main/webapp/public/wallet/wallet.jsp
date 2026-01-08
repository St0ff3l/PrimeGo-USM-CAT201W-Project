<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="com.primego.wallet.model.WalletTransaction" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("loginMsg", "Please login to view wallet.");
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    WalletDAO dao = new WalletDAO();
    String role = (user.getRole() != null) ? user.getRole().toString() : "";

    if ("ADMIN".equals(role)) {
        List<WalletTransaction> pendingList = dao.getPendingTransactions();
        request.setAttribute("pendingList", pendingList);
    } else {
        BigDecimal currentBalance = dao.getBalance(user.getId());
        if (currentBalance == null) currentBalance = BigDecimal.ZERO;
        request.setAttribute("displayBalance", String.format("%.2f", currentBalance));

        List<WalletTransaction> myTransactions = dao.getUserTransactions(user.getId());
        request.setAttribute("myTransactions", myTransactions);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Wallet - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Poppins',sans-serif; }
        body { background: linear-gradient(to bottom, #f0f2f5, #e0e5ec); min-height:100vh; color:#333; overflow-x: hidden; }
        .glass-panel { background: rgba(255, 255, 255, 0.75); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.6); border-radius: 30px; padding: 50px; box-shadow: 0 20px 60px rgba(0,0,0,0.08); max-width: 1000px; margin: 60px auto; position: relative; z-index: 10; }
        .back-row { margin-bottom: 30px; }
        .back-btn { display:inline-flex; align-items:center; justify-content:center; width:40px; height:40px; border-radius:50%; background:rgba(255,255,255,0.5); border:1px solid rgba(0,0,0,0.05); text-decoration:none; color:#666; font-size:1.1rem; transition:all .3s ease; }
        .back-btn:hover { width:130px; border-radius:20px; background:rgba(0,0,0,.05); color:#2d3436; }
        .back-text { max-width:0; opacity:0; margin-left:0; transition:all .3s ease; font-size:.9rem; font-weight:600; white-space:nowrap; overflow:hidden; }
        .back-btn:hover .back-text { max-width:100px; opacity:1; margin-left:8px; }
        .header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:40px; }
        .balance-label { font-size:.9rem; color:#666; text-transform:uppercase; letter-spacing:1px; font-weight:700; margin-bottom:5px; }
        .balance-val { font-size:4rem; font-weight:800; color:#2d3436; line-height:1; letter-spacing:-1px; }
        .role-badge { padding:8px 20px; border-radius:999px; font-size:.85rem; font-weight:700; color:#fff; text-transform:uppercase; letter-spacing:.8px; box-shadow:0 8px 18px rgba(0,0,0,0.18); }
        .badge-cust  { background:linear-gradient(145deg, #ffad33, #e68a00); }
        .badge-merch { background:linear-gradient(135deg,#ffdb4d,#e6b800); }
        .badge-admin { background:linear-gradient(135deg,#ff5e55,#d92e25); }
        .btn-group { display:flex; gap:20px; margin-bottom:30px; }
        .btn { padding:14px 32px; border-radius:50px; text-decoration:none; font-weight:600; transition:all .3s ease; border:none; cursor:pointer; display:inline-flex; align-items:center; gap:10px; font-size:1rem; }
        .btn-primary { background:linear-gradient(45deg,#2ecc71,#27ae60); color:#fff; box-shadow:0 10px 20px rgba(39,174,96,0.35); }
        .btn-secondary { background:#fff; border:2px solid #e74c3c; color:#e74c3c; }
        .btn-purple { background:linear-gradient(45deg,#6c5ce7,#a29bfe); color:#fff; box-shadow:0 8px 20px rgba(108,92,231,.3); }
        .txn-header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
        .txn-title { font-size:1.6rem; font-weight:700; color:#2d3436; }
        .txn-tabs { display:flex; padding:8px; border-radius:999px; box-shadow:0 10px 25px rgba(0,0,0,0.08); gap:4px; }
        .tabs-cust { background:linear-gradient(145deg,#ffad33,#e68a00); }
        .txn-tab { min-width:120px; padding:10px 18px; border-radius:999px; border:none; background:transparent; font-weight:600; font-size:.95rem; color:#f4f4f4; cursor:pointer; }
        .txn-tab-active { background:#fff; color:#2d3436; box-shadow:0 6px 18px rgba(0,0,0,0.12); border:2px solid #222; }
        .txn-list { display:flex; flex-direction:column; gap:18px; }
        .txn-item { display:flex; justify-content:space-between; align-items:center; padding:22px 30px; border-radius:24px; background:linear-gradient(90deg,#ffffff,#fefaf3); box-shadow:0 10px 30px rgba(0,0,0,0.03); }
        .txn-left-main { font-size:1rem; font-weight:600; color:#2d3436; margin-bottom:4px; }
        .txn-left-sub { font-size:.85rem; color:#95a5a6; }
        .txn-right { display:flex; align-items:center; gap:10px; font-size:1rem; font-weight:700; color:#2d3436; }
        .txn-amount-minus { color:#e74c3c; }
        .txn-amount-plus  { color:#27ae60; }
        .admin-action-btn { padding:8px 14px; border-radius:999px; border:none; color:#fff; font-size:.85rem; font-weight:600; cursor:pointer; text-decoration: none; display: inline-block;}
        .btn-approve { background: #2ecc71; }
        .btn-reject { background: #e74c3c; }
    </style>
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
        <a href="${pageContext.request.contextPath}/index.jsp" class="back-btn" title="Back to Home">
            <span>←</span><span class="back-text">Back Home</span>
        </a>
    </div>

    <c:if test="${not empty sessionScope.message}">
        <div style="background: #d4edda; color: #155724; padding: 15px 20px; border-radius: 15px; margin-bottom: 30px; border: 1px solid #c3e6cb; display: flex; align-items: center; gap: 10px;">
            <i class="ri-checkbox-circle-line"></i><span>${sessionScope.message}</span>
        </div>
        <c:remove var="message" scope="session" />
    </c:if>

    <div class="header-row">
        <div>
            <div class="balance-label">
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'ADMIN'}">Audit Dashboard</c:when>
                    <c:when test="${sessionScope.user.role == 'MERCHANT'}">Shop Total Revenue</c:when>
                    <c:otherwise>Personal Balance</c:otherwise>
                </c:choose>
            </div>
            <c:choose>
                <c:when test="${sessionScope.user.role == 'ADMIN'}">
                    <div style="font-size: 2rem; font-weight: 800; color: #2d3436; margin-top: 10px;">Pending Requests</div>
                </c:when>
                <c:otherwise>
                    <div class="balance-val">RM ${displayBalance}</div>
                </c:otherwise>
            </c:choose>
        </div>
        <div>
            <c:choose>
                <c:when test="${sessionScope.user.role == 'MERCHANT'}">
                    <span class="role-badge badge-merch">MERCHANT</span>
                </c:when>
                <c:when test="${sessionScope.user.role == 'ADMIN'}">
                    <span class="role-badge badge-admin">ADMIN</span>
                </c:when>
                <c:otherwise>
                    <span class="role-badge badge-cust">CUSTOMER</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- 按钮组 -->
    <c:if test="${sessionScope.user.role != 'ADMIN'}">
        <div class="btn-group">
            <c:choose>
                <c:when test="${sessionScope.user.role == 'CUSTOMER' || empty sessionScope.user.role}">
                    <a href="topup.jsp" class="btn btn-primary">＋ Top Up Wallet</a>
                    <a href="withdraw.jsp" class="btn btn-secondary">↘ Withdraw Funds</a>
                </c:when>
                <c:when test="${sessionScope.user.role == 'MERCHANT'}">
                    <a href="withdraw.jsp" class="btn btn-purple">🏦 Withdraw Revenue</a>
                </c:when>
            </c:choose>
        </div>
    </c:if>

    <div class="txn-list">
        <!-- ADMIN 视图 -->
        <c:if test="${sessionScope.user.role == 'ADMIN'}">
            <c:if test="${empty pendingList}">
                <div class="txn-item" style="color: #888; justify-content: center; padding: 40px;"><p>No pending requests.</p></div>
            </c:if>
            <c:forEach var="txn" items="${pendingList}">
                <div class="txn-item">
                    <div>
                        <div class="txn-left-main">
                                ${txn.transactionType == 'TOPUP' ? 'Top Up Request' : 'Withdraw Request'}
                            <span style="font-weight:normal; color:#666; font-size:0.9rem;">(ID: ${txn.id})</span>
                        </div>
                        <div class="txn-left-sub">
                            User ID: ${txn.userId} • <fmt:formatDate value="${txn.createdAt}" pattern="yyyy-MM-dd HH:mm"/>

                            <!-- ⭐ 显示图片链接 (智能判断文件夹) -->
                            <c:if test="${not empty txn.receiptImage}">
                                <br>
                                <c:set var="folderName" value="${txn.transactionType == 'WITHDRAW' ? 'Withdraw_Photos' : 'Recharge_Photos'}" />

                                <a href="${pageContext.request.contextPath}/assets/images/${folderName}/${txn.receiptImage}" target="_blank" style="color:#3498db; text-decoration:none;">
                                    <i class="${txn.transactionType == 'WITHDRAW' ? 'ri-qr-code-line' : 'ri-image-line'}"></i>
                                        ${txn.transactionType == 'WITHDRAW' ? 'View QR Code' : 'View Receipt'}
                                </a>
                            </c:if>
                        </div>
                    </div>
                    <div class="txn-right">
                        <span style="font-size: 1.2rem; margin-right: 15px;">RM ${txn.amount}</span>
                        <form action="${pageContext.request.contextPath}/WalletAdminServlet" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="${txn.id}"><input type="hidden" name="action" value="reject">
                            <button type="submit" class="admin-action-btn btn-reject">Reject</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/WalletAdminServlet" method="post" style="display:inline; margin-left:5px;">
                            <input type="hidden" name="id" value="${txn.id}"><input type="hidden" name="action" value="approve">
                            <button type="submit" class="admin-action-btn btn-approve">Approve</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:if>

        <!-- 普通用户/商家 视图 -->
        <c:if test="${sessionScope.user.role != 'ADMIN'}">
            <c:if test="${empty myTransactions}">
                <div class="txn-item" style="color: #888; justify-content: center; padding: 40px;"><p>No transaction history found.</p></div>
            </c:if>
            <c:forEach var="txn" items="${myTransactions}">
                <div class="txn-item">
                    <div>
                        <div class="txn-left-main">
                            <c:choose>
                                <c:when test="${txn.transactionType == 'TOPUP'}">Top Up</c:when>
                                <c:when test="${txn.transactionType == 'WITHDRAW'}">Withdraw</c:when>
                                <c:when test="${txn.transactionType == 'PURCHASE'}">Payment (Shopping)</c:when>
                                <c:when test="${txn.transactionType == 'SALES'}">Sales Revenue</c:when>
                                <c:otherwise>${txn.transactionType}</c:otherwise>
                            </c:choose>
                            <span style="font-size:0.8rem; padding:2px 8px; border-radius:10px; margin-left: 5px;
                                    background:${txn.status == 'APPROVED' ? '#d4edda' : (txn.status == 'PENDING' ? '#fff3cd' : '#f8d7da')};
                                    color:${txn.status == 'APPROVED' ? '#155724' : (txn.status == 'PENDING' ? '#856404' : '#721c24')};">
                                    ${txn.status}
                            </span>
                        </div>
                        <div class="txn-left-sub">
                            <fmt:formatDate value="${txn.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                        </div>
                    </div>
                    <div class="txn-right">
                        <c:choose>
                            <c:when test="${txn.transactionType == 'TOPUP' || txn.transactionType == 'SALES'}">
                                <span class="txn-amount-plus">+ RM ${txn.amount}</span>
                            </c:when>
                            <c:otherwise>
                                <span class="txn-amount-minus">- RM ${txn.amount}</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </c:if>
    </div>
</div>
</body>
</html>
