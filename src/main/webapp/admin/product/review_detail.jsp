<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.user.model.Role" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.product.model.ProductImage" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (user.getRole() != Role.ADMIN) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
        return;
    }

    ProductDTO product = (ProductDTO) request.getAttribute("product");
    @SuppressWarnings("unchecked")
    List<ProductImage> images = (List<ProductImage>) request.getAttribute("images");

    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Product - Admin</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family: 'Poppins', sans-serif; }
        body { background: linear-gradient(to bottom, #f0f2f5, #e0e5ec); padding: 40px; color:#333; }

        .top {
            display:flex;
            justify-content: space-between;
            align-items:center;
            margin-bottom: 18px;
        }
        .title { font-size: 1.8rem; font-weight: 800; color:#d63031; }
        .top a { text-decoration:none; padding: 10px 14px; border-radius: 12px; background:#333; color:white; }

        .panel { background: rgba(255,255,255,0.75); border: 1px solid rgba(255,255,255,0.6); border-radius: 16px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); padding: 20px; }

        .grid { display:grid; grid-template-columns: 1.4fr 1fr; gap: 20px; }
        .field { margin-bottom: 10px; }
        .label { font-size: 0.85rem; color:#666; font-weight: 700; margin-bottom: 4px; }
        .value { font-size: 1rem; font-weight: 700; }

        .images { display:grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
        .images img { width: 100%; aspect-ratio: 1/1; object-fit: cover; border-radius: 12px; border: 1px solid rgba(0,0,0,0.08); }

        .status { display:inline-block; padding: 4px 10px; border-radius: 999px; font-size: 0.8rem; font-weight: 800; background:#fff3e0; color:#ef6c00; }

        .actions { margin-top: 16px; display:flex; justify-content:flex-end; gap: 10px; }
        .btn { border:none; padding: 10px 14px; border-radius: 12px; font-weight: 800; cursor:pointer; }
        .btn-approve { background: #27ae60; color: white; }
        .btn-reject { background: #d63031; color: white; }

        .input { width:100%; padding: 10px 12px; border-radius: 12px; border: 2px solid rgba(0,0,0,0.08); background: rgba(255,255,255,0.8); }

        .message { margin-bottom: 12px; padding: 10px 12px; border-radius: 12px; font-weight: 700; }
        .message-success { background: #e8f5e9; color:#1b5e20; }
        .message-error { background:#ffebee; color:#b71c1c; }

        @media (max-width: 1024px) {
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="top">
    <div class="title">Review Product</div>
    <a href="${pageContext.request.contextPath}/admin/product/review/list">Back to Queue</a>
</div>

<div class="panel">

    <% if (msg != null && "approved".equals(msg)) { %>
        <div class="message message-success">Product approved.</div>
    <% } else if (msg != null && "rejected".equals(msg)) { %>
        <div class="message message-error">Product rejected.</div>
    <% } %>

    <% if (product == null) { %>
        <div class="message message-error">Product not found.</div>
    <% } else { %>

    <div class="grid">
        <div>
            <div class="field">
                <div class="label">Product</div>
                <div class="value"><%= product.getProductName() %></div>
            </div>
            <div class="field">
                <div class="label">Audit Status</div>
                <div class="value"><span class="status"><%= product.getAuditStatus() %></span></div>
            </div>
            <div class="field">
                <div class="label">Audit Message</div>
                <div class="value"><%= (product.getAuditMessage() == null || product.getAuditMessage().isEmpty()) ? "-" : product.getAuditMessage() %></div>
            </div>
            <div class="field">
                <div class="label">Merchant</div>
                <div class="value"><%= product.getMerchantName() %></div>
            </div>
            <div class="field">
                <div class="label">Category</div>
                <div class="value"><%= product.getCategoryName() %></div>
            </div>
            <div class="field">
                <div class="label">Price</div>
                <div class="value">RM <%= product.getProductPrice() %></div>
            </div>
            <div class="field">
                <div class="label">Stock</div>
                <div class="value"><%= product.getProductStockQuantity() %></div>
            </div>
            <div class="field">
                <div class="label">Description</div>
                <div class="value"><%= (product.getProductDescription() == null || product.getProductDescription().isEmpty()) ? "-" : product.getProductDescription() %></div>
            </div>
        </div>

        <div>
            <div class="label" style="margin-bottom: 10px;">Images</div>
            <div class="images">
                <%
                    if (images != null && !images.isEmpty()) {
                        for (ProductImage img : images) {
                %>
                    <img src="${pageContext.request.contextPath}/<%= img.getImageUrl() %>" alt="product image">
                <%
                        }
                    } else {
                %>
                    <div style="grid-column:1/-1; color:#666;">No images.</div>
                <%
                    }
                %>
            </div>

            <hr style="border:none; border-top: 1px solid rgba(0,0,0,0.06); margin: 16px 0;">

            <form method="post" action="${pageContext.request.contextPath}/admin/product/review/action">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">

                <div class="field">
                    <div class="label">Reject reason (only required for reject)</div>
                    <textarea class="input" name="reason" rows="4" placeholder="Optional message to merchant..."></textarea>
                </div>

                <div class="actions">
                    <button class="btn btn-reject" type="submit" name="action" value="reject">Reject</button>
                    <button class="btn btn-approve" type="submit" name="action" value="approve">Approve</button>
                </div>

            </form>
        </div>
    </div>

    <% } %>

</div>

</body>
</html>
