package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.user.model.User;
import com.primego.wallet.model.AdminTransactionLog;
import com.primego.wallet.model.WalletTransaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/WalletAdminServlet")
public class WalletAdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 获取当前用户 session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // 2. 权限检查：确保只有 ADMIN 可以操作
        String role = (user != null && user.getRole() != null) ? user.getRole().toString() : "";

        if (!"ADMIN".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You are not an admin.");
            return;
        }

        // 3. 获取前端传来的参数
        String idStr = request.getParameter("id");
        String action = request.getParameter("action"); // "approve" 或 "reject"
        String remarks = request.getParameter("remarks"); // 获取备注

        if (idStr != null && action != null) {
            try {
                int transactionId = Integer.parseInt(idStr);
                WalletDAO dao = new WalletDAO();
                boolean success = false;
                
                // 获取旧状态 (为了日志)
                WalletTransaction oldTxn = dao.getTransactionById(transactionId);
                String previousStatus = (oldTxn != null) ? oldTxn.getStatus() : "UNKNOWN";

                // 4. 根据动作更新数据库
                String newStatus = "";
                if ("approve".equalsIgnoreCase(action)) {
                    newStatus = "APPROVED";
                    success = dao.updateTransactionStatus(transactionId, newStatus);
                } else if ("reject".equalsIgnoreCase(action)) {
                    newStatus = "REJECTED";
                    success = dao.updateTransactionStatus(transactionId, newStatus);
                }

                // 5. 记录到 admin_transaction_logs
                if (success) {
                    AdminTransactionLog log = new AdminTransactionLog();
                    log.setAdminId(user.getId());
                    log.setWalletTransactionId(transactionId);
                    log.setActionType(action.toUpperCase());
                    log.setPreviousStatus(previousStatus);
                    log.setCurrentStatus(newStatus);
                    
                    // 使用前端传来的备注，如果为空则使用默认值
                    if (remarks == null || remarks.trim().isEmpty()) {
                        remarks = "Admin " + action + "d the request.";
                    }
                    log.setRemarks(remarks);
                    
                    dao.addAdminLog(log);
                    
                    session.setAttribute("message", "Transaction " + action + "d successfully.");
                } else {
                    session.setAttribute("error", "Failed to update transaction in database.");
                }

            } catch (NumberFormatException e) {
                e.printStackTrace();
                session.setAttribute("error", "Invalid ID format.");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "System error: " + e.getMessage());
            }
        } else {
            session.setAttribute("error", "Missing parameters.");
        }

        // 6. 重定向回审批页面 (注意：这里改回了 admin_approval.jsp)
        response.sendRedirect(request.getContextPath() + "/admin/wallet/admin_approval.jsp");
    }
}
