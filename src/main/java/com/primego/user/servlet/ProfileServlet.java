package com.primego.user.servlet;

import com.primego.user.dao.ProfileDAO;
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
}
