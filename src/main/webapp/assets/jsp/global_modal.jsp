<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
  /* ===== Custom modal styles (start) ===== */
  .custom-modal-overlay {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.4); backdrop-filter: blur(5px);
    z-index: 9999; display: none; opacity: 0; transition: opacity 0.3s ease;
    justify-content: center; align-items: center;
  }
  .custom-modal-overlay.active { display: flex; opacity: 1; }

  .custom-modal-box {
    background: #fff; padding: 30px; width: 400px; max-width: 90%;
    border-radius: 20px; text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.2);
    transform: scale(0.8); transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }
  .custom-modal-overlay.active .custom-modal-box { transform: scale(1); }

  .modal-icon-wrap {
    width: 60px; height: 60px; margin: 0 auto 15px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center; font-size: 30px;
  }
  /* Red (error) state */
  .icon-error { background: #ffebee; color: #ef5350; }
  /* Green (success) state */
  .icon-success { background: #e8f5e9; color: #66bb6a; }
  /* Orange (warning / confirm) state */
  .icon-warning { background: #fff3e0; color: #ff9800; }

  .modal-title { font-size: 1.2rem; font-weight: 700; color: #333; margin-bottom: 10px; }
  .modal-message { font-size: 0.95rem; color: #666; margin-bottom: 25px; line-height: 1.5; }

  .modal-btn {
    background: #2d3436; color: #fff; border: none; padding: 10px 30px;
    border-radius: 50px; font-weight: 600; cursor: pointer; transition: 0.2s;
    outline: none;
  }
  .modal-btn:hover { background: #000; box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
  /* ===== Custom modal styles (end) ===== */
</style>

<div class="custom-modal-overlay" id="customModal">
  <div class="custom-modal-box">
    <div class="modal-icon-wrap" id="modalIconBg">
      <i class="" id="modalIcon"></i>
    </div>

    <h3 class="modal-title" id="modalTitle">Title</h3>
    <p class="modal-message" id="modalMessage">Message goes here.</p>

    <button class="modal-btn" id="modalBtnCancel" onclick="closeModal(false)" style="background: #e0e0e0; color: #333; display: none; margin-right: 10px;">Cancel</button>
    <button class="modal-btn" id="modalBtnOk" onclick="closeModal(true)">OK, Got it</button>
  </div>
</div>

<script>
  /* ===== Global modal logic ===== */
  (function() {
    const modalOverlay = document.getElementById('customModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalMessage = document.getElementById('modalMessage');
    const modalIcon = document.getElementById('modalIcon');
    const modalIconBg = document.getElementById('modalIconBg');
    const modalBtnCancel = document.getElementById('modalBtnCancel');
    const modalBtnOk = document.getElementById('modalBtnOk');

    let currentMode = 'alert'; // 'alert' or 'confirm'
    let onPrimaryCallback = null;   // alert: callback; confirm: onConfirm
    let onSecondaryCallback = null; // confirm: onCancel

    // Expose as a global function on window
    // Supported type values: 'error', 'success', 'warning' (also supports legacy boolean true/false)
    window.showModal = function(title, message, type = 'error', callback = null) {
      currentMode = 'alert';
      modalTitle.innerText = title;
      modalMessage.innerText = message;
      onPrimaryCallback = callback;
      onSecondaryCallback = null;

      // Reset icon classes
      modalIcon.className = '';
      modalIconBg.className = 'modal-icon-wrap';

      // Apply icon and color based on modal type
      if (type === 'error' || type === true) {
        modalIcon.classList.add('ri-error-warning-line');
        modalIconBg.classList.add('icon-error');
      } else if (type === 'success' || type === false) {
        modalIcon.classList.add('ri-checkbox-circle-line');
        modalIconBg.classList.add('icon-success');
      } else if (type === 'warning') {
        modalIcon.classList.add('ri-alert-line');
        modalIconBg.classList.add('icon-warning');
      }

      // Hide cancel, show OK
      modalBtnCancel.style.display = 'none';
      modalBtnOk.innerText = "OK, Got it";

      // Show modal
      modalOverlay.classList.add('active');
    };

    // Confirm modal (shows Cancel + custom primary callback)
    window.showConfirm = function(title, message, onConfirm, onCancel = null) {
      currentMode = 'confirm';
      modalTitle.innerText = title;
      modalMessage.innerText = message;
      onPrimaryCallback = onConfirm;
      onSecondaryCallback = onCancel;

      // Icon for question/confirmation
      modalIcon.className = 'ri-question-line';
      modalIconBg.className = 'modal-icon-wrap icon-warning';
      modalIconBg.classList.remove('icon-error', 'icon-success');
      modalIconBg.classList.add('icon-warning');

      // Show cancel, update OK text
      modalBtnCancel.style.display = 'inline-block';
      modalBtnOk.innerText = "Yes, Proceed";

      modalOverlay.classList.add('active');
    };

    // Close the modal; in confirm mode, the argument indicates whether the primary action was chosen
    window.closeModal = function(isPrimaryAction = false) {
      modalOverlay.classList.remove('active');

      if (currentMode === 'alert') {
        // Alert mode: always run callback if provided
        if (onPrimaryCallback) onPrimaryCallback();
      } else {
        // Confirm mode
        if (isPrimaryAction) {
           if (onPrimaryCallback) onPrimaryCallback();
        } else {
           if (onSecondaryCallback) onSecondaryCallback();
        }
      }

      // Clear callbacks
      onPrimaryCallback = null;
      onSecondaryCallback = null;
    };

    // Clicking outside the dialog closes it (treated as Cancel / Close)
    modalOverlay.addEventListener('click', function(e) {
      if(e.target === modalOverlay) {
        window.closeModal(false);
      }
    });
  })();
</script>