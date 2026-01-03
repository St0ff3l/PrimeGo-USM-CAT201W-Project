package com.primego.user.servlet;

import com.primego.user.dao.ProfileDAO;
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

@WebServlet("/admin/api/user-details")
public class UserDetailsServlet extends HttpServlet {

    private ProfileDAO profileDAO = new ProfileDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Auth Check
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        // 2. Fetch Details
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            String userIdParam = req.getParameter("userId");
            if (userIdParam == null || userIdParam.isEmpty()) {
                throw new IllegalArgumentException("User ID is required");
            }
            int userId = Integer.parseInt(userIdParam);
            String roleStr = req.getParameter("role");

            StringBuilder json = new StringBuilder();
            json.append("{");

            if ("CUSTOMER".equals(roleStr)) {
                com.primego.user.model.CustomerProfile p = profileDAO.getCustomerProfile(userId);
                if (p != null) {
                    json.append("\"fullName\": \"").append(escapeJson(p.getFullName())).append("\",");
                    json.append("\"email\": \"").append(escapeJson(p.getEmail())).append("\",");
                    json.append("\"phone\": \"").append(escapeJson(p.getPhone())).append("\",");
                    json.append("\"address\": \"").append(escapeJson(p.getFormattedAddress())).append("\"");
                } else {
                    json.append("\"error\": \"Profile not found\"");
                }
            } else if ("MERCHANT".equals(roleStr)) {
                com.primego.user.model.MerchantProfile p = profileDAO.getMerchantProfile(userId);
                if (p != null) {
                    json.append("\"storeName\": \"").append(escapeJson(p.getStoreName())).append("\",");
                    json.append("\"license\": \"").append(escapeJson(p.getBusinessLicense())).append("\",");
                    json.append("\"contact\": \"").append(escapeJson(p.getContactInfo())).append("\"");
                } else {
                    json.append("\"error\": \"Profile not found\"");
                }
            } else if ("ADMIN".equals(roleStr)) {
                AdminProfile p = profileDAO.getAdminProfile(userId);
                if (p != null) {
                    json.append("\"department\": \"").append(escapeJson(p.getDepartment())).append("\",");
                    json.append("\"level\": ").append(p.getLevel());
                } else {
                    json.append("\"error\": \"Profile not found\"");
                }
            } else {
                json.append("\"error\": \"Invalid or unknown role: " + escapeJson(roleStr) + "\"");
            }

            json.append("}");
            resp.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Server Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }
}
