<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.user.model.Role" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Admin security check (align with AdminDashboardServlet)
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (user.getRole() != Role.ADMIN) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
        return;
    }

    @SuppressWarnings("unchecked")
    List<ProductDTO> products = (List<ProductDTO>) request.getAttribute("products");
    String currentFilter = (String) request.getAttribute("currentFilter");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Review - Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            /* background: linear-gradient(to bottom, #f0f2f5, #e0e5ec); */
            min-height: 100vh;
            color: #333;
            padding: 40px;
            position: relative;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .title {
            font-size: 2.2rem;
            font-weight: 700;
            color: #d63031;
            background: rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(10px);
            padding: 10px 30px;
            border-radius: 50px;
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        }

        .actions a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 12px 20px;
            border-radius: 30px;
            text-decoration: none;
            color: white;
            background: #333;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .actions a:hover {
            background: #555;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.15);
        }

        .panel {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 30px;
            overflow: hidden;
        }

        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 15px; border-bottom: 1px solid rgba(0,0,0,0.06); }
        th { color: #666; font-weight: 700; font-size: 0.95rem; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: rgba(255,255,255,0.3); }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        .badge-pending { background: #fff3e0; color: #ef6c00; border: 1px solid #ffe0b2; }
        .badge-approved { background: #e8f5e9; color: #2e7d32; border: 1px solid #c8e6c9; }
        .badge-rejected { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }

        /* ⭐ 新增的标签样式 */
        .badge-new {
            background: #e3f2fd;
            color: #1976d2;
            border: 1px solid #bbdefb;
        }
        .badge-update {
            background: #f3e5f5;
            color: #7b1fa2;
            border: 1px solid #e1bee7;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 8px 16px;
            border-radius: 20px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        .btn-view {
            background: linear-gradient(45deg, #FF3B30, #FF9500);
            color: white;
            box-shadow: 0 4px 10px rgba(255, 59, 48, 0.3);
        }
        .btn-view:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(255, 59, 48, 0.4);
        }

        .empty {
            padding: 40px;
            color: #666;
            text-align: center;
            font-size: 1.1rem;
        }

        /* Tabs */
        .tabs {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        .tab {
            padding: 10px 20px;
            border-radius: 25px;
            text-decoration: none;
            font-weight: 600;
            color: #666;
            background: rgba(255,255,255,0.5);
            transition: all 0.3s;
            border: 1px solid transparent;
        }
        .tab:hover {
            background: rgba(255,255,255,0.8);
        }
        .tab.active {
            background: #333;
            color: white;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>

<%@ include file="../../common/background_admin.jsp" %>

<div class="header">
    <div class="title">
        <i class="ri-shield-check-line" style="vertical-align: middle; margin-right: 10px;"></i>
        Product Review Queue
    </div>
    <div class="actions">
        <a href="${pageContext.request.contextPath}/admin/dashboard">
            <i class="ri-arrow-left-line"></i> Back to Dashboard
        </a>
    </div>
</div>

<div class="tabs">
    <a href="?filter=pending" class="tab <%= "pending".equals(currentFilter) ? "active" : "" %>">Pending Review</a>
    <a href="?filter=history" class="tab <%= "history".equals(currentFilter) ? "active" : "" %>">Review History</a>
</div>

<div class="panel">
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Product</th>
            <th>Merchant</th>
            <th>Category</th>
            <th>Status</th>
            <th><%= "history".equals(currentFilter) ? "Reviewed At" : "Created At" %></th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (products == null || products.isEmpty()) {
        %>
        <tr><td colspan="7" class="empty">No products found.</td></tr>
        <%
        } else {
            for (ProductDTO p : products) {
                // 原有状态样式
                String badgeClass = "badge-pending";
                if ("APPROVED".equals(p.getAuditStatus())) badgeClass = "badge-approved";
                if ("REJECTED".equals(p.getAuditStatus())) badgeClass = "badge-rejected";

                // ⭐ 判断是新商品还是修改
                boolean isModification = p.isHasBeenApproved();
                String typeLabel = isModification ? "Modification" : "New Listing";
                String typeClass = isModification ? "badge-update" : "badge-new";
        %>
        <tr>
            <td><%= p.getProductId() %></td>
            <td>
                <div style="font-weight: 600;"><%= p.getProductName() %></div>

                <% if ("PENDING".equals(p.getAuditStatus())) { %>
                <span class="badge <%= typeClass %>" style="font-size: 0.75rem; margin-top: 5px;">
                        <%= typeLabel %>
                    </span>
                <% } %>
            </td>
            <td><%= p.getMerchantName() %></td>
            <td><%= p.getCategoryName() %></td>
            <td><span class="badge <%= badgeClass %>"><%= p.getAuditStatus() %></span></td>
            <td><%= "history".equals(currentFilter) ? p.getProductUpdatedAt() : p.getProductCreatedAt() %></td>
            <td>
                <a class="btn btn-view" href="${pageContext.request.contextPath}/admin/product/review?productId=<%= p.getProductId() %>">
                    <%= "history".equals(currentFilter) ? "View" : "Review" %>
                </a>
            </td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>

</body>
</html>