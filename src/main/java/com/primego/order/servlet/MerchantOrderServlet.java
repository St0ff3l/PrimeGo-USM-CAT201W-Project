package com.primego.order.servlet;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Order;
import com.primego.user.model.User;
import com.primego.wallet.dao.WalletDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

// 访问路径: /merchant/order/order_management
@WebServlet("/merchant/order/order_management")
public class MerchantOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. 权限检查
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        // ✅ 新增：返回地址填写页
        String action = req.getParameter("action");
        if ("toReturnAddress".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            if (orderIdStr != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.getOrderById(orderId);
                    req.setAttribute("order", order);
                    req.getRequestDispatcher("/merchant/order/return_address.jsp").forward(req, resp);
                    return;
                } catch (NumberFormatException e) {
                    session.setAttribute("message", "Invalid order id.");
                    session.setAttribute("messageType", "error");
                }
            } else {
                session.setAttribute("message", "Missing order id.");
                session.setAttribute("messageType", "error");
            }
            resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
            return;
        }

        // 2. 查询该商家的所有订单
        List<Order> orders = orderDAO.getOrdersByMerchantId(user.getId());
        req.setAttribute("orders", orders);

        // 3. 转发
        req.getRequestDispatcher("/merchant/order/order_management.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        HttpSession session = req.getSession(false);
        User merchant = (User) (session != null ? session.getAttribute("user") : null);

        if (merchant == null) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        // ✅ 新增：保存退货地址
        if ("saveReturnAddress".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String returnAddress = req.getParameter("returnAddress");

            if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
                session.setAttribute("message", "Missing order id.");
                session.setAttribute("messageType", "error");
                resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
                return;
            }

            try {
                int orderId = Integer.parseInt(orderIdStr);
                if (returnAddress == null || returnAddress.trim().isEmpty()) {
                    session.setAttribute("message", "Please enter return address.");
                    session.setAttribute("messageType", "error");
                    resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?action=toReturnAddress&orderId=" + orderId);
                    return;
                }

                boolean ok = orderDAO.agreeReturn(orderId, returnAddress.trim());
                if (ok) {
                    session.setAttribute("message", "Return address saved. Waiting for customer to ship back.");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Failed to save return address. Please try again.");
                    session.setAttribute("messageType", "error");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("message", "Invalid order id.");
                session.setAttribute("messageType", "error");
            }

            resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
            return;
        }

        // === 1. 发货逻辑 ===
        if ("shipOrder".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String trackingNumber = req.getParameter("trackingNumber");

            if (orderIdStr == null || trackingNumber == null || trackingNumber.trim().isEmpty()) {
                session.setAttribute("message", "Missing order id or tracking number.");
                session.setAttribute("messageType", "error");
            } else {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    boolean updated = orderDAO.shipOrder(orderId, trackingNumber.trim());
                    if (updated) {
                        session.setAttribute("message", "Order shipped successfully!");
                        session.setAttribute("messageType", "success");
                    } else {
                        session.setAttribute("message", "Failed to ship order. Please try again.");
                        session.setAttribute("messageType", "error");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("message", "System error while shipping order.");
                    session.setAttribute("messageType", "error");
                }
            }
        }

        // === 2. 处理退款逻辑 ===
        else if ("processRefund".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String decision = req.getParameter("decision");
            String merchantReason = req.getParameter("merchantReason");
            String refundType = req.getParameter("refundType");

            if (orderIdStr == null || orderIdStr.trim().isEmpty() || decision == null || decision.trim().isEmpty()) {
                session.setAttribute("message", "Missing order id or decision.");
                session.setAttribute("messageType", "error");
            } else {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.getOrderById(orderId);

                    if (order == null) {
                        session.setAttribute("message", "Order not found.");
                        session.setAttribute("messageType", "error");
                    } else {
                        String rt = (refundType == null || refundType.trim().isEmpty()) ? "MONEY_ONLY" : refundType.trim();
                        if (!"MONEY_ONLY".equals(rt) && !"RETURN_AND_REFUND".equals(rt)) {
                            rt = "MONEY_ONLY";
                        }

                        // MONEY_ONLY: merchant should not do "agree_return" step; approve means refund now.
                        if ("MONEY_ONLY".equals(rt) && "agree_return".equals(decision)) {
                            decision = "confirm_return_receipt";
                        }

                        // === 场景 A: 商家同意退货 (第一步) ===
                        if ("agree_return".equals(decision)) {
                            // For RETURN_AND_REFUND, merchant must provide a return address
                            if ("RETURN_AND_REFUND".equals(rt)) {
                                resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?action=toReturnAddress&orderId=" + Integer.parseInt(orderIdStr));
                                return;
                            } else {
                                // MONEY_ONLY doesn't need return address
                                boolean ok = orderDAO.agreeReturn(orderId);
                                if (ok) {
                                    session.setAttribute("message", "Request Accepted. Waiting for customer to return items.");
                                    session.setAttribute("messageType", "success");
                                } else {
                                    session.setAttribute("message", "Failed to accept return request. Please try again.");
                                    session.setAttribute("messageType", "error");
                                }
                            }
                        }

                        // === 场景 B: 商家确认收到退货 (最后一步 - 退钱) ===
                        else if ("confirm_return_receipt".equals(decision)) {
                            // 1) 平台托管退款：只把钱退回给买家，不扣商家
                            boolean refundSuccess = walletDAO.refundFromEscrowToCustomer(
                                    order.getCustomerId(),
                                    order.getTotalAmount()
                            );

                            if (refundSuccess) {
                                // 2) 更新状态为 APPROVED / REFUNDED
                                boolean ok = orderDAO.approveRefundStatus(orderId);
                                if (ok) {
                                    session.setAttribute("message", "Refund processed successfully.");
                                    session.setAttribute("messageType", "success");
                                } else {
                                    session.setAttribute("message", "Refund sent but failed to update order status.");
                                    session.setAttribute("messageType", "error");
                                }
                            } else {
                                session.setAttribute("message", "Refund failed. Please try again.");
                                session.setAttribute("messageType", "error");
                            }
                        }

                        // === 场景 C: 商家拒绝 ===
                        else if ("reject".equals(decision)) {
                            if (merchantReason == null || merchantReason.trim().isEmpty()) {
                                session.setAttribute("message", "Please provide a rejection reason.");
                                session.setAttribute("messageType", "error");
                            } else {
                                boolean ok = orderDAO.rejectRefund(orderId, merchantReason);
                                if (ok) {
                                    session.setAttribute("message", "Refund Rejected.");
                                    session.setAttribute("messageType", "warning");
                                } else {
                                    session.setAttribute("message", "Failed to reject refund. Please try again.");
                                    session.setAttribute("messageType", "error");
                                }
                            }
                        } else {
                            session.setAttribute("message", "Invalid decision: " + decision);
                            session.setAttribute("messageType", "error");
                        }
                    }

                } catch (NumberFormatException e) {
                    session.setAttribute("message", "Invalid order id.");
                    session.setAttribute("messageType", "error");
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("message", "System Error processing refund.");
                    session.setAttribute("messageType", "error");
                }
            }
        }

        // 重定向回 Returns 标签页，让商家看到处理结果
        resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
    }
}
