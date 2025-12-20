<%@ page import="com.primego.user.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // ==========================================
    // 1. 安全检查逻辑
    // ==========================================
    try {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }
        if (user.getRole() == null) {
            out.println("<h2 style='color:red; padding:20px;'>Error: User Role is null.</h2>");
            return;
        }
        String roleStr = user.getRole().toString();
        if (!"MERCHANT".equals(roleStr) && !"ADMIN".equals(roleStr)) {
            response.sendRedirect(request.getContextPath() + "/public/login.jsp");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Error: " + e.getMessage());
        return;
    }
    User currentUser = (User) session.getAttribute("user");
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
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            min-height: 100vh;
            position: relative;
        }

        /* 背景球体 */
        .background-blob { position: fixed; border-radius: 50%; z-index: -1; filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2)); pointer-events: none; }
        .blob-red { width: 750px; height: 650px; top: -200px; left: -200px; transform: rotate(-10deg); background: #ffffff; }
        .blob-yellow { width: 900px; height: 700px; top: -250px; right: -100px; transform: rotate(30deg); background: linear-gradient(145deg, #ffdb4d, #e6b800); }
        .blob-orange { width: 1800px; height: 950px; bottom: -650px; left: -600px; transform: rotate(-10deg); background: #ffffff; }

        /* Navbar */
        .navbar {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            padding: 15px 40px;
            display: flex; justify-content: space-between; align-items: center;
            position: sticky; top: 0; z-index: 1000;
            border-bottom: 1px solid rgba(255,255,255,0.5);
            box-shadow: 0 4px 20px rgba(0,0,0,0.03);
            height: 80px; /* 固定高度确保对齐 */
        }
        .logo { font-weight: 800; font-size: 1.5rem; color: var(--secondary); display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .logo-img { width: 35px; height: 35px; object-fit: contain; }
        .nav-actions { display: flex; align-items: center; gap: 20px; }
        .nav-btn { border: none; background: transparent; font-weight: 600; color: var(--text-gray); cursor: pointer; font-size: 0.95rem; transition: 0.3s; }
        .nav-btn:hover { color: var(--primary); }

        /* 核心布局 - Grid */
        .layout-container {
            max-width: 1400px;
            margin: 25px auto; /* 稍微减小顶部边距 */
            padding: 0 20px;
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 30px;
            align-items: start; /* 顶部对齐，高度自由 */
        }

        /* Sidebar - 固定高度逻辑 */
        .sidebar-card {
            background: white; border-radius: var(--card-radius);
            padding: 25px 20px; box-shadow: var(--card-shadow);
            position: sticky; top: 105px; /* Navbar 80 + Margin 25 */
            height: calc(100vh - 130px); /* 视口高度减去导航和边距 */
            display: flex; flex-direction: column;
        }

        .menu-group-title { font-size: 0.8rem; color: #b2bec3; font-weight: 700; margin-bottom: 10px; margin-top: 20px; text-transform: uppercase; letter-spacing: 1px; }
        .menu-group-title:first-child { margin-top: 0; }
        .menu-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 15px; margin-bottom: 5px;
            color: var(--text-dark); text-decoration: none;
            border-radius: 12px; transition: all 0.3s ease; font-weight: 500; font-size: 0.95rem;
            cursor: pointer; border: none; background: transparent; width: 100%; text-align: left;
        }
        .menu-item:hover { background: #FFF4E6; color: var(--primary); transform: translateX(5px); }
        .menu-item.active-view { background: linear-gradient(45deg, #FF9500, #FF5E55); color: white; box-shadow: 0 5px 15px rgba(255, 94, 85, 0.3); }
        .menu-item i { font-size: 1.2rem; }

        /* ==================== Publish 表单样式 (压缩版) ==================== */
        .form-card {
            background: white;
            border-radius: var(--card-radius);
            padding: 30px 40px; /* 减少上下 padding，从40px减为30px */
            box-shadow: var(--card-shadow);
            width: 100%;
        }

        .page-header { margin-bottom: 25px; border-bottom: 1px solid #f1f2f6; padding-bottom: 15px; }
        .page-header h2 { font-size: 1.6rem; font-weight: 700; color: var(--text-dark); margin-bottom: 5px; }
        .page-header p { color: var(--text-gray); font-size: 0.85rem; }

        /* Grid: 2:1 比例 */
        .form-content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 40px;
        }

        /* 表单控件 */
        .form-group { margin-bottom: 18px; } /* 减小间距 */
        .row-group { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

        .form-label { display: block; font-weight: 600; margin-bottom: 6px; color: var(--text-dark); font-size: 0.9rem; }
        .form-label span { color: var(--secondary); margin-left: 2px; }

        .form-input, .form-select, .form-textarea {
            width: 100%; padding: 10px 15px; /* 稍微减小高度 */
            border: 2px solid #f1f2f6; border-radius: 10px;
            font-size: 0.9rem; transition: 0.3s;
            background: #fcfcfc; color: var(--text-dark); outline: none;
        }
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: var(--primary); background: white;
            box-shadow: 0 0 0 4px rgba(255, 149, 0, 0.1);
        }

        /* 上传区域 - 高度适配 */
        .right-col {
            display: flex; flex-direction: column;
        }
        .upload-container {
            flex-grow: 1; /* 让容器填满剩余空间 */
            display: flex; flex-direction: column;
        }
        .upload-box {
            flex-grow: 1; /* 自动撑满高度，与左侧对齐 */
            min-height: 280px; /* 减小最小高度限制 */
            border: 2px dashed #dfe6e9;
            border-radius: var(--card-radius);
            background: #fafafa;
            position: relative;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            transition: all 0.3s ease; cursor: pointer; overflow: hidden;
        }
        .upload-box:hover { border-color: var(--primary); background: #FFF9F0; }

        .upload-icon-circle {
            width: 60px; height: 60px; background: white; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 10px; box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }
        .upload-icon { font-size: 1.8rem; color: #b2bec3; }
        .upload-text { font-weight: 700; color: var(--text-dark); margin-bottom: 2px; font-size: 1rem; }
        .upload-sub { font-size: 0.75rem; color: #b2bec3; text-align: center; }

        #imagePreview { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; display: none; }
        .remove-btn {
            position: absolute; top: 15px; right: 15px; width: 35px; height: 35px; border-radius: 50%;
            background: white; color: var(--secondary); border: none; cursor: pointer;
            display: none; align-items: center; justify-content: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); font-size: 1.2rem; z-index: 10;
        }

        /* 按钮区 */
        .btn-container {
            margin-top: 20px; /* 减小上方间距 */
            display: flex; justify-content: flex-end; gap: 15px;
            border-top: 1px solid #f1f2f6; padding-top: 20px;
        }
        .btn-cancel {
            padding: 10px 30px; border-radius: 30px; border: 1px solid #dfe6e9;
            background: white; color: var(--text-gray); font-weight: 600; cursor: pointer; transition: 0.3s;
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
            .menu-item span, .menu-group-title { display: none; }
            .form-content-grid { grid-template-columns: 1fr; }
            .upload-box { min-height: 250px; margin-top: 20px; }
        }
    </style>
</head>
<body>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>

<nav class="navbar">
    <a href="#" class="logo">
        <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="Logo" class="logo-img">
        <span>Seller Center</span>
    </a>
    <div class="nav-actions">
        <button class="nav-btn" onclick="location.href='${pageContext.request.contextPath}/index.jsp'">
            <i class="ri-store-2-line"></i> Back to Shop
        </button>
        <div style="width: 1px; height: 20px; background: #ddd;"></div>
        <div style="display: flex; align-items: center; gap: 10px;">
            <span style="font-weight: 600; font-size: 0.9rem;"><%= currentUser.getUsername() %></span>
            <div style="width: 35px; height: 35px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold;">
                <%= currentUser.getUsername().substring(0, 1).toUpperCase() %>
            </div>
        </div>
    </div>
</nav>

<div class="layout-container">

    <aside class="sidebar-card">
        <div class="menu-group-title">Main</div>
        <a href="${pageContext.request.contextPath}/merchant/merchant_dashboard.jsp" class="menu-item">
            <i class="ri-dashboard-3-line"></i> <span>Dashboard</span>
        </a>

        <div class="menu-group-title">Management</div>
        <a href="${pageContext.request.contextPath}/merchant/product/product_manager.jsp" class="menu-item active-view">
            <i class="ri-box-3-line"></i> <span>Product Manager</span>
        </a>

        <button class="menu-item" onclick="alert('Order module coming soon!')">
            <i class="ri-list-check-2"></i> <span>Orders</span>
        </button>
        <button class="menu-item" onclick="alert('Wallet module coming soon!')">
            <i class="ri-wallet-3-line"></i> <span>Finance</span>
        </button>

        <div style="margin-top: auto;">
            <div class="menu-group-title">System</div>
            <a href="${pageContext.request.contextPath}/logout" class="menu-item" style="color: #FF5E55;">
                <i class="ri-logout-box-r-line"></i> <span>Log Out</span>
            </a>
        </div>
    </aside>

    <main>
        <form action="${pageContext.request.contextPath}/product_add_action" method="post" enctype="multipart/form-data" class="form-card">

            <div class="page-header">
                <h2>Publish New Product</h2>
                <p>Fill in the details below to add a new item to your store.</p>
            </div>

            <div class="form-content-grid">

                <div class="left-col">
                    <div class="form-group">
                        <label class="form-label">Product Name <span>*</span></label>
                        <input type="text" name="productName" class="form-input" placeholder="e.g. Vintage Leather Jacket" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Category <span>*</span></label>
                        <select name="category" class="form-select">
                            <option value="electronics">Electronics</option>
                            <option value="fashion">Fashion</option>
                            <option value="home">Home & Living</option>
                            <option value="books">Books</option>
                        </select>
                    </div>

                    <div class="row-group">
                        <div class="form-group">
                            <label class="form-label">Price (RM) <span>*</span></label>
                            <input type="number" name="price" class="form-input" placeholder="0.00" step="0.01" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Stock <span>*</span></label>
                            <input type="number" name="stock" class="form-input" placeholder="1" required>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;"> <label class="form-label">Description</label>
                        <textarea name="description" class="form-textarea" rows="5" placeholder="Describe your item..."></textarea>
                    </div>
                </div>

                <div class="right-col">
                    <label class="form-label">Product Image <span>*</span></label>
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

    fileInput.addEventListener('change', function(e) {
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
        dropZone.style.borderColor = '#dfe6e9';
    }

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(e => {
        dropZone.addEventListener(e, (ev) => { ev.preventDefault(); ev.stopPropagation(); });
    });

    dropZone.addEventListener('dragenter', () => dropZone.style.borderColor = 'var(--primary)');
    dropZone.addEventListener('dragleave', () => dropZone.style.borderColor = '#dfe6e9');
    dropZone.addEventListener('drop', (e) => {
        dropZone.style.borderColor = '#dfe6e9';
        const files = e.dataTransfer.files;
        if (files && files[0]) {
            fileInput.files = files;
            showPreview(files[0]);
        }
    });
</script>

</body>
</html>