package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/TopUpServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class TopUpServlet extends HttpServlet {

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
        Part filePart = request.getPart("receipt");

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            // 3. 处理文件上传
            // 【修改点】路径改为 assets/images/Recharge_Photos
            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "Recharge_Photos";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs(); // 如果目录不存在，自动创建

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            // 防止文件名冲突，加个UUID前缀
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;

            filePart.write(uploadPath + File.separator + uniqueFileName);

            // 4. 保存到数据库
            WalletTransaction transaction = new WalletTransaction();
            transaction.setUserId(user.getId());
            transaction.setAmount(amount);
            transaction.setStatus("PENDING");
            transaction.setTransactionType("TOPUP");
            transaction.setReceiptImage(uniqueFileName); // 存文件名到数据库

            WalletDAO dao = new WalletDAO();
            boolean success = dao.requestTopUp(transaction);

            if (success) {
                session.setAttribute("message", "Top-up request submitted! Waiting for approval.");
                response.sendRedirect(request.getContextPath() + "/public/wallet/wallet.jsp");
            } else {
                request.setAttribute("error", "Database error. Please try again.");
                request.getRequestDispatcher("/public/wallet/topup.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid amount format.");
            request.getRequestDispatcher("/public/wallet/topup.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/public/wallet/topup.jsp").forward(request, response);
        }
    }
}
