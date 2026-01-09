<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Include global modal for popup messages --%>
<jsp:include page="../../assets/jsp/global_modal.jsp" />

<div id="refundModal" class="modal-overlay">
    <div class="modal-content" style="width: 500px;">
        <h3 style="margin-bottom: 10px; color: #d35400;">Handle Refund Request</h3>

        <form action="${pageContext.request.contextPath}/merchant/order/order_management" method="post" id="refundForm">
            <input type="hidden" name="action" value="processRefund">
            <input type="hidden" id="refundModalOrderId" name="orderId" value="">
            <input type="hidden" id="refundDecision" name="decision" value=""> <%-- agree_return / confirm_return_receipt / reject --%>
            <input type="hidden" id="refundType" name="refundType" value="">

            <div class="form-group">
                <label style="color: #666;">Customer's Reason:</label>
                <div id="displayCustomerReason" style="background: #f8f9fa; padding: 10px; border-radius: 8px; font-style: italic; color: #555;">
                </div>
            </div>

            <div class="form-group">
                <label style="color:#666;">Refund Type:</label>
                <div id="displayRefundType" style="background:#f8f9fa; padding: 10px; border-radius: 8px; color:#555;">
                </div>
            </div>

            <div class="form-group">
                <label>Your Response / Rejection Reason</label>
                <textarea name="merchantReason" id="merchantReason" class="form-textarea" placeholder="If rejecting, please explain why (e.g. item damaged by user)..."></textarea>
            </div>

            <div class="form-group" id="returnTrackingGroup" style="display:none;">
                <label style="color:#666;">Customer Return Tracking No:</label>
                <div id="displayReturnTracking" style="background:#f8f9fa; padding: 10px; border-radius: 8px; color:#555;"></div>
            </div>

            <div class="modal-actions" style="justify-content: space-between;">
                <button type="button" class="btn-cancel" onclick="closeRefundModal()">Cancel</button>
                <div style="display: flex; gap: 10px;">
                    <button type="button" class="btn-reject" onclick="submitRefund('reject')">Reject</button>

                    <button type="button" id="btnApprove" class="btn-approve" onclick="submitRefund('approve_logic')">
                        Approve
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<script>
    // Open Refund Modal (with refund status + refund type)
    function openRefundModal(orderId, customerReason, refundStatus, refundType, returnTrackingNumber) {
        document.getElementById('refundModalOrderId').value = orderId;
        if (!customerReason || customerReason === 'null') customerReason = "No reason provided.";
        document.getElementById('displayCustomerReason').innerText = customerReason;
        document.getElementById('merchantReason').value = "";

        // Show return tracking number if provided
        const rtn = (returnTrackingNumber && returnTrackingNumber !== 'null') ? returnTrackingNumber : '';
        const rtnGroup = document.getElementById('returnTrackingGroup');
        if (rtn) {
            document.getElementById('displayReturnTracking').innerText = rtn;
            rtnGroup.style.display = 'block';
        } else {
            document.getElementById('displayReturnTracking').innerText = '';
            rtnGroup.style.display = 'none';
        }

        // Normalize refundType
        let rt = (refundType && refundType !== 'null') ? refundType : '';
        if (!rt) {
            // infer for legacy rows
            rt = (refundStatus === 'WAITING_RETURN' || refundStatus === 'RETURN_SHIPPED') ? 'RETURN_AND_REFUND' : 'MONEY_ONLY';
        }
        document.getElementById('refundType').value = rt;
        document.getElementById('displayRefundType').innerText = (rt === 'RETURN_AND_REFUND')
                ? 'Return & Refund'
                : 'Refund only (no return)';

        // UI logic
        const btn = document.getElementById('btnApprove');

        if (rt === 'MONEY_ONLY') {
            // money-only: merchant can refund directly
            btn.innerText = "Approve Refund";
            btn.setAttribute('onclick', "submitRefund('confirm_return_receipt')");
            btn.style.background = "#2ecc71";
        } else {
            // return+refund: need agree_return first, then confirm receipt after customer shipped
            if (refundStatus === 'RETURN_SHIPPED') {
                btn.innerText = "Confirm Return Receipt (Refund)";
                btn.setAttribute('onclick', "submitRefund('confirm_return_receipt')");
                btn.style.background = "#2ecc71";
            } else {
                btn.innerText = "Agree to Return";
                btn.setAttribute('onclick', "submitRefund('agree_return')");
                btn.style.background = "#3498db";
            }
        }

        document.getElementById('refundModal').style.display = 'flex';
    }

    function closeRefundModal() {
        document.getElementById('refundModal').style.display = 'none';
    }

    function submitRefund(decision) {
        document.getElementById('refundDecision').value = decision;

        if (decision === 'reject') {
            const reason = document.getElementById('merchantReason').value.trim();
            if (!reason) {
                // Use global modal instead of native alert
                showModal("Action Required", "Please provide a reason for rejection.", "error");
                return;
            }
        }

        // Use global modal confirm instead of native confirm
        showConfirm(
            "Confirm Action",
            "Proceed with " + decision + "?",
            function() {
                document.getElementById('refundForm').submit();
            }
        );
    }
</script>