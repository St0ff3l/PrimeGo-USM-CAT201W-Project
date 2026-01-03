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
                // Fetch addresses for the new Addresses tab
                req.setAttribute("addresses", new com.primego.user.dao.AddressDAO().getAddressesByUserId(userId));
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
            // Note: Address is now managed exclusively via AddressServlet. We pass null for
            // defaultAddress here.
            // PaymentPin is managed via updatePin action, so we pass null here too.
            // Email is not updated here, pass null or empty string.
            CustomerProfile profile = new CustomerProfile(
                    user.getId(),
                    fullName,
                    "", // Email ignored in update
                    phone,
                    null,
                    null);

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
        } else if ("changePassword".equals(action)) {
            String oldPassword = req.getParameter("oldPassword");
            String newPassword = req.getParameter("newPassword");
            String confirmPassword = req.getParameter("confirmPassword");

            if (newPassword != null && newPassword.equals(confirmPassword)) {
                // Validate old password
                User validUser = userDAO.validateCredentials(user.getUsername(), oldPassword);
                if (validUser != null) {
                    // Update to new password
                    if (userDAO.updatePassword(user.getId(), newPassword)) {
                        req.setAttribute("message", "Password changed successfully!");
                        req.setAttribute("messageType", "success");
                    } else {
                        req.setAttribute("message", "Failed to update password. Database error.");
                        req.setAttribute("messageType", "error");
                    }
                } else {
                    req.setAttribute("message", "Incorrect old password.");
                    req.setAttribute("messageType", "error");
                }
            } else {
                req.setAttribute("message", "New passwords do not match.");
                req.setAttribute("messageType", "error");
            }
        } else if ("updatePin".equals(action)) {
            String pin1 = req.getParameter("pin1");
            String pin2 = req.getParameter("pin2");
            String pin3 = req.getParameter("pin3");
            String pin4 = req.getParameter("pin4");
            String pin5 = req.getParameter("pin5");
            String pin6 = req.getParameter("pin6");

            String newPin = pin1 + pin2 + pin3 + pin4 + pin5 + pin6;

            String confirmPin1 = req.getParameter("confirmPin1");
            String confirmPin2 = req.getParameter("confirmPin2");
            String confirmPin3 = req.getParameter("confirmPin3");
            String confirmPin4 = req.getParameter("confirmPin4");
            String confirmPin5 = req.getParameter("confirmPin5");
            String confirmPin6 = req.getParameter("confirmPin6");

            String confirmPin = confirmPin1 + confirmPin2 + confirmPin3 + confirmPin4 + confirmPin5 + confirmPin6;

            if (newPin.length() == 6 && newPin.equals(confirmPin)) {
                CustomerProfile currentProfile = profileDAO.getCustomerProfile(user.getId());
                boolean isUpdate = currentProfile != null && currentProfile.getPaymentPin() != null
                        && !currentProfile.getPaymentPin().isEmpty();

                boolean authorized = true;
                if (isUpdate) {
                    // Check old PIN
                    String oldPin1 = req.getParameter("oldPin1");
                    String oldPin2 = req.getParameter("oldPin2");
                    String oldPin3 = req.getParameter("oldPin3");
                    String oldPin4 = req.getParameter("oldPin4");
                    String oldPin5 = req.getParameter("oldPin5");
                    String oldPin6 = req.getParameter("oldPin6");
                    String oldPin = oldPin1 + oldPin2 + oldPin3 + oldPin4 + oldPin5 + oldPin6;

                    if (!com.primego.common.util.PasswordUtil.checkPassword(oldPin, currentProfile.getPaymentPin())) {
                        authorized = false;
                        req.setAttribute("message", "Incorrect current PIN.");
                        req.setAttribute("messageType", "error");
                    }
                }

                if (authorized) {
                    String hashedPin = com.primego.common.util.PasswordUtil.hashPassword(newPin);
                    if (profileDAO.updatePaymentPin(user.getId(), hashedPin)) {
                        req.setAttribute("message", "Payment PIN updated successfully!");
                        req.setAttribute("messageType", "success");
                    } else {
                        req.setAttribute("message", "Failed to update PIN. Database error.");
                        req.setAttribute("messageType", "error");
                    }
                }
            } else {
                req.setAttribute("message", "New PINs do not match or are incomplete.");
                req.setAttribute("messageType", "error");
            }
        }

        doGet(req, resp); // Reload page
    }
}
