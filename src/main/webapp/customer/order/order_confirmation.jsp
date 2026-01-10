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
<%-- ⭐ 新增导入：用于检查 PIN 码 --%>
<%@ page import="com.primego.user.dao.ProfileDAO" %>
<%@ page import="com.primego.user.model.CustomerProfile" %>
<%-- ⭐ 新增导入：用于计算商家数量 --%>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>

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

    // ⭐ 2. 获取默认地址
    AddressDAO addressDAO = new AddressDAO();
    UserAddress defaultAddress = addressDAO.getDefaultAddress(user.getId());

    // ⭐ 3. 检查用户是否设置了 PIN 码
    ProfileDAO profileDAO = new ProfileDAO();
    CustomerProfile profile = profileDAO.getCustomerProfile(user.getId());
    boolean hasPin = (profile != null && profile.getPaymentPin() != null && !profile.getPaymentPin().isEmpty());

    // -----------------------------------------------------------------
    // 购物车/立即购买逻辑
    // -----------------------------------------------------------------

    String productIdStr = request.getParameter("productId");
    boolean isBuyNow = (productIdStr != null && !productIdStr.isEmpty());

    String[] selectedIds = request.getParameterValues("selectedProductIds");
    List<String> selectedIdList = (selectedIds != null) ? Arrays.asList(selectedIds) : new ArrayList<>();

    List<CartItem> orderItems = new ArrayList<>();
    BigDecimal subTotal = BigDecimal.ZERO;

    // ⭐ 新增：定义 buyNowQuantity 变量，默认为 1
    int buyNowQuantity = 1;

    if (isBuyNow) {
        try {
            int productId = Integer.parseInt(productIdStr);

            // ⭐ 修复点：尝试从请求中获取数量，而不是默认 1
            String qtyParam = request.getParameter("quantity");
            if (qtyParam != null && !qtyParam.isEmpty()) {
                buyNowQuantity = Integer.parseInt(qtyParam);
            }

            ProductDAO productDAO = new ProductDAO();
            ProductDTO product = productDAO.getProductById(productId);
            if (product != null) {
                // 使用获取到的数量创建 CartItem
                CartItem item = new CartItem(product, buyNowQuantity);
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

    // ========================================================
    // ⭐ 新增：计算涉及的商家数量，以便正确计算运费
    // ========================================================
    Set<Integer> merchantSet = new HashSet<>();
    for (CartItem item : orderItems) {
        if (item.getProduct() != null) {
            merchantSet.add(item.getProduct().getMerchantId());
        }
    }
    int merchantCount = merchantSet.isEmpty() ? 1 : merchantSet.size();

    // 基础运费 RM 15.00 * 商家数量
    BigDecimal singleShipFee = new BigDecimal("15.00");
    BigDecimal totalShipFee = singleShipFee.multiply(new BigDecimal(merchantCount));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Confirm Order - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
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
        .btn-pay { width: 100%; background: linear-gradient(45deg, #FF3B30, #FF9500); color: white; border: none; padding: 15px; border-radius: 15px; font-weight: 600; font-size: 1.1rem; cursor: pointer; margin-top: 20px; box-shadow: 0 5px 15px rgba(255, 59, 48, 0.3); transition: 0.3s; }
        .btn-pay:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(255, 59, 48, 0.5); }
        .btn-pay:disabled { background: #ccc; cursor: not-allowed; transform: none; box-shadow: none; }

        .wallet-info { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; padding: 10px; border-radius: 10px; margin-bottom: 15px; text-align: center; font-weight: 600; }

        /* 地址卡片样式 */
        .delivery-opt { display: flex; gap: 15px; margin-bottom: 15px; }
        .opt-box { flex: 1; border: 2px solid transparent; background: rgba(255,255,255,0.5); padding: 15px; border-radius: 12px; cursor: pointer; text-align: center; }
        .opt-box.selected { border-color: #FF3B30; background: rgba(255, 59, 48, 0.05); color: #FF3B30; font-weight: 600; }

        .address-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 15px; margin-top: 15px; }
        .address-card { border: 2px solid #e0e0e0; border-radius: 15px; padding: 15px; cursor: pointer; transition: all 0.3s ease; background: rgba(255,255,255,0.6); position: relative; display: flex; flex-direction: column; justify-content: space-between; min-height: 120px; }
        .address-card:hover { border-color: #FF9500; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .address-card.selected { border-color: #FF3B30; background: rgba(255, 59, 48, 0.05); }
        .address-card.selected::after { content: '✓'; position: absolute; top: 10px; right: 10px; background: #FF3B30; color: white; width: 20px; height: 20px; border-radius: 50%; font-size: 12px; display: flex; align-items: center; justify-content: center; }
        .addr-name { font-weight: 700; font-size: 1.1rem; margin-bottom: 5px; color: #2d3436; }
        .addr-phone { color: #888; font-size: 0.9rem; margin-bottom: 10px; }
        .addr-detail { color: #555; font-size: 0.9rem; line-height: 1.4; word-break: break-word; }
        .btn-add-address { border: 2px dashed #ccc; border-radius: 15px; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #888; text-decoration: none; transition: 0.3s; min-height: 120px; background: rgba(255,255,255,0.3); }
        .btn-add-address:hover { border-color: #FF3B30; color: #FF3B30; background: rgba(255,255,255,0.8); }

        /* --- ⭐ Modal Styles (弹窗样式) --- */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.5); backdrop-filter: blur(8px);
            display: none; /* 默认隐藏 */
            justify-content: center; align-items: center;
            z-index: 1000; animation: fadeIn 0.3s;
        }
        .modal-overlay.active { display: flex; }

        .modal-box {
            background: white; padding: 40px; border-radius: 25px;
            text-align: center; box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            width: 400px; position: relative;
        }
        .modal-icon { font-size: 3.5rem; color: #FF9500; margin-bottom: 10px; }

        /* PIN 输入框容器 */
        .pin-input-container {
            display: flex; gap: 10px; justify-content: center; margin: 25px 0;
        }
        .pin-digit {
            width: 45px; height: 50px; border-radius: 10px;
            border: 1px solid #ccc; text-align: center; font-size: 1.5rem;
            font-weight: bold; color: #333; outline: none; transition: 0.3s;
        }
        .pin-digit:focus { border-color: #FF9500; box-shadow: 0 0 0 4px rgba(255, 149, 0, 0.2); }

        .btn-modal-confirm {
            background: #FF9500; color: white; border: none; padding: 12px 40px;
            border-radius: 30px; font-weight: 600; cursor: pointer; width: 100%;
            font-size: 1rem; transition: 0.3s; margin-top: 10px;
        }
        .btn-modal-confirm:hover { background: #e68600; transform: translateY(-2px); }

        .btn-modal-cancel {
            background: transparent; border: 1px solid #ccc; color: #666;
            padding: 12px 40px; border-radius: 30px; font-weight: 600; cursor: pointer;
            width: 100%; margin-top: 10px; transition: 0.3s;
        }
        .btn-modal-cancel:hover { background: #f5f5f5; }

        .btn-modal-setup {
            background: #FF9500; color: white; text-decoration: none; display: inline-block;
            padding: 12px 30px; border-radius: 30px; font-weight: 600; margin-top: 20px;
        }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<form action="<%= request.getContextPath() %>/placeOrder" method="post" id="orderForm">

    <input type="hidden" name="isBuyNow" value="<%= isBuyNow %>">
    <% if (isBuyNow) { %>
    <input type="hidden" name="productId" value="<%= productIdStr %>">
    <%-- ⭐ 修复点：value 属性改为动态变量 buyNowQuantity --%>
    <input type="hidden" name="quantity" id="hiddenQuantity" value="<%= buyNowQuantity %>">
    <% } %>

    <% if (selectedIds != null) {
        for (String id : selectedIds) { %>
    <input type="hidden" name="selectedProductIds" value="<%= id %>">
    <%     }
    } %>

    <%-- ⭐ 隐藏的 input，用于接收 Modal 输入的最终 PIN 码提交给后台 --%>
    <input type="hidden" name="paymentPin" id="finalPaymentPin">

    <div class="container">
        <div class="left-col">
            <div class="card">
                <h2>Order Items (<%= orderItems.size() %>)</h2>
                <% for(CartItem item : orderItems) { %>
                <div class="order-item">
                    <div class="item-img">
                        <img src="<%= (item.getProduct().getPrimaryImageUrl() != null && !item.getProduct().getPrimaryImageUrl().isEmpty()) ? request.getContextPath() + "/" + item.getProduct().getPrimaryImageUrl() : request.getContextPath() + "/assets/images/product-placeholder.svg" %>"
                             alt="<%= item.getProduct().getProductName() %>"
                             onerror="this.onerror=null; this.src='<%= request.getContextPath() %>/assets/images/product-placeholder.svg';">
                    </div>
                    <div>
                        <h4><%= item.getProduct().getProductName() %></h4>
                        <div style="display: flex; align-items: center; gap: 10px; margin: 5px 0;">
                            <span style="color:#666; font-size: 0.9rem;">Quantity:</span>

                            <% int stock = item.getProduct().getProductStockQuantity(); %>

                            <%-- ⭐ onkeydown 拦截回车，防止意外提交 --%>
                            <input type="number" min="1" max="<%= stock %>" value="<%= item.getQuantity() %>"
                                   style="width: 60px; padding: 5px; border-radius: 5px; border: 1px solid #ccc;"
                                   onkeydown="if(event.key === 'Enter') { event.preventDefault(); this.blur(); }"
                                   onchange="updateQuantity(this, <%= item.getProduct().getProductPrice() %>, <%= stock %>)">

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
                    <%-- ⭐ 修改：显示运费金额 (Java算好的) --%>
                    <div class="opt-box selected">🚚 Shipping</div>
                </div>

                <input type="hidden" name="fullName" id="inputName" value="<%= defaultAddress != null ? defaultAddress.getRecipientName() : "" %>">
                <input type="hidden" name="phone" id="inputPhone" value="<%= defaultAddress != null ? defaultAddress.getPhone() : "" %>">
                <input type="hidden" name="address" id="inputAddress" value="<%= defaultAddress != null ? defaultAddress.getFullAddress() : "" %>">

                <div class="address-grid">
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
                    <div style="grid-column: 1 / -1; color:#666; font-style:italic; padding:10px;">
                        You don't have a default address. Please add one.
                    </div>
                    <% } %>

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
                <div class="wallet-info">
                    Wallet Balance: RM <%= String.format("%.2f", walletBalance) %>
                </div>

                <div class="summary-row"><span>Subtotal</span><span id="subTotal">RM <%= String.format("%.2f", subTotal) %></span></div>

                <%-- ⭐ 修改：显示商家数量和总运费 --%>
                <div class="summary-row">
                    <span>Delivery (<%= merchantCount %> Merchant<%= merchantCount > 1 ? "s" : "" %>)</span>
                    <span id="shipFee">RM <%= String.format("%.2f", totalShipFee) %></span>
                </div>

                <%-- ⭐ 修改：显示总价 (subTotal + totalShipFee) --%>
                <div class="total-row"><span>Total</span><span id="totalDisplay" style="color:#FF3B30;">RM <%= String.format("%.2f", subTotal.add(totalShipFee)) %></span></div>

                <%-- ⭐ 修改：按钮类型改为 button，点击触发 handlePayClick --%>
                <button type="button" class="btn-pay" onclick="handlePayClick()">Pay Now</button>

                <% if(request.getAttribute("errorMessage") != null) { %>
                <p style="color:red; text-align:center; margin-top:10px;"><%= request.getAttribute("errorMessage") %></p>
                <% } %>
            </div>
        </div>
    </div>
</form>

<%-- ⭐ Modal 1: 输入 PIN 码 --%>
<div class="modal-overlay" id="pinModal">
    <div class="modal-box">
        <div class="modal-icon">🔒</div>
        <h2 style="color:#333; margin-bottom:5px;">Enter Payment PIN</h2>
        <p style="color:#666; font-size:0.9rem;">Please enter your 6-digit PIN to confirm.</p>

        <% if(request.getAttribute("errorMessage") != null) { %>
        <p style="color: #FF3B30; font-size: 0.9rem; margin-top: 10px; font-weight: 600; background: #ffebee; padding: 8px; border-radius: 8px;">
            <i class="ri-error-warning-line"></i> <%= request.getAttribute("errorMessage") %>
        </p>
        <% } %>

        <div class="pin-input-container">
            <% for(int i=0; i<6; i++) { %>
            <input type="password" class="pin-digit" maxlength="1" oninput="moveToNext(this)" onkeydown="handleBackspace(event, this)">
            <% } %>
        </div>

        <div style="display:flex; gap:10px;">
            <button type="button" class="btn-modal-cancel" onclick="closeModal('pinModal')">Cancel</button>
            <button type="button" class="btn-modal-confirm" onclick="confirmPayment()">Confirm</button>
        </div>
    </div>
</div>

<%-- ⭐ Modal 2: 提醒设置 PIN 码 --%>
<div class="modal-overlay" id="noPinModal">
    <div class="modal-box">
        <div class="modal-icon">⚠️</div>
        <h2 style="color:#333; margin-bottom:10px;">No PIN Set</h2>
        <p style="color:#666; margin-bottom:20px;">
            To protect your wallet, you must set a <strong>Payment PIN</strong> before purchasing.
        </p>
        <a href="${pageContext.request.contextPath}/profile?tab=settings&pinAction=true" class="btn-modal-setup">
            Set PIN Now
        </a>
        <br>
        <button type="button" style="margin-top:15px; border:none; background:transparent; color:#999; cursor:pointer;" onclick="closeModal('noPinModal')">Cancel</button>
    </div>
</div>

<%-- ⭐ 自动重新打开弹窗逻辑 --%>
<%
    if (request.getAttribute("showPinModal") != null && (Boolean)request.getAttribute("showPinModal")) {
%>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        document.getElementById('pinModal').classList.add('active');
        setTimeout(() => document.querySelector('.pin-digit').focus(), 100);
    });
</script>
<% } %>

<script>
    let basePrice = <%= subTotal %>;
    // ⭐ 修改 JS：运费不再是固定的 15，而是算出来的 totalShipFee
    let shipCost = <%= totalShipFee %>;

    // ⭐ 后端传入变量
    const userHasPin = <%= hasPin %>;

    // ⭐ 点击 "Pay Now" 触发
    function handlePayClick() {
        const addr = document.getElementById('inputAddress').value;
        if(!addr) {
            alert("Please select a delivery address.");
            return;
        }

        if (userHasPin) {
            document.getElementById('pinModal').classList.add('active');
            setTimeout(() => document.querySelector('.pin-digit').focus(), 100);
        } else {
            document.getElementById('noPinModal').classList.add('active');
        }
    }

    // ⭐ 关闭弹窗
    function closeModal(modalId) {
        document.getElementById(modalId).classList.remove('active');
        if(modalId === 'pinModal') {
            document.querySelectorAll('.pin-digit').forEach(input => input.value = '');
        }
    }

    // ⭐ PIN 输入框自动跳转逻辑
    function moveToNext(input) {
        if (input.value.length >= 1) {
            let next = input.nextElementSibling;
            if (next && next.classList.contains('pin-digit')) {
                next.focus();
            }
        }
    }

    function handleBackspace(event, input) {
        if (event.key === 'Backspace' && input.value.length === 0) {
            let prev = input.previousElementSibling;
            if (prev && prev.classList.contains('pin-digit')) {
                prev.focus();
            }
        }
        if (event.key === 'Enter') {
            confirmPayment();
        }
    }

    // ⭐ 确认支付
    function confirmPayment() {
        let pin = "";
        const inputs = document.querySelectorAll('.pin-digit');
        let allFilled = true;

        inputs.forEach(input => {
            if(!input.value) allFilled = false;
            pin += input.value;
        });

        if (!allFilled) {
            alert("Please enter all 6 digits.");
            return;
        }

        document.getElementById('finalPaymentPin').value = pin;
        document.getElementById('orderForm').submit();
    }

    // 原有的地址选择逻辑
    function selectAddress(card, name, phone, address) {
        document.querySelectorAll('.address-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        document.getElementById('inputName').value = name;
        document.getElementById('inputPhone').value = phone;
        document.getElementById('inputAddress').value = address;
    }

    // 原有的数量更新逻辑
    function updateQuantity(input, unitPrice, maxStock) {
        let quantity = parseInt(input.value);
        if (quantity < 1 || isNaN(quantity)) {
            quantity = 1;
            input.value = 1;
        }
        if (quantity > maxStock) {
            quantity = maxStock;
            input.value = maxStock;
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

    // ⭐ 修改 updateSummary 函数
    function updateSummary() {
        document.getElementById('shipFee').innerText = "RM " + shipCost.toFixed(2);
        let total = basePrice + shipCost;
        document.getElementById('totalDisplay').innerText = "RM " + total.toFixed(2);
    }
</script>

</body>
</html>