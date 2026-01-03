<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!-- Login Check Modal -->
<div id="loginCheckModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
        <div class="modal-header">
            <h3>Login Required</h3>
            <span class="close-modal" onclick="closeLoginModal()">&times;</span>
        </div>
        <div class="modal-body">
            <p>You need to login to proceed with this action.</p>
            <div class="modal-actions">
                <a href="${pageContext.request.contextPath}/public/login.jsp" class="btn-login-modal">Login Now</a>
                <button class="btn-cancel-modal" onclick="closeLoginModal()">Cancel</button>
            </div>
        </div>
    </div>
</div>

<style>
    .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: 2000;
        display: flex;
        justify-content: center;
        align-items: center;
        backdrop-filter: blur(5px);
    }

    .modal-content {
        background: white;
        padding: 25px;
        border-radius: 15px;
        width: 90%;
        max-width: 400px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        animation: modalFadeIn 0.3s ease;
    }

    @keyframes modalFadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .modal-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        border-bottom: 1px solid #eee;
        padding-bottom: 10px;
    }

    .modal-header h3 {
        margin: 0;
        color: #2d3436;
    }

    .close-modal {
        font-size: 1.5rem;
        cursor: pointer;
        color: #aaa;
    }

    .close-modal:hover {
        color: #333;
    }

    .modal-body p {
        color: #666;
        margin-bottom: 20px;
    }

    .modal-actions {
        display: flex;
        gap: 10px;
    }

    .btn-login-modal {
        flex: 1;
        background: #FF9500;
        color: white;
        text-align: center;
        padding: 10px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 600;
        transition: background 0.2s;
    }

    .btn-login-modal:hover {
        background: #e68600;
    }

    .btn-cancel-modal {
        flex: 1;
        background: #f1f2f6;
        color: #333;
        border: none;
        padding: 10px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
        transition: background 0.2s;
    }

    .btn-cancel-modal:hover {
        background: #dfe4ea;
    }
</style>

<script>
    function showLoginModal() {
        document.getElementById('loginCheckModal').style.display = 'flex';
    }

    function closeLoginModal() {
        document.getElementById('loginCheckModal').style.display = 'none';
    }

    // Close modal when clicking outside
    window.onclick = function(event) {
        var modal = document.getElementById('loginCheckModal');
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
</script>
