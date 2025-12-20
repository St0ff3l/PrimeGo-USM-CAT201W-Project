<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--
  Merchant Sidebar (Reusable Layout Component)
  Contract:
  - Input: requestScope.activeMenu (String) e.g. "dashboard" | "products" | "orders" | "wallet" | "profile"
  - Output: <aside class="sidebar-card">...</aside>

  Self-contained:
  - Uses inline SVG icons (no external icon fonts)
  - Optionally injects Poppins font (best-effort; UI still works without it)
  - Includes all CSS needed for the sidebar look & feel
  - Styles are scoped under .pg-merchant-sidebar to avoid clashes
--%>

<script>
    (function ensureMerchantSidebarAssets() {
        var head = document.head || document.getElementsByTagName('head')[0];
        if (!head) return;

        function ensureLink(id, href, rel, extra) {
            if (document.getElementById(id)) return;
            var link = document.createElement('link');
            link.id = id;
            link.rel = rel || 'stylesheet';
            link.href = href;
            if (extra) {
                Object.keys(extra).forEach(function (k) { link.setAttribute(k, extra[k]); });
            }
            head.appendChild(link);
        }

        /* Font is optional; icons are inline SVG so no external icon font needed */
        ensureLink('pg-merchant-sidebar-preconnect-gfonts', 'https://fonts.googleapis.com', 'preconnect');
        ensureLink('pg-merchant-sidebar-preconnect-gstatic', 'https://fonts.gstatic.com', 'preconnect', { crossorigin: '' });
        ensureLink('pg-merchant-sidebar-font-poppins', 'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap', 'stylesheet');
    })();
</script>

