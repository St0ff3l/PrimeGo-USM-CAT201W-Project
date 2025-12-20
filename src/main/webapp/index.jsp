<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PrimeGo - Premium B2C E-Commerce</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

  <style>
    /* ================= 1. 全局基础样式 ================= */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Poppins', sans-serif;
    }

    body {
      /* 背景颜色和动画已移至 common/background.jsp */
      /* 这里只保留文字颜色和基本定位 */
      color: #333;
      position: relative;
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

    /* ================= 3. 导航栏样式 ================= */
    header {
      position: fixed;
      top: 15px;
      left: 50%;
      transform: translateX(-50%);
      z-index: 1000;
      width: 92%;
      max-width: 1300px;
      border-radius: 50px;
      padding: 12px 40px;
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(25px);
      -webkit-backdrop-filter: blur(25px);
      border: 1px solid rgba(255, 255, 255, 0.9);
      box-shadow:
              0 10px 30px rgba(0, 0, 0, 0.1),
              0 4px 6px rgba(0, 0, 0, 0.05);
      transition: all 0.3s ease;
    }

    .navbar {
      width: 100%;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    /* Logo 区域 */
    .brand-link {
      display: flex;
      align-items: center;
      gap: 12px;
      text-decoration: none;
      cursor: pointer;
    }

    .brand-logo-img {
      height: 40px;
      width: auto;
      object-fit: contain;
      transition: transform 0.3s ease;
    }

    .brand-text {
      font-size: 1.5rem;
      font-weight: 700;
      color: #d63031;
      letter-spacing: 1px;
      line-height: 1;
      transition: color 0.3s ease;
    }

    .brand-link:hover .brand-logo-img {
      transform: scale(1.1);
    }
    .brand-link:hover .brand-text {
      color: #FF9500;
    }

    /* 菜单区域 */
    .nav-menu {
      display: flex;
      list-style: none;
      gap: 40px;
    }

    .nav-menu a {
      text-decoration: none;
      color: #444;
      font-weight: 600;
      font-size: 1rem;
      transition: 0.3s;
      padding: 8px 16px;
      border-radius: 20px;
    }

    .nav-menu a:hover {
      color: #FF9500;
      background: rgba(0,0,0,0.03);
    }

    /* 图标区域 */
    .nav-icons span {
      margin-left: 20px;
      cursor: pointer;
      font-size: 1.2rem;
      transition: 0.3s;
    }

    .nav-icons span:hover {
      transform: scale(1.1);
      color: #FF9500;
    }

    /* ================= 4. Hero 区域 ================= */
    .hero {
      max-width: 1200px;
      margin: 140px auto 50px;
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

<%@ include file="common/background.jsp" %>

<header>
  <div class="navbar">
    <a href="${pageContext.request.contextPath}/index.jsp" class="brand-link">
      <img src="${pageContext.request.contextPath}/assets/images/logo.png"
           alt="PrimeGo Logo"
           class="brand-logo-img">
      <span class="brand-text">PrimeGo</span>
    </a>
    <ul class="nav-menu">
      <li><a href="index.jsp">Home</a></li>
      <li><a href="#">Categories</a></li>
      <li><a href="#">About Us</a></li>
      <c:if test="${empty sessionScope.user}">
        <li><a href="login">Login</a></li>
      </c:if>
      <c:if test="${not empty sessionScope.user}">
        <c:if test="${sessionScope.user.role == 'ADMIN'}">
          <li><a href="admin/dashboard">Dashboard</a></li>
        </c:if>
        <li><a href="profile">Profile</a></li>
        <li><a href="logout">Logout</a></li>
      </c:if>
    </ul>
    <div class="nav-icons">
      <span onclick="toggleSearch()">🔍</span>
      <span onclick="showCart()">🛒 <span id="cart-count">0</span></span>

      <c:if test="${empty sessionScope.user}">
        <a href="login" style="text-decoration: none; margin-left: 20px;">
          <button style="padding: 8px 16px; border-radius: 20px; border: none; background: #333; color: white; cursor: pointer; font-weight: 600;">Login</button>
        </a>
      </c:if>
      <c:if test="${not empty sessionScope.user}">
        <a href="profile" style="text-decoration: none; margin-left: 20px; display: inline-flex; align-items: center; justify-content: center; width: 40px; height: 40px; background: #007bff; color: white; border-radius: 50%; font-weight: bold; font-size: 1.2rem;" title="Profile">
            ${sessionScope.user.username.charAt(0).toString().toUpperCase()}
        </a>
      </c:if>
    </div>
  </div>
</header>

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
  let count = 0;

  function addToCart() {
    count++;
    document.getElementById('cart-count').innerText = count;
    alert("Success! Item added to your cart.");
  }

  function showCart() {
    if (count === 0) {
      alert("Your cart is empty. Discover our premium products!");
    } else {
      alert(`You have ${count} items in your cart. Checkout functionality will be implemented with Java.`);
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