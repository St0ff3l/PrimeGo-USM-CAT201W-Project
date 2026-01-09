package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.product.model.ProductDTO;
import com.primego.user.model.Role;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/product/review/list")
public class AdminProductReviewListServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

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

        String filter = req.getParameter("filter");
        List<ProductDTO> products;

        if ("history".equals(filter)) {
            products = productDAO.getReviewedProducts();
            req.setAttribute("currentFilter", "history");
        } else {
            products = productDAO.getProductsPendingReview();
            req.setAttribute("currentFilter", "pending");
        }

        req.setAttribute("products", products);

        req.getRequestDispatcher("/admin/product/review_list.jsp").forward(req, resp);
    }
}
