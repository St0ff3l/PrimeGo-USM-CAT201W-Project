<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Top Up Wallet - Manual QR</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link rel="icon" href="${pageContext.request.contextPath}/logo.png" type="image/png">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/images_uploader.css">

    <style>
        /* ===== Global Styles ===== */
        * { margin:0; padding:0; box-sizing:border-box; font-family:'Poppins',sans-serif; }
        body {
            background: linear-gradient(to bottom, #f0f2f5, #e0e5ec);
            min-height:100vh;
            color:#333;
            overflow-x:hidden;
        }

        /* Glass Panel */
        .glass-panel {
            background: rgba(255,255,255,0.75);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.6);
            border-radius: 24px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.08);
            max-width: 900px;
            margin: 60px auto;
            padding: 40px;
            position: relative;
            z-index: 10;
        }

        /* Top Bar Navigation */
        .top-bar { display:flex; align-items:center; margin-bottom:30px; }
        .back-btn {
            display:inline-flex; align-items:center; justify-content:center;
            width:40px; height:40px; border-radius:50%;
            background:rgba(255,255,255,0.8); text-decoration:none;
            color:#555; font-size:1.2rem; font-weight:600; transition:.2s;
        }
        .back-btn:hover { background:#fff; transform:scale(1.1); box-shadow:0 4px 10px rgba(0,0,0,0.1); }
        .page-title { margin-left:20px; font-size:1.5rem; font-weight:700; color:#2d3436; }

        /* Layout Grid */
        .topup-grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 40px; }

        /* Left Side: QR Code Section */
        .qr-section {
            background: #fff;
            border-radius: 20px; padding: 30px; text-align: center;
            box-shadow: 0 8px 20px rgba(0,0,0,0.05);
            display: flex; flex-direction: column; align-items: center; justify-content: center;
        }
        .qr-title { font-size: 1.1rem; font-weight: 700; color: #2d3436; margin-bottom: 5px; }
        .qr-desc { font-size: 0.85rem; color: #888; margin-bottom: 20px; }

        /* QR Image Container */
        .qr-img-placeholder {
            width: 200px;
            height: 200px;
            margin-bottom: 15px;
            display: flex; align-items: center; justify-content: center;
        }
        .qr-img-real { width: 100%; height: 100%; object-fit: contain; border-radius: 8px; }

        .bank-info { background: #f8f9fa; width: 100%; padding: 10px; border-radius: 10px; font-size: 0.85rem; color: #555; text-align: left; }
        .bank-row { display: flex; justify-content: space-between; margin-bottom: 5px; }

        /* Right Side: Upload Form */
        .form-section { display: flex; flex-direction: column; justify-content: center; }
        label { display: block; font-weight: 600; font-size: 0.9rem; margin-bottom: 8px; color: #444; }
        .input-group { margin-bottom: 20px; }

        input[type="number"] {
            width: 100%;
            padding: 12px 16px; border-radius: 12px;
            border: 1px solid rgba(0,0,0,0.1); background: rgba(255,255,255,0.6);
            font-size: 1rem; outline: none; transition: .3s;
        }
        input[type="number"]:focus { border-color: #0984e3; background: #fff; }

        /* Submit Button */
        .btn-submit {
            width: 100%;
            padding: 14px; border-radius: 50px; border: none;
            background: linear-gradient(135deg, #0984e3, #74b9ff);
            color: white; font-size: 1rem; font-weight: 700; cursor: pointer;
            box-shadow: 0 8px 20px rgba(9, 132, 227, 0.3); transition: .3s;
        }
        .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 12px 25px rgba(9, 132, 227, 0.4); }

        @media(max-width: 768px) { .topup-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<jsp:include page="/common/background_customer.jsp" />

<div class="glass-panel">
    <div class="top-bar">
        <a href="wallet.jsp" class="back-btn"><i class="ri-arrow-left-line"></i></a>
        <div class="page-title">Manual Top Up</div>
    </div>

    <div class="topup-grid">
        <div class="qr-section">
            <div class="qr-title">Scan to Pay</div>
            <div class="qr-desc">Use Touch'n Go / DuitNow</div>

            <div class="qr-img-placeholder">
                <img src="${pageContext.request.contextPath}/assets/images/QR code.jpg" class="qr-img-real" alt="DuitNow QR">
            </div>

            <div class="bank-info">
                <div class="bank-row"><span>Bank:</span> <strong>Maybank</strong></div>
                <div class="bank-row"><span>Acc:</span> <strong>5123 4567 8901</strong></div>
                <div class="bank-row"><span>Name:</span> <strong>PrimeGo Sdn Bhd</strong></div>
            </div>
        </div>

        <div class="form-section">
            <form action="${pageContext.request.contextPath}/TopUpServlet" method="post" enctype="multipart/form-data" onsubmit="return handleSubmit(event)">

                <div class="input-group">
                    <label>1. Enter Amount (RM)</label>
                    <input type="number" name="amount" id="amount" placeholder="e.g. 50.00" min="1" step="0.01" required>
                </div>

                <div class="input-group">
                    <label>2. Upload Receipt</label>
                    <div id="receipt-uploader"></div>
                </div>

                <button type="submit" class="btn-submit">Submit for Approval</button>
                <p style="text-align:center; font-size:0.8rem; color:#888; margin-top:15px;">
                    <i class="ri-time-line"></i> Your request will be processed within 24 hours.
                </p>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/assets/jsp/global_modal.jsp" />
<script src="${pageContext.request.contextPath}/assets/js/images_uploader.js"></script>
<script>
    // Initialize Upload Component
    new ImagesUploader('#receipt-uploader', {
        inputName: 'receipt'
    });

    // Form Submission Validation
    function handleSubmit(e) {
        const amount = document.getElementById('amount').value;
        const fileInput = document.querySelector('input[name="receipt"]');

        // 1. Validate Amount
        if(!amount) {
            e.preventDefault();
            // showModal(title, message, type)
            // type options: 'error', 'success', 'warning'
            showModal("Missing Amount", "Please enter the top-up amount before submitting.", 'error');
            return false;
        }

        // 2. Validate File Upload
        if(!fileInput || !fileInput.files || fileInput.files.length === 0) {
            e.preventDefault();
            showModal("Receipt Missing", "Please upload the payment receipt so we can verify your transaction.", 'error');
            return false;
        }

        // Validation Passed
        return true;
    }
</script>

</body>
</html>
