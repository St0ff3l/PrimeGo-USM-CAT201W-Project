<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  File: common/background_customer.jsp
  Purpose: Customer-facing background decoration (orange theme).

  Notes:
  - Styles in this file target the global <body> background.
  - The blobs are fixed-position decorative elements and sit behind page content.
  - Red/Yellow blobs are rendered as white to de-emphasize them in this theme.
--%>

<style>
  /* ================= Background-only styles ================= */

  /* 1) Base <body> setup */
  body {
    background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
    min-height: 100vh;
    position: relative;
    overflow-x: hidden;
  }

  /* 2) Background blob base styles */
  .background-blob {
    position: fixed;
    border-radius: 50%;
    z-index: -1;
    opacity: 1;
    filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
    pointer-events: none; /* Keep purely decorative; do not block clicks */
  }

  /* Red blob: rendered as white (hidden/auxiliary) */
  .blob-red {
    width: 750px; height: 650px; top: -200px; left: -200px;
    transform: rotate(-10deg);
    background: #ffffff;
    box-shadow: none;
  }

  /* Yellow blob: rendered as white (hidden/auxiliary) */
  .blob-yellow {
    width: 900px; height: 700px; top: -250px; right: -100px;
    transform: rotate(30deg);
    background: #ffffff;
    box-shadow: none;
  }

  /* Orange blob: primary visual element (orange gradient) */
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