<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Confirm Order - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; }

        header { position: fixed; top: 15px; left: 50%; transform: translateX(-50%); z-index: 1000; width: 92%; max-width: 1300px; border-radius: 50px; padding: 12px 40px; background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(25px); border: 1px solid rgba(255, 255, 255, 0.9); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); display: flex; justify-content: space-between; align-items: center; }
        .brand-text { font-size: 1.5rem; font-weight: 700; color: #d63031; }

        .container { max-width: 1000px; margin: 120px auto 50px; padding: 0 20px; display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; align-items: start; }

        .card { background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.6); border-radius: 20px; padding: 25px; margin-bottom: 20px; }

        h2 { font-size: 1.2rem; margin-bottom: 20px; border-bottom: 1px solid rgba(0,0,0,0.1); padding-bottom: 10px; }

        /* 商品展示 */
        .order-item { display: flex; gap: 15px; align-items: center; }
        .item-img { width: 80px; height: 80px; background: rgba(255,255,255,0.5); border-radius: 12px; display: flex; justify-content: center; align-items: center; font-size: 2rem; }

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
    <div class="left-col">
        <div class="card">
            <h2>Order Item</h2>
            <div class="order-item">
                <div class="item-img">📦</div>
                <div>
                    <h4 id="prodTitle">Product Name</h4>
                    <p style="color:#FF3B30; font-weight:700;" id="prodPrice">RM 0.00</p>
                </div>
            </div>
        </div>

        <div class="card">
            <h2>Delivery Method</h2>
            <div class="delivery-opt">
                <div class="opt-box selected" onclick="selectOpt(this, 15)">🚚 Shipping</div>
            </div>

            <div id="shippingForm">
                <div class="input-group"><input type="text" class="input-field" placeholder="Full Name"></div>
                <div class="input-group"><input type="text" class="input-field" placeholder="Address"></div>
            </div>
        </div>
    </div>

    <div class="right-col">
        <div class="card">
            <h2>Summary</h2>
            <div class="summary-row"><span>Subtotal</span><span id="subTotal">RM 0.00</span></div>
            <div class="summary-row"><span>Delivery</span><span id="shipFee">RM 0.00</span></div>
            <div class="total-row"><span>Total</span><span id="totalDisplay" style="color:#FF3B30;">RM 0.00</span></div>

            <button class="btn-pay" onclick="window.location.href='payment_success.jsp'">Pay Now</button>
        </div>
    </div>
</div>

<script>
    let basePrice = 3250.00; // Example price
    let shipCost = 15; // 默认改为15，因为只剩下Shipping选项

    document.addEventListener("DOMContentLoaded", () => {
        // Initial Render
        updateSummary();
        document.getElementById('prodTitle').innerText = "Premium Business Laptop";
        document.getElementById('prodPrice').innerText = "RM " + basePrice.toFixed(2);
    });

    function selectOpt(el, cost) {
        document.querySelectorAll('.opt-box').forEach(b => b.classList.remove('selected'));
        el.classList.add('selected');

        shipCost = cost;
        // 这里的逻辑保留，但实际上只会走到 cost > 0 的情况
        document.getElementById('shippingForm').style.display = cost > 0 ? 'block' : 'none';
        updateSummary();
    }

    function updateSummary() {
        document.getElementById('subTotal').innerText = "RM " + basePrice.toFixed(2);
        document.getElementById('shipFee').innerText = "RM " + shipCost.toFixed(2);
        document.getElementById('totalDisplay').innerText = "RM " + (basePrice + shipCost).toFixed(2);
    }
</script>

</body>
</html>