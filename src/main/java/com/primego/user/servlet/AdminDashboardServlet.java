package com.primego.user.servlet;

import com.primego.common.util.PasswordUtil;
import com.primego.user.dao.ProfileDAO;
import com.primego.user.dao.UserDAO;
import com.primego.user.model.AdminProfile;
import com.primego.user.model.Role;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private ProfileDAO profileDAO = new ProfileDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // Load Admin Profile
        AdminProfile adminProfile = profileDAO.getAdminProfile(user.getId());
        req.setAttribute("adminProfile", adminProfile);

        // --- 1. Dashboard Overview Data (Mock) ---
        req.setAttribute("totalUsers", 1250);
        req.setAttribute("activeSessions", 42);
        req.setAttribute("dailyVisits", 3500);
        req.setAttribute("revenue", "RM 15,420");
        req.setAttribute("chartLabels", "'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'");
        req.setAttribute("chartData", "120, 190, 300, 500, 200, 300, 450");

        List<LogEntry> logs = new ArrayList<>();
        logs.add(new LogEntry("INFO", "User 'customer1' logged in", "10:42 AM"));
        logs.add(new LogEntry("WARN", "High memory usage detected", "10:30 AM"));
        logs.add(new LogEntry("INFO", "New order #10234 placed", "10:15 AM"));
        logs.add(new LogEntry("ERROR", "Payment gateway timeout (Retry 1)", "09:55 AM"));
        logs.add(new LogEntry("INFO", "Daily backup completed", "04:00 AM"));
        req.setAttribute("logs", logs);

        // --- 2. User Management Data (Real) ---
        List<User> allUsers = userDAO.findAllUsers();
        req.setAttribute("userList", allUsers);

        req.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String action = req.getParameter("action");
        String message = "";
        String messageType = "info";

        if ("updateProfile".equals(action)) {
            String department = req.getParameter("department");
            AdminProfile profile = new AdminProfile(user.getId(), department, 0); // Level not editable from UI
            if (profileDAO.updateAdminProfile(profile)) {
                message = "Profile updated successfully.";
                messageType = "success";
            } else {
                message = "Failed to update profile.";
                messageType = "error";
            }
        } else if ("changePassword".equals(action)) {
            String currentPassword = req.getParameter("currentPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");

            if (!PasswordUtil.checkPassword(currentPassword, user.getPassword())) {
                message = "Current password is incorrect.";
                messageType = "error";
            } else if (!newPassword.equals(confirmPassword)) {
                message = "New passwords do not match.";
                messageType = "error";
            } else {
                if (userDAO.updatePassword(user.getId(), newPassword)) {
                    // Update session user password
                    user.setPassword(PasswordUtil.hashPassword(newPassword));
                    message = "Password changed successfully.";
                    messageType = "success";
                } else {
                    message = "Failed to change password.";
                    messageType = "error";
                }
            }
        }

        // Set message and reload dashboard
        req.setAttribute("settingsMessage", message);
        req.setAttribute("settingsMessageType", messageType);

        doGet(req, resp); // Reload dashboard with updated data
    }

    public static class LogEntry {
        private String level;
        private String message;
        private String time;

        public LogEntry(String level, String message, String time) {
            this.level = level;
            this.message = message;
            this.time = time;
        }

        public String getLevel() {
            return level;
        }

        public String getMessage() {
            return message;
        }

        public String getTime() {
            return time;
        }
    }
}
