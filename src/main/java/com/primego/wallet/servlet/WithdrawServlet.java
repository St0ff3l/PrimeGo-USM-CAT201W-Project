package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/WithdrawServlet")
@MultipartConfig
public class WithdrawServlet extends HttpServlet {

    private WalletDAO walletDAO;

    public void init() {
        walletDAO = new WalletDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        try {
            // 1. 获取金额
            String amountStr = request.getParameter("amount");
            BigDecimal amount = new BigDecimal(amountStr);

            // 2. 检查余额
            BigDecimal currentBalance = walletDAO.getBalance(user.getId());
            if (currentBalance.compareTo(amount) < 0) {
                request.setAttribute("error", "Insufficient balance.");
                request.getRequestDispatcher("/common/wallet/withdraw.jsp").forward(request, response);
                return;
            }

            // 3. 处理图片上传
            Part filePart = request.getPart("receiptImage");
            String fileName = null;

            if (filePart != null && filePart.getSize() > 0) {
                // 生成唯一文件名
                String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String fileExt = "";
                int dotIndex = originalFileName.lastIndexOf(".");
                if (dotIndex > 0) {
                    fileExt = originalFileName.substring(dotIndex);
                }
                fileName = UUID.randomUUID().toString() + fileExt;

                // ⭐ 修改点：保存到 Withdraw_Photos 文件夹
                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "Withdraw_Photos";

                // 自动创建文件夹
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                // 保存文件
                filePart.write(uploadPath + File.separator + fileName);
            } else {
                request.setAttribute("error", "Please upload your QR Code.");
                request.getRequestDispatcher("/common/wallet/withdraw.jsp").forward(request, response);
                return;
            }

            // 4. 创建交易对象
            WalletTransaction transaction = new WalletTransaction();
            transaction.setUserId(user.getId());
            transaction.setAmount(amount);
            transaction.setStatus("PENDING");
            transaction.setTransactionType("WITHDRAW");
            transaction.setReceiptImage(fileName); // 存入文件名

            // 5. 保存到数据库
            boolean success = walletDAO.requestWithdraw(transaction);

            if (success) {
                session.setAttribute("message", "Withdrawal request submitted! QR Code uploaded.");
                response.sendRedirect(request.getContextPath() + "/common/wallet/wallet.jsp");
            } else {
                request.setAttribute("error", "Failed to submit request.");
                request.getRequestDispatcher("/common/wallet/withdraw.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error: " + e.getMessage());
            request.getRequestDispatcher("/common/wallet/withdraw.jsp").forward(request, response);
        }
    }
}
