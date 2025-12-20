package com.primego.user.servlet;

import com.primego.user.dao.UserDAO;
import com.primego.user.model.Role;
import com.primego.user.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. 设置请求编码，防止中文乱码
        req.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        User user = userDAO.validateCredentials(username, password);

        if (user != null) {
            // 2. 登录成功，创建 Session
            HttpSession session = req.getSession();
            session.setAttribute("user", user);

            // Redirect based on role
            if (user.getRole() == Role.MERCHANT) {
                resp.sendRedirect(req.getContextPath() + "/merchant/merchant_dashboard.jsp");
            } else {
                // Admin and Customer both go to index.jsp
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
            }

        } else {
            // 4. 登录失败
            req.setAttribute("error", "Invalid username or password");
            req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
        }
    }
}