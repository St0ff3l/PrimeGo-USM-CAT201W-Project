<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        /* Inherit basic styles */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
            color: #333;
        }

        /* Admin Dashboard uses RED theme (Same as Admin Profile) */
        .background-blob {
            position: fixed;
            border-radius: 50%;
            z-index: -1;
            opacity: 1;
            filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        }

        .blob-red {
            width: 750px; height: 650px; top: -200px; left: -200px;
            transform: rotate(-10deg);
            background: linear-gradient(145deg, #ff5e55, #d92e25);
            box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
        }

        .blob-yellow {
            width: 900px; height: 700px; top: -250px; right: -100px;
            transform: rotate(30deg);
            background: #ffffff;
            box-shadow: none;
        }

        .blob-orange {
            width: 1800px; height: 950px; bottom: -650px; left: -600px;
            transform: rotate(-10deg);
            background: #ffffff;
            box-shadow: none;
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 40px;
            max-width: 1000px;
            margin: 50px auto;
        }

        h1 { margin-bottom: 30px; color: #d63031; text-align: center; }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
        }

        .dashboard-card {
            background: rgba(255,255,255,0.6);
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            transition: 0.3s;
            cursor: pointer;
        }
        .dashboard-card:hover {
            background: rgba(255,255,255,0.9);
            transform: translateY(-5px);
        }
        .dashboard-card h3 { margin-bottom: 10px; color: #333; }
        .dashboard-card p { color: #666; }

        .btn-back {
            display: block; width: 200px; margin: 30px auto 0; padding: 10px 20px; 
            background: #333; color: white; text-align: center;
            text-decoration: none; border-radius: 20px;
        }
    </style>
</head>
<body>
    <div class="background-blob blob-red"></div>
    <div class="background-blob blob-yellow"></div>
    <div class="background-blob blob-orange"></div>

    <div class="glass-panel">
        <h1>Admin Dashboard</h1>
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>User Management</h3>
                <p>View and manage registered users.</p>
            </div>
            <div class="dashboard-card">
                <h3>Product Management</h3>
                <p>Approve or remove listings.</p>
            </div>
            <div class="dashboard-card">
                <h3>System Reports</h3>
                <p>View traffic and sales analytics.</p>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">Back to Home</a>
    </div>
</body>
</html>
