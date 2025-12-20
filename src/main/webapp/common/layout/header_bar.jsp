<%@ page pageEncoding="UTF-8" %> <%-- 关键：防止Emoji和中文乱码 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link id="primego-font-poppins" href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

<header class="home-header">
  <div class="navbar">
    <%-- Logo 区域 --%>
    <a href="${pageContext.request.contextPath}/index.jsp" class="brand-link">
      <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="PrimeGo Logo" class="brand-logo-img">
      <span class="brand-text">PrimeGo</span>
    </a>

    <%-- 菜单区域 --%>
    <ul class="nav-menu">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
      <li><a href="#">Categories</a></li>
      <li><a href="#">About Us</a></li>
      <c:if test="${empty sessionScope.user}">
        <li><a href="${pageContext.request.contextPath}/public/login.jsp">Login</a></li>
      </c:if>
      <c:if test="${not empty sessionScope.user}">
        <c:if test="${sessionScope.user.role == 'ADMIN'}">
          <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
        </c:if>
        <li><a href="${pageContext.request.contextPath}/profile">Profile</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
      </c:if>
    </ul>

    <%-- 图标与用户操作区域 --%>
    <div class="nav-icons">
      <span onclick="toggleSearch()" title="Search">🔍</span>
      <span onclick="showCart()" title="Cart">🛒 <span id="cart-count">0</span></span>

      <%-- 未登录显示登录按钮 --%>
      <c:if test="${empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/public/login.jsp" class="nav-login-btn-link">
          <button class="nav-login-btn">Login</button>
        </a>
      </c:if>

      <%-- 已登录显示头像 --%>
      <c:if test="${not empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/profile" class="nav-avatar" title="Current User: ${sessionScope.user.username}">
            ${sessionScope.user.username.charAt(0).toString().toUpperCase()}
        </a>
      </c:if>
    </div>
  </div>
</header>

<style>
  /* ================= Header Bar 依赖的通用基础样式 =================
     说明：这些是 header bar 视觉所需的通用字体/基础 reset。
     为避免影响页面其它区域，这里只作用于 header bar 组件内部。
  */
  .home-header,
  .home-header * ,
  .home-header *::before,
  .home-header *::after {
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
  }

  /* ================= 导航栏容器 ================= */
  .home-header {
    position: fixed;
    top: 15px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1000;
    width: 92%;
    max-width: 1300px;
    border-radius: 50px;
    padding: 12px 40px;
    /* 优化的毛玻璃背景 */
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
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
  }

  /* ================= Logo 样式 ================= */
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

  /* ================= 菜单链接样式 ================= */
  .nav-menu {
    display: flex;
    list-style: none;
    gap: 40px;
    margin: 0;
    padding: 0;
  }

  .nav-menu a {
    text-decoration: none;
    color: #444;
    font-weight: 600;
    font-size: 1rem;
    padding: 8px 16px;
    border-radius: 20px;
    transition: all 0.3s ease;
  }

  .nav-menu a:hover {
    color: #FF9500;
    background: rgba(0, 0, 0, 0.03);
  }

  /* ================= 图标区域样式 ================= */
  .nav-icons {
    display: flex;
    align-items: center;
  }

  .nav-icons span {
    margin-left: 20px;
    cursor: pointer;
    font-size: 1.2rem;
    transition: transform 0.3s, color 0.3s;
  }

  .nav-icons span:hover {
    transform: scale(1.1);
    color: #FF9500;
  }

  #cart-count {
    font-size: 0.9rem;
    font-weight: bold;
    color: #d63031;
  }

  /* ================= 登录按钮样式 ================= */
  .nav-login-btn-link {
    text-decoration: none;
    margin-left: 20px;
  }

  .nav-login-btn {
    padding: 8px 20px;
    border-radius: 20px;
    border: none;
    background: #333;
    color: white;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s ease;
  }

  .nav-login-btn:hover {
    background: #FF9500;
    transform: translateY(-2px);
    box-shadow: 0 4px 10px rgba(255, 149, 0, 0.3);
  }

  /* ================= 头像样式 ================= */
  .nav-avatar {
    margin-left: 20px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: white;
    border-radius: 50%;
    font-weight: bold;
    font-size: 1.2rem;
    text-decoration: none;
    box-shadow: 0 4px 10px rgba(0, 123, 255, 0.3);
    transition: transform 0.3s;
  }

  .nav-avatar:hover {
    transform: scale(1.1) rotate(5deg);
  }
</style>