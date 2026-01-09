<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Request Refund - PrimeGo</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer_dashboard.css">
    <style>
        .refund-card {
            background: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 20px;
            max-width: 800px;
            margin: 0 auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .refund-reason-area {
            width: 100%;
            height: 150px;
            padding: 15px;
            border: 2px solid #eee;
            border-radius: 10px;
            font-family: 'Poppins', sans-serif;
            margin-top: 10px;
            resize: none;
        }
        .refund-reason-area:focus {
            border-color: #e68a00;
            outline: none;
        }
        .btn-submit {
            background: #e74c3c; color: white; padding: 12px 30px; border: none;
            border-radius: 25px; font-weight: 600; cursor: pointer; font-size: 1rem;
            margin-top: 20px; transition: 0.3s;
        }
        .btn-submit:hover { background: #c0392b; transform: translateY(-2px); }
        .btn-cancel {
            background: transparent; border: 1px solid #ccc; color: #666; padding: 12px 30px;
            border-radius: 25px; text-decoration: none; font-weight: 600; margin-right: 10px;
        }
    </style>
</head>
<body>

<div class="background-blob blob-red"></div>
<div class="background-blob blob-yellow"></div>

<div class="main-content" style="margin: 50px auto; width: 100%; max-width: 1000px; padding-left: 0;">

    <div class="refund-card">
        <h2 style="margin-bottom: 20px; color: #2d3436;">Request Refund</h2>

        <div style="background: #fff3cd; padding: 15px; border-radius: 10px; color: #856404; margin-bottom: 30px;">
            <i class="ri-information-fill"></i> You are applying for a refund for the order below. This action is valid within 7 days of receipt.
        </div>

        <div style="border-bottom: 1px solid #eee; padding-bottom: 20px; margin-bottom: 20px;">
            <h4 style="color: #555;">Order ID: #${refundOrder.ordersId}</h4>
            <p style="color: #888;">Placed on: ${refundOrder.createdAt}</p>
            <h3 style="color: #e68a00; margin-top: 10px;">Refund Amount: $${refundOrder.totalAmount}</h3>
        </div>

        <form action="${pageContext.request.contextPath}/customer/orders" method="post">
            <input type="hidden" name="action" value="processRefundRequest">
            <input type="hidden" name="orderId" value="${refundOrder.ordersId}">
            <input type="hidden" name="status" value="${param.status}">

            <label style="font-weight: 600; color: #333;">Why do you want to return this?</label>
            <textarea name="reason" class="refund-reason-area" placeholder="Please describe the reason (e.g., Damaged item, Wrong size, Changed mind)..." required></textarea>

            <div style="text-align: right; margin-top: 20px;">
                <a href="${pageContext.request.contextPath}/customer/orders?status=${empty param.status ? 'ALL' : param.status}" class="btn-cancel">Cancel</a>
                <button type="submit" class="btn-submit">Submit Request</button>
            </div>
        </form>
    </div>
</div>

</body>
</html>