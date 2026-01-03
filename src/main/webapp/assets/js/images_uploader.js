/**
 * Images Uploader Component
 * File: assets/js/images_uploader.js
 * Supports Drag & Drop, Multiple Images, Preview, and Removal.
 */
class ImagesUploader {
    constructor(containerSelector, config = {}) {
        this.container = document.querySelector(containerSelector);
        if (!this.container) {
            console.error(`ImagesUploader: Container '${containerSelector}' not found.`);
            return;
        }

        // Default name is 'evidence[]', can be overridden
        this.inputName = config.inputName || 'images[]';
        this.dt = new DataTransfer(); // Use DataTransfer to manage file list

        this.render();
        this.bindEvents();
    }

    // Render HTML structure
    render() {
        this.container.innerHTML = `
            <div class="iu-upload-area">
                <button type="button" class="iu-clear-btn">Clear All</button>
                
                <div class="iu-placeholder">
                    <div class="iu-icon"><i class="ri-camera-lens-line"></i></div>
                    <p style="margin-top: 15px; color: #6B7280; font-weight: 500;">Click or Drag & Drop images</p>
                    <p style="font-size: 0.75rem; color: #9CA3AF; margin-top: 4px;">JPG, PNG, WEBP supported</p>
                </div>
                
                <div class="iu-preview"></div>
                
                <button type="button" class="iu-add-btn"><i class="ri-add-line"></i></button>
                <input type="file" name="${this.inputName}" multiple accept="image/*" style="display: none;">
            </div>
        `;

        this.ui = {
            area: this.container.querySelector('.iu-upload-area'),
            placeholder: this.container.querySelector('.iu-placeholder'),
            preview: this.container.querySelector('.iu-preview'),
            input: this.container.querySelector('input[type="file"]'),
            addBtn: this.container.querySelector('.iu-add-btn'),
            clearBtn: this.container.querySelector('.iu-clear-btn')
        };
    }

    // Bind event logic
    bindEvents() {
        const { area, input, placeholder, addBtn, clearBtn } = this.ui;

        const trigger = () => input.click();
        placeholder.addEventListener('click', trigger);
        addBtn.addEventListener('click', trigger);

        // Input change
        input.addEventListener('change', (e) => this.handleFiles(e.target.files));

        // Drag & Drop events
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evt => {
            area.addEventListener(evt, (e) => { e.preventDefault(); e.stopPropagation(); });
        });
        ['dragenter', 'dragover'].forEach(evt => area.classList.add('drag-over'));
        ['dragleave', 'drop'].forEach(evt => area.classList.remove('drag-over'));

        area.addEventListener('drop', (e) => this.handleFiles(e.dataTransfer.files));

        // Clear button
        if (clearBtn) {
            clearBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.dt.items.clear();
                this.updateInput();
            });
        }
    }

    // Core file handling logic
    handleFiles(files) {
        let hasNew = false;
        for (let file of files) {
            // Only accept images
            if (file.type.startsWith('image/')) {
                this.dt.items.add(file);
                hasNew = true;
            }
        }
        if (hasNew) this.updateInput();
    }

    // Remove single image
    removeFile(index) {
        const newDt = new DataTransfer();
        const files = this.dt.files;
        for (let i = 0; i < files.length; i++) {
            if (i !== index) newDt.items.add(files[i]);
        }
        this.dt = newDt;
        this.updateInput();
    }

    // Update UI and Input value (sync with DataTransfer)
    updateInput() {
        this.ui.input.files = this.dt.files;
        this.renderPreview();
    }

    renderPreview() {
        const { preview, placeholder, clearBtn, addBtn } = this.ui;
        preview.innerHTML = '';

        if (this.dt.files.length > 0) {
            placeholder.style.display = 'none';
            if (clearBtn) clearBtn.style.display = 'block';
            addBtn.style.display = 'flex';
            preview.style.display = 'flex';

            Array.from(this.dt.files).forEach((file, index) => {
                const reader = new FileReader();
                reader.onload = (e) => {
                    const div = document.createElement('div');
                    div.className = 'iu-preview-wrapper';
                    div.innerHTML = `
                        <img src="${e.target.result}" class="iu-preview-item">
                        <div class="iu-del-btn"><i class="ri-close-line"></i></div>
                    `;
                    div.querySelector('.iu-del-btn').onclick = (ev) => {
                        ev.stopPropagation();
                        this.removeFile(index);
                    };
                    preview.appendChild(div);
                };
                reader.readAsDataURL(file);
            });
        } else {
            placeholder.style.display = 'block';
            if (clearBtn) clearBtn.style.display = 'none';
            addBtn.style.display = 'none';
            preview.style.display = 'none';
        }
    }
}