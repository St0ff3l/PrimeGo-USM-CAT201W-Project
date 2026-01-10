<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.CategoryDAO" %>
<%@ page import="com.primego.product.model.Category" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ==========================================
    // 1. Access control checks
    // ==========================================
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }
    String roleStr = (user.getRole() != null) ? user.getRole().toString() : "";
    if (!"MERCHANT".equals(roleStr) && !"ADMIN".equals(roleStr)) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    // Load categories for the <select> dropdown
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categories = categoryDAO.findAll();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Publish Product - Seller Center</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/images_uploader.css" rel="stylesheet">

    <style>
        /* ==================== CSS variables ==================== */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500; /* PrimeGo orange */
            --primary-hover: #E68600;
            --secondary: #FF5E55;
            --text-dark: #2d3436;
            --text-gray: #636e72;

            /* Glassmorphism tokens */
            --pg-glass-bg-055: rgba(255, 255, 255, 0.55);
            --pg-glass-border: rgba(255, 255, 255, 0.9);
            --pg-glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
            --pg-glass-blur: 25px;
            --card-radius: 16px;

            /* Theme overrides for the image uploader component */
            --iu-primary: var(--primary);
            --iu-bg: rgba(255, 255, 255, 0.4);
            --iu-border: #dfe6e9;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
            position: relative;
            padding-top: 90px;
        }

        /* Main layout grid */
        .layout-container {
            max-width: 1400px;
            margin: 25px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 30px;
            align-items: start;
        }

        /* ==================== Publish form styles ==================== */
        .form-card {
            background: var(--pg-glass-bg-055);
            backdrop-filter: blur(var(--pg-glass-blur));
            -webkit-backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            box-shadow: var(--pg-glass-shadow);
            border-radius: var(--card-radius);
            padding: 30px 40px;
            width: 100%;
            /* Entrance animation */
            opacity: 0;
            transform: translateY(22px);
            animation: pgFadeInUp 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
        }

        @keyframes pgFadeInUp {
            from { opacity: 0; transform: translateY(22px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .page-header { margin-bottom: 25px; border-bottom: 1px solid rgba(0,0,0,0.06); padding-bottom: 15px; }
        .page-header h2 { font-size: 1.6rem; font-weight: 700; color: var(--text-dark); margin-bottom: 5px; }
        .page-header p { color: var(--text-gray); font-size: 0.85rem; }

        /* Grid: give more space to the upload area */
        .form-content-grid {
            display: grid;
            grid-template-columns: 1.8fr 1.2fr;
            gap: 40px;
        }

        /* Form controls */
        .form-group { margin-bottom: 18px; }
        .row-group { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

        .form-label { display: block; font-weight: 600; margin-bottom: 6px; color: var(--text-dark); font-size: 0.9rem; }
        .form-label span { color: var(--secondary); margin-left: 2px; }

        .form-input, .form-select, .form-textarea {
            width: 100%; padding: 10px 15px;
            border: 2px solid rgba(0,0,0,0.06);
            border-radius: 10px;
            font-size:  0.9rem; transition: 0.3s;
            background: rgba(255,255,255,0.55);
            color: var(--text-dark); outline: none;
        }
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: var(--primary);
            background: rgba(255,255,255,0.75);
            box-shadow: 0 0 0 4px rgba(255, 149, 0, 0.1);
        }

        /* Upload area container */
        .right-col { display: flex; flex-direction: column; }

        /* Form actions */
        .btn-container {
            margin-top: 20px;
            display: flex; justify-content: flex-end; gap: 15px;
            border-top: 1px solid rgba(0,0,0,0.06); padding-top: 20px;
        }
        .btn-cancel {
            padding: 10px 30px; border-radius: 30px; border: 1px solid rgba(0,0,0,0.12);
            background: rgba(255,255,255,0.7); color: var(--text-gray); font-weight: 600; cursor: pointer; transition: 0.3s;
        }
        .btn-cancel:hover { border-color: var(--text-dark); color: var(--text-dark); }
        .btn-submit {
            padding: 10px 40px; border-radius: 30px; border: none;
            background: var(--primary); color: white; font-weight: 600; cursor: pointer;
            box-shadow: 0 5px 15px rgba(255, 149, 0, 0.3); transition: 0.3s;
        }
        .btn-submit:hover { background: var(--primary-hover); transform: translateY(-2px); }

        @media (max-width: 1024px) {
            .layout-container { grid-template-columns: 80px 1fr; }
            .form-content-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="layout-container">

    <% request.setAttribute("activeMenu", "publish"); %>
    <%@ include file="../../common/layout/merchant_sidebar.jsp" %>

    <main>
        <form action="${pageContext.request.contextPath}/product_add_action" method="post" enctype="multipart/form-data" class="form-card">

            <div class="page-header">
                <h2>Publish New Product</h2>
                <p>Fill in the details below to add a new item to your store.</p>
            </div>

            <div class="form-content-grid">

                <div class="left-col">
                    <div class="form-group">
                        <label class="form-label" for="productName">Product Name <span>*</span></label>
                        <input id="productName" type="text" name="productName" class="form-input" placeholder="e.g. Vintage Leather Jacket" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="category">Category <span>*</span></label>
                        <select id="category" name="categoryId" class="form-select" required>
                            <option value="" disabled selected>Select a category</option>
                            <% for (Category c : categories) { %>
                            <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="row-group">
                        <div class="form-group">
                            <label class="form-label" for="price">Price (RM) <span>*</span></label>
                            <input id="price" type="number" name="price" class="form-input" placeholder="0.00" step="0.01" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="stock">Stock <span>*</span></label>
                            <input id="stock" type="number" name="stock" class="form-input" placeholder="1" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="whatsapp">
                            <i class="ri-whatsapp-line" style="font-size: 1.1rem; vertical-align: middle; margin-right: 4px; color: #25D366;"></i>
                            WhatsApp Contact <span>*</span>
                        </label>
                        <input id="whatsapp" type="text" name="contactWhatsapp" class="form-input" placeholder="e.g. 60123456789" required>
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label" for="description">Description</label>
                        <textarea id="description" name="description" class="form-textarea" rows="5" placeholder="Describe your item..."></textarea>
                    </div>
                </div>

                <div class="right-col">
                    <label class="form-label">Product Images <span>*</span></label>

                    <div id="photo-upload-container"></div>
                </div>
            </div>

            <div class="btn-container">
                <button type="button" class="btn-cancel" onclick="history.back()">Cancel</button>
                <button type="submit" class="btn-submit">Publish Now</button>
            </div>

        </form>
    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/images_uploader.js?v=<%= System.currentTimeMillis() %>"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Initialize the image uploader
        // 1) Container selector
        // 2) inputName: the <input type="file"> name used for form submission
        // Note: if the backend expects multiple files under the same field name, keep it as 'productImage'.
        new ImagesUploader('#photo-upload-container', {
            inputName: 'productImage',
            placeholderImg: '${pageContext.request.contextPath}/assets/images/product-placeholder.svg'
        });
    });
</script>

</body>
</html>

