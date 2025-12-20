<%@ page import="com.primego.user.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ==========================================
    // 1. 安全检查逻辑
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Publish Product - Seller Center</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        /* ==================== 变量定义 ==================== */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --secondary: #FF5E55;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --glass-bg: rgba(255, 255, 255, 0.95);
            --card-radius: 16px;
            --card-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --border-color: #dfe6e9;

            /* Glass tokens (match merchant sidebar glass) */
            --pg-glass-bg-055: rgba(255, 255, 255, 0.55);
            --pg-glass-border: rgba(255, 255, 255, 0.9);
            --pg-glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
            --pg-glass-blur: 25px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
            position: relative;
            /* header_bar.jsp is fixed */
            padding-top: 90px;
        }

        /* 核心布局 - Grid */
        .layout-container {
            max-width: 1400px;
            margin: 25px auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 30px;
            align-items: start;
        }

        /* ==================== Publish 表单样式 ==================== */
        .form-card {
            background: var(--pg-glass-bg-055);
            backdrop-filter: blur(var(--pg-glass-blur));
            -webkit-backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            box-shadow: var(--pg-glass-shadow);

            border-radius: var(--card-radius);
            padding: 30px 40px;
            width: 100%;

            /* 入场效果 */
            opacity: 0;
            transform: translateY(22px);
            animation: pgFadeInUp 0.6s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
        }

        /* 卡片入场动画：从下往上浮现 */
        @keyframes pgFadeInUp {
            from { opacity: 0; transform: translateY(22px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (prefers-reduced-motion: reduce) {
            .form-card {
                opacity: 1;
                transform: none;
                animation: none;
            }
        }

        .page-header { margin-bottom: 25px; border-bottom: 1px solid rgba(0,0,0,0.06); padding-bottom: 15px; }
        .page-header h2 { font-size: 1.6rem; font-weight: 700; color: var(--text-dark); margin-bottom: 5px; }
        .page-header p { color: var(--text-gray); font-size: 0.85rem; }

        /* Grid: 2:1 比例 */
        .form-content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }

        /* 表单控件 */
        .form-group { margin-bottom: 18px; }
        .row-group { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

        .form-label { display: block; font-weight: 600; margin-bottom: 6px; color: var(--text-dark); font-size: 0.9rem; }
        .form-label span { color: var(--secondary); margin-left: 2px; }

        .form-input, .form-select, .form-textarea {
            width: 100%; padding: 10px 15px;
            border: 2px solid rgba(0,0,0,0.06);
            border-radius: 10px;
            font-size: 0.9rem; transition: 0.3s;
            background: rgba(255,255,255,0.55);
            color: var(--text-dark); outline: none;
        }
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: var(--primary);
            background: rgba(255,255,255,0.75);
            box-shadow: 0 0 0 4px rgba(255, 149, 0, 0.1);
        }

        /* 上传区域 */
        .right-col { display: flex; flex-direction: column; }
        .upload-container { flex-grow: 1; display: flex; flex-direction: column; }
        .upload-box {
            flex-grow: 1;
            min-height: 280px;
            border: 2px dashed rgba(0,0,0,0.12);
            border-radius: var(--card-radius);
            background: rgba(255,255,255,0.35);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            position: relative;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            transition: all 0.3s ease; cursor: pointer; overflow: hidden;
        }
        .upload-box:hover { border-color: var(--primary); background: rgba(255, 244, 230, 0.55); }

        .upload-icon-circle {
            width: 60px; height: 60px; background: rgba(255,255,255,0.7); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }
        .upload-icon { font-size: 1.8rem; color: #b2bec3; }
        .upload-text { font-weight: 700; color: var(--text-dark); margin-bottom: 2px; font-size: 1rem; }
        .upload-sub { font-size: 0.75rem; color: #b2bec3; text-align: center; }

        #imagePreview { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; display: none; }
        .remove-btn {
            position: absolute; top: 15px; right: 15px; width: 35px; height: 35px; border-radius: 50%;
            background: rgba(255,255,255,0.85); color: var(--secondary); border: none; cursor: pointer;
            display: none; align-items: center; justify-content: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); font-size: 1.2rem; z-index: 10;
        }

        /* 按钮区 */
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
            .upload-box { min-height: 250px; margin-top: 20px; }
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
                        <select id="category" name="category" class="form-select">
                            <option value="electronics">Electronics</option>
                            <option value="fashion">Fashion</option>
                            <option value="home">Home & Living</option>
                            <option value="books">Books</option>
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

                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label" for="description">Description</label>
                        <textarea id="description" name="description" class="form-textarea" rows="5" placeholder="Describe your item..."></textarea>
                    </div>
                </div>

                <div class="right-col">
                    <label class="form-label" for="fileInput">Product Image <span>*</span></label>
                    <div class="upload-container">
                        <input type="file" name="productImage" id="fileInput" accept="image/*" hidden required>

                        <div class="upload-box" id="dropZone" onclick="document.getElementById('fileInput').click()">
                            <div id="uploadPlaceholder" style="text-align: center;">
                                <div class="upload-icon-circle">
                                    <i class="ri-image-add-line upload-icon"></i>
                                </div>
                                <div class="upload-text">Upload Image</div>
                                <div class="upload-sub">Supports: JPG, PNG, WEBP</div>
                            </div>

                            <img id="imagePreview" src="" alt="Preview">

                            <button type="button" class="remove-btn" id="removeBtn" onclick="removeImage(event)">
                                <i class="ri-close-line"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="btn-container">
                <button type="button" class="btn-cancel" onclick="history.back()">Cancel</button>
                <button type="submit" class="btn-submit">Publish Now</button>
            </div>

        </form>
    </main>
</div>

<script>
    const fileInput = document.getElementById('fileInput');
    const dropZone = document.getElementById('dropZone');
    const imagePreview = document.getElementById('imagePreview');
    const uploadPlaceholder = document.getElementById('uploadPlaceholder');
    const removeBtn = document.getElementById('removeBtn');

    fileInput.addEventListener('change', function() {
        if (this.files && this.files[0]) showPreview(this.files[0]);
    });

    function showPreview(file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            imagePreview.src = e.target.result;
            imagePreview.style.display = 'block';
            uploadPlaceholder.style.display = 'none';
            removeBtn.style.display = 'flex';
            dropZone.style.borderStyle = 'solid';
            dropZone.style.borderColor = 'transparent';
        }
        reader.readAsDataURL(file);
    }

    function removeImage(event) {
        event.stopPropagation();
        fileInput.value = '';
        imagePreview.style.display = 'none';
        imagePreview.src = '';
        uploadPlaceholder.style.display = 'block';
        removeBtn.style.display = 'none';
        dropZone.style.borderStyle = 'dashed';
        dropZone.style.borderColor = 'rgba(0,0,0,0.12)';
    }

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(e => {
        dropZone.addEventListener(e, (ev) => { ev.preventDefault(); ev.stopPropagation(); });
    });

    dropZone.addEventListener('dragenter', () => dropZone.style.borderColor = 'var(--primary)');
    dropZone.addEventListener('dragleave', () => dropZone.style.borderColor = 'rgba(0,0,0,0.12)');
    dropZone.addEventListener('drop', (e) => {
        dropZone.style.borderColor = 'rgba(0,0,0,0.12)';
        const files = e.dataTransfer.files;
        if (files && files[0]) {
            fileInput.files = files;
            showPreview(files[0]);
        }
    });
</script>

</body>
</html>



