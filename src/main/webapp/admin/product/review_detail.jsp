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
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; font-family: 'Poppins', sans-serif; }
        body {
            /* background: linear-gradient(to bottom, #f0f2f5, #e0e5ec); */
            padding: 40px;
            color:#333;
            min-height: 100vh;
            position: relative;
        }

        .top {
            display:flex;
            justify-content: space-between;
            align-items:center;
            margin-bottom: 30px;
        }
        .title {
            font-size: 2.2rem;
            font-weight: 700;
            color:#d63031;
            background: rgba(255, 255, 255, 0.6);
            backdrop-filter: blur(10px);
            padding: 10px 30px;
            border-radius: 50px;
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        }
        .top a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration:none;
            padding: 12px 20px;
            border-radius: 30px;
            background:#333;
            color:white;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .top a:hover {
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

        .grid { display:grid; grid-template-columns: 1.4fr 1fr; gap: 40px; }
        .field { margin-bottom: 20px; }
        .label { font-size: 0.9rem; color:#666; font-weight: 600; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        .value { font-size: 1.1rem; font-weight: 600; color: #2d3436; line-height: 1.5; }

        .images { display:grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 15px; }
        .images img {
            width: 100%;
            aspect-ratio: 1/1;
            object-fit: cover;
            border-radius: 15px;
            border: 1px solid rgba(255,255,255,0.8);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
            transition: transform 0.3s ease;
        }
        .images img:hover { transform: scale(1.05); }

        .status {
            display:inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 700;
            background:#fff3e0;
            color:#ef6c00;
            border: 1px solid #ffe0b2;
        }

        .actions { margin-top: 25px; display:flex; justify-content:flex-end; gap: 15px; }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            border:none;
            padding: 12px 25px;
            border-radius: 30px;
            font-weight: 600;
            cursor:pointer;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        .btn-approve {
            background: linear-gradient(45deg, #2ecc71, #27ae60);
            color: white;
            box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3);
        }
        .btn-approve:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(46, 204, 113, 0.4);
        }
        .btn-reject {
            background: linear-gradient(45deg, #e74c3c, #c0392b);
            color: white;
            box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3);
        }
        .btn-reject:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(231, 76, 60, 0.4);
        }

        .input {
            width:100%;
            padding: 15px;
            border-radius: 15px;
            border: 1px solid rgba(0,0,0,0.1);
            background: rgba(255,255,255,0.5);
            font-family: inherit;
            font-size: 1rem;
            transition: all 0.3s;
        }
        .input:focus {
            outline: none;
            background: white;
            box-shadow: 0 0 0 3px rgba(214, 48, 49, 0.1);
            border-color: #d63031;
        }

        .message { margin-bottom: 20px; padding: 15px 20px; border-radius: 15px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .message-success { background: #d4edda; color:#155724; border: 1px solid #c3e6cb; }
        .message-error { background:#f8d7da; color:#721c24; border: 1px solid #f5c6cb; }

        @media (max-width: 1024px) {
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background_admin.jsp" %>

<div class="top">
    <div class="title">
        <i class="ri-eye-line" style="vertical-align: middle; margin-right: 10px;"></i>
        Review Product
    </div>
    <a href="${pageContext.request.contextPath}/admin/product/review/list">
        <i class="ri-arrow-left-line"></i> Back to Queue
    </a>
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

            <% if ("PENDING".equals(product.getAuditStatus())) { %>
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
            <% } else { %>
            <div class="message <%= "APPROVED".equals(product.getAuditStatus()) ? "message-success" : "message-error" %>">
                This product has been <%= product.getAuditStatus().toLowerCase() %>.
            </div>
            <% } %>
        </div>
    </div>

    <% } %>

</div>

</body>
</html>
