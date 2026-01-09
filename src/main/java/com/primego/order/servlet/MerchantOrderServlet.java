package com.primego.order.servlet;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Order;
import com.primego.user.model.User;
import com.primego.wallet.dao.WalletDAO; // 🟢 1. 引入 WalletDAO

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

    private OrderDAO orderDAO = new OrderDAO();
    private WalletDAO walletDAO = new WalletDAO(); // 🟢 2. 初始化 WalletDAO

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
        req.getRequestDispatcher("/merchant/order/order_management.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); // 防止中文乱码
        String action = req.getParameter("action");

        // 获取当前登录商家 (用于扣款鉴权)
        HttpSession session = req.getSession(false);
        User merchant = (User) (session != null ? session.getAttribute("user") : null);

        if (merchant == null) {
            resp.sendRedirect(req.getContextPath() + "/public/login.jsp");
            return;
        }

        // === 1. 发货逻辑 (保持不变) ===
        if ("shipOrder".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String trackingNumber = req.getParameter("trackingNumber");

            if (orderIdStr != null && trackingNumber != null && !trackingNumber.trim().isEmpty()) {
                int orderId = Integer.parseInt(orderIdStr);
                orderDAO.shipOrder(orderId, trackingNumber);
            }
        }

        // === 🟢 3. 新增：处理退款逻辑 (这部分是你之前漏掉的) ===
        else if ("processRefund".equals(action)) {
            String orderIdStr = req.getParameter("orderId");
            String decision = req.getParameter("decision"); // "approve" 或 "reject"
            String merchantReason = req.getParameter("merchantReason");

            if (orderIdStr != null && decision != null) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderDAO.getOrderById(orderId);

                    if (order != null) {
                        if ("approve".equals(decision)) {
                            // >>> 商家同意 <<<

                            // ⭐⭐⭐ 临时修改：模拟退款成功，跳过 WalletDAO ⭐⭐⭐
                            // 等队友写好 WalletDAO 后，取消注释下面这行，删掉 boolean refundSuccess = true;
                            // boolean refundSuccess = walletDAO.refundToCustomer(merchant.getId(), order.getCustomerId(), order.getTotalAmount());

                            boolean refundSuccess = true; // 强行模拟成功，为了看 UI 效果

                            if (refundSuccess) {
                                // 2. 转账成功后，更新数据库状态为 REFUNDED
                                orderDAO.approveRefundStatus(orderId);
                                session.setAttribute("message", "Refund Approved (UI Test Mode). Status updated.");
                                session.setAttribute("messageType", "success");
                            } else {
                                session.setAttribute("message", "Refund failed. Insufficient wallet balance?");
                                session.setAttribute("messageType", "error");
                            }
                        } else if ("reject".equals(decision)) {
                            // >>> 商家拒绝 <<<

                            // 更新拒绝次数+1，记录理由，状态回退
                            orderDAO.rejectRefund(orderId, merchantReason);
                            session.setAttribute("message", "Refund Rejected.");
                            session.setAttribute("messageType", "warning");
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("message", "System Error processing refund.");
                    session.setAttribute("messageType", "error");
                }
            }
        }

        // 处理完后重定向回退款列表，方便查看结果
        resp.sendRedirect(req.getContextPath() + "/merchant/order/order_management?filter=return");
    }
}