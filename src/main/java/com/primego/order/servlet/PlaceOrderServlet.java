package com.primego.order.controller;

import com.primego.order.dao.OrderDAO;
import com.primego.order.model.Cart;
import com.primego.order.model.CartItem;
import com.primego.order.model.Order;
import com.primego.order.model.OrderItem;
import com.primego.product.dao.ProductDAO;
import com.primego.product.model.ProductDTO;
import com.primego.user.model.User;

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

@WebServlet("/placeOrder")
public class PlaceOrderServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();
    private ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // 1. 获取当前登录用户
        User user = (User) session.getAttribute("user");
        if (user == null) {
            // 修复路径：使用 request.getContextPath() 确保跳转正确
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }
        int userId = user.getId();

        // 2. 获取表单收货信息
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String fullAddress = fullName + ", " + address + ", Phone: " + phone;

        // 运费 (固定)
        BigDecimal shippingFee = new BigDecimal("15.00");

        // 3. 准备订单数据
        Order order = new Order();
        order.setCustomerId(userId);
        order.setAddress(fullAddress);
        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal subTotal = BigDecimal.ZERO;

        // 4. 判断来源：直接购买 (Buy Now) 还是 购物车结算 (Cart)
        String isBuyNow = request.getParameter("isBuyNow");
        String productIdStr = request.getParameter("productId");
        String quantityStr = request.getParameter("quantity");

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
                    OrderItem item = new OrderItem();
                    item.setProductId(cartItem.getProduct().getProductId());
                    item.setProductName(cartItem.getProduct().getProductName());
                    item.setPrice(cartItem.getProduct().getProductPrice());
                    item.setQuantity(cartItem.getQuantity());
                    item.setSubtotal(cartItem.getTotalPrice());

                    orderItems.add(item);
                }
                subTotal = cart.getTotalPrice();
            }
        }

        // 如果订单为空，跳回首页 (修复路径)
        if (orderItems.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=EmptyOrder");
            return;
        }

        order.setOrderItems(orderItems);
        order.setTotalAmount(subTotal.add(shippingFee)); // 总价 + 运费

        // 5. 调用 DAO 执行事务
        int orderId = orderDAO.createOrder(order);

        if (orderId > 0) {
            // 6. 成功处理
            // 如果是购物车结算，清空 Session 中的购物车
            if (!"true".equals(isBuyNow)) {
                session.removeAttribute("cart");
            }

            // ⭐⭐⭐ 关键修复：添加完整的文件夹路径，解决 404 问题 ⭐⭐⭐
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_success.jsp?orderId=" + orderId);

        } else {
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_failed.jsp");
        }
    }
}