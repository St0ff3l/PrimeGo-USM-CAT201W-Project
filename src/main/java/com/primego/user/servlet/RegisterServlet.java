package com.primego.user.servlet;

import com.primego.user.dao.UserDAO;
import com.primego.user.model.Role;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/signup.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String confirmEmail = req.getParameter("confirmEmail");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Server-side validation
        if (!email.equals(confirmEmail)) {
            req.setAttribute("error", "Emails do not match");
            req.getRequestDispatcher("/public/signup.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match");
            req.getRequestDispatcher("/public/signup.jsp").forward(req, resp);
            return;
        }

        if (userDAO.findByUsername(username) != null) {
            req.setAttribute("error", "Username already exists");
            req.getRequestDispatcher("/public/signup.jsp").forward(req, resp);
            return;
        }

        // Create new user (Default role: CUSTOMER)
        User newUser = new User(username, password, Role.CUSTOMER);
        boolean success = userDAO.createUser(newUser, email);

        if (success) {
            // Redirect to login page with success message (optional: could pass via session or URL param)
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
        } else {
            req.setAttribute("error", "Registration failed. Please try again.");
            req.getRequestDispatcher("/public/signup.jsp").forward(req, resp);
        }
    }
}
