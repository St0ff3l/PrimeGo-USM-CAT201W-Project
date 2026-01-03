<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.order.model.Cart" %>
<%@ page import="com.primego.order.model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Arrays" %>
<%-- ⭐ 导入 DAO 和 Model --%>
<%@ page import="com.primego.wallet.dao.WalletDAO" %>
<%@ page import="com.primego.user.dao.AddressDAO" %>
<%@ page import="com.primego.user.model.UserAddress" %>
<%@ page import="com.primego.user.model.User" %>

<%
    // ⭐ 0. 获取当前用户 (必须登录)
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    // ⭐ 1. 获取钱包余额
    WalletDAO walletDAO = new WalletDAO();
    BigDecimal walletBalance = walletDAO.getBalance(user.getId());

    // ⭐ 2. 获取默认地址 (用于初始化选中状态)
    AddressDAO addressDAO = new AddressDAO();
    UserAddress defaultAddress = addressDAO.getDefaultAddress(user.getId());

    // -----------------------------------------------------------------
    // 购物车/立即购买逻辑
    // -----------------------------------------------------------------

    String productIdStr = request.getParameter("productId");
    boolean isBuyNow = (productIdStr != null && !productIdStr.isEmpty());

    String[] selectedIds = request.getParameterValues("selectedProductIds");
    List<String> selectedIdList = (selectedIds != null) ? Arrays.asList(selectedIds) : new ArrayList<>();

    List<CartItem> orderItems = new ArrayList<>();
    BigDecimal subTotal = BigDecimal.ZERO;

    if (isBuyNow) {
        try {
            int productId = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            ProductDTO product = productDAO.getProductById(productId);
            if (product != null) {
                CartItem item = new CartItem(product, 1);
                orderItems.add(item);
                subTotal = item.getTotalPrice();
            }
        } catch (NumberFormatException e) {}
    } else {
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart != null) {
            for (CartItem item : cart.getItems()) {
                String pId = String.valueOf(item.getProduct().getProductId());
                if (selectedIdList.isEmpty() || selectedIdList.contains(pId)) {
                    orderItems.add(item);
                    subTotal = subTotal.add(item.getTotalPrice());
                }
            }
        }
    }

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

        .container { max-width: 1000px; margin: 140px auto 50px; padding: 0 20px; display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; align-items: start; }
        .card { background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.6); border-radius: 20px; padding: 25px; margin-bottom: 20px; }
        h2 { font-size: 1.2rem; margin-bottom: 20px; border-bottom: 1px solid rgba(0,0,0,0.1); padding-bottom: 10px; }

        /* 商品列表样式 */
        .order-item { display: flex; gap: 15px; align-items: center; margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px dashed #eee; }
        .order-item:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
        .item-img { width: 80px; height: 80px; background: rgba(255,255,255,0.5); border-radius: 12px; display: flex; justify-content: center; align-items: center; font-size: 2rem; overflow: hidden; }
        .item-img img { width: 100%; height: 100%; object-fit: cover; }

        /* 摘要和钱包样式 */
        .summary-row { display: flex; justify-content: space-between; margin-bottom: 10px; color: #555; }
        .total-row { display: flex; justify-content: space-between; margin-top: 20px; font-weight: 700; font-size: 1.3rem; color: #2d3436; border-top: 2px dashed #ccc; padding-top: 20px; }
        .btn-pay { width: 100%; background: linear-gradient(45deg, #FF3B30, #FF9500); color: white; border: none; padding: 15px; border-radius: 15px; font-weight: 600; font-size: 1.1rem; cursor: pointer; margin-top: 20px; box-shadow: 0 5px 15px rgba(255, 59, 48, 0.3); }
        .btn-pay:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255, 59, 48, 0.5); }
        .wallet-info { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; padding: 10px; border-radius: 10px; margin-bottom: 15px; text-align: center; font-weight: 600; }

        /* --- ⭐ 新增：地址卡片样式 --- */
        .delivery-opt { display: flex; gap: 15px; margin-bottom: 15px; }
        .opt-box { flex: 1; border: 2px solid transparent; background: rgba(255,255,255,0.5); padding: 15px; border-radius: 12px; cursor: pointer; text-align: center; }
        .opt-box.selected { border-color: #FF3B30; background: rgba(255, 59, 48, 0.05); color: #FF3B30; font-weight: 600; }

        .address-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .address-card {
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            padding: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            background: rgba(255,255,255,0.6);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 120px;
        }

        .address-card:hover { border-color: #FF9500; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.05); }

        .address-card.selected { border-color: #FF3B30; background: rgba(255, 59, 48, 0.05); }
        .address-card.selected::after {
            content: '✓'; position: absolute; top: 10px; right: 10px;
            background: #FF3B30; color: white; width: 20px; height: 20px;
            border-radius: 50%; font-size: 12px; display: flex; align-items: center; justify-content: center;
        }

        .addr-name { font-weight: 700; font-size: 1.1rem; margin-bottom: 5px; color: #2d3436; }
        .addr-phone { color: #888; font-size: 0.9rem; margin-bottom: 10px; }
        .addr-detail { color: #555; font-size: 0.9rem; line-height: 1.4; word-break: break-word; }

        .btn-add-address {
            border: 2px dashed #ccc; border-radius: 15px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            color: #888; text-decoration: none; transition: 0.3s;
            min-height: 120px; background: rgba(255,255,255,0.3);
        }
        .btn-add-address:hover { border-color: #FF3B30; color: #FF3B30; background: rgba(255,255,255,0.8); }
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

    <% if (selectedIds != null) {
        for (String id : selectedIds) { %>
    <input type="hidden" name="selectedProductIds" value="<%= id %>">
    <%     }
    } %>

    <div class="container">
        <div class="left-col">
            <div class="card">
                <h2>Order Items (<%= orderItems.size() %>)</h2>
                <% for(CartItem item : orderItems) { %>
                <div class="order-item">
                    <div class="item-img">
                        <% if (item.getProduct().getPrimaryImageUrl() != null && !item.getProduct().getPrimaryImageUrl().isEmpty()) { %>
                        <img src="<%= request.getContextPath() + "/" + item.getProduct().getPrimaryImageUrl() %>" alt="<%= item.getProduct().getProductName() %>">
                        <% } else { %>📦<% } %>
                    </div>
                    <div>
                        <h4><%= item.getProduct().getProductName() %></h4>
                        <div style="display: flex; align-items: center; gap: 10px; margin: 5px 0;">
                            <span style="color:#666; font-size: 0.9rem;">Quantity:</span>

                            <%-- ⭐ 获取库存并设置 max 属性，传入库存到 updateQuantity 函数 --%>
                            <% int stock = item.getProduct().getProductStockQuantity(); %>
                            <input type="number" min="1" max="<%= stock %>" value="<%= item.getQuantity() %>"
                                   style="width: 60px; padding: 5px; border-radius: 5px; border: 1px solid #ccc;"
                                   onchange="updateQuantity(this, <%= item.getProduct().getProductPrice() %>, <%= stock %>)">

                            <%-- ⭐ 显示最大库存提示 --%>
                            <span style="font-size: 0.8rem; color: #999; margin-left: 5px;">(Max: <%= stock %>)</span>
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

                <%-- ⭐ 关键修改：隐藏的输入框 (Servlet 接收这些数据) --%>
                <%-- 默认填充 Default Address 的数据，如果用户点击了其他卡片，JS 会更新这里的值 --%>
                <input type="hidden" name="fullName" id="inputName" value="<%= defaultAddress != null ? defaultAddress.getRecipientName() : "" %>">
                <input type="hidden" name="phone" id="inputPhone" value="<%= defaultAddress != null ? defaultAddress.getPhone() : "" %>">
                <input type="hidden" name="address" id="inputAddress" value="<%= defaultAddress != null ? defaultAddress.getFullAddress() : "" %>">

                <div class="address-grid">
                    <%-- ⭐ 1. 渲染默认地址卡片 (如果存在) --%>
                    <% if (defaultAddress != null) { %>
                    <div class="address-card selected"
                         onclick="selectAddress(this, '<%= defaultAddress.getRecipientName() %>', '<%= defaultAddress.getPhone() %>', '<%= defaultAddress.getFullAddress() %>')">
                        <div>
                            <div class="addr-name"><%= defaultAddress.getRecipientName() %> <span style="font-size:0.8rem; color:#FF3B30; border:1px solid #FF3B30; padding:1px 5px; border-radius:4px; margin-left:5px;">Default</span></div>
                            <div class="addr-phone"><%= defaultAddress.getPhone() %></div>
                            <div class="addr-detail"><%= defaultAddress.getFullAddress() %></div>
                        </div>
                    </div>
                    <% } else { %>
                    <%-- 如果没有默认地址，提示用户添加 --%>
                    <div style="grid-column: 1 / -1; color:#666; font-style:italic; padding:10px;">
                        You don't have a default address. Please add one.
                    </div>
                    <% } %>

                    <%-- ⭐ 2. 添加地址按钮 (链接已修正为 ProfileServlet) --%>
                    <a href="${pageContext.request.contextPath}/profile?tab=addresses" class="btn-add-address">
                        <span style="font-size:24px;">+</span>
                        <span>Add New Address</span>
                    </a>
                </div>
            </div>
        </div>

        <div class="right-col">
            <div class="card">
                <h2>Summary</h2>
                <%-- 显示钱包余额 --%>
                <div class="wallet-info">
                    Wallet Balance: RM <%= String.format("%.2f", walletBalance) %>
                </div>

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

    // ⭐ 选择地址卡片的逻辑
    function selectAddress(card, name, phone, address) {
        // 1. 移除其他卡片的选中样式
        document.querySelectorAll('.address-card').forEach(c => c.classList.remove('selected'));
        // 2. 选中当前卡片
        card.classList.add('selected');
        // 3. 填充隐藏域
        document.getElementById('inputName').value = name;
        document.getElementById('inputPhone').value = phone;
        document.getElementById('inputAddress').value = address;
    }

    // ⭐ 修改：增加 maxStock 参数进行校验
    function updateQuantity(input, unitPrice, maxStock) {
        let quantity = parseInt(input.value);

        // 1. 检查最小值
        if (quantity < 1 || isNaN(quantity)) {
            quantity = 1;
            input.value = 1;
        }

        // 2. ⭐ 检查库存上限
        if (quantity > maxStock) {
            alert("Sorry, only " + maxStock + " units available in stock.");
            quantity = maxStock;
            input.value = maxStock; // 重置输入框的值
        }

        let hiddenQty = document.getElementById("hiddenQuantity");
        if (hiddenQty) hiddenQty.value = quantity;

        let itemContainer = input.closest('.order-item');
        let priceDisplay = itemContainer.querySelector('.item-total-price');
        let itemTotal = unitPrice * quantity;
        priceDisplay.innerText = "RM " + itemTotal.toFixed(2);

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