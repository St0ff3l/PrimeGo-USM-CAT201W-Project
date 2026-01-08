<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="com.primego.wallet.model.WalletTransaction" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.util.List" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("loginMsg", "Please login to access admin dashboard.");
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    String role = (user.getRole() != null) ? user.getRole().toString() : "";
    // 安全检查：非管理员跳转到个人钱包或拒绝访问
    if (!"ADMIN".equals(role)) {
        response.sendRedirect("my_wallet.jsp");
        return;
    }

    WalletDAO dao = new WalletDAO();
    List<WalletTransaction> pendingList = dao.getPendingTransactions();
    request.setAttribute("pendingList", pendingList);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Approval - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <!-- 复用原有样式 -->
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
        .role-badge { padding:8px 20px; border-radius:999px; font-size:.85rem; font-weight:700; color:#fff; text-transform:uppercase; letter-spacing:.8px; box-shadow:0 8px 18px rgba(0,0,0,0.18); }
        .badge-admin { background:linear-gradient(135deg,#ff5e55,#d92e25); }
        .txn-header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
        .txn-title { font-size:1.6rem; font-weight:700; color:#2d3436; }
        .txn-list { display:flex; flex-direction:column; gap:18px; }
        .txn-item { display:flex; justify-content:space-between; align-items:center; padding:22px 30px; border-radius:24px; background:linear-gradient(90deg,#ffffff,#fefaf3); box-shadow:0 10px 30px rgba(0,0,0,0.03); }
        .txn-left-main { font-size:1rem; font-weight:600; color:#2d3436; margin-bottom:4px; }
        .txn-left-sub { font-size:.85rem; color:#95a5a6; }
        .txn-right { display:flex; align-items:center; gap:10px; font-size:1rem; font-weight:700; color:#2d3436; }
        .admin-action-btn { padding:8px 14px; border-radius:999px; border:none; color:#fff; font-size:.85rem; font-weight:600; cursor:pointer; text-decoration: none; display: inline-block;}
        .btn-approve { background: #2ecc71; }
        .btn-reject { background: #e74c3c; }
    </style>
</head>
<body>

<jsp:include page="/common/background_admin.jsp" />

<div class="glass-panel">
    <div class="back-row">
        <a href="${pageContext.request.contextPath}/index.jsp" class="back-btn" title="Back to Home">
            <span>←</span><span class="back-text">Back Home</span>
        </a>
    </div>

    <!-- 消息提示区域 -->
    <c:if test="${not empty sessionScope.message}">
        <div style="background: #d4edda; color: #155724; padding: 15px 20px; border-radius: 15px; margin-bottom: 30px; border: 1px solid #c3e6cb; display: flex; align-items: center; gap: 10px;">
            <i class="ri-checkbox-circle-line"></i><span>${sessionScope.message}</span>
        </div>
        <c:remove var="message" scope="session" />
    </c:if>
    <c:if test="${not empty requestScope.error}">
        <div style="background: #f8d7da; color: #721c24; padding: 15px 20px; border-radius: 15px; margin-bottom: 30px; border: 1px solid #f5c6cb; display: flex; align-items: center; gap: 10px;">
            <i class="ri-error-warning-line"></i><span>${requestScope.error}</span>
        </div>
    </c:if>

    <div class="header-row">
        <div>
            <div class="balance-label">Audit Dashboard</div>
            <div style="font-size: 2rem; font-weight: 800; color: #2d3436; margin-top: 10px;">Pending Requests</div>
        </div>
        <div>
            <span class="role-badge badge-admin">ADMIN</span>
        </div>
    </div>

    <div class="txn-header-row">
        <div class="txn-title">Approval Queue</div>
    </div>

    <div class="txn-list">
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
                        <c:if test="${txn.transactionType == 'TOPUP' && not empty txn.receiptImage}">
                            <br>
                            <a href="${pageContext.request.contextPath}/assets/images/Recharge_Photos/${txn.receiptImage}" target="_blank" style="color:#3498db; text-decoration:none;">
                                <i class="ri-image-line"></i> View Receipt
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
    </div>
</div>
</body>
</html>
