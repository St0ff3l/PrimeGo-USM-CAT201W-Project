<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.product.dao.CategoryDAO" %>
<%@ page import="com.primego.product.model.Category" %>
<%@ page import="com.primego.product.dao.ProductImageDAO" %>
<%@ page import="com.primego.product.model.ProductImage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // ==========================================
    // Java 后端逻辑 (保持不变)
    // ==========================================
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"MERCHANT".equals(currentUser.getRole().toString())) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }

    String productIdStr = request.getParameter("id");
    ProductDTO product = null;
    List<Category> categoryList = null;
    List<ProductImage> imageList = new ArrayList<>();

    if (productIdStr != null && !productIdStr.trim().isEmpty()) {
        try {
            int pid = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            product = productDAO.getProductById(pid);

            if (product != null && product.getMerchantId() != currentUser.getId()) {
                response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=unauthorized");
                return;
            }

            CategoryDAO categoryDAO = new CategoryDAO();
            categoryList = categoryDAO.findAll();

            ProductImageDAO imageDAO = new ProductImageDAO();
            imageList = imageDAO.getImagesByProductId(pid);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/merchant/product/product_management.jsp?error=notfound");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Product - PrimeGo</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.bootcdn.net/ajax/libs/remixicon/3.5.0/remixicon.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/images_uploader.css" rel="stylesheet">

    <style>
        /* --- 变量定义 --- */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --input-bg: #ffffff;
            --card-radius: 16px;
            --pg-glass-bg: rgba(255, 255, 255, 0.85);
            --pg-glass-border: rgba(255, 255, 255, 0.9);
            --pg-glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --iu-primary: var(--primary);
            --iu-bg: #f8f9fa;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            padding-top: 100px;
            padding-bottom: 50px;
        }

        .container { max-width: 1600px; margin: 0 auto; padding: 0 30px; }

        /* --- 核心布局：Grid --- */
        /* 这里的结构是：[Gallery 400px] [Main Content 1fr] */
        .layout-container {
            display: grid;
            grid-template-columns: 400px 1fr;
            gap: 30px;
            align-items: start;
        }

        /* === 1. 左侧：图片轮播 (Gallery) === */
        .gallery-card {
            background: var(--pg-glass-bg);
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            padding: 20px;
            position: sticky; top: 110px;
        }

        .main-image-container {
            height: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 15px;
            position: relative;
            background: white;
            border-radius: 12px;
            border: 1px solid #eee;
        }
        .carousel-img { max-width: 100%; max-height: 100%; object-fit: contain; transition: opacity 0.3s ease; }

        .carousel-btn {
            position: absolute; top: 50%; transform: translateY(-50%);
            width: 40px; height: 40px; background: rgba(255,255,255,0.9);
            border: none; border-radius: 50%; box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem; color: var(--text-dark); z-index: 10; transition: all 0.2s;
        }
        .carousel-btn:hover { background: var(--primary); color: white; }
        .prev-btn { left: 10px; } .next-btn { right: 10px; }

        .carousel-indicators {
            display: flex; justify-content: center; gap: 8px; margin-top: 10px;
        }
        .indicator { width: 8px; height: 8px; border-radius: 50%; background: #ccc; transition: 0.3s; cursor: pointer; }
        .indicator.active { background: var(--primary); transform: scale(1.3); }


        /* === 2. 右侧主体区 (Main Content) === */
        .main-content-area {
            /* 内部再分两栏：左(Info+Desc) 右(Upload) */
            display: grid;
            grid-template-columns: 1.2fr 0.8fr; /* 左侧宽一些，右侧上传窄一些 */
            gap: 25px;
        }

        /* 通用卡片样式 */
        .glass-card {
            background: var(--pg-glass-bg);
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            padding: 25px;
            backdrop-filter: blur(20px);
        }

        /* --- 2.1 右侧主体 - 左半部分 (Info + Desc) --- */
        .form-left-col {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* 上半：基本信息 Grid */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        .col-span-2 { grid-column: span 2; }

        .form-label { display: block; margin-bottom: 6px; font-weight: 600; color: var(--text-dark); font-size: 0.85rem; }
        .form-control { width: 100%; padding: 10px 15px; border: 1px solid #dfe6e9; border-radius: 10px; background: var(--input-bg); font-size: 0.95rem; outline: none; transition: 0.3s; }
        .form-control:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(255, 149, 0, 0.1); }

        /* 下半：描述框 (自动填充剩余高度) */
        .desc-card {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        textarea.form-control {
            resize: vertical;
            flex-grow: 1;
            min-height: 200px;
            line-height: 1.6;
        }

        /* --- 2.2 右侧主体 - 右半部分 (Upload) --- */
        .form-right-col {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .upload-card {
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        /* 强制覆盖上传组件样式 */
        #photo-upload-container { flex-grow: 1; display: flex; flex-direction: column; }
        .iu-upload-area { flex-grow: 1; min-height: 400px !important; }

        /* 底部按钮 (跨两列) */
        .action-bar {
            grid-column: span 2;
            display: flex; justify-content: flex-end; gap: 15px;
            margin-top: 10px; padding-top: 20px; border-top: 1px solid rgba(0,0,0,0.05);
        }
        .btn-action { padding: 12px 35px; border-radius: 50px; font-weight: 600; cursor: pointer; border: none; transition: 0.3s; font-size: 1rem; text-decoration: none; display: flex; align-items: center; }
        .btn-cancel { background: #f1f2f6; color: var(--text-gray); }
        .btn-cancel:hover { background: #dfe6e9; color: var(--text-dark); }
        .btn-save { background: var(--primary); color: white; box-shadow: 0 5px 15px rgba(255, 149, 0, 0.3); }
        .btn-save:hover { background: var(--primary-hover); transform: translateY(-2px); }

        /* header title */
        .page-header { grid-column: span 2; display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .page-header h2 { font-size: 1.6rem; font-weight: 700; }
        .badge { padding: 5px 12px; border-radius: 12px; background: #E3F2FD; color: #1976D2; font-size: 0.85rem; font-weight: 600; }

        @media (max-width: 1200px) {
            .layout-container { grid-template-columns: 1fr; } /* 极窄屏幕变单栏 */
            .main-content-area { grid-template-columns: 1fr; } /* 表单区变垂直 */
            .gallery-card { position: static; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>

<div class="container">
    <form action="${pageContext.request.contextPath}/product_action" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="productId" value="<%= product.getProductId() %>">

        <div class="layout-container">

            <div class="gallery-card">
                <div style="margin-bottom: 10px; font-weight: 600; color: var(--text-gray);">Preview</div>
                <div class="main-image-container">
                    <button type="button" class="carousel-btn prev-btn" onclick="prevImage()"><i class="ri-arrow-left-s-line"></i></button>
                    <img id="mainImage" src="" alt="Product Image" class="carousel-img">
                    <button type="button" class="carousel-btn next-btn" onclick="nextImage()"><i class="ri-arrow-right-s-line"></i></button>
                </div>
                <div class="carousel-indicators" id="indicators"></div>
                <p style="text-align: center; color: #b2bec3; font-size: 0.8rem; margin-top: 15px;">
                    This is the customer view.
                </p>
            </div>

            <div class="main-content-area">

                <div class="page-header">
                    <h2>Edit Product</h2>
                    <span class="badge">ID: <%= product.getProductId() %></span>
                </div>

                <div class="form-left-col">

                    <div class="glass-card">
                        <div class="info-grid">
                            <div class="form-group col-span-2">
                                <label class="form-label">Product Name</label>
                                <input type="text" name="productName" class="form-control" value="<%= product.getProductName() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Category</label>
                                <select name="categoryId" class="form-control">
                                    <% if (categoryList != null) for (Category c : categoryList) { %>
                                    <option value="<%= c.getCategoryId() %>" <%= c.getCategoryId() == product.getCategoryId() ? "selected" : "" %>><%= c.getCategoryName() %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Status</label>
                                <select name="productStatus" class="form-control">
                                    <option value="ON_SALE" <%= "ON_SALE".equals(product.getProductStatus()) ? "selected" : "" %>>On Sale</option>
                                    <option value="OFF_SALE" <%= "OFF_SALE".equals(product.getProductStatus()) ? "selected" : "" %>>Off Sale</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Price (RM)</label>
                                <input type="number" name="productPrice" class="form-control" step="0.01" min="0" value="<%= product.getProductPrice() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Stock</label>
                                <input type="number" name="productStock" class="form-control" step="1" min="0" value="<%= product.getProductStockQuantity() %>" required>
                            </div>
                        </div>
                    </div>

                    <div class="glass-card desc-card">
                        <label class="form-label">Description</label>
                        <textarea name="productDescription" class="form-control" placeholder="Product details..."><%= product.getProductDescription() != null ? product.getProductDescription() : "" %></textarea>
                    </div>
                </div>

                <div class="form-right-col">
                    <div class="glass-card upload-card">
                        <label class="form-label" style="margin-bottom: 12px;">Manage Images</label>
                        <p style="font-size: 0.8rem; color: var(--text-gray); margin-bottom: 15px;">
                            Drag images to reorder. First one is Primary.
                        </p>
                        <div id="photo-upload-container"></div>
                    </div>
                </div>

                <div class="action-bar">
                    <a href="${pageContext.request.contextPath}/merchant/product/product_management.jsp" class="btn-action btn-cancel">Cancel</a>
                    <button type="submit" class="btn-action btn-save"><i class="ri-save-line" style="margin-right: 6px;"></i> Save Changes</button>
                </div>

            </div> </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/assets/js/images_uploader.js"></script>
<script>
    // 准备数据
    const serverImages = [
        <% for (int i = 0; i < imageList.size(); i++) { ProductImage img = imageList.get(i); %>
        {
            id: <%= img.getImageId() %>,
            url: '<%= request.getContextPath() + "/" + img.getImageUrl() %>',
            isPrimary: <%= img.isImageIsPrimary() %>
        }<%= (i < imageList.size() - 1) ? "," : "" %>
        <% } %>
    ];

    document.addEventListener("DOMContentLoaded", function() {
        // 初始化上传组件
        const uploader = new ImagesUploader('#photo-upload-container', {
            inputName: 'newImages',
            deleteInputName: 'deleteImageIds',
            sortInputName: 'imageSortOrder'
        });

        // 回显图片
        uploader.setInitialImages(serverImages);

        // 初始化左侧轮播
        renderCarousel();
    });

    // 轮播图逻辑
    let currentIndex = 0;
    const mainImage = document.getElementById('mainImage');
    const indicatorsContainer = document.getElementById('indicators');

    if (serverImages.length === 0) serverImages.push({ url: 'https://via.placeholder.com/600x450?text=No+Image' });

    function renderCarousel() {
        mainImage.style.opacity = 0;
        setTimeout(() => {
            mainImage.src = serverImages[currentIndex].url;
            mainImage.style.opacity = 1;
        }, 150);

        indicatorsContainer.innerHTML = '';
        serverImages.forEach((_, idx) => {
            const dot = document.createElement('div');
            // 注意反斜杠转义
            dot.className = `indicator \${idx === currentIndex ? 'active' : ''}`;
            dot.onclick = () => { currentIndex = idx; renderCarousel(); };
            indicatorsContainer.appendChild(dot);
        });
    }

    function prevImage() { currentIndex = (currentIndex === 0) ? serverImages.length - 1 : currentIndex - 1; renderCarousel(); }
    function nextImage() { currentIndex = (currentIndex === serverImages.length - 1) ? 0 : currentIndex + 1; renderCarousel(); }
</script>

</body>
</html>

