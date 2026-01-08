package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/WithdrawServlet")
public class WithdrawServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 获取当前用户
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        // 2. 获取表单数据
        String amountStr = request.getParameter("amount");

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            // 3. 检查余额是否足够 (可选，建议加上)
            WalletDAO dao = new WalletDAO();
            BigDecimal currentBalance = dao.getBalance(user.getId());

            if (currentBalance.compareTo(amount) < 0) {
                request.setAttribute("error", "Insufficient balance!");
                request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
                return;
            }

            // 4. 创建提现交易对象
            WalletTransaction transaction = new WalletTransaction();
            transaction.setUserId(user.getId());
            transaction.setAmount(amount);
            transaction.setStatus("PENDING");
            transaction.setTransactionType("WITHDRAW");

            // 5. 保存到数据库
            boolean success = dao.requestWithdraw(transaction);

            if (success) {
                session.setAttribute("message", "Withdrawal request submitted successfully!");
                response.sendRedirect(request.getContextPath() + "/public/wallet/wallet.jsp");
            } else {
                request.setAttribute("error", "Database error. Please try again.");
                request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid amount format.");
            request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
        }
    }
}