<style>
    /* ================= Merchant Sidebar UI (Self-contained) ================= */

    /* Scope everything to avoid leaking styles */
    .pg-merchant-sidebar {
        /* component-local defaults (won't override a page that already defines these) */
        --pg-merchant-primary: var(--primary, #FF9500);
        --pg-merchant-secondary: var(--secondary, #FF5E55);
        --pg-merchant-text-dark: var(--text-dark, #2d3436);
        --pg-merchant-text-gray: var(--text-gray, #636e72);
        --pg-merchant-card-radius: var(--card-radius, 16px);
        --pg-merchant-card-shadow: var(--card-shadow, 0 10px 30px rgba(0, 0, 0, 0.05));
    }

    .pg-merchant-sidebar,
    .pg-merchant-sidebar * ,
    .pg-merchant-sidebar *::before,
    .pg-merchant-sidebar *::after {
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }

    .pg-merchant-sidebar .sidebar-card {
        background: rgba(255, 255, 255, 0.98);
        border-radius: var(--pg-merchant-card-radius);
        padding: 26px 18px;
        box-shadow: var(--pg-merchant-card-shadow);
        position: sticky;
        top: 100px;
        height: calc(100vh - 130px);
        display: flex;
        flex-direction: column;
    }

    .pg-merchant-sidebar .menu-group {
        display: flex;
        flex-direction: column;
    }

    .pg-merchant-sidebar .menu-group + .menu-group {
        margin-top: 18px;
    }

    .pg-merchant-sidebar .menu-group-title {
        font-size: 0.78rem;
        color: #b2bec3;
        font-weight: 800;
        margin: 0 12px 10px;
        text-transform: uppercase;
        letter-spacing: 1.6px;
    }

    .pg-merchant-sidebar .menu-item {
        position: relative;
        display: flex;
        align-items: center;
        gap: 12px;

        padding: 12px 14px;
        margin: 4px 6px;

        color: var(--pg-merchant-text-dark);
        text-decoration: none;

        border-radius: 14px;
        transition: transform 0.2s ease, background 0.2s ease, color 0.2s ease, box-shadow 0.2s ease;

        font-weight: 650;
        font-size: 0.98rem;
        line-height: 1;

        cursor: pointer;
        border: none;
        background: transparent;
        width: auto;
        text-align: left;
    }

    /* Icon base: consistent square so items align nicely */
    .pg-merchant-sidebar .menu-item .pg-mi {
        width: 30px;
        height: 30px;
        border-radius: 10px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex: 0 0 30px;

        color: var(--pg-merchant-text-gray);
        background: rgba(0, 0, 0, 0.04);
        transition: background 0.2s ease, color 0.2s ease;
    }

    .pg-merchant-sidebar .menu-item .pg-mi svg {
        width: 18px;
        height: 18px;
        display: block;
        stroke: currentColor;
        fill: none;
        stroke-width: 2;
        stroke-linecap: round;
        stroke-linejoin: round;
    }

    /* Hard override for hostile global CSS (e.g. svg { fill: transparent } or svg { display:none }) */
    .pg-merchant-sidebar svg {
        display: block !important;
        visibility: visible !important;
        opacity: 1 !important;
    }

    .pg-merchant-sidebar .pg-mi svg {
        stroke: currentColor !important;
        fill: none !important;
        stroke-width: 2 !important;
    }

    /* Even stronger: some resets target the SVG shape elements directly */
    .pg-merchant-sidebar svg path,
    .pg-merchant-sidebar svg rect,
    .pg-merchant-sidebar svg circle,
    .pg-merchant-sidebar svg line,
    .pg-merchant-sidebar svg polyline,
    .pg-merchant-sidebar svg polygon {
        stroke: currentColor !important;
        fill: none !important;
        stroke-width: 2 !important;
        opacity: 1 !important;
        visibility: visible !important;
        vector-effect: non-scaling-stroke;
    }

    .pg-merchant-sidebar .menu-item:hover {
        background: #FFF4E6;
        color: var(--pg-merchant-primary);
        transform: translateX(4px);
    }

    .pg-merchant-sidebar .menu-item:hover .pg-mi {
        background: rgba(255, 149, 0, 0.14);
        color: var(--pg-merchant-primary);
    }

    .pg-merchant-sidebar .menu-item.active-view {
        background: linear-gradient(45deg, var(--pg-merchant-primary), var(--pg-merchant-secondary));
        color: #fff;
        box-shadow: 0 8px 22px rgba(255, 94, 85, 0.25);
        transform: none;
    }

    .pg-merchant-sidebar .menu-item.active-view .pg-mi {
        background: rgba(255, 255, 255, 0.18);
        color: #fff;
    }

    /* Small active icon badge */
    .pg-merchant-sidebar .menu-item.active-view::after {
        content: "";
        position: absolute;
        left: 10px;
        top: 50%;
        transform: translateY(-50%);
        width: 34px;
        height: 34px;
        border-radius: 12px;
        background: rgba(255, 255, 255, 0.14);
        pointer-events: none;
    }

    /* Destructive action: Logout */
    .pg-merchant-sidebar .menu-item.menu-logout {
        color: #d63031;
    }

    .pg-merchant-sidebar .menu-item.menu-logout .pg-mi {
        color: #d63031;
        background: rgba(214, 48, 49, 0.08);
    }

    .pg-merchant-sidebar .menu-item.menu-logout:hover {
        background: rgba(214, 48, 49, 0.10);
        color: #d63031;
        transform: translateX(4px);
    }

    .pg-merchant-sidebar .menu-item.menu-logout:hover .pg-mi {
        background: rgba(214, 48, 49, 0.16);
        color: #d63031;
    }

    @media (max-width: 1024px) {
        .pg-merchant-sidebar .sidebar-card { align-items: center; padding: 20px 10px; }
        .pg-merchant-sidebar .menu-item span,
        .pg-merchant-sidebar .menu-group-title { display: none; }
        .pg-merchant-sidebar .menu-item { margin: 6px 0; padding: 12px; }
    }
</style>

<c:set var="active" value="${empty requestScope.activeMenu ? 'dashboard' : requestScope.activeMenu}" />

<div class="pg-merchant-sidebar">
    <aside class="sidebar-card">
        <div class="menu-group">
            <div class="menu-group-title">Overview</div>

            <a class="menu-item ${active == 'dashboard' ? 'active-view' : ''}"
               href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <rect x="3" y="3" width="8" height="8" rx="2"></rect>
                        <rect x="13" y="3" width="8" height="5" rx="2"></rect>
                        <rect x="13" y="10" width="8" height="11" rx="2"></rect>
                        <rect x="3" y="13" width="8" height="8" rx="2"></rect>
                    </svg>
                </span>
                <span>Dashboard</span>
            </a>
        </div>

        <div class="menu-group">
            <div class="menu-group-title">Manage</div>

            <a class="menu-item ${active == 'products' ? 'active-view' : ''}"
               href="${pageContext.request.contextPath}/merchant/product/product_manager.jsp">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                        <path d="M3.3 7l8.7 5 8.7-5"></path>
                        <path d="M12 22V12"></path>
                    </svg>
                </span>
                <span>Products</span>
            </a>

            <a class="menu-item ${active == 'orders' ? 'active-view' : ''}"
               href="${pageContext.request.contextPath}/merchant/order/manage.jsp">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <rect x="4" y="3" width="16" height="18" rx="2"></rect>
                        <path d="M8 7h8"></path>
                        <path d="M8 11h8"></path>
                        <path d="M8 15h6"></path>
                    </svg>
                </span>
                <span>Orders</span>
            </a>

            <a class="menu-item ${active == 'wallet' ? 'active-view' : ''}"
               href="${pageContext.request.contextPath}/merchant/wallet/">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7z"></path>
                        <path d="M21 9H17a2 2 0 0 0 0 4h4"></path>
                        <path d="M17 11h.01"></path>
                    </svg>
                </span>
                <span>Wallet</span>
            </a>
        </div>

        <div class="menu-group">
            <div class="menu-group-title">Account</div>

            <a class="menu-item ${active == 'profile' ? 'active-view' : ''}"
               href="${pageContext.request.contextPath}/merchant/user/merchant_profile.jsp">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M20 21a8 8 0 0 0-16 0"></path>
                        <circle cx="12" cy="7" r="4"></circle>
                    </svg>
                </span>
                <span>Profile</span>
            </a>

            <a class="menu-item menu-logout" href="${pageContext.request.contextPath}/logout">
                <span class="pg-mi" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                        <path d="M16 17l5-5-5-5"></path>
                        <path d="M21 12H9"></path>
                    </svg>
                </span>
                <span>Logout</span>
            </a>
        </div>
    </aside>
</div>
