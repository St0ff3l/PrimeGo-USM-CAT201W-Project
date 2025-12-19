<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CAT201 E-Commerce Project - Wide Navbar (Slightly Shorter)</title>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

  <style>
    /* ================= 1. 全局重置 ================= */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Poppins', sans-serif;
    }

    body {
      background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
      min-height: 100vh;
      overflow-x: hidden;
      position: relative;
      color: #333;
    }

    /* ================= 2. 纯 CSS 背景 (实心 3D) ================= */
    .background-blob {
      position: fixed;
      border-radius: 50%;
      z-index: -1;
      opacity: 1;
      filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
    }

    .blob-red {
      width: 750px;
      height: 650px;
      top: -200px;
      left: -200px;
      transform: rotate(-10deg);
      background: linear-gradient(145deg, #ff5e55, #d92e25);
      box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
    }

    .blob-yellow {
      width: 900px;
      height: 700px;
      top: -250px;
      right: -100px;
      transform: rotate(30deg);
      background: linear-gradient(145deg, #ffdb4d, #e6b800);
      box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
    }

    .blob-orange {
      width: 1800px;
      height: 950px;
      bottom: -650px;
      left: -600px;
      transform: rotate(-10deg);
      background: linear-gradient(145deg, #ffad33, #e68a00);
      box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
    }

    /* ================= 3. 毛玻璃容器样式 ================= */
    .glass-panel {
      background: rgba(255, 255, 255, 0.7);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.6);
      border-radius: 20px;
      box-shadow:
              0 8px 32px rgba(0, 0, 0, 0.1),
              inset 0 0 0 1px rgba(255, 255, 255, 0.5);
    }

    /* ================= 4. 导航栏 (稍微短一点的悬浮胶囊) ================= */
    header {
      position: fixed;
      top: 15px;
      left: 50%;
      transform: translateX(-50%);
      z-index: 1000;

      /* [修改点]：宽度微调 */
      /* 之前是 96%，现在改为 92%，左右空隙稍微大一点 */
      width: 92%;
      /* 最大宽度也稍微收一下，防止在超大屏幕上太长 */
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

    .logo {
      font-size: 1.5rem;
      font-weight: 700;
      color: #d63031;
      text-transform: uppercase;
      letter-spacing: 1px;
    }

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

    /* ================= 5. Hero 区域 ================= */
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

    /* ================= 6. 商品网格 ================= */
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

    /* ================= 7. 页脚 ================= */
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

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>

<header>
  <div class="navbar">
    <div class="logo">USM SHOP</div>
    <ul class="nav-menu">
      <li><a href=" ">Home</a ></li>
      <li><a href="#">Categories</a ></li>
      <li><a href="#">About Us</a ></li>
      <li><a href="#">Admin Login</a ></li>
    </ul>
    <div class="nav-icons">
      <span onclick="toggleSearch()">🔍</span>
      <span onclick="showCart()">🛒 <span id="cart-count">0</span></span>
    </div>
  </div>
</header>

<section class="hero glass-panel">
  <h1>Welcome to CAT201<br>Student Marketplace</h1>
  <p>A platform built with Java & Web Technologies for USM students.</p >
  <button class="btn btn-primary" onclick="window.location.href='#products'">Start Shopping</button>
</section>

<div class="section-container" id="products">
  <h2 class="section-title">Featured Products</h2>

  <div class="product-grid">
    <div class="product-card glass-panel">
      <div class="product-img-placeholder">💻</div>
      <div class="product-details">
        <h3 class="product-name">Second-hand Laptop</h3>
        <p class="product-price">RM 1,250.00</p >
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Good condition, 16GB RAM.</p >
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">📚</div>
      <div class="product-details">
        <h3 class="product-name">Java Programming Textbook</h3>
        <p class="product-price">RM 55.00</p >
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Essential for CAT201.</p >
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">⌚</div>
      <div class="product-details">
        <h3 class="product-name">Smart Watch Series 5</h3>
        <p class="product-price">RM 300.00</p >
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Includes charger box.</p >
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>

    <div class="product-card glass-panel">
      <div class="product-img-placeholder">👟</div>
      <div class="product-details">
        <h3 class="product-name">Sport Shoes (Size 9)</h3>
        <p class="product-price">RM 89.00</p >
        <p style="font-size: 0.9rem; color:#666; margin-bottom:10px;">Never worn, wrong size.</p >
        <button class="btn btn-add" onclick="addToCart()">Add to Cart</button>
      </div>
    </div>
  </div>
</div>

<footer>
  <p>CAT201 Project Group Assignment | Semester 1 2025/2026</p >
  <p style="font-size: 0.8rem; opacity: 0.7;">Developed using Native HTML, CSS, and JS (No Frameworks).</p >
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
      alert("Your cart is empty. Go buy something!");
    } else {
      alert(`You have ${count} items in your cart. Checkout functionality will be implemented with Java.`);
    }
  }

  function toggleSearch() {
    let searchTerm = prompt("What are you looking for?");
    if (searchTerm) {
      alert("Searching for: " + searchTerm);
    }
  }
</script>
</body>
</html>