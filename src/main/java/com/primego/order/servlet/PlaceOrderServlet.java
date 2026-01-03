package com.primego.order.controller;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Cart;
import com.primego.order.model.CartItem;
import com.primego.order.model.Order;
import com.primego.order.model.OrderItem;
import com.primego.product.dao.ProductDAO;
import com.primego.product.model.ProductDTO;
import com.primego.user.model.User;
import com.primego.user.dao.ProfileDAO;
import com.primego.user.model.CustomerProfile;
import com.primego.common.util.PasswordUtil;
// ⭐ 1. 引入 WalletDAO
import com.primego.wallet.dao.WalletDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

@WebServlet("/placeOrder")
public class PlaceOrderServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();
    private ProductDAO productDAO = new ProductDAO();
    private ProfileDAO profileDAO = new ProfileDAO();
    // ⭐ 2. 实例化 WalletDAO
    private WalletDAO walletDAO = new WalletDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // 1. 获取当前登录用户
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }
        int userId = user.getId();

        // =========================================================================
        // Step 1: 验证支付 PIN 码
        // =========================================================================
        String inputPin = request.getParameter("paymentPin");
        CustomerProfile profile = profileDAO.getCustomerProfile(userId);

        boolean isPinValid = false;
        if (profile != null && profile.getPaymentPin() != null && inputPin != null) {
            isPinValid = PasswordUtil.checkPassword(inputPin, profile.getPaymentPin());
        }

        if (!isPinValid) {
            request.setAttribute("errorMessage", "Invalid Payment PIN. Please try again.");
            request.setAttribute("showPinModal", true);
            request.getRequestDispatcher("/customer/order/order_confirmation.jsp").forward(request, response);
            return;
        }

        // =========================================================================
        // Step 2: 准备订单数据
        // =========================================================================
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String fullAddress = fullName + ", " + address + ", Phone: " + phone;

        BigDecimal shippingFee = new BigDecimal("15.00");

        Order order = new Order();
        order.setCustomerId(userId);
        order.setAddress(fullAddress);
        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal subTotal = BigDecimal.ZERO;

        // -----------------------------------------------------------
        // 处理商品 (Buy Now vs Cart)
        // -----------------------------------------------------------
        String isBuyNow = request.getParameter("isBuyNow");
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");
        String[] selectedIds = request.getParameterValues("selectedProductIds");
        List<String> selectedIdList = (selectedIds != null) ? Arrays.asList(selectedIds) : new ArrayList<>();

        if ("true".equals(isBuyNow) && productIdStr != null) {
            // === 场景 A: 立即购买 ===
            try {
                int productId = Integer.parseInt(productIdStr);
                int quantity = Integer.parseInt(quantityStr);
                ProductDTO product = productDAO.getProductById(productId);

                if (product != null) {
                    OrderItem item = new OrderItem();
                    item.setProductId(product.getProductId());
                    item.setProductName(product.getProductName());
                    item.setPrice(product.getProductPrice());
                    item.setQuantity(quantity);
                    item.setSubtotal(product.getProductPrice().multiply(new BigDecimal(quantity)));

                    orderItems.add(item);
                    subTotal = item.getSubtotal();
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        } else {
            // === 场景 B: 购物车结算 ===
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart != null && !cart.getItems().isEmpty()) {
                for (CartItem cartItem : cart.getItems()) {
                    String pId = String.valueOf(cartItem.getProduct().getProductId());
                    // 只处理选中的商品
                    if (!selectedIdList.isEmpty() && !selectedIdList.contains(pId)) {
                        continue;
                    }

                    OrderItem item = new OrderItem();
                    item.setProductId(cartItem.getProduct().getProductId());
                    item.setProductName(cartItem.getProduct().getProductName());
                    item.setPrice(cartItem.getProduct().getProductPrice());
                    item.setQuantity(cartItem.getQuantity());
                    item.setSubtotal(cartItem.getTotalPrice());

                    orderItems.add(item);
                }
                for (OrderItem oi : orderItems) {
                    subTotal = subTotal.add(oi.getSubtotal());
                }
            }
        }

        if (orderItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=EmptyOrder");
            return;
        }

        // 计算最终总价
        BigDecimal totalAmount = subTotal.add(shippingFee);
        order.setOrderItems(orderItems);
        order.setTotalAmount(totalAmount);

        // =========================================================================
        // ⭐ Step 3: 关键修改 —— 检查钱包余额
        // =========================================================================
        BigDecimal currentBalance = walletDAO.getBalance(userId);

        // 如果 余额 < 总金额
        if (currentBalance.compareTo(totalAmount) < 0) {
            // ❌ 余额不足，直接拦截！
            // 跳转到支付失败页面
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_failed.jsp");
            return; // 必须 return，防止后续代码执行
        }

        // =========================================================================
        // Step 4: 执行交易 (扣款 + 扣库存 + 生成订单)
        // =========================================================================
        int orderId = orderDAO.createOrder(order);

        if (orderId > 0) {
            // === 成功 ===
            if (!"true".equals(isBuyNow)) {
                // 清理购物车中已购买的商品
                Cart cart = (Cart) session.getAttribute("cart");
                if (cart != null && !selectedIdList.isEmpty()) {
                    for (String id : selectedIdList) {
                        int pId = Integer.parseInt(id);
                        cart.removeItem(pId);
                        // 建议这里也调用 cartDAO.removeItemFromCart(...)
                    }
                } else {
                    session.removeAttribute("cart");
                }
            }

            response.sendRedirect(request.getContextPath() + "/customer/order/payment_success.jsp?orderId=" + orderId);
        } else {
            // === 失败 (可能是库存不足等数据库原因) ===
            // 这里也可以选择跳到 failed 页面，或者返回确认页显示具体错误
            request.setAttribute("errorMessage", "Order processing failed. Please try again.");
            request.getRequestDispatcher("/customer/order/order_confirmation.jsp").forward(request, response);
        }
    }
}