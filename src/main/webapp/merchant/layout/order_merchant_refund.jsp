<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div id="refundModal" class="modal-overlay">
    <div class="modal-content" style="width: 500px;">
        <h3 style="margin-bottom: 10px; color: #d35400;">Handle Refund Request</h3>

        <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post" id="refundForm">
            <input type="hidden" name="action" value="processRefund">
            <input type="hidden" id="refundModalOrderId" name="orderId" value="">
            <input type="hidden" id="refundDecision" name="decision" value=""> <%-- approve or reject --%>

            <div class="form-group">
                <label style="color: #666;">Customer's Reason:</label>
                <div id="displayCustomerReason" style="background: #f8f9fa; padding: 10px; border-radius: 8px; font-style: italic; color: #555;">
                </div>
            </div>

            <div class="form-group">
                <label>Your Response / Rejection Reason</label>
                <textarea name="merchantReason" id="merchantReason" class="form-textarea" placeholder="If rejecting, please explain why (e.g. item damaged by user)..."></textarea>
            </div>

            <div class="modal-actions" style="justify-content: space-between;">
                <button type="button" class="btn-cancel" onclick="closeRefundModal()">Cancel</button>
                <div style="display: flex; gap: 10px;">
                    <button type="button" class="btn-reject" onclick="submitRefund('reject')">Reject</button>
                    <button type="button" class="btn-approve" onclick="submitRefund('approve')">Approve Refund</button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    // Open Refund Modal
    function openRefundModal(orderId, customerReason) {
        document.getElementById('refundModalOrderId').value = orderId;
        // Check if customerReason is empty or null string
        if (!customerReason || customerReason === 'null') {
            customerReason = "No specific reason provided.";
        }
        document.getElementById('displayCustomerReason').innerText = customerReason;
        document.getElementById('merchantReason').value = ""; // clear previous input
        document.getElementById('refundModal').style.display = 'flex';
    }

    // Close Refund Modal
    function closeRefundModal() {
        document.getElementById('refundModal').style.display = 'none';
    }

    // Submit Refund Logic
    function submitRefund(decision) {
        document.getElementById('refundDecision').value = decision;

        // Validation for Rejection
        if (decision === 'reject') {
            const reason = document.getElementById('merchantReason').value.trim();
            if (!reason) {
                alert("Please provide a reason for rejection.");
                return;
            }
        }

        if (confirm("Are you sure you want to " + decision.toUpperCase() + " this refund?")) {
            document.getElementById('refundForm').submit();
        }
    }
</script>