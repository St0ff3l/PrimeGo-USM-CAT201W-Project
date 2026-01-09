package com.primego.user.servlet;

import com.primego.common.listener.ActiveSessionListener;
import com.primego.common.util.PasswordUtil;
import com.primego.order.dao.OrderDAO;
import com.primego.user.dao.LogDAO;
import com.primego.user.dao.ProfileDAO;
import com.primego.user.dao.UserDAO;
import com.primego.user.dao.VisitDAO;
import com.primego.user.model.AdminProfile;
import com.primego.user.model.Role;
import com.primego.user.model.SystemLog;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private ProfileDAO profileDAO = new ProfileDAO();
    private OrderDAO orderDAO = new OrderDAO();
    private LogDAO logDAO = new LogDAO();

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

        // Log this access (Optional: limit frequency or move to filter)
        logDAO.addLog("INFO", "Admin '" + user.getUsername() + "' accessed dashboard");

        // Load Admin Profile
        AdminProfile adminProfile = profileDAO.getAdminProfile(user.getId());
        req.setAttribute("adminProfile", adminProfile);

        // --- 1. Dashboard Overview Data (Real) ---
        req.setAttribute("totalUsers", userDAO.countUsers());
        req.setAttribute("activeSessions", ActiveSessionListener.getActiveSessionsCount());
        req.setAttribute("dailyVisits", new VisitDAO().getTodayVisits());
        req.setAttribute("revenue", orderDAO.countTotalTransactions());

        // --- Real Chart Data (Last 7 Days) ---
        Map<java.time.LocalDate, Integer> visitsMap = new VisitDAO().getLast7DaysVisits();

        StringBuilder labelsBuilder = new StringBuilder();
        StringBuilder dataBuilder = new StringBuilder();

        int i = 0;
        for (Map.Entry<java.time.LocalDate, Integer> entry : visitsMap.entrySet()) {
            if (i > 0) {
                labelsBuilder.append(", ");
                dataBuilder.append(", ");
            }
            // Format: 'Mon'
            String dayName = entry.getKey().getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            labelsBuilder.append("'").append(dayName).append("'");
            dataBuilder.append(entry.getValue());
            i++;
        }

        req.setAttribute("chartLabels", labelsBuilder.toString());
        req.setAttribute("chartData", dataBuilder.toString());

        // --- Real User Distribution Data ---
        int customerCount = userDAO.countUsersByRole(Role.CUSTOMER);
        int merchantCount = userDAO.countUsersByRole(Role.MERCHANT);
        int adminCount = userDAO.countUsersByRole(Role.ADMIN);
        req.setAttribute("userChartData", customerCount + ", " + merchantCount + ", " + adminCount);

        // Fetch Order Lists for Transaction Modal
        req.setAttribute("paidOrders", orderDAO.getOrdersByStatusForAdmin("PAID"));
        req.setAttribute("shippedOrders", orderDAO.getOrdersByStatusForAdmin("SHIPPED"));
        req.setAttribute("completedOrders", orderDAO.getOrdersByStatusForAdmin("COMPLETED"));
        req.setAttribute("cancelledOrders", orderDAO.getOrdersByStatusForAdmin("CANCELLED"));

        // --- Real System Logs ---
        List<SystemLog> logs = logDAO.getRecentLogs(5);
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

}
