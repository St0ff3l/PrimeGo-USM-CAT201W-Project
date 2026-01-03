<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.order.model.Cart" %>
<%@ page import="com.primego.order.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>

<%
    // Check if we are buying a single product directly or checking out the cart
    String productIdStr = request.getParameter("productId");
    // 定义一个布尔变量方便下面判断
    boolean isBuyNow = (productIdStr != null && !productIdStr.isEmpty());

    List<CartItem> orderItems = new ArrayList<>();
    BigDecimal subTotal = BigDecimal.ZERO;

    if (isBuyNow) {
        // Buy Now mode
        try {
            int productId = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            ProductDTO product = productDAO.getProductById(productId);
            if (product != null) {
                CartItem item = new CartItem(product, 1);
                orderItems.add(item);
                subTotal = item.getTotalPrice();
            }
        } catch (NumberFormatException e) {
            // Handle error
        }
    } else {
        // Cart Checkout mode
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart != null) {
            orderItems = cart.getItems();
            subTotal = cart.getTotalPrice();
        }
    }

    // If no items, redirect back
    if (orderItems.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Confirm Order - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; }

        /* Header styles handled by header_bar.jsp */

        .container { max-width: 1000px; margin: 140px auto 50px; padding: 0 20px; display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; align-items: start; }

        .card { background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.6); border-radius: 20px; padding: 25px; margin-bottom: 20px; }

        h2 { font-size: 1.2rem; margin-bottom: 20px; border-bottom: 1px solid rgba(0,0,0,0.1); padding-bottom: 10px; }

        /* 商品展示 */
        .order-item { display: flex; gap: 15px; align-items: center; margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px dashed #eee; }
        .order-item:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }

        .item-img { width: 80px; height: 80px; background: rgba(255,255,255,0.5); border-radius: 12px; display: flex; justify-content: center; align-items: center; font-size: 2rem; overflow: hidden; }
        .item-img img { width: 100%; height: 100%; object-fit: cover; }

        /* 配送选项 */
        .delivery-opt { display: flex; gap: 15px; margin-bottom: 15px; }
        .opt-box { flex: 1; border: 2px solid transparent; background: rgba(255,255,255,0.5); padding: 15px; border-radius: 12px; cursor: pointer; text-align: center; }
        .opt-box.selected { border-color: #FF3B30; background: rgba(255, 59, 48, 0.05); color: #FF3B30; font-weight: 600; }

        /* 表单输入 */
        .input-group { margin-bottom: 15px; }
        .input-field { width: 100%; padding: 12px; border-radius: 10px; border: 1px solid #ccc; background: rgba(255,255,255,0.8); }

        /* 摘要 */
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; color: #555; }
        .total-row { display: flex; justify-content: space-between; margin-top: 20px; font-weight: 700; font-size: 1.3rem; color: #2d3436; border-top: 2px dashed #ccc; padding-top: 20px; }

        .btn-pay { width: 100%; background: linear-gradient(45deg, #FF3B30, #FF9500); color: white; border: none; padding: 15px; border-radius: 15px; font-weight: 600; font-size: 1.1rem; cursor: pointer; margin-top: 20px; box-shadow: 0 5px 15px rgba(255, 59, 48, 0.3); }
        .btn-pay:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255, 59, 48, 0.5); }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<form action="<%= request.getContextPath() %>/placeOrder" method="post" id="orderForm">

    <input type="hidden" name="isBuyNow" value="<%= isBuyNow %>">
    <% if (isBuyNow) { %>
    <input type="hidden" name="productId" value="<%= productIdStr %>">
    <input type="hidden" name="quantity" id="hiddenQuantity" value="1">
    <% } %>

    <div class="container">
        <div class="left-col">
            <div class="card">
                <h2>Order Items (<%= orderItems.size() %>)</h2>
                <% for(CartItem item : orderItems) { %>
                <div class="order-item">
                    <div class="item-img">
                        <% if (item.getProduct().getPrimaryImageUrl() != null && !item.getProduct().getPrimaryImageUrl().isEmpty()) { %>
                        <img src="<%= request.getContextPath() + "/" + item.getProduct().getPrimaryImageUrl() %>" alt="<%= item.getProduct().getProductName() %>">
                        <% } else { %>
                        📦
                        <% } %>
                    </div>
                    <div>
                        <h4><%= item.getProduct().getProductName() %></h4>
                        <div style="display: flex; align-items: center; gap: 10px; margin: 5px 0;">
                            <span style="color:#666; font-size: 0.9rem;">Quantity:</span>
                            <input type="number" min="1" value="<%= item.getQuantity() %>"
                                   style="width: 60px; padding: 5px; border-radius: 5px; border: 1px solid #ccc;"
                                   onchange="updateQuantity(this, <%= item.getProduct().getProductPrice() %>)">
                        </div>
                        <p style="color:#FF3B30; font-weight:700;" class="item-total-price" data-unit-price="<%= item.getProduct().getProductPrice() %>">RM <%= String.format("%.2f", item.getTotalPrice()) %></p>
                    </div>
                </div>
                <% } %>
            </div>

            <div class="card">
                <h2>Delivery Method</h2>
                <div class="delivery-opt">
                    <div class="opt-box selected" onclick="selectOpt(this, 15)">🚚 Shipping</div>
                </div>

                <div id="shippingForm">
                    <div class="input-group">
                        <input type="text" name="fullName" class="input-field" placeholder="Full Name" required>
                    </div>
                    <div class="input-group">
                        <input type="text" name="address" class="input-field" placeholder="Address" required>
                    </div>
                    <div class="input-group">
                        <input type="text" name="phone" class="input-field" placeholder="Phone Number" required>
                    </div>
                </div>
            </div>
        </div>

        <div class="right-col">
            <div class="card">
                <h2>Summary</h2>
                <div class="summary-row"><span>Subtotal</span><span id="subTotal">RM <%= String.format("%.2f", subTotal) %></span></div>
                <div class="summary-row"><span>Delivery</span><span id="shipFee">RM 15.00</span></div>
                <div class="total-row"><span>Total</span><span id="totalDisplay" style="color:#FF3B30;">RM <%= String.format("%.2f", subTotal.add(new BigDecimal("15.00"))) %></span></div>

                <button type="submit" class="btn-pay">Pay Now</button>

                <% if(request.getAttribute("errorMessage") != null) { %>
                <p style="color:red; text-align:center; margin-top:10px;"><%= request.getAttribute("errorMessage") %></p>
                <% } %>
            </div>
        </div>
    </div>
</form>

<script>
    let basePrice = <%= subTotal %>;
    let shipCost = 15;

    function updateQuantity(input, unitPrice) {
        let quantity = parseInt(input.value);
        if (quantity < 1) {
            quantity = 1;
            input.value = 1;
        }

        // ⭐ 如果是 Buy Now 模式，同步数量到隐藏域
        let hiddenQty = document.getElementById("hiddenQuantity");
        if (hiddenQty) {
            hiddenQty.value = quantity;
        }

        // Update item total price display
        let itemContainer = input.closest('.order-item');
        let priceDisplay = itemContainer.querySelector('.item-total-price');
        let itemTotal = unitPrice * quantity;
        priceDisplay.innerText = "RM " + itemTotal.toFixed(2);

        // Recalculate subtotal
        let newSubTotal = 0;
        document.querySelectorAll('.item-total-price').forEach(el => {
            let priceText = el.innerText.replace('RM ', '');
            newSubTotal += parseFloat(priceText);
        });

        basePrice = newSubTotal;
        document.getElementById('subTotal').innerText = "RM " + basePrice.toFixed(2);
        updateSummary();
    }

    function selectOpt(el, cost) {
        document.querySelectorAll('.opt-box').forEach(b => b.classList.remove('selected'));
        el.classList.add('selected');

        shipCost = cost;
        document.getElementById('shippingForm').style.display = cost > 0 ? 'block' : 'none';
        updateSummary();
    }

    function updateSummary() {
        document.getElementById('shipFee').innerText = "RM " + shipCost.toFixed(2);
        let total = basePrice + shipCost;
        document.getElementById('totalDisplay').innerText = "RM " + total.toFixed(2);
    }
</script>

</body>
</html>