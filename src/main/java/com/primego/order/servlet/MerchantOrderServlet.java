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

// Route: /merchant/order/order_management
@WebServlet("/merchant/order/order_management")
public class MerchantOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Authorization check: only logged-in merchants can access this page.
        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        // Forward to the return-address form for return-and-refund flows.
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

        // Load all orders belonging to the current merchant.
        List<Order> orders = orderDAO.getOrdersByMerchantId(user.getId());
        req.setAttribute("orders", orders);

        // Render the order management page.
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

        // Persist the merchant's return address for a specific order.
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

        // 1) Shipping flow
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

        // 2) Refund/return flow
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
                        // Normalize refund type.
                        String rt = (refundType == null || refundType.trim().isEmpty()) ? "MONEY_ONLY" : refundType.trim();
                        if (!"MONEY_ONLY".equals(rt) && !"RETURN_AND_REFUND".equals(rt)) {
                            rt = "MONEY_ONLY";
                        }

                        // For MONEY_ONLY, approving the request means refunding immediately.
                        if ("MONEY_ONLY".equals(rt) && "agree_return".equals(decision)) {
                            decision = "confirm_return_receipt";
                        }

                        // Case A: merchant agrees to a return (first step for RETURN_AND_REFUND).
                        if ("agree_return".equals(decision)) {
                            // For RETURN_AND_REFUND, a return address is required.
                            if ("RETURN_AND_REFUND".equals(rt)) {
                                resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?action=toReturnAddress&orderId=" + Integer.parseInt(orderIdStr));
                                return;
                            } else {
                                // MONEY_ONLY does not require a return address.
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

                        // Case B: merchant confirms receipt of returned items (final step, triggers refund).
                        else if ("confirm_return_receipt".equals(decision)) {
                            // Refund from platform escrow back to the customer.
                            boolean refundSuccess = walletDAO.refundFromEscrowToCustomer(
                                    order.getCustomerId(),
                                    order.getTotalAmount()
                            );

                            if (refundSuccess) {
                                // Update refund status to approved/refunded.
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

                        // Case C: merchant rejects the request.
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

        // Redirect back to the Returns tab so the merchant can see the latest state.
        resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
    }
}
