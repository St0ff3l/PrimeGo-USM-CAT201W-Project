<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  File: common/background.jsp
  Purpose: Shared background decoration using pure CSS “3D blob” elements.

  Notes:
  - This file styles the global <body> background.
  - The blob elements are fixed-position and placed behind page content.
--%>

<style>
    /* ================= Background-only styles ================= */

    /* 1) Base page background applied to <body>
       Keep in mind: other stylesheets can override body background if they set it later. */
    body {
        background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
        min-height: 100vh;
        overflow-x: hidden; /* Prevent horizontal scrollbars caused by off-screen blobs */
        position: relative;
    }

    /* 2) Pure CSS background blobs (solid 3D spheres) */
    .background-blob {
        position: fixed; /* Stays in place while scrolling */
        border-radius: 50%;
        z-index: -1;     /* Keep behind all page content */
        opacity: 1;
        filter: drop-shadow(30px 40px 50px rgba(0, 0, 0, 0.2));
        pointer-events: none; /* Do not block clicks on the page */
    }

    /* Red blob: top-left */
    .blob-red {
        width: 750px;
        height: 650px;
        top: -200px;
        left: -200px;
        transform: rotate(-10deg);
        background: linear-gradient(145deg, #ff5e55, #d92e25);
        box-shadow: inset 10px 10px 30px rgba(255, 255, 255, 0.5), inset -20px -20px 60px rgba(139, 0, 0, 0.4);
    }

    /* Yellow blob: top-right */
    .blob-yellow {
        width: 900px;
        height: 700px;
        top: -250px;
        right: -100px;
        transform: rotate(30deg);
        background: linear-gradient(145deg, #ffdb4d, #e6b800);
        box-shadow: inset 10px 10px 40px rgba(255, 255, 255, 0.7), inset -30px -30px 60px rgba(184, 134, 11, 0.3);
    }

    /* Orange blob: bottom-left */
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

<!-- Background blobs (decorative only) -->
<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>
<div class="background-blob blob-orange"></div>