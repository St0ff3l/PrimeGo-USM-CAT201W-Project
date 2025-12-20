<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  文件名: common/background_admin.jsp
  描述: 管理员专用背景组件 (红色主题)
--%>

<style>
    /* ================= 背景专用样式 ================= */

    /* 1. Body 基础设置 */
    body {
        background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
        min-height: 100vh;
        position: relative;
        overflow-x: hidden;
        /* 这里不写 color: #333，留给主页面定义，或者放通用css里 */
    }

    /* 2. 背景球体样式 */
    .background-blob {
        position: fixed;
        border-radius: 50%;
        z-index: -1;
        opacity: 1;
        filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        pointer-events: none; /* 防止背景挡住点击 */
    }

    /* Admin 专属红色主球 */
    .blob-red {
        width: 750px;
        height: 650px;
        top: -200px;
        left: -200px;
        transform: rotate(-10deg);
        background: linear-gradient(145deg, #ff5e55, #d92e25);
        box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
    }

    /* 辅助白色球体 (Admin设计) */
    .blob-yellow {
        width: 900px;
        height: 700px;
        top: -250px;
        right: -100px;
        transform: rotate(30deg);
        background: #ffffff;
        box-shadow: none;
    }

    .blob-orange {
        width: 1800px;
        height: 950px;
        bottom: -650px;
        left: -600px;
        transform: rotate(-10deg);
        background: #ffffff;
        box-shadow: none;
    }
</style>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>