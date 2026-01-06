<%@ page pageEncoding="UTF-8" %> <%-- 关键：防止Emoji和中文乱码 --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.CategoryDAO" %>
<%@ page import="com.primego.product.model.Category" %>
<%@ page import="java.util.List" %>

<%
  // Centralized branching flags
  String pgUri = request.getRequestURI();
  boolean pgIsMerchantRoute = pgUri != null && pgUri.contains("/merchant/");

  User pgUser = (User) session.getAttribute("user");
  String pgRole = (pgUser != null && pgUser.getRole() != null) ? pgUser.getRole().toString() : "";
  boolean pgIsMerchantUser = "MERCHANT".equals(pgRole);
  boolean pgIsAdminUser = "ADMIN".equals(pgRole);

  // Fetch Categories for Dropdown
  CategoryDAO __pgCategoryDAO = new CategoryDAO();
  List<Category> __pgCategories = __pgCategoryDAO.findAll();
%>

<link id="primego-font-poppins" href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
<link href="https://cdn.bootcdn.net/ajax/libs/remixicon/3.5.0/remixicon.css" rel="stylesheet">

<header class="home-header <%= pgIsMerchantRoute ? "pg-header-merchant-minimal" : "" %>">
  <div class="navbar">
    <%-- Logo 区域 --%>
    <a href="${pageContext.request.contextPath}/index.jsp" class="brand-link">
      <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="PrimeGo Logo" class="brand-logo-img">
      <span class="brand-text">PrimeGo</span>
    </a>

    <%-- 菜单区域 --%>
    <ul class="nav-menu">
      <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>

      <li class="nav-item-dropdown">
        <a href="#" class="dropdown-trigger">Categories ▾</a>
        <ul class="dropdown-menu">
          <% if (__pgCategories != null && !__pgCategories.isEmpty()) { %>
          <% for(Category c : __pgCategories) { %>
          <li><a href="${pageContext.request.contextPath}/customer/product/search_result.jsp?categoryId=<%=c.getCategoryId()%>"><%=c.getCategoryName()%></a></li>
          <% } %>
          <% } else { %>
          <li><a href="#">No Categories</a></li>
          <% } %>
        </ul>
      </li>

      <li><a href="#">About Us</a></li>

      <c:if test="${empty sessionScope.user}">
        <li><a href="${pageContext.request.contextPath}/public/login.jsp">Login</a></li>
      </c:if>

      <c:if test="${not empty sessionScope.user}">
        <%-- admin dashboard entry --%>
        <c:if test="${sessionScope.user.role.toString() == 'ADMIN'}">
          <li><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
        </c:if>
        <%-- merchant dashboard entry --%>
        <c:if test="${sessionScope.user.role.toString() == 'MERCHANT'}">
          <li><a href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp">Dashboard</a></li>
        </c:if>

        <li><a href="${pageContext.request.contextPath}/profile">Profile</a></li>
        <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
      </c:if>
    </ul>

    <%-- 图标与用户操作区域 --%>
    <div class="nav-icons">
      <div class="search-container">
        <form action="${pageContext.request.contextPath}/customer/product/search_result.jsp" method="get" class="search-form">
          <input type="text" name="keyword" class="search-input-header" placeholder="Search...">
          <button type="submit" class="search-btn-header"><i class="ri-search-line"></i></button>
        </form>
      </div>

      <span class="nav-icon nav-icon-search" onclick="toggleSearch()" title="Search">
        <i class="ri-search-line"></i>
      </span>

      <span class="nav-icon nav-icon-cart" onclick="window.location.href='${pageContext.request.contextPath}/customer/order/cart.jsp'" title="Cart">
        <i class="ri-shopping-cart-fill"></i>
      </span>

      <c:if test="${empty sessionScope.user}">
        <a href="${pageContext.request.contextPath}/public/login.jsp" class="nav-login-btn-link">
          <button class="nav-login-btn">Login</button>
        </a>
      </c:if>

      <c:if test="${not empty sessionScope.user}">
        <%
          String __pgUsername = (pgUser != null && pgUser.getUsername() != null) ? pgUser.getUsername() : "";
          boolean __showMerchantTop = pgIsMerchantRoute && pgIsMerchantUser;
        %>
        <% if (__showMerchantTop) { %>
        <a class="pg-merchant-wallet" href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp#wallet" title="Wallet">Wallet</a>
        <span class="pg-merchant-username" title="<%= __pgUsername %>"><%= __pgUsername %></span>
        <% } %>

        <a href="${pageContext.request.contextPath}/profile" class="nav-avatar" title="Current User: ${sessionScope.user.username}">
            ${sessionScope.user.username.charAt(0).toString().toUpperCase()}
        </a>
      </c:if>
    </div>
  </div>
</header>

