<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="com.primego.wallet.model.WalletTransaction" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.wallet.model.AdminTransactionLog" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        session.setAttribute("loginMsg", "Please login to access admin dashboard.");
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    String role = (user.getRole() != null) ? user.getRole().toString() : "";
    if (!"ADMIN".equals(role)) {
        response.sendRedirect("my_wallet.jsp");
        return;
    }

    WalletDAO dao = new WalletDAO();
    
    // 获取参数
    String view = request.getParameter("view"); // "pending" (default) or "history"
    String type = request.getParameter("type"); // "TOPUP" or "WITHDRAW"
    
    // 默认进入 TOPUP 分类
    if (type == null || type.isEmpty()) {
        type = "TOPUP";
    }
    
    List<WalletTransaction> pendingList = null;
    List<AdminTransactionLog> historyList = null;

    if ("history".equals(view)) {
        // 获取历史记录
        historyList = dao.getProcessedTransactions();
        // 可以在这里加 type 过滤，如果需要的话，目前先显示全部或在前端过滤
    } else {
        // 获取待处理记录
        List<WalletTransaction> allPending = dao.getPendingTransactions();
        pendingList = new ArrayList<>();
        for (WalletTransaction txn : allPending) {
            if (txn.getTransactionType() != null && txn.getTransactionType().equalsIgnoreCase(type)) {
                pendingList.add(txn);
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Approval - PrimeGo</title>
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
        .header-row { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; }
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

        .action-buttons { display: flex; gap: 20px; margin-bottom: 30px; }
        .btn-filter {
            display: inline-flex; align-items: center; justify-content: center;
            padding: 12px 24px; border-radius: 50px; font-weight: 600;
            text-decoration: none; transition: all 0.3s ease; font-size: 1rem;
        }
        .btn-filter-topup {
            background-color: #2ecc71; color: #fff;
            border: 2px solid #2ecc71;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.3);
        }
        .btn-filter-topup:hover, .btn-filter-topup.active {
            background-color: #27ae60; border-color: #27ae60; transform: translateY(-2px);
        }
        .btn-filter-withdraw {
            background-color: transparent; color: #e74c3c;
            border: 2px solid #e74c3c;
        }
        .btn-filter-withdraw:hover, .btn-filter-withdraw.active {
            background-color: #e74c3c; color: #fff;
            box-shadow: 0 4px 15px rgba(231, 76, 60, 0.2); transform: translateY(-2px);
        }
        .btn-filter.inactive { opacity: 0.5; box-shadow: none; }
        
        /* Tabs for View Switch */
        .view-tabs { display: flex; gap: 10px; margin-bottom: 20px; background: rgba(255,255,255,0.5); padding: 5px; border-radius: 50px; width: fit-content; }
        .view-tab { padding: 8px 20px; border-radius: 40px; text-decoration: none; color: #666; font-weight: 600; transition: all 0.3s; }
        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(5px);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 20px;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            position: relative;
            animation: slideUp 0.3s ease;
        }
        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        .modal-close {
            position: absolute;
            top: 15px; right: 20px;
            font-size: 1.5rem;
            cursor: pointer;
            color: #666;
        }
        .modal-img {
            width: 100%;
            border-radius: 10px;
            max-height: 80vh;
            object-fit: contain;
        }
        .modal-title {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 15px;
            color: #2d3436;
        }
        .modal-textarea {
            width: 100%;
            padding: 12px;
            border-radius: 10px;
            border: 1px solid #ddd;
            margin-bottom: 20px;
            font-family: inherit;
            resize: vertical;
            min-height: 100px;
        }
        .modal-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
    </style>
</head>
<body>

<jsp:include page="/common/background_admin.jsp" />

<!-- Image Preview Modal -->
<div id="imageModal" class="modal-overlay" onclick="closeImageModal()">
    <div class="modal-content" style="background: transparent; box-shadow: none; padding: 0; width: auto;" onclick="event.stopPropagation()">
        <img id="modalImage" src="" class="modal-img">
    </div>
</div>

<!-- Action Modal -->
<div id="actionModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-close" onclick="closeActionModal()">&times;</div>
        <div class="modal-title" id="actionTitle">Review Request</div>
        
        <!-- Transaction Details -->
        <div style="background: #f8f9fa; padding: 15px; border-radius: 10px; margin-bottom: 20px; font-size: 0.9rem;">
            <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                <span style="color: #666;">User ID:</span>
                <strong id="modalUserId"></strong>
            </div>
            <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                <span style="color: #666;">Amount:</span>
                <strong id="modalAmount"></strong>
            </div>
            <div style="display: flex; justify-content: space-between;">
                <span style="color: #666;">Time:</span>
                <strong id="modalTime"></strong>
            </div>
        </div>
        
        <form action="${pageContext.request.contextPath}/WalletAdminServlet" method="post">
            <input type="hidden" name="id" id="actionId">
            <input type="hidden" name="action" id="actionType">
            
            <div style="margin-bottom: 15px; color: #666; font-size: 0.9rem;">
                Please provide remarks for this action. This will be recorded in the audit log.
            </div>
            
            <textarea name="remarks" id="modalRemarks" class="modal-textarea" placeholder="Enter remarks..." required></textarea>
            
            <div class="modal-actions">
                <button type="button" class="btn-filter" onclick="closeActionModal()" style="border: 1px solid #ddd;">Cancel</button>
                <button type="submit" class="btn-filter" id="actionSubmitBtn" style="color: white;">Confirm</button>
            </div>
        </form>
    </div>
</div>

<div class="glass-panel">
    <div class="back-row">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="back-btn" title="Back to Dashboard">
            <span>←</span><span class="back-text">Dashboard</span>
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
            <div style="font-size: 2rem; font-weight: 800; color: #2d3436; margin-top: 10px;">
                <%= "history".equals(view) ? "Audit History" : "Pending Requests" %>
            </div>
        </div>
        <div>
            <span class="role-badge badge-admin">ADMIN</span>
        </div>
    </div>
    
    <!-- View Switcher -->
    <div class="view-tabs">
        <a href="?view=pending&type=<%= type %>" class="view-tab <%= !"history".equals(view) ? "active" : "" %>">Pending</a>
        <a href="?view=history" class="view-tab <%= "history".equals(view) ? "active" : "" %>">History</a>
    </div>

    <% if (!"history".equals(view)) { %>
    <!-- 筛选按钮组 (仅在 Pending 视图显示) -->
    <div class="action-buttons">
        <a href="?view=pending&type=TOPUP"
           class="btn-filter btn-filter-topup <%= "TOPUP".equals(type) ? "active" : "inactive" %>">
            Top Up Requests
        </a>

        <a href="?view=pending&type=WITHDRAW"
           class="btn-filter btn-filter-withdraw <%= "WITHDRAW".equals(type) ? "active" : "inactive" %>">
            Withdraw Requests
        </a>
    </div>
    <% } %>

    <div class="txn-list">
        <% if ("history".equals(view)) { %>
            <!-- 历史记录视图 -->
            <% if (historyList == null || historyList.isEmpty()) { %>
                <div class="txn-item" style="color: #888; justify-content: center; padding: 40px; flex-direction: column; text-align: center;">
                    <i class="ri-history-line" style="font-size: 3rem; margin-bottom: 10px; opacity: 0.5;"></i>
                    <p>No audit history found.</p>
                </div>
            <% } else { 
                for (AdminTransactionLog log : historyList) {
                    // 获取关联的交易详情以显示图片
                    WalletTransaction txn = dao.getTransactionById(log.getWalletTransactionId());
            %>
                <div class="txn-item">
                    <div>
                        <div class="txn-left-main">
                            <%= log.getActionType() %> 
                            <span style="font-size:0.9rem; color:#666;">(Txn ID: <%= log.getWalletTransactionId() %>)</span>
                        </div>
                        <div class="txn-left-sub">
                            By Admin: <strong><%= log.getAdminName() %></strong> • <fmt:formatDate value="<%= log.getCreatedAt() %>" pattern="yyyy-MM-dd HH:mm"/>
                            <br>
                            Status: <%= log.getPreviousStatus() %> ➝ <strong><%= log.getCurrentStatus() %></strong>
                            <br>
                            <span style="color: #555;">Amount: <strong>RM <%= txn != null ? txn.getAmount() : "N/A" %></strong></span>
                            <span style="margin-left: 10px; color: #555;">User ID: <strong><%= txn != null ? txn.getUserId() : "N/A" %></strong></span>
                            <% if (log.getRemarks() != null && !log.getRemarks().isEmpty()) { %>
                                <br>
                                <span style="color: #666; font-style: italic;">Remarks: "<%= log.getRemarks() %>"</span>
                            <% } %>
                            
                            <% if (txn != null && txn.getReceiptImage() != null && !txn.getReceiptImage().isEmpty()) { %>
                                <br>
                                <a href="javascript:void(0)" onclick="showImage('${pageContext.request.contextPath}/<%= txn.getReceiptImage() %>')" style="color:#3498db; text-decoration:none; margin-top: 5px; display: inline-block;">
                                    <i class="<%= "WITHDRAW".equals(txn.getTransactionType()) ? "ri-qr-code-line" : "ri-image-line" %>"></i>
                                    View Image
                                </a>
                            <% } %>
                        </div>
                    </div>
                    <div class="txn-right">
                        <span style="font-size: 1rem; padding: 6px 12px; border-radius: 15px; 
                            background: <%= "APPROVED".equals(log.getCurrentStatus()) ? "#d4edda" : "#f8d7da" %>;
                            color: <%= "APPROVED".equals(log.getCurrentStatus()) ? "#155724" : "#721c24" %>;">
                            <%= log.getCurrentStatus() %>
                        </span>
                    </div>
                </div>
            <%  } 
               } %>
        <% } else { %>
            <!-- 待处理视图 -->
            <% if (pendingList == null || pendingList.isEmpty()) { %>
                <div class="txn-item" style="color: #888; justify-content: center; padding: 40px; flex-direction: column; text-align: center;">
                    <i class="ri-inbox-line" style="font-size: 3rem; margin-bottom: 10px; opacity: 0.5;"></i>
                    <p>No pending requests found.</p>
                </div>
            <% } else { 
                for (WalletTransaction txn : pendingList) {
            %>
                <div class="txn-item">
                    <div>
                        <div class="txn-left-main">
                            <%= "TOPUP".equals(txn.getTransactionType()) ? "Top Up Request" : "Withdraw Request" %>
                            <span style="font-weight:normal; color:#666; font-size:0.9rem;">(ID: <%= txn.getId() %>)</span>
                        </div>
                        <div class="txn-left-sub">
                            User ID: <%= txn.getUserId() %> • <fmt:formatDate value="<%= txn.getCreatedAt() %>" pattern="yyyy-MM-dd HH:mm"/>

                            <% if (txn.getReceiptImage() != null && !txn.getReceiptImage().isEmpty()) { %>
                                <br>
                                <a href="javascript:void(0)" onclick="showImage('${pageContext.request.contextPath}/<%= txn.getReceiptImage() %>')" style="color:#3498db; text-decoration:none; margin-top: 5px; display: inline-block;">
                                    <i class="<%= "WITHDRAW".equals(txn.getTransactionType()) ? "ri-qr-code-line" : "ri-image-line" %>"></i>
                                    <%= "WITHDRAW".equals(txn.getTransactionType()) ? "View QR Code" : "View Receipt" %>
                                </a>
                            <% } %>
                        </div>
                    </div>
                    <div class="txn-right">
                        <span style="font-size: 1.2rem; margin-right: 15px; color: <%= "TOPUP".equals(txn.getTransactionType()) ? "#2ecc71" : "#e74c3c" %>;">
                            <%= "TOPUP".equals(txn.getTransactionType()) ? "+" : "-" %> RM <%= txn.getAmount() %>
                        </span>
                        <button class="admin-action-btn btn-reject" onclick="openActionModal('<%= txn.getId() %>', 'reject', '<%= txn.getUserId() %>', 'RM <%= txn.getAmount() %>', '<fmt:formatDate value="<%= txn.getCreatedAt() %>" pattern="yyyy-MM-dd HH:mm"/>')">Reject</button>
                        <button class="admin-action-btn btn-approve" onclick="openActionModal('<%= txn.getId() %>', 'approve', '<%= txn.getUserId() %>', 'RM <%= txn.getAmount() %>', '<fmt:formatDate value="<%= txn.getCreatedAt() %>" pattern="yyyy-MM-dd HH:mm"/>')" style="margin-left: 5px;">Approve</button>
                    </div>
                </div>
            <%  } 
               } %>
        <% } %>
    </div>
</div>

<script>
    function showImage(src) {
        document.getElementById('modalImage').src = src;
        document.getElementById('imageModal').style.display = 'flex';
    }

    function closeImageModal() {
        document.getElementById('imageModal').style.display = 'none';
    }

    function openActionModal(id, action, userId, amount, time) {
        document.getElementById('actionId').value = id;
        document.getElementById('actionType').value = action;
        
        // Set details
        document.getElementById('modalUserId').innerText = userId;
        document.getElementById('modalAmount').innerText = amount;
        document.getElementById('modalTime').innerText = time;
        
        const title = document.getElementById('actionTitle');
        const btn = document.getElementById('actionSubmitBtn');
        const remarks = document.getElementById('modalRemarks');
        
        if (action === 'approve') {
            title.innerText = 'Approve Request';
            title.style.color = '#2ecc71';
            btn.style.backgroundColor = '#2ecc71';
            btn.innerText = 'Confirm Approve';
            
            // Approve: Remarks optional
            remarks.required = false;
            remarks.placeholder = "Optional remarks...";
        } else {
            title.innerText = 'Reject Request';
            title.style.color = '#e74c3c';
            btn.style.backgroundColor = '#e74c3c';
            btn.innerText = 'Confirm Reject';
            
            // Reject: Remarks required
            remarks.required = true;
            remarks.placeholder = "Reason for rejection (Required)...";
        }
        
        document.getElementById('actionModal').style.display = 'flex';
    }

    function closeActionModal() {
        document.getElementById('actionModal').style.display = 'none';
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        if (event.target == document.getElementById('actionModal')) {
            closeActionModal();
        }
    }
</script>

</body>
</html>
