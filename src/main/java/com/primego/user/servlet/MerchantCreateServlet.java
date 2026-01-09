package com.primego.user.servlet;

import com.primego.user.dao.UserDAO;
import com.primego.user.model.MerchantProfile;
import com.primego.user.model.Role;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/admin/merchant/create")
public class MerchantCreateServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

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

        req.getRequestDispatcher("/admin/merchant_create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String contactInfo = req.getParameter("contactInfo");

        if (userDAO.findByUsername(username) != null) {
            req.setAttribute("error", "Username already exists.");
            req.getRequestDispatcher("/admin/merchant_create.jsp").forward(req, resp);
            return;
        }

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(password); // Will be hashed in DAO
        newUser.setRole(Role.MERCHANT);
        newUser.setStatus(1); // Active

        // Store Name is optional/not required at creation now
        MerchantProfile profile = new MerchantProfile(0, null, null, contactInfo); // ID set in DAO

        try {
            userDAO.createMerchant(newUser, profile);
            session.setAttribute("globalMessage", "Merchant account created successfully!");
            session.setAttribute("globalMessageType", "success");
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard?tab=users");
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/admin/merchant_create.jsp").forward(req, resp);
        }
    }
}
