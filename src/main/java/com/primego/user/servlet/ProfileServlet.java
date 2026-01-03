package com.primego.user.servlet;

import com.primego.user.dao.ProfileDAO;
import com.primego.user.dao.UserDAO;
import com.primego.user.model.CustomerProfile;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private ProfileDAO profileDAO = new ProfileDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        switch (user.getRole()) {
            case CUSTOMER:
                req.setAttribute("profile", profileDAO.getCustomerProfile(userId));
                req.getRequestDispatcher("/customer/user/customer_profile.jsp").forward(req, resp);
                break;
            case MERCHANT:
                req.setAttribute("profile", profileDAO.getMerchantProfile(userId));
                req.getRequestDispatcher("/merchant/user/merchant_profile.jsp").forward(req, resp);
                break;
            case ADMIN:
                req.setAttribute("profile", profileDAO.getAdminProfile(userId));
                req.getRequestDispatcher("/admin/user/admin_profile.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        if ("updateCustomerProfile".equals(action)) {
            String newUsername = req.getParameter("username");

            // Name
            String firstName = req.getParameter("firstName");
            String lastName = req.getParameter("lastName");
            String fullName = (firstName + " " + lastName).trim();

            // Phone
            String phoneAreaCode = req.getParameter("phoneAreaCode");
            String phoneNumber = req.getParameter("phoneNumber");
            String phone = (phoneAreaCode + " " + phoneNumber).trim();

            // Address
            String street = req.getParameter("street");
            String unit = req.getParameter("unit");
            String city = req.getParameter("city");
            String country = req.getParameter("country");
            String state = req.getParameter("state");
            String zip = req.getParameter("zip");

            // Combine address with delimiter ||
            // Format: Street||Unit||City||State||Zip||Country
            String address = String.join("||",
                    street != null ? street : "",
                    unit != null ? unit : "",
                    city != null ? city : "",
                    state != null ? state : "",
                    zip != null ? zip : "",
                    country != null ? country : "");

            // 1. Update Username (in users table)
            boolean usernameUpdated = true;
            if (newUsername != null && !newUsername.trim().isEmpty() && !newUsername.equals(user.getUsername())) {
                if (userDAO.updateUsername(user.getId(), newUsername)) {
                    user.setUsername(newUsername); // Update session object
                } else {
                    usernameUpdated = false; // Failed (likely duplicate)
                }
            }

            // 2. Update Profile Details (in customer_profiles table)
            CustomerProfile profile = new CustomerProfile(user.getId(), fullName, null, phone, address);
            boolean profileUpdated = profileDAO.updateCustomerProfile(profile);

            if (usernameUpdated && profileUpdated) {
                req.setAttribute("message", "Profile updated successfully!");
                req.setAttribute("messageType", "success");
            } else if (!usernameUpdated) {
                req.setAttribute("message", "Failed to update username. It might be taken.");
                req.setAttribute("messageType", "error");
            } else {
                req.setAttribute("message", "Failed to update profile details.");
                req.setAttribute("messageType", "error");
            }
        }

        doGet(req, resp); // Reload page
    }
}
