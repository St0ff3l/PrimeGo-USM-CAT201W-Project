<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  File: common/background_merchant.jsp
  Purpose: Merchant-facing background decoration (yellow / gold theme).

  Notes:
  - Styles in this file target the global <body> background.
  - The blobs are fixed-position decorative elements and sit behind page content.
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

    /* Yellow blob: primary visual element (gold/yellow gradient) */
    .blob-yellow {
        width: 900px; height: 700px; top: -250px; right: -100px;
        transform: rotate(30deg);
        background: linear-gradient(145deg, #ffdb4d, #e6b800);
        box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
    }

    /* Orange blob: rendered as white (hidden/auxiliary) */
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