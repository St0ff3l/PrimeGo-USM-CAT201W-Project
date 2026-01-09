<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--
  Customer profile sidebar.

  Usage:
    <jsp:include page="/common/layout/customer_profile_sidebar.jsp">
      <jsp:param name="active" value="orders" />
    </jsp:include>

  Params:
    active: profile | orders | addresses | wallet | settings
--%>

<div class="sidebar">
    <h2>My Account</h2>

    <a href="${pageContext.request.contextPath}/profile" class="nav-item ${param.active == 'profile' ? 'active' : ''}">
        <i class="ri-user-line"></i><span>Profile Info</span>
    </a>

    <a href="${pageContext.request.contextPath}/customer/orders?status=ALL" class="nav-item ${param.active == 'orders' ? 'active' : ''}">
        <i class="ri-shopping-bag-3-line"></i><span>My Orders</span>
    </a>

    <a href="${pageContext.request.contextPath}/profile?tab=addresses" class="nav-item ${param.active == 'addresses' ? 'active' : ''}">
        <i class="ri-map-pin-line"></i><span>Addresses</span>
    </a>

    <a href="${pageContext.request.contextPath}/public/wallet/wallet.jsp" class="nav-item ${param.active == 'wallet' ? 'active' : ''}">
        <i class="ri-wallet-line"></i><span>Wallet</span>
    </a>

    <a href="${pageContext.request.contextPath}/profile?tab=settings" class="nav-item ${param.active == 'settings' ? 'active' : ''}">
        <i class="ri-settings-3-line"></i><span>Settings</span>
    </a>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-logout" style="margin-bottom: 10px; background: #555;">
            <i class="ri-home-4-line" style="margin-right: 5px;"></i>Back to Home
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">
            <i class="ri-logout-box-line" style="margin-right: 5px;"></i>Logout
        </a>
    </div>
</div>
