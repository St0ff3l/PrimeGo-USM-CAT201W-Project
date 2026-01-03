package com.primego.product.servlet;

import com.primego.product.dao.ProductDAO;
import com.primego.product.dao.ProductImageDAO;
import com.primego.product.model.ProductDTO;
import com.primego.product.model.ProductImage;
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

@WebServlet("/admin/product/review")
public class AdminProductReviewDetailServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductImageDAO imageDAO = new ProductImageDAO();

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

        String idStr = req.getParameter("productId");
        if (idStr == null) {
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

        ProductDTO product = productDAO.getProductById(productId);
        List<ProductImage> images = imageDAO.getImagesByProductId(productId);

        req.setAttribute("product", product);
        req.setAttribute("images", images);

        req.getRequestDispatcher("/admin/product/review_detail.jsp").forward(req, resp);
    }
}

