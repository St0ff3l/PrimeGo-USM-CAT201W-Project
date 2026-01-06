<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
  // ============================================================
  // 1. 商家强制重定向逻辑 (保留)
  // ============================================================

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

  // ============================================================
  // 2. 获取商品数据并过滤库存
  // ============================================================
  ProductDAO productDAO = new ProductDAO();
  List<ProductDTO> productList = productDAO.getAllProducts();

  // ⭐ 新增：过滤逻辑，只保留库存大于 0 的商品
  List<ProductDTO> displayList = new ArrayList<>();
  if (productList != null) {
    for (ProductDTO p : productList) {
      if (p.getProductStockQuantity() > 0) {
        displayList.add(p);
      }
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
    body {
      font-family: 'Poppins', sans-serif;
      color: #333;
      position: relative;
      margin: 0;
    }

    /* ================= 2. 毛玻璃容器样式 ================= */
    .glass-panel {
      background: rgba(255, 255, 255, 0.7);
      backdrop-filter: blur(20px);
      border: 1px solid rgba(255, 255, 255, 0.6);
      border-radius: 20px;
      box-shadow:
              0 8px 32px rgba(0, 0, 0, 0.1),
              inset 0 0 0 1px rgba(255, 255, 255, 0.5);
    }

    /* ================= 3. Hero 区域 ================= */
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

    /* ================= 4. 商品网格 ================= */
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
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 25px;
    }

    .product-card {
      overflow: hidden;
      transition: transform 0.3s, box-shadow 0.3s;
      display: flex;
      flex-direction: column;
      cursor: pointer; /* 鼠标变手型 */
    }

    .product-card:hover {
      transform: translateY(-10px);
      box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
    }

    .product-img-container {
      width: 100%;
      aspect-ratio: 1 / 1;
      overflow: hidden;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f5f6fa;
    }

    .product-img-container img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .product-img-placeholder {
      width: 100%;
      aspect-ratio: 1 / 1;
      background-color: rgba(245, 246, 250, 0.6);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 4rem;
    }

    .product-details {
      padding: 10px;
      display: flex;
      flex-direction: column;
      flex-grow: 1;
    }

    .product-name {
      font-size: 1rem;
      font-weight: 600;
      margin-bottom: 2px;
    }

    .product-price {
      font-size: 1.1rem;
      color: #FF3B30;
      font-weight: 700;
      margin-bottom: 5px;
    }

    .btn-add {
      margin-top: auto;
      background-color: transparent;
      border: 2px solid #333;
      color: #333;
      width: 100%;
      position: relative;
      z-index: 2;
    }

    .btn-add:hover {
      background-color: #333;
      color: white;
    }

    /* ================= 5. 页脚 ================= */
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

<%-- 引入通用组件 --%>
<%@ include file="common/background.jsp" %>
<%@ include file="common/layout/header_bar.jsp" %>

<section class="hero glass-panel">
  <h1>Welcome to PrimeGo<br>Premium Marketplace</h1>
  <p>Your destination for high-quality first-hand products.</p>
  <button class="btn btn-primary" onclick="window.location.href='#products'">Start Shopping</button>
</section>

<div class="section-container" id="products">
  <h2 class="section-title">Featured Products</h2>

  <div class="product-grid">
    <%
      // ⭐ 修改：使用 displayList (已过滤库存) 进行判空
      if (displayList.isEmpty()) {
    %>
    <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
      <h3>No products available at the moment.</h3>
      <p>Please check back later!</p>
    </div>
    <%
    } else {
      // ⭐ 修改：遍历 displayList
      for (ProductDTO p : displayList) {
        // 卡片整体点击跳转到详情页
        String detailUrl = request.getContextPath() + "/customer/product/product_detail.jsp?id=" + p.getProductId();
    %>

    <div class="product-card glass-panel"
         onclick="window.location.href='<%= detailUrl %>'">

      <% if (p.getPrimaryImageUrl() != null && !p.getPrimaryImageUrl().isEmpty()) { %>
      <div class="product-img-container">
        <img src="<%= request.getContextPath() + "/" + p.getPrimaryImageUrl() %>"
             alt="<%= p.getProductName() %>">
      </div>
      <% } else { %>
      <div class="product-img-placeholder">📦</div>
      <% } %>

      <div class="product-details">
        <h3 class="product-name"><%= p.getProductName() %></h3>
        <p class="product-price">RM <%= String.format("%.2f", p.getProductPrice()) %></p>
        <p style="font-size: 0.85rem; color:#666; margin-bottom:8px; line-height: 1.3;">
          <%= (p.getProductDescription() != null && p.getProductDescription().length() > 50)
                  ? p.getProductDescription().substring(0, 50) + "..."
                  : (p.getProductDescription() != null ? p.getProductDescription() : "") %>
        </p>

        <%--
          addToCart() 接收商品 ID
          event.stopPropagation() 防止点击按钮时触发卡片的跳转
        --%>
        <button class="btn btn-add" onclick="event.stopPropagation(); addToCart(<%= p.getProductId() %>)">Add to Cart</button>
      </div>
    </div>
    <%
        }
      }
    %>
  </div>
</div>

<footer>
  <p>PrimeGo E-Commerce | USM CAT201 Project</p>
  <p style="font-size: 0.8rem; opacity: 0.7;">Developed using Native HTML, CSS, and JS (No Frameworks).</p>
</footer>

<script>
  window.count = 0;

  /**
   * 添加到购物车逻辑
   * @param {number} productId - 商品ID
   */
  function addToCart(productId) {
    // 假设你的 Servlet 映射为 /cart_action，并且接受 add 动作
    // 如果未登录，后端 Servlet 应该处理重定向或 Session 存储
    window.location.href = "${pageContext.request.contextPath}/cart_action?action=add&productId=" + productId + "&quantity=1";
  }
</script>
</body>
</html>