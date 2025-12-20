<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  文件名: common/background_merchant.jsp
  描述: 商家专用背景组件 (黄色/金色主题)
--%>

<style>
    /* ================= 背景专用样式 ================= */

    /* 1. Body 基础设置 */
    body {
        background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
        min-height: 100vh;
        position: relative;
        overflow-x: hidden;
    }

    /* 2. 背景球体通用样式 */
    .background-blob {
        position: fixed;
        border-radius: 50%;
        z-index: -1;
        opacity: 1;
        filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        pointer-events: none; /* 防止背景挡住点击 */
    }

    /* Red Blob -> 改为白色 (隐藏/辅助) */
    .blob-red {
        width: 750px; height: 650px; top: -200px; left: -200px;
        transform: rotate(-10deg);
        background: #ffffff;
        box-shadow: none;
    }

    /* Yellow Blob -> 主视觉 (金色/黄色渐变) */
    .blob-yellow {
        width: 900px; height: 700px; top: -250px; right: -100px;
        transform: rotate(30deg);
        background: linear-gradient(145deg, #ffdb4d, #e6b800);
        box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
    }

    /* Orange Blob -> 改为白色 (隐藏/辅助) */
    .blob-orange {
        width: 1800px; height: 950px; bottom: -650px; left: -600px;
        transform: rotate(-10deg);
        background: #ffffff;
        box-shadow: none;
    }
</style>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>