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
    List<ProductDTO> pendingProducts = (List<ProductDTO>) request.getAttribute("pendingProducts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Review - Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height: 100vh;
            color: #333;
            padding: 40px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #d63031;
        }

        .actions a {
            display: inline-block;
            padding: 10px 14px;
            border-radius: 12px;
            text-decoration: none;
            color: white;
            background: #333;
        }

        .panel {
            background: rgba(255,255,255,0.75);
            border: 1px solid rgba(255,255,255,0.6);
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            padding: 18px;
        }

        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 12px; border-bottom: 1px solid rgba(0,0,0,0.06); }
        th { color: #666; font-weight: 700; font-size: 0.9rem; }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 700;
        }
        .badge-pending { background: #fff3e0; color: #ef6c00; }

        .btn {
            display: inline-block;
            padding: 8px 12px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 700;
        }
        .btn-view { background: linear-gradient(45deg, #FF3B30, #FF9500); color: white; }

        .empty {
            padding: 20px;
            color: #666;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="title">Product Review Queue</div>
    <div class="actions">
        <a href="${pageContext.request.contextPath}/admin/dashboard">Back to Dashboard</a>
    </div>
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
            <th>Created At</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (pendingProducts == null || pendingProducts.isEmpty()) {
        %>
        <tr><td colspan="7" class="empty">No products pending review.</td></tr>
        <%
            } else {
                for (ProductDTO p : pendingProducts) {
        %>
        <tr>
            <td><%= p.getProductId() %></td>
            <td><%= p.getProductName() %></td>
            <td><%= p.getMerchantName() %></td>
            <td><%= p.getCategoryName() %></td>
            <td><span class="badge badge-pending"><%= p.getAuditStatus() %></span></td>
            <td><%= p.getProductCreatedAt() %></td>
            <td>
                <a class="btn btn-view" href="${pageContext.request.contextPath}/admin/product/review?productId=<%= p.getProductId() %>">Review</a>
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
