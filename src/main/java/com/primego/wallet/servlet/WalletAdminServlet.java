package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.user.model.User;

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
        // 将 Role 枚举转为 String 进行比较，防止 null
        String role = (user != null && user.getRole() != null) ? user.getRole().toString() : "";

        if (!"ADMIN".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You are not an admin.");
            return;
        }

        // 3. 获取前端传来的参数
        String idStr = request.getParameter("id");
        String action = request.getParameter("action"); // "approve" 或 "reject"

        if (idStr != null && action != null) {
            try {
                int transactionId = Integer.parseInt(idStr);
                WalletDAO dao = new WalletDAO();
                boolean success = false;

                // 4. 根据动作更新数据库
                if ("approve".equalsIgnoreCase(action)) {
                    success = dao.updateTransactionStatus(transactionId, "APPROVED");
                } else if ("reject".equalsIgnoreCase(action)) {
                    success = dao.updateTransactionStatus(transactionId, "REJECTED");
                }

                // 5. 设置反馈消息
                if (success) {
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

        // 6. 重定向回钱包页面
        response.sendRedirect(request.getContextPath() + "/public/wallet/wallet.jsp");
    }
}
