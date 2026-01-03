package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.user.model.Role;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/admin/product/review/action")
public class AdminProductReviewActionServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

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

        String idStr = req.getParameter("productId");
        String action = req.getParameter("action");
        String reason = req.getParameter("reason");

        if (idStr == null || action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/product/review/list");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/product/review/list");
            return;
        }

        boolean ok;
        String msg;

        if ("approve".equals(action)) {
            ok = productDAO.updateProductAuditByAdmin(productId, "APPROVED", null);
            msg = ok ? "approved" : "error";
        } else if ("reject".equals(action)) {
            String trimmedReason = (reason == null) ? null : reason.trim();
            ok = productDAO.updateProductAuditByAdmin(productId, "REJECTED", trimmedReason);
            msg = ok ? "rejected" : "error";
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/product/review?productId=" + productId);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/product/review?productId=" + productId + "&msg=" + msg);
    }
}
