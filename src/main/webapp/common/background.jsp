<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  文件名: components/background.jsp
  描述: 包含 3D 悬浮球背景的 CSS 和 HTML 结构
--%>

<style>
    /* ================= 背景专用样式 ================= */

    /* 1. 设置 Body 的基础渐变背景 */
    /* 注意：这里设置 body 背景不会冲突，但要注意不要在其他地方覆盖它 */
    body {
        background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
        min-height: 100vh;
        overflow-x: hidden; /* 防止球体溢出导致滚动条 */
        position: relative;
    }

    /* 2. 纯 CSS 背景 (实心 3D 球体) */
    .background-blob {
        position: fixed; /* 固定定位，滚动页面时背景不动 */
        border-radius: 50%;
        z-index: -1;     /* 确保在最底层 */
        opacity: 1;
        filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        pointer-events: none; /* 确保背景不阻挡鼠标点击 */
    }

    .blob-red {
        width: 750px;
        height: 650px;
        top: -200px;
        left: -200px;
        transform: rotate(-10deg);
        background: linear-gradient(145deg, #ff5e55, #d92e25);
        box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
    }

    .blob-yellow {
        width: 900px;
        height: 700px;
        top: -250px;
        right: -100px;
        transform: rotate(30deg);
        background: linear-gradient(145deg, #ffdb4d, #e6b800);
        box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
    }

    .blob-orange {
        width: 1800px;
        height: 950px;
        bottom: -650px;
        left: -600px;
        transform: rotate(-10deg);
        background: linear-gradient(145deg, #ffad33, #e68a00);
        box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
    }
</style>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>