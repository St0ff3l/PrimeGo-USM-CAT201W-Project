<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.primego.order.model.Cart" %>
<%@ page import="com.primego.order.model.CartItem" %>
<%@ page import="com.primego.order.dao.CartDAO" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%-- ⭐ 1. 必须添加这行 JSTL 引用，否则 c:if 不起作用 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // 1. Try to get cart from session
    Cart cart = (Cart) session.getAttribute("cart");
    User user = (User) session.getAttribute("user");

    // 2. If session cart is empty/null but user is logged in, try to fetch from DB
    if (user != null) {
        CartDAO cartDAO = new CartDAO();
        // Always refresh from DB for logged-in users to ensure consistency
        cart = cartDAO.getCartByUserId(user.getId());
        session.setAttribute("cart", cart);
    } else if (cart == null) {
        cart = new Cart();
        session.setAttribute("cart", cart);
    }

    List<CartItem> items = cart.getItems();
    BigDecimal total = cart.getTotalPrice();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; padding-bottom: 100px; }

        /* Header styles handled by header_bar.jsp */

        .container { max-width: 1000px; margin: 140px auto 0; padding: 0 20px; }
        .page-title { font-size: 2rem; margin-bottom: 30px; font-weight: 700; color: #2d3436; border-left: 5px solid #FF9500; padding-left: 15px; }

        /* 购物车列表容器 */
        .cart-list { display: flex; flex-direction: column; gap: 20px; }

        /* 单个商品卡片 (长条形) */
        .cart-item {
            background: rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.3s;
        }
        .cart-item:hover { transform: translateX(5px); background: rgba(255, 255, 255, 0.8); }

        .item-checkbox { width: 20px; height: 20px; accent-color: #FF3B30; cursor: pointer; }

        .item-img { width: 100px; height: 100px; border-radius: 12px; background: #eee; display: flex; align-items: center; justify-content: center; font-size: 2rem; object-fit: cover; overflow: hidden; }
        .item-img img { width: 100%; height: 100%; object-fit: cover; }

        .item-info { flex: 1; }
        .item-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 5px; }
        .item-meta { color: #666; font-size: 0.9rem; }
        .item-price { color: #FF3B30; font-weight: 700; font-size: 1.2rem; margin-top: 5px; }

        .btn-delete { width: 35px; height: 35px; border-radius: 50%; border: 1px solid #ddd; background: white; color: #666; cursor: pointer; transition: 0.2s; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 1.2rem; line-height: 1; }
        .btn-delete:hover { background: #FF3B30; color: white; border-color: #FF3B30; }

        /* 底部结算栏 */
        .checkout-bar {
            position: fixed; bottom: 30px; left: 50%; transform: translateX(-50%);
            width: 90%; max-width: 1000px;
            background: #2d3436; color: white;
            padding: 15px 30px; border-radius: 50px;
            display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            z-index: 999;
        }
        .total-info span { color: #FF9500; font-size: 1.3rem; font-weight: 700; }
        .btn-checkout {
            background: linear-gradient(45deg, #FF3B30, #FF9500);
            border: none; color: white; padding: 10px 30px; border-radius: 30px;
            font-weight: 600; cursor: pointer; font-size: 1rem;
            box-shadow: 0 4px 15px rgba(255, 59, 48, 0.4);
            text-decoration: none;
        }

        .empty-cart { text-align: center; padding: 50px; color: #666; }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="container">
    <h1 class="page-title">My Cart <span style="font-size:1rem; color:#666; font-weight:400;">(<%= items.size() %> Items)</span></h1>

    <%-- ⭐ 2. 插入错误提示代码 --%>
    <c:if test="${not empty errorMessage}">
        <div style="background-color: #ffebee; color: #c62828; padding: 15px; border-radius: 10px; margin-bottom: 20px; border: 1px solid #ef9a9a; display: flex; align-items: center; gap: 10px;">
            <i class="ri-error-warning-line" style="font-size: 1.2rem;"></i>
            <span>${errorMessage}</span>
        </div>
    </c:if>

    <div class="cart-list" id="cartList">
        <% if (items.isEmpty()) { %>
        <div class="empty-cart">
            <h3>Your cart is empty</h3>
            <p>Go find some treasures!</p>
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn-checkout" style="text-decoration:none; display:inline-block; margin-top:20px;">Start Shopping</a>
        </div>
        <% } else {
            for (CartItem item : items) {
        %>
        <div class="cart-item">
            <input type="checkbox" class="item-checkbox" value="<%= item.getProduct().getProductId() %>" checked onchange="updateTotal()">

            <div class="item-img">
                <% if (item.getProduct().getPrimaryImageUrl() != null && !item.getProduct().getPrimaryImageUrl().isEmpty()) { %>
                <img src="<%= request.getContextPath() + "/" + item.getProduct().getPrimaryImageUrl() %>" alt="<%= item.getProduct().getProductName() %>">
                <% } else { %>
                <span style="font-size: 0.8rem; color: #ccc;">No Image</span>
                <% } %>
            </div>
            <div class="item-info">
                <a href="${pageContext.request.contextPath}/customer/product/product_detail.jsp?id=<%= item.getProduct().getProductId() %>" style="text-decoration:none; color:inherit;">
                    <div class="item-title"><%= item.getProduct().getProductName() %></div>
                </a>
                <div class="item-meta" style="display:flex; align-items:center; gap:10px; margin-top:5px;">
                    Quantity:
                    <form action="${pageContext.request.contextPath}/cart_action" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="productId" value="<%= item.getProduct().getProductId() %>">
                        <input type="number" name="quantity" min="1" value="<%= item.getQuantity() %>"
                               style="width:60px; padding:5px; border-radius:5px; border:1px solid #ccc;"
                               onchange="this.form.submit()">
                    </form>
                </div>
                <div class="item-price" data-price="<%= item.getTotalPrice() %>">RM <%= String.format("%.2f", item.getTotalPrice()) %></div>
            </div>
            <a href="${pageContext.request.contextPath}/cart_action?action=remove&productId=<%= item.getProduct().getProductId() %>" class="btn-delete" onclick="return confirm('Remove this item?')">×</a>
        </div>
        <%
                }
            }
        %>
    </div>
</div>

<div class="checkout-bar">
    <div class="total-info">Total: <span id="totalPrice">RM <%= String.format("%.2f", total) %></span></div>
    <button type="button" class="btn-checkout" onclick="proceedToCheckout()">Checkout</button>
</div>

<form id="checkoutForm" action="${pageContext.request.contextPath}/customer/order/order_confirmation.jsp" method="post" style="display:none;">
</form>

<script>
    function updateTotal() {
        let total = 0;
        document.querySelectorAll('.cart-item').forEach(item => {
            const checkbox = item.querySelector('.item-checkbox');
            if(checkbox.checked) {
                const price = parseFloat(item.querySelector('.item-price').dataset.price);
                total += price;
            }
        });
        document.getElementById('totalPrice').innerText = "RM " + total.toFixed(2);
    }

    function proceedToCheckout() {
        const form = document.getElementById('checkoutForm');
        form.innerHTML = ''; // 清空旧数据

        // 获取所有被勾选的复选框
        const checkboxes = document.querySelectorAll('.item-checkbox:checked');

        if (checkboxes.length === 0) {
            alert('Please select at least one item to checkout.');
            return;
        }

        // 为每个选中的商品创建一个隐藏的 input
        checkboxes.forEach(cb => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'selectedProductIds'; // 关键参数名
            input.value = cb.value;
            form.appendChild(input);
        });

        form.submit(); // 提交到 order_confirmation.jsp
    }
</script>

</body>
</html>