<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Search Results - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { color: #333; position: relative; }

        header { position: fixed; top: 15px; left: 50%; transform: translateX(-50%); z-index: 1000; width: 92%; max-width: 1300px; border-radius: 50px; padding: 12px 40px; background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(25px); border: 1px solid rgba(255, 255, 255, 0.9); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); display: flex; justify-content: space-between; align-items: center; }
        .brand-text { font-size: 1.5rem; font-weight: 700; color: #d63031; }

        /* 搜索栏区域 */
        .search-bar-container { margin: 100px auto 30px; text-align: center; max-width: 800px; padding: 0 20px; }
        .search-input { width: 70%; padding: 15px 25px; border-radius: 30px; border: none; background: rgba(255,255,255,0.8); backdrop-filter: blur(10px); box-shadow: 0 5px 15px rgba(0,0,0,0.05); outline: none; font-size: 1rem; }
        .btn-search { padding: 15px 30px; border-radius: 30px; border: none; background: #333; color: white; cursor: pointer; margin-left: 10px; font-weight: 600; }

        .main-layout { max-width: 1200px; margin: 0 auto 50px; padding: 0 20px; display: grid; grid-template-columns: 250px 1fr; gap: 30px; align-items: start; }

        /* 侧边栏 */
        .sidebar { background: rgba(255, 255, 255, 0.6); backdrop-filter: blur(20px); padding: 25px; border-radius: 20px; border: 1px solid rgba(255,255,255,0.6); }
        .filter-title { font-weight: 700; margin-bottom: 15px; display: block; }
        .filter-option { display: block; margin-bottom: 10px; cursor: pointer; color: #555; }
        .filter-option:hover { color: #FF3B30; }

        /* 商品网格 */
        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 25px; }

        /* 商品卡片 (复用 index.jsp 样式) */
        .product-card { background: rgba(255, 255, 255, 0.7); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.6); border-radius: 20px; overflow: hidden; transition: transform 0.3s; display: flex; flex-direction: column; text-decoration: none; color: inherit; }
        .product-card:hover { transform: translateY(-10px); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
        .card-img { height: 180px; background: rgba(255,255,255,0.5); display: flex; align-items: center; justify-content: center; font-size: 3rem; }
        .card-info { padding: 20px; }
        .price { color: #FF3B30; font-weight: 700; font-size: 1.1rem; }
    </style>
</head>
<body>

<%@ include file="../../common/background.jsp" %>

<header>
    <a href="${pageContext.request.contextPath}/index.jsp" style="text-decoration:none; display: flex; align-items: center; gap: 10px;">

        <img src="${pageContext.request.contextPath}/assets/images/logo.png"
             alt="Logo"
             style="height: 40px; width: auto;">

        <span class="brand-text">PrimeGo</span>
    </a>
    <div style="font-weight:600;">Search</div>
</header>

<div class="search-bar-container">
    <input type="text" class="search-input" placeholder="Search for treasures...">
    <button class="btn-search">Search</button>
</div>

<div class="main-layout">
    <aside class="sidebar">
        <span class="filter-title">Categories</span>
        <label class="filter-option"><input type="checkbox"> Digital</label>
        <label class="filter-option"><input type="checkbox"> Fashion</label>
        <label class="filter-option"><input type="checkbox"> Books</label>

        <hr style="border:0; border-top:1px solid rgba(0,0,0,0.1); margin: 20px 0;">

        <span class="filter-title">Price Range</span>
        <div style="display:flex; gap:5px;">
            <input type="number" placeholder="Min" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
            <input type="number" placeholder="Max" style="width:100%; padding:8px; border-radius:10px; border:1px solid #ccc;">
        </div>
    </aside>

    <main>
        <h3 style="margin-bottom:20px; color:#555;">Results for "Laptop"</h3>
        <div class="product-grid">
            <a href="product_detail.jsp?id=1" class="product-card">
                <div class="card-img">💻</div>
                <div class="card-info">
                    <h4>Business Laptop</h4>
                    <p class="price">RM 3,250.00</p>
                    <small style="color:#666;">Penang • Used</small>
                </div>
            </a>

            <a href="product_detail.jsp?id=2" class="product-card">
                <div class="card-img">📱</div>
                <div class="card-info">
                    <h4>iPhone 13</h4>
                    <p class="price">RM 2,100.00</p>
                    <small style="color:#666;">KL • Like New</small>
                </div>
            </a>
        </div>
    </main>
</div>

</body>
</html>