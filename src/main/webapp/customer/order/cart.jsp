<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; padding-bottom: 100px; }

        header { position: fixed; top: 15px; left: 50%; transform: translateX(-50%); z-index: 1000; width: 92%; max-width: 1300px; border-radius: 50px; padding: 12px 40px; background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(25px); border: 1px solid rgba(255, 255, 255, 0.9); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); display: flex; justify-content: space-between; align-items: center; }
        .brand-text { font-size: 1.5rem; font-weight: 700; color: #d63031; }

        .container { max-width: 1000px; margin: 120px auto 0; padding: 0 20px; }
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

        .item-img { width: 100px; height: 100px; border-radius: 12px; background: #eee; display: flex; align-items: center; justify-content: center; font-size: 2rem; object-fit: cover; }

        .item-info { flex: 1; }
        .item-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 5px; }
        .item-meta { color: #666; font-size: 0.9rem; }
        .item-price { color: #FF3B30; font-weight: 700; font-size: 1.2rem; margin-top: 5px; }

        .btn-delete { width: 35px; height: 35px; border-radius: 50%; border: 1px solid #ddd; background: white; color: #666; cursor: pointer; transition: 0.2s; }
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
        }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>

<header>
    <a href="${pageContext.request.contextPath}/index.jsp" style="text-decoration:none; display: flex; align-items: center; gap: 10px;">

        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             alt="Logo"
             style="height: 40px; width: auto;">

        <span class="brand-text">PrimeGo</span>
    </a>
    <div style="font-weight:600;">Search</div>
</header>

<div class="container">
    <h1 class="page-title">My Cart <span style="font-size:1rem; color:#666; font-weight:400;">(3 Items)</span></h1>

    <div class="cart-list" id="cartList">
        <div class="cart-item">
            <input type="checkbox" class="item-checkbox" checked onchange="updateTotal()">
            <div class="item-img">💻</div>
            <div class="item-info">
                <div class="item-title">Premium Business Laptop</div>
                <div class="item-meta">Seller: TechGuy_99 | Condition: New</div>
                <div class="item-price" data-price="3250">RM 3,250.00</div>
            </div>
            <button class="btn-delete" onclick="removeItem(this)">×</button>
        </div>

        <div class="cart-item">
            <input type="checkbox" class="item-checkbox" checked onchange="updateTotal()">
            <div class="item-img">👟</div>
            <div class="item-info">
                <div class="item-title">Running Pro Shoes</div>
                <div class="item-meta">Seller: SportyLife | Condition: New</div>
                <div class="item-price" data-price="189">RM 189.00</div>
            </div>
            <button class="btn-delete" onclick="removeItem(this)">×</button>
        </div>
    </div>
</div>

<div class="checkout-bar">
    <div class="total-info">Total: <span id="totalPrice">RM 3,439.00</span></div>
    <button class="btn-checkout" onclick="window.location.href='order_confirmation.jsp'">Checkout</button>
</div>

<script>
    function removeItem(btn) {
        if(confirm("Remove this item from cart?")) {
            btn.closest('.cart-item').remove();
            updateTotal();
        }
    }

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
</script>

</body>
</html>