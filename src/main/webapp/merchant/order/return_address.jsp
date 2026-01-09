<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // basic auth check (kept simple to match current project style)
    com.primego.user.model.User user = (com.primego.user.model.User) session.getAttribute("user");
    if (user == null || !"MERCHANT".equals(user.getRole().toString())) {
        response.sendRedirect(request.getContextPath() + "/public/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Return Address - PrimeGo Seller</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; font-family: 'Poppins', sans-serif; }
        body { background:#F3F6F9; padding-top: 90px; }
        .container { max-width: 900px; margin: 30px auto; padding: 0 20px; }
        .panel { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        .title { font-size: 1.4rem; font-weight: 700; margin-bottom: 6px; color:#2d3436; }
        .sub { color:#636e72; margin-bottom: 18px; }
        label { display:block; font-weight:600; margin: 14px 0 6px; }
        textarea { width:100%; min-height: 120px; border: 2px solid #eee; border-radius: 12px; padding: 12px; resize: vertical; }
        .row { display:flex; gap: 12px; align-items: center; margin-top: 16px; }
        .btn { border:none; border-radius: 10px; padding: 10px 16px; cursor:pointer; font-weight:600; }
        .btn-cancel { background:#eee; color:#2d3436; }
        .btn-save { background:#3498db; color:white; }
        .hint { font-size: 0.85rem; color:#666; margin-top: 6px; }
    </style>
</head>
<body>

<%@ include file="../../common/background_merchant.jsp" %>
<%@ include file="../../common/layout/header_bar.jsp" %>
<%-- Include Global Modal --%>
<jsp:include page="../../assets/jsp/global_modal.jsp" />

<div class="container">
    <div class="panel">
        <div class="title">Provide Return Address</div>
        <div class="sub">Order #<c:out value="${order.ordersId}"/> — This address will be shown to the customer for returning the item.</div>

        <c:if test="${empty order}">
            <div style="color:#c0392b;">Order not found or not accessible.</div>
        </c:if>

        <c:if test="${not empty order}">
            <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post">
                <input type="hidden" name="action" value="saveReturnAddress" />
                <input type="hidden" name="orderId" value="${order.ordersId}" />

                <label for="returnAddress">Return Address</label>
                <textarea id="returnAddress" name="returnAddress" placeholder="Receiver name, phone, full address" required>${order.returnAddress}</textarea>
                <div class="hint">Tip: include name + phone + full address to avoid delivery issues.</div>

                <div class="row">
                    <button type="button" class="btn btn-cancel" onclick="window.location='${pageContext.request.contextPath}/merchant/order/order_management?filter=return'">Cancel</button>
                    <button type="button" class="btn btn-save" onclick="confirmSaveAddress()">Save & Continue</button>
                </div>
            </form>
        </c:if>
    </div>
</div>

<script>
    function confirmSaveAddress() {
        const addr = document.getElementById('returnAddress').value.trim();
        if(!addr) {
            showModal("Validation Error", "Return address is required.", "error");
            return;
        }

        showConfirm(
            "Confirm Save",
            "Are you sure you want to save this return address?",
            function() {
                // Submit the form
                const form = document.querySelector('input[name="action"][value="saveReturnAddress"]').form;
                if(form) form.submit();
            }
        );
    }
</script>

</body>
</html>
