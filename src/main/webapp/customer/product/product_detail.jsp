<%@ page import="com.primego.user.model.User" %>
<%@ page import="com.primego.product.dao.ProductDAO" %>
<%@ page import="com.primego.product.model.ProductDTO" %>
<%@ page import="com.primego.product.dao.ProductImageDAO" %>
<%@ page import="com.primego.product.model.ProductImage" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // ==========================================
    // 1. 获取产品 ID 与 数据
    // ==========================================
    String productIdStr = request.getParameter("id");

    ProductDTO product = null;
    List<ProductImage> imageList = new ArrayList<>(); // 存储所有图片
    String statusDisplay = "";

    if (productIdStr != null && !productIdStr.trim().isEmpty()) {
        try {
            int pid = Integer.parseInt(productIdStr);
            ProductDAO productDAO = new ProductDAO();
            product = productDAO.getProductById(pid);

            // 获取该商品的所有图片
            ProductImageDAO imageDAO = new ProductImageDAO();
            imageList = imageDAO.getImagesByProductId(pid);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 如果找不到商品，跳回首页
    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // --- 处理状态显示 ---
    if (product.getProductStatus() != null) {
        if ("ON_SALE".equals(product.getProductStatus())) {
            statusDisplay = "On Sale";
        } else if ("OFF_SALE".equals(product.getProductStatus())) {
            statusDisplay = "Off Sale";
        } else {
            statusDisplay = product.getProductStatus().replace("_", " ");
        }
    }

    // 获取当前登录用户 (用于判断购物车/购买按钮状态)
    User currentUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getProductName() %> - PrimeGo</title>

    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        /* --- 1. Global Styles --- */
        :root {
            --bg-color: #F3F6F9;
            --primary: #FF9500;
            --primary-hover: #E68600;
            --dark-btn: #2d3436;
            --dark-btn-hover: #000000;
            --text-dark: #2d3436;
            --text-gray: #636e72;
            --success: #10B981;
            --card-radius: 20px;

            /* Glass tokens */
            --pg-glass-bg: rgba(255, 255, 255, 0.7);
            --pg-glass-border: rgba(255, 255, 255, 0.9);
            --pg-glass-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            --pg-glass-blur: 20px;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            background-color: var(--bg-color);
            color: var(--text-dark);
            padding-top: 100px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* --- 2. Layout & Animation --- */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .product-wrapper {
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 40px;
            animation: fadeInUp 0.6s ease forwards;
        }

        /* --- 3. Gallery (Carousel) Styles --- */
        .gallery-section {
            position: sticky;
            top: 120px;
        }

        .main-image-container {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            height: 500px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            margin-bottom: 20px;
            position: relative;
        }

        .carousel-img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
            transition: opacity 0.3s ease;
        }

        .carousel-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 45px; height: 45px;
            background: rgba(255,255,255,0.9);
            border: none;
            border-radius: 50%;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
            cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
            color: var(--text-dark);
            z-index: 10;
            transition: all 0.2s;
            opacity: 0;
        }
        .main-image-container:hover .carousel-btn { opacity: 1; }
        .carousel-btn:hover { background: var(--primary); color: white; }
        .prev-btn { left: 20px; }
        .next-btn { right: 20px; }

        .carousel-indicators {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 15px;
        }
        .indicator {
            width: 50px; height: 50px;
            border-radius: 10px;
            border: 2px solid transparent;
            overflow: hidden;
            cursor: pointer;
            opacity: 0.6;
            transition: 0.3s;
        }
        .indicator img { width: 100%; height: 100%; object-fit: cover; }
        .indicator.active { border-color: var(--primary); opacity: 1; transform: scale(1.1); }


        /* --- 4. Info Styles --- */
        .info-section {
            background: var(--pg-glass-bg);
            backdrop-filter: blur(var(--pg-glass-blur));
            border: 1px solid var(--pg-glass-border);
            border-radius: var(--card-radius);
            box-shadow: var(--pg-glass-shadow);
            padding: 40px;
        }

        .condition-tag {
            display: inline-block;
            padding: 6px 16px;
            background: #FFF4E5;
            color: var(--primary);
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .product-title {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 10px;
            line-height: 1.2;
        }

        .price-tag {
            font-size: 2.4rem;
            color: var(--primary);
            font-weight: 800;
            margin-bottom: 25px;
        }

        .description-box {
            margin: 30px 0;
            padding-top: 20px;
            border-top: 1px solid rgba(0,0,0,0.05);
        }

        .description-box h3 { margin-bottom: 10px; font-size: 1.1rem; }
        .description-box p { color: var(--text-gray); line-height: 1.7; }

        /* --- 5. Seller Card (Enhanced) --- */
        .seller-card {
            display: flex;
            align-items: center;
            gap: 15px;
            background: rgba(255,255,255,0.4);
            padding: 15px;
            border-radius: 15px;
            margin-bottom: 30px;
        }

        .seller-avatar {
            width: 50px; height: 50px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700;
            font-size: 1.2rem;
        }

        /* WhatsApp Button */
        .btn-whatsapp {
            margin-left: auto;
            background-color: #25D366;
            color: white;
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 0.95rem;
            font-weight: 600;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 12px rgba(37, 211, 102, 0.3);
            transition: all 0.3s ease;
        }
        .btn-whatsapp:hover {
            background-color: #128C7E;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(37, 211, 102, 0.4);
            color: white;
        }

        /* --- 6. Action Buttons --- */
        .action-group {
            display: flex;
            gap: 15px;
        }

        .btn-action {
            flex: 1;
            padding: 18px;
            border-radius: 16px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            border: none;
        }

        .btn-cart {
            background: var(--dark-btn);
            color: white;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        .btn-cart:hover {
            background: var(--dark-btn-hover);
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(0, 0, 0, 0.15);
        }

        .btn-buy {
            background: var(--primary);
            color: white;
            box-shadow: 0 10px 20px rgba(255, 149, 0, 0.2);
        }
        .btn-buy:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 15px 25px rgba(255, 149, 0, 0.3);
        }

        @media (max-width: 768px) {
            .product-wrapper { grid-template-columns: 1fr; }
            .gallery-section { position: static; }
        }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>
<%@ include file="../../common/login_check_modal.jsp" %>

<div class="container">
    <div class="product-wrapper">

        <div class="gallery-section">
            <div class="main-image-container">
                <button type="button" class="carousel-btn prev-btn" onclick="prevImage()">
                    <i class="ri-arrow-left-s-line"></i>
                </button>

                <img id="mainImage" src="" alt="Product Image" class="carousel-img">

                <button type="button" class="carousel-btn next-btn" onclick="nextImage()">
                    <i class="ri-arrow-right-s-line"></i>
                </button>
            </div>

            <div class="carousel-indicators" id="indicators"></div>
        </div>

        <div class="info-section">
            <span class="condition-tag">
                <i class="ri-shield-check-line"></i> <%= statusDisplay %>
            </span>

            <h1 class="product-title"><%= product.getProductName() %></h1>

            <div class="price-tag">
                RM <%= String.format("%.2f", product.getProductPrice()) %>
            </div>

            <div class="seller-card">
                <div class="seller-avatar">
                    <%= (product.getMerchantName() != null && product.getMerchantName().length() > 0) ? product.getMerchantName().substring(0,1).toUpperCase() : "S" %>
                </div>
                <div>
                    <div style="font-weight: 600; font-size: 1.05rem;"><%= product.getMerchantName() %></div>
                    <div style="font-size: 0.8rem; color: var(--text-gray);">Official Merchant</div>

                    <%-- ⭐ 号码展示区域 --%>
                    <% if (product.getContactWhatsapp() != null && !product.getContactWhatsapp().trim().isEmpty()) { %>
                    <div style="display: flex; align-items: center; gap: 4px; margin-top: 4px; color: #25D366; font-weight: 500; font-size: 0.9rem;">
                        <i class="ri-whatsapp-fill"></i>
                        <span><%= product.getContactWhatsapp() %></span>
                    </div>
                    <% } %>
                </div>

                <%-- ⭐ Chat 按钮 (点击跳转) --%>
                <% if (product.getContactWhatsapp() != null && !product.getContactWhatsapp().trim().isEmpty()) { %>
                <a href="https://wa.me/<%= product.getContactWhatsapp().replaceAll("[^0-9]", "") %>"
                   target="_blank" class="btn-whatsapp">
                    Chat
                    <i class="ri-arrow-right-up-line"></i>
                </a>
                <% } %>
            </div>

            <div class="description-box">
                <h3>Description</h3>
                <p><%= (product.getProductDescription() != null) ? product.getProductDescription() : "No description provided." %></p>
            </div>

            <div class="action-group">
                <% if (currentUser != null) { %>
                <%--
                    ⭐ 修改点: 添加购物车改为 Button + AJAX
                    使用 javascript:void(0) 防止页面跳转，onclick 调用 JS 函数
                --%>
                <button onclick="addToCart(<%= product.getProductId() %>)" class="btn-action btn-cart">
                    <i class="ri-shopping-cart-2-line"></i> Add to Cart
                </button>

                <a href="${pageContext.request.contextPath}/customer/order/order_confirmation.jsp?productId=<%= product.getProductId() %>" class="btn-action btn-buy">
                    Buy Now
                </a>
                <% } else { %>
                <button onclick="showLoginModal()" class="btn-action btn-cart">
                    <i class="ri-shopping-cart-2-line"></i> Add to Cart
                </button>

                <button onclick="showLoginModal()" class="btn-action btn-buy">
                    Buy Now
                </button>
                <% } %>
            </div>

            <div style="margin-top: 30px; font-size: 0.85rem; color: var(--text-gray); display: flex; align-items: center; gap: 8px;">
                <i class="ri-shield-flash-line" style="color: var(--success); font-size: 1.2rem;"></i>
                PrimeGo Verified Listing
            </div>
        </div>
    </div>
</div>

<jsp:include page="/assets/jsp/global_modal.jsp" />

<script>
    // ==========================================
    // AJAX 添加购物车逻辑 (新增)
    // ==========================================
    function addToCart(productId) {
        // 构建请求 URL
        const url = '${pageContext.request.contextPath}/cart_action?action=add&productId=' + productId;

        // 发送 AJAX 请求
        fetch(url)
            .then(response => {
                // 如果后端 Servlet 是执行 response.sendRedirect，Fetch 会自动跟随并返回 200 OK
                // 我们不需要解析返回的 HTML，只要状态码是 200 就代表添加成功
                if (response.ok) {
                    showModal("Success!", "Product successfully added to your cart.", "success");
                } else {
                    showModal("Oops", "Something went wrong. Please try again.", "error");
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showModal("Error", "Network error. Please check your connection.", "error");
            });
    }

    // ==========================================
    // 图片轮播逻辑
    // ==========================================
    const productImages = [
        <% for (int i = 0; i < imageList.size(); i++) {
               ProductImage img = imageList.get(i);
        %>
        "<%= request.getContextPath() + "/" + img.getImageUrl() %>"<%= (i < imageList.size() - 1) ? "," : "" %>
        <% } %>
    ];

    if (productImages.length === 0) {
        productImages.push("https://via.placeholder.com/600x600?text=No+Image");
    }

    let currentIndex = 0;
    const mainImage = document.getElementById('mainImage');
    const indicatorsContainer = document.getElementById('indicators');

    function renderGallery() {
        mainImage.style.opacity = 0;
        setTimeout(() => {
            mainImage.src = productImages[currentIndex];
            mainImage.style.opacity = 1;
        }, 150);

        indicatorsContainer.innerHTML = '';
        productImages.forEach((src, idx) => {
            const div = document.createElement('div');
            div.className = `indicator \${idx === currentIndex ? 'active' : ''}`;
            div.innerHTML = `<img src="\${src}" alt="Thumb">`;
            div.onclick = () => { currentIndex = idx; renderGallery(); };
            indicatorsContainer.appendChild(div);
        });
    }

    function prevImage() { currentIndex = (currentIndex === 0) ? productImages.length - 1 : currentIndex - 1; renderGallery(); }
    function nextImage() { currentIndex = (currentIndex === productImages.length - 1) ? 0 : currentIndex + 1; renderGallery(); }

    renderGallery();
</script>

</body>
</html>