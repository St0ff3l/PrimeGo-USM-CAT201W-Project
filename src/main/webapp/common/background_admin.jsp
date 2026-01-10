<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  File: common/background_admin.jsp
  Purpose: Admin-only background decoration (red theme).

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
        /* Intentionally no text color here; let the page-level stylesheet decide */
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

    /* Admin primary red blob */
    .blob-red {
        width: 750px;
        height: 650px;
        top: -200px;
        left: -200px;
        transform: rotate(-10deg);
        background: linear-gradient(145deg, #ff5e55, #d92e25);
        box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
    }

    /* Secondary white blobs (admin design) */
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

<!-- Background blobs (decorative only) -->
<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>