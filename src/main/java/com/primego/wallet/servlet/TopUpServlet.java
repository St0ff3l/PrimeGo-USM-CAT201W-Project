package com.primego.wallet.servlet;

import com.primego.wallet.dao.WalletDAO;
import com.primego.wallet.model.WalletTransaction;
import com.primego.user.model.User; // 假设你有 User 类

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.UUID;

@WebServlet("/TopUpServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class TopUpServlet extends HttpServlet {

    // 图片保存目录 (相对于 webapp)
    private static final String UPLOAD_DIR = "assets/uploads/receipts";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. 获取当前用户 (假设 Session 中存了 user 对象)
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2. 获取表单数据
        String amountStr = request.getParameter("amount");
        BigDecimal amount = new BigDecimal(amountStr);

        // 3. 处理文件上传
        Part filePart = request.getPart("receipt");
        String fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);

        // 构建保存路径
        String applicationPath = request.getServletContext().getRealPath("");
        String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;

        // 创建目录如果不存在
        File uploadDir = new File(uploadFilePath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 保存文件到服务器
        filePart.write(uploadFilePath + File.separator + fileName);

        // 4. 保存到数据库
        WalletTransaction transaction = new WalletTransaction(user.getId(), amount, fileName);
        WalletDAO dao = new WalletDAO();
        boolean success = dao.requestTopUp(transaction);

        // 5. 反馈结果
        if (success) {
            // 成功后跳转回钱包页，并带上成功消息
            session.setAttribute("message", "Top-up request submitted! Waiting for approval.");
            response.sendRedirect(request.getContextPath() + "/common/wallet/wallet.jsp");
        } else {
            request.setAttribute("error", "Database error. Please try again.");
            request.getRequestDispatcher("/common/wallet/topup.jsp").forward(request, response);
        }
    }

    // 工具方法：从 Part 中提取文件名
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
