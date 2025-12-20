<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.primego.user.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
  // If merchant is logged in, send them directly to merchant dashboard
  // (No bypass: merchants shouldn't access index.jsp)

  // (some pages/flows may store user in request scope; check both)
  User __idxUser = (User) session.getAttribute("user");
  if (__idxUser == null) {
    Object __reqUser = request.getAttribute("user");
    if (__reqUser instanceof User) {
      __idxUser = (User) __reqUser;
    }
  }

  if (__idxUser != null && __idxUser.getRole() != null) {
    String __roleStr = __idxUser.getRole().name();
    if ("MERCHANT".equals(__roleStr)) {
      response.sendRedirect(request.getContextPath() + "/merchant/merchant_dashboard.jsp");
      return;
    }
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PrimeGo - Premium B2C E-Commerce</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

  <style>
    /* ================= 1. 全局基础样式 ================= */
    /* 说明：通用字体/reset 已移至 common/layout/header_bar.jsp（仅作用于 header bar），
       index.jsp 这里只保留页面自身需要的样式，避免全局覆盖其它页面。 */

    body {
      /* 背景颜色和动画已移至 common/background.jsp */
      font-family: 'Poppins', sans-serif;
      color: #333;
      position: relative;
      margin: 0;
    }

    /* ================= 2. 毛玻璃容器样式 (通用) ================= */
    .glass-panel {
      background: rgba(255, 255, 255, 0.7);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.6);
      border-radius: 20px;
      box-shadow:
              0 8px 32px rgba(0, 0, 0, 0.1),
              inset 0 0 0 1px rgba(255, 255, 255, 0.5);
    }

    /* 导航栏（header bar）相关样式不放在 index.jsp：
       统一由 common/layout/header_bar.jsp 提供，避免多个页面重复定义/冲突。
    */

    /* ================= 4. Hero 区域 ================= */
    .hero {
      max-width: 1200px;
      margin: 140px auto 50px; /* 顶部留白给 fixed 导航栏 */
      padding: 60px 40px;
      text-align: center;
    }

    .hero h1 {
      font-size: 3.5rem;
      margin-bottom: 20px;
      line-height: 1.2;
      color: #2d3436;
    }

    .hero p {
      font-size: 1.2rem;
      color: #636e72;
      margin-bottom: 30px;
    }

    .btn {
      padding: 12px 30px;
      border-radius: 30px;
      text-decoration: none;
      font-weight: 600;
      transition: all 0.3s ease;
      cursor: pointer;
      border: none;
    }

    .btn-primary {
      background: linear-gradient(45deg, #FF3B30, #FF9500);
      color: white;
      box-shadow: 0 5px 15px rgba(255, 59, 48, 0.4);
    }

    .btn-primary:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(255, 59, 48, 0.6);
    }

    /* ================= 5. 商品网格 ================= */
    .section-container {
      max-width: 1200px;
      margin: 0 auto 50px;
      padding: 0 20px;
    }

    .section-title {
      font-size: 2rem;
      margin-bottom: 30px;
      color: #2d3436;
      border-left: 5px solid #FFCC00;
      padding-left: 15px;
    }

    .product-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 30px;
    }

    .product-card {
      overflow: hidden;
      transition: transform 0.3s;
      display: flex;
      flex-direction: column;
    }

    .product-card:hover {
      transform: translateY(-10px);
    }

    .product-img-placeholder {
      height: 200px;
      background-color: rgba(245, 246, 250, 0.6);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 4rem;
    }

    .product-details {
      padding: 20px;
      display: flex;
      flex-direction: column;
      flex-grow: 1;
    }

    .product-name {
      font-size: 1.1rem;
      font-weight: 600;
      margin-bottom: 10px;
    }

    .product-price {
      font-size: 1.2rem;
      color: #FF3B30;
      font-weight: 700;
      margin-bottom: 15px;
    }

    .btn-add {
      margin-top: auto;
      background-color: transparent;
      border: 2px solid #333;
      color: #333;
      width: 100%;
    }

    .btn-add:hover {
      background-color: #333;
      color: white;
    }

    /* ================= 6. 页脚 ================= */
    footer {
      background: #2d3436;
      color: white;
      text-align: center;
      padding: 30px;
      margin-top: 50px;
    }
  </style>
</head>
<body>

<%-- 1. 引入背景 --%>
<%@ include file="common/background.jsp" %>

<%-- 2. 引入独立的导航栏组件 (含样式) --%>
<%@ include file="common/layout/header_bar.jsp" %>

<section class="hero glass-panel">
  <h1>Welcome to PrimeGo<br>Premium Marketplace</h1>
  <p>Your destination for high-quality first-hand products.</p>
  <button class="btn btn-primary" onclick="window.location.href='#products'">Start Shopping</button>
</section>

<div class="section-container" id="products">
  <h2 class="section-title">Featured Products</h2>

  <div class="product-grid">
    <div class="product-card glass-panel">
      <div class="product-img-placeholder">💻</div>
      <div class="product-details">
        <h3 class="product-name">Premium Business Laptop</h3>
        <p class="product-price">RM 3,250.00</p>
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Brand new, 16GB RAM, 512GB SSD.</p>
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">📚</div>
      <div class="product-details">
        <h3 class="product-name">Java Programming Mastery</h3>
        <p class="product-price">RM 85.00</p>
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Latest Edition. Hardcover.</p>
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">⌚</div>
      <div class="product-details">
        <h3 class="product-name">Smart Watch Ultra</h3>
        <p class="product-price">RM 800.00</p>
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Original packaging with warranty.</p>
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">👟</div>
      <div class="product-details">
        <h3 class="product-name">Running Pro Shoes</h3>
        <p class="product-price">RM 189.00</p>
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">New Season Arrival.</p>
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>
  </div>
</div>

<footer>
  <p>PrimeGo E-Commerce | USM CAT201 Project</p>
  <p style="font-size: 0.8rem; opacity: 0.7;">Developed using Native HTML, CSS, and JS (No Frameworks).</p>
</footer>

<script>
  window.count = 0;

  function addToCart() {
    window.count++;
    document.getElementById('cart-count').innerText = window.count;
    alert("Success! Item added to your cart.");
  }

  function showCart() {
    if (window.count === 0) {
      alert("Your cart is empty. Discover our premium products!");
    } else {
      alert("You have " + window.count + " items in your cart. Checkout functionality will be implemented with Java.");
    }
  }

  function toggleSearch() {
    let searchTerm = prompt("Search PrimeGo products:");
    if (searchTerm) {
      alert("Searching for: " + searchTerm);
    }
  }
</script>
</body>
</html>



