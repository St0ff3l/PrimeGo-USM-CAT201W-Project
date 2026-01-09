package com.primego.order.servlet;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Order;
import com.primego.product.dao.ProductDAO;
import com.primego.product.model.ProductDTO;
import com.primego.user.model.User;
import com.primego.wallet.dao.WalletDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/customer/orders")
public class CustomerOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        // 获取 URL 上的 action 参数
        String action = req.getParameter("action");

        // ⭐ 核心逻辑 1: 跳转到退款申请页面 (中间页)
        if ("toRefundPage".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.getOrderById(orderId);

                    // 安全检查：只能看自己的订单，且必须是已完成状态
                    if (order != null && order.getCustomerId() == userId && "COMPLETED".equals(order.getOrderStatus())) {
                        req.setAttribute("refundOrder", order);
                        req.getRequestDispatcher("/customer/order/refund_application.jsp").forward(req, resp);
                        return; // 转发后直接结束
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            // 如果出错，回到列表页
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
            return;
        }

        // === 默认逻辑：显示订单列表 ===
        String status = req.getParameter("status");

        // ⭐ 核心修改：处理 RETURNS 过滤器
        if ("RETURNS".equals(status)) {
            // 查询所有售后相关的订单 (包含被拒绝的 SHIPPED 订单)
            req.setAttribute("orderList", orderDAO.getReturnOrdersByUserId(userId));
            req.setAttribute("currentStatus", "RETURNS");
        } else if (status != null && !status.isEmpty() && !"ALL".equals(status)) {
            req.setAttribute("orderList", orderDAO.getOrdersByUserIdAndStatus(userId, status));
            req.setAttribute("currentStatus", status);
        } else {
            req.setAttribute("orderList", orderDAO.getOrdersByUserId(userId));
            req.setAttribute("currentStatus", "ALL");
        }

        req.getRequestDispatcher("/customer/order/my_order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        String status = req.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        if ("cancelOrder".equals(action)) {
            handleCancelOrder(req);
            resp.sendRedirect(req.getContextPath() + "/customer/orders?status=" + status);
            return;
        }

        if ("confirmReceipt".equals(action)) {
            handleConfirmReceipt(req);
            resp.sendRedirect(req.getContextPath() + "/customer/orders?status=" + status);
            return;
        }

        // Return/Refund request (SHIPPED only). Support both action names during migration.
        if ("processRefundRequest".equals(action) || "requestRefund".equals(action)) {
            handleReturnRequest(req);
            resp.sendRedirect(req.getContextPath() + "/customer/orders?status=" + status);
            return;
        }

        // 🟢 处理买家确认退货寄出
        if ("confirmReturnShipped".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String returnTrackingNumber = req.getParameter("returnTrackingNumber");

            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);

                    if (returnTrackingNumber == null || returnTrackingNumber.trim().isEmpty()) {
                        session.setAttribute("message", "Please enter return tracking number.");
                        session.setAttribute("messageType", "error");
                    } else {
                        orderDAO.buyerConfirmShipped(orderId, returnTrackingNumber.trim());
                        session.setAttribute("message", "Return shipment submitted. Waiting for merchant to receive.");
                        session.setAttribute("messageType", "success");
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    session.setAttribute("message", "Invalid order id.");
                    session.setAttribute("messageType", "error");
                }
            } else {
                session.setAttribute("message", "Missing order id.");
                session.setAttribute("messageType", "error");
            }
            // 重定向回 Returns 列表
            resp.sendRedirect(req.getContextPath() + "/customer/orders?status=RETURNS");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/customer/orders?status=" + status);
    }

    private void handleCancelOrder(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null) {
            session.setAttribute("message", "Missing order id.");
            session.setAttribute("messageType", "error");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getCustomerId() != userId) {
                session.setAttribute("message", "Order not found.");
                session.setAttribute("messageType", "error");
                return;
            }

            if (!"PAID".equals(order.getOrderStatus())) {
                session.setAttribute("message", "Only PAID orders can be cancelled.");
                session.setAttribute("messageType", "error");
                return;
            }

            // NOTE: This just updates status; wallet refund/restock logic is not implemented in current DAO.
            boolean success = orderDAO.updateOrderStatus(orderId, "CANCELLED");
            if (success) {
                session.setAttribute("message", "Order cancelled successfully.");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to cancel order.");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Failed to cancel order.");
            session.setAttribute("messageType", "error");
        }
    }

    // SHIPPED -> RETURN_REQUESTED
    private void handleReturnRequest(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        String orderIdStr = req.getParameter("orderId");
        String reason = req.getParameter("reason");
        String refundType = req.getParameter("refundType");

        if (orderIdStr == null) {
            session.setAttribute("message", "Missing order id.");
            session.setAttribute("messageType", "error");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getCustomerId() != userId) {
                session.setAttribute("message", "Order not found.");
                session.setAttribute("messageType", "error");
                return;
            }

            if (!"SHIPPED".equals(order.getOrderStatus())) {
                session.setAttribute("message", "Only SHIPPED orders can request a return.");
                session.setAttribute("messageType", "error");
                return;
            }

            // 7-day no-reason return window (using createdAt as fallback; ideally use shipped_at if available)
            long now = System.currentTimeMillis();
            long baseTime = (order.getCreatedAt() != null) ? order.getCreatedAt().getTime() : now;
            long daysDiff = (now - baseTime) / (1000L * 60 * 60 * 24);
            if (daysDiff > 7) {
                session.setAttribute("message", "Sorry, return period expired.");
                session.setAttribute("messageType", "error");
                return;
            }

            boolean success = orderDAO.requestRefund(orderId, reason, user.getId(), refundType);
            if (success) {
                session.setAttribute("message", "Return request submitted successfully!");
                session.setAttribute("messageType", "success");
            } else {
                session.setAttribute("message", "Failed to submit request.");
                session.setAttribute("messageType", "error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Failed to submit request.");
            session.setAttribute("messageType", "error");
        }
    }

    private void handleConfirmReceipt(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null) {
            session.setAttribute("message", "Missing order id.");
            session.setAttribute("messageType", "error");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getCustomerId() != userId) {
                session.setAttribute("message", "Order not found.");
                session.setAttribute("messageType", "error");
                return;
            }

            if (!"SHIPPED".equals(order.getOrderStatus())) {
                session.setAttribute("message", "Only shipped orders can be confirmed.");
                session.setAttribute("messageType", "error");
                return;
            }

            // SHIPPED -> COMPLETED
            if (!order.getOrderItems().isEmpty()) {
                int productId = order.getOrderItems().get(0).getProductId();
                ProductDTO product = productDAO.getProductById(productId);
                if (product != null) {
                    walletDAO.creditMerchantBalance(product.getMerchantId(), order.getTotalAmount());
                    orderDAO.updateOrderStatus(orderId, "COMPLETED");
                    session.setAttribute("message", "Order confirmed!");
                    session.setAttribute("messageType", "success");
                    return;
                }
            }

            session.setAttribute("message", "Failed to confirm order.");
            session.setAttribute("messageType", "error");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("message", "Failed to confirm order.");
            session.setAttribute("messageType", "error");
        }
    }
}
