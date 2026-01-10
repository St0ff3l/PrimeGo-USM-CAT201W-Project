package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User;
import com.primego.common.util.PathUtil;

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

        // 1. Get current user
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }

        // 2. Retrieve form data
        String amountStr = request.getParameter("amount");
        Part filePart = request.getPart("receipt");

        try {
            BigDecimal amount = new BigDecimal(amountStr);

            // 3. Handle file upload
            // Get deployment directory path (runtime usage)
            String uploadPath = request.getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "rechargephotos";

            // Get source directory path (for persistence) - using PathUtil
            String projectPath = PathUtil.getUploadDir(request.getServletContext(), "rechargephotos");

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs(); // Create directory if it doesn't exist

            File sourceDir = new File(projectPath);
            if (!sourceDir.exists()) sourceDir.mkdirs();

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            // Prevent filename conflicts by adding a UUID prefix
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;

            // Save to deployment directory
            filePart.write(uploadPath + File.separator + uniqueFileName);

            // Save to source directory (Sync for local development persistence)
            // Only copy if the paths differ to prevent errors
            if (!new File(uploadPath).getAbsolutePath().equals(new File(projectPath).getAbsolutePath())) {
                try {
                    java.nio.file.Files.copy(
                            new File(uploadPath + File.separator + uniqueFileName).toPath(),
                            new File(projectPath + File.separator + uniqueFileName).toPath(),
                            java.nio.file.StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace(); // Ignore source write failure, does not affect main flow
                }
            }

            // 4. Save to database
            WalletTransaction transaction = new WalletTransaction();
            transaction.setUserId(user.getId());
            transaction.setAmount(amount);
            transaction.setStatus("PENDING");
            transaction.setTransactionType("TOPUP");
            // Save relative path for frontend reference
            transaction.setReceiptImage("assets/images/rechargephotos/" + uniqueFileName);

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
