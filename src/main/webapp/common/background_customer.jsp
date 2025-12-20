<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  文件名: common/background_customer.jsp
  描述: 买家/客户专用背景组件 (橙色主题)
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

  /* Yellow Blob -> 改为白色 (隐藏/辅助) */
  .blob-yellow {
    width: 900px; height: 700px; top: -250px; right: -100px;
    transform: rotate(30deg);
    background: #ffffff;
    box-shadow: none;
  }

  /* Orange Blob -> 主视觉 (橙色渐变) */
  .blob-orange {
    width: 1800px; height: 950px; bottom: -650px; left: -600px;
    transform: rotate(-10deg);
    background: linear-gradient(145deg, #ffad33, #e68a00);
    box-shadow: inset 15px 15px 50px rgba(255, 255, 255, 0.5), inset -40px -40px 80px rgba(160, 82, 45, 0.3);
  }
</style>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>