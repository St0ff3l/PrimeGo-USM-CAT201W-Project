package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User;
import com.primego.common.util.PathUtil;

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
            // 1. Get amount
            String amountStr = request.getParameter("amount");
            BigDecimal amount = new BigDecimal(amountStr);

            // 2. Check balance
            BigDecimal currentBalance = walletDAO.getBalance(user.getId());
            if (currentBalance.compareTo(amount) < 0) {
                request.setAttribute("error", "Insufficient balance.");
                request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
                return;
            }

            // 3. Handle image upload
            Part filePart = request.getPart("receiptImage");
            String fileName = null;

            if (filePart != null && filePart.getSize() > 0) {
                // Generate unique filename
                String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String fileExt = "";
                int dotIndex = originalFileName.lastIndexOf(".");
                if (dotIndex > 0) {
                    fileExt = originalFileName.substring(dotIndex);
                }
                fileName = UUID.randomUUID().toString() + fileExt;

                // Save to withdrawphotos folder
                // 1. Deployment directory
                String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "withdrawphotos";

                // 2. Source directory - Use PathUtil
                String projectPath = PathUtil.getUploadDir(getServletContext(), "withdrawphotos");

                // DEBUG LOGGING
                System.out.println("[WithdrawServlet] Upload Dir (Runtime): " + uploadPath);
                System.out.println("[WithdrawServlet] Source Dir (Local): " + projectPath);

                // Automatically create directories
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                File sourceDir = new File(projectPath);
                if (!sourceDir.exists()) sourceDir.mkdirs();

                // Save file to deployment directory
                filePart.write(uploadPath + File.separator + fileName);

                // Copy to source directory
                if (!new File(uploadPath).getAbsolutePath().equals(new File(projectPath).getAbsolutePath())) {
                    try {
                        java.nio.file.Files.copy(
                                new File(uploadPath + File.separator + fileName).toPath(),
                                new File(projectPath + File.separator + fileName).toPath(),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING
                        );
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            } else {
                request.setAttribute("error", "Please upload your QR Code.");
                request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
                return;
            }

            // 4. Create transaction object
            WalletTransaction transaction = new WalletTransaction();
            transaction.setUserId(user.getId());
            transaction.setAmount(amount);
            transaction.setStatus("PENDING");
            transaction.setTransactionType("WITHDRAW");
            // Save relative path
            transaction.setReceiptImage("assets/images/withdrawphotos/" + fileName);

            // 5. Save to database
            boolean success = walletDAO.requestWithdraw(transaction);

            if (success) {
                session.setAttribute("message", "Withdrawal request submitted! QR Code uploaded.");
                response.sendRedirect(request.getContextPath() + "/public/wallet/wallet.jsp");
            } else {
                request.setAttribute("error", "Failed to submit request.");
                request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "System error: " + e.getMessage());
            request.getRequestDispatcher("/public/wallet/withdraw.jsp").forward(request, response);
        }
    }
}
