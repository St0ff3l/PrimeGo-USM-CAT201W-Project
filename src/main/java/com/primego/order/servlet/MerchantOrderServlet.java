package com.primego.order.servlet;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Order;
import com.primego.user.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

// 访问路径: /merchant/order/manage
@WebServlet("/merchant/order/manage")
public class MerchantOrderServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. 检查权限
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        // 2. 查询该商家的所有订单
        List<Order> orders = orderDAO.getOrdersByMerchantId(user.getId());
        req.setAttribute("orders", orders);

        // 3. 转发到 JSP 页面
        req.getRequestDispatcher("/merchant/order/manage.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("shipOrder".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String trackingNumber = req.getParameter("trackingNumber"); // ⭐ 获取快递单号

            if (orderIdStr != null && trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                int orderId = Integer.parseInt(orderIdStr);
                // ⭐ 调用新的发货方法
                orderDAO.shipOrder(orderId, trackingNumber);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/merchant/order/manage");
    }
}