<style>
  /* ================= 基础样式重置 ================= */
  .home-header,
  .home-header * ,
  .home-header *::before,
  .home-header *::after {
    box-sizing: border-box;
    /* ⚠️ 注意：删除了这里的 font-family，防止覆盖图标字体 */
  }

  /* 仅针对文本内容设置字体 */
  .home-header,
  .home-header a,
  .home-header input,
  .home-header button,
  .home-header span:not(.nav-icon) {
    font-family: 'Poppins', sans-serif;
  }

  /* ⚠️ 强制图标使用 RemixIcon 字体 */
  .home-header i[class^="ri-"],
  .home-header i[class*=" ri-"] {
    font-family: 'remixicon' !important;
    font-style: normal;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    line-height: 1;
    vertical-align: middle;
    display: inline-block;
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
    min-width: 0;
  }

  .home-header .brand-link { flex: 0 0 auto; }
  .home-header .nav-menu { flex: 1 1 auto; min-width: 0; }
  .home-header .nav-icons { flex: 0 0 auto; min-width: 0; white-space: nowrap; }

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

  .brand-link:hover .brand-logo-img { transform: scale(1.1); }
  .brand-link:hover .brand-text { color: #FF9500; }

  /* ================= 菜单链接样式 ================= */
  .nav-menu {
    display: flex;
    /* ⭐ 新增以下两行 ⭐ */
    justify-content: center; /* 水平居中 */
    align-items: center;     /* 垂直居中 */

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
    gap: 16px;
  }

  .nav-icons .nav-icon {
    margin-left: 0;
    cursor: pointer;
    font-size: 1.5rem; /* 图标大小 */
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.3s, color 0.3s;
    color: #333;
    gap: 5px;
  }

  .nav-icons .nav-icon:hover {
    transform: scale(1.1);
    color: #FF9500;
  }

  .nav-icons span { margin-left: 0; }

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
    margin-left: 0;
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

  /* ================= Merchant minimal header ================= */
  .home-header.pg-header-merchant-minimal .nav-menu,
  .home-header.pg-header-merchant-minimal .nav-login-btn-link {
    display: none !important;
  }

  .home-header.pg-header-merchant-minimal .nav-icons .nav-icon {
    display: none !important;
  }

  .home-header.pg-header-merchant-minimal .pg-merchant-username,
  .home-header.pg-header-merchant-minimal .pg-merchant-wallet,
  .home-header.pg-header-merchant-minimal .nav-avatar {
    display: inline-flex !important;
    align-items: center;
    opacity: 1 !important;
    visibility: visible !important;
  }

  .home-header.pg-header-merchant-minimal .nav-icons { gap: 18px; }

  .home-header .pg-merchant-username {
    margin-left: 0;
    font-weight: 700;
    color: #2d3436;
    font-size: 0.98rem;
    max-width: 220px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    line-height: 1;
  }

  .home-header .pg-merchant-wallet {
    text-decoration: none;
    color: #444;
    font-weight: 600;
    font-size: 1rem;
    padding: 8px 16px;
    border-radius: 20px;
    transition: all 0.3s ease;
    background: transparent;
  }

  .home-header .pg-merchant-wallet:hover {
    color: #FF9500;
    background: rgba(0, 0, 0, 0.03);
    transform: translateY(-2px);
  }

  /* ================= Dropdown Styles ================= */
  .nav-item-dropdown { position: relative; }

  .dropdown-menu {
    display: none;
    position: absolute;
    top: 100%;
    left: 0;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    border: 1px solid rgba(255, 255, 255, 0.9);
    border-radius: 15px;
    padding: 10px 0;
    min-width: 200px;
    flex-direction: column;
    gap: 2px;
    z-index: 1001;
    list-style: none;
    margin-top: 10px;
    animation: fadeInDown 0.3s ease;
  }

  @keyframes fadeInDown {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .nav-item-dropdown:hover .dropdown-menu { display: flex; }
  .dropdown-menu li { width: 100%; }

  .dropdown-menu a {
    display: block;
    padding: 10px 20px;
    white-space: nowrap;
    color: #444;
    font-weight: 500;
    transition: all 0.2s;
    border-radius: 0;
  }

  .dropdown-menu a:hover {
    background: rgba(255, 149, 0, 0.1);
    color: #FF9500;
    padding-left: 25px;
  }

  /* ================= Search Overlay Styles ================= */
  .search-container {
    display: none;
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    padding: 10px;
    border-radius: 10px;
    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    margin-top: 10px;
  }

  .search-container.active {
    display: block;
    animation: fadeInDown 0.3s ease;
  }

  .search-form { display: flex; align-items: center; gap: 5px; }

  .search-input-header {
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 20px;
    outline: none;
    font-size: 0.9rem;
    width: 200px;
  }

  .search-btn-header {
    background: none;
    border: none;
    cursor: pointer;
    font-size: 1.2rem;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #444;
    transition: color 0.3s;
  }

  .search-btn-header:hover {
    color: #FF9500;
  }
</style>

<script>
  function toggleSearch() {
    const searchContainer = document.querySelector('.search-container');
    searchContainer.classList.toggle('active');
    if (searchContainer.classList.contains('active')) {
      document.querySelector('.search-input-header').focus();
    }
  }

  document.addEventListener('click', function(event) {
    const searchContainer = document.querySelector('.search-container');
    const searchIcon = document.querySelector('.nav-icon-search');

    if (searchContainer && searchIcon && !searchContainer.contains(event.target) && !searchIcon.contains(event.target)) {
      searchContainer.classList.remove('active');
    }
  });
</script>