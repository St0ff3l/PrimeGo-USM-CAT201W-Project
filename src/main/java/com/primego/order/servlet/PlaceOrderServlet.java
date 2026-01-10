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

        // 1) Get the current logged-in user.
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }
        int userId = user.getId();

        // =========================================================================
        // Step 1: Validate the payment PIN.
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
        // Step 2: Prepare grouped items (group by merchantId to support split orders).
        // =========================================================================
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String fullAddress = fullName + ", " + address + ", Phone: " + phone;

        // Group items by merchantId.
        // Key: merchantId, Value: List<OrderItem>
        Map<Integer, List<OrderItem>> merchantItemsMap = new HashMap<>();

        String isBuyNow = request.getParameter("isBuyNow");
        String productIdStr = request.getParameter("productId");
        // Quantity selected on the confirmation page.
        String quantityStr = request.getParameter("quantity");

        String[] selectedIds = request.getParameterValues("selectedProductIds");
        List<String> selectedIdList = (selectedIds != null) ? Arrays.asList(selectedIds) : new ArrayList<>();

        if ("true".equals(isBuyNow) && productIdStr != null) {
            // Scenario A: Buy now
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

                    // Create an order item and add it to the merchant group.
                    OrderItem item = createOrderItem(product, quantity);
                    merchantItemsMap.get(merchantId).add(item);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        } else {
            // Scenario B: Checkout from cart (iterate cart items and group by merchant).
            Cart cart = (Cart) session.getAttribute("cart");
            if (cart != null && !cart.getItems().isEmpty()) {
                for (CartItem cartItem : cart.getItems()) {
                    String pId = String.valueOf(cartItem.getProduct().getProductId());
                    // Process only selected products.
                    if (!selectedIdList.isEmpty() && !selectedIdList.contains(pId)) {
                        continue;
                    }

                    // Relies on product data in the cart item containing a valid merchantId.
                    int merchantId = cartItem.getProduct().getMerchantId();

                    merchantItemsMap.putIfAbsent(merchantId, new ArrayList<>());

                    // Create an order item and add it to the merchant group.
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
        // Step 3: Convert the grouped map into a list of orders and calculate totals.
        // =========================================================================
        List<Order> ordersToCreate = new ArrayList<>();
        BigDecimal grandTotal = BigDecimal.ZERO; // Total amount across all sub-orders.

        for (Map.Entry<Integer, List<OrderItem>> entry : merchantItemsMap.entrySet()) {
            List<OrderItem> items = entry.getValue();

            // 3.1 Calculate subtotal for this sub-order.
            BigDecimal subTotal = BigDecimal.ZERO;
            for (OrderItem item : items) {
                subTotal = subTotal.add(item.getSubtotal());
            }

            // 3.2 Add shipping fee (policy: each sub-order charges its own shipping fee).
            BigDecimal shippingFee = new BigDecimal("15.00");
            BigDecimal orderTotal = subTotal.add(shippingFee);

            // 3.3 Build the sub-order.
            Order order = new Order();
            order.setCustomerId(userId);
            order.setAddress(fullAddress);
            order.setOrderItems(items);
            order.setTotalAmount(orderTotal);

            ordersToCreate.add(order);

            // 3.4 Accumulate to the overall total.
            grandTotal = grandTotal.add(orderTotal);
        }

        // =========================================================================
        // Step 4: Check wallet balance using grandTotal.
        // =========================================================================
        BigDecimal currentBalance = walletDAO.getBalance(userId);
        if (currentBalance.compareTo(grandTotal) < 0) {
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_failed.jsp");
            return;
        }

        // =========================================================================
        // Step 5: Create orders in batch.
        // =========================================================================
        List<Integer> createdIds = orderDAO.createOrdersBatch(ordersToCreate);

        if (createdIds != null && !createdIds.isEmpty()) {
            // Success
            if (!"true".equals(isBuyNow)) {
                // Remove purchased cart items from session and database.
                Cart cart = (Cart) session.getAttribute("cart");
                int cartId = cartDAO.getOrCreateCartId(userId);

                if (cart != null && !selectedIdList.isEmpty()) {
                    for (String id : selectedIdList) {
                        try {
                            int pId = Integer.parseInt(id);
                            cart.removeItem(pId); // Remove from session cart
                            cartDAO.removeItemFromCart(cartId, pId); // Remove from database cart
                        } catch (NumberFormatException e) {
                            // ignore
                        }
                    }
                }
            }

            // Build a comma-separated list of created order ids.
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < createdIds.size(); i++) {
                sb.append(createdIds.get(i));
                if (i < createdIds.size() - 1) {
                    sb.append(",");
                }
            }

            // Redirect to the success page. Parameter name: orderIds
            response.sendRedirect(request.getContextPath() + "/customer/order/payment_success.jsp?orderIds=" + sb.toString());
        } else {
            // Failure
            request.setAttribute("errorMessage", "Order processing failed. Please try again.");
            request.getRequestDispatcher("/customer/order/order_confirmation.jsp").forward(request, response);
        }
    }

    // Helper: convert ProductDTO into OrderItem to avoid duplicating mapping logic.
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