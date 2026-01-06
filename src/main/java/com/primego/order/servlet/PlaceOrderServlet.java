package com.primego.order.servlet;

import com.primego.order.dao.CartDAO;
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
import com.primego.wallet.dao.WalletDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@WebServlet("/placeOrder")
public class PlaceOrderServlet extends HttpServlet {

    private OrderDAO orderDAO = new OrderDAO();
    private ProductDAO productDAO = new ProductDAO();
    private ProfileDAO profileDAO = new ProfileDAO();
    private WalletDAO walletDAO = new WalletDAO();
    private CartDAO cartDAO = new CartDAO();

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
        // Step 2: 准备分组数据 (按 MerchantId 分组，支持拆单)
        // =========================================================================
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String fullAddress = fullName + ", " + address + ", Phone: " + phone;

        // ⭐ 核心逻辑：使用 Map 按 MerchantId 分组存放商品
        // Key: MerchantId, Value: List<OrderItem>
        Map<Integer, List<OrderItem>> merchantItemsMap = new HashMap<>();

        String isBuyNow = request.getParameter("isBuyNow");
        String productIdStr = request.getParameter("productId");
        // 获取确认页面传来的真实购买数量
        String quantityStr = request.getParameter("quantity");

        String[] selectedIds = request.getParameterValues("selectedProductIds");
        List<String> selectedIdList = (selectedIds != null) ? Arrays.asList(selectedIds) : new ArrayList<>();

        if ("true".equals(isBuyNow) && productIdStr != null) {
            // === 场景 A: 立即购买 ===
            try {
                int productId = Integer.parseInt(productIdStr);
                int quantity = 1;
                if (quantityStr != null && !quantityStr.isEmpty()) {
                    quantity = Integer.parseInt(quantityStr);
                }

                ProductDTO product = productDAO.getProductById(productId);
                if (product != null) {
                    int merchantId = product.getMerchantId();
                    merchantItemsMap.putIfAbsent(merchantId, new ArrayList<>());

                    // 创建 Item 并放入 Map
                    OrderItem item = createOrderItem(product, quantity);
                    merchantItemsMap.get(merchantId).add(item);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        } else {
            // === 场景 B: 购物车结算 (核心：遍历并按商家分组) ===
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart != null && !cart.getItems().isEmpty()) {
                for (CartItem cartItem : cart.getItems()) {
                    String pId = String.valueOf(cartItem.getProduct().getProductId());
                    // 只处理被勾选的商品
                    if (!selectedIdList.isEmpty() && !selectedIdList.contains(pId)) {
                        continue;
                    }

                    // ⭐ 此处依赖 CartDAO 的修复，如果不修复，getMerchantId() 为 0，拆单会失败
                    int merchantId = cartItem.getProduct().getMerchantId();

                    merchantItemsMap.putIfAbsent(merchantId, new ArrayList<>());

                    // 创建 Item 并放入 Map
                    OrderItem item = createOrderItem(cartItem.getProduct(), cartItem.getQuantity());
                    merchantItemsMap.get(merchantId).add(item);
                }
            }
        }

        if (merchantItemsMap.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=EmptyOrder");
            return;
        }

        // =========================================================================
        // Step 3: 将分组 Map 转换为 List<Order> 并计算总价
        // =========================================================================
        List<Order> ordersToCreate = new ArrayList<>();
        BigDecimal grandTotal = BigDecimal.ZERO; // 所有子订单的总金额 (用于检查钱包)

        for (Map.Entry<Integer, List<OrderItem>> entry : merchantItemsMap.entrySet()) {
            List<OrderItem> items = entry.getValue();

            // 3.1 计算该子订单的商品总价
            BigDecimal subTotal = BigDecimal.ZERO;
            for (OrderItem item : items) {
                subTotal = subTotal.add(item.getSubtotal());
            }

            // 3.2 加上运费 (策略：每个拆分的子订单都单独加 15 运费)
            BigDecimal shippingFee = new BigDecimal("15.00");
            BigDecimal orderTotal = subTotal.add(shippingFee);

            // 3.3 创建子订单对象
            Order order = new Order();
            order.setCustomerId(userId);
            order.setAddress(fullAddress);
            order.setOrderItems(items);
            order.setTotalAmount(orderTotal);

            ordersToCreate.add(order);

            // 3.4 累加到全局总金额
            grandTotal = grandTotal.add(orderTotal);
        }

        // =========================================================================
        // Step 4: 检查钱包余额 (使用 grandTotal)
        // =========================================================================
        BigDecimal currentBalance = walletDAO.getBalance(userId);
        if (currentBalance.compareTo(grandTotal) < 0) {
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_failed.jsp");
            return;
        }

        // =========================================================================
        // Step 5: 调用批量创建方法 (⭐ 调用 OrderDAO 新增的方法)
        // =========================================================================
        List<Integer> createdIds = orderDAO.createOrdersBatch(ordersToCreate);

        if (createdIds != null && !createdIds.isEmpty()) {
            // === 成功 ===
            if (!"true".equals(isBuyNow)) {
                // 清理购物车中已购买的商品
                Cart cart = (Cart) session.getAttribute("cart");
                int cartId = cartDAO.getOrCreateCartId(userId);

                if (cart != null && !selectedIdList.isEmpty()) {
                    for (String id : selectedIdList) {
                        try {
                            int pId = Integer.parseInt(id);
                            cart.removeItem(pId); // 清除 Session 中的购物车项
                            cartDAO.removeItemFromCart(cartId, pId); // 清除数据库中的购物车项
                        } catch (NumberFormatException e) {
                            // ignore
                        }
                    }
                }
            }

            // ⭐ 关键修改：拼接所有生成的订单ID，传给成功页面
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < createdIds.size(); i++) {
                sb.append(createdIds.get(i));
                if (i < createdIds.size() - 1) {
                    sb.append(",");
                }
            }

            // 跳转到成功页面，参数名为 orderIds (注意多了个s)
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_success.jsp?orderIds=" + sb.toString());
        } else {
            // === 失败 ===
            request.setAttribute("errorMessage", "Order processing failed. Please try again.");
            request.getRequestDispatcher("/customer/order/order_confirmation.jsp").forward(request, response);
        }
    }

    // 辅助方法：将 ProductDTO 转换为 OrderItem (避免重复代码)
    private OrderItem createOrderItem(ProductDTO product, int quantity) {
        OrderItem item = new OrderItem();
        item.setProductId(product.getProductId());
        item.setProductName(product.getProductName());
        item.setPrice(product.getProductPrice());
        item.setQuantity(quantity);
        item.setSubtotal(product.getProductPrice().multiply(new BigDecimal(quantity)));
        return item;
    }
}