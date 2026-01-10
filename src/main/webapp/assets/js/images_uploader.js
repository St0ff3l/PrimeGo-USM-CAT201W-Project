/**
 * Images Uploader component with drag-and-drop sorting.
 *
 * Responsibilities:
 * - Select multiple images via file picker or drop them onto the upload area.
 * - Render local previews for newly selected files.
 * - Render existing (server) images and allow them to be removed.
 * - Allow reordering of preview tiles via drag-and-drop.
 *
 * Form integration:
 * - New files are submitted through the hidden <input type="file">.
 * - Deleted server image IDs are written to a hidden input as a comma-separated list.
 * - The current sort order of server image IDs is written to a hidden input.
 */
class ImagesUploader {
    constructor(containerSelector, config = {}) {
        this.container = document.querySelector(containerSelector);
        if (!this.container) return;

        this.inputName = config.inputName || 'newImages'; // Input name used for newly added files
        this.deleteInputName = config.deleteInputName || 'deleteImageIds'; // Input name used for deleted server image IDs
        this.sortInputName = config.sortInputName || 'imageSortOrder'; // Input name used for the sorted server image ID list
        this.placeholderImg = config.placeholderImg || ''; // Fallback image URL if a preview fails to load

        this.dt = new DataTransfer();
        this.deletedIds = new Set();

        this.render();
        this.bindEvents();
    }

    render() {
        this.container.innerHTML = `
            <div class="iu-upload-area">
                <div class="iu-placeholder">
                    <div class="iu-icon"><i class="ri-camera-lens-line"></i></div>
                    <p style="margin-top: 15px; color: #6B7280;">Click or Drag images here</p>
                    <p style="font-size: 0.75rem; color: #9CA3AF;">First image will be the Primary Image</p>
                </div>
                
                <div class="iu-preview"></div>
                
                <button type="button" class="iu-add-btn"><i class="ri-add-line"></i></button>
                
                <input type="file" name="${this.inputName}" multiple accept="image/*" style="display: none;">
                <input type="hidden" name="${this.deleteInputName}" class="iu-delete-input">
                <input type="hidden" name="${this.sortInputName}" class="iu-sort-input">
            </div>
        `;

        this.ui = {
            area: this.container.querySelector('.iu-upload-area'),
            placeholder: this.container.querySelector('.iu-placeholder'),
            preview: this.container.querySelector('.iu-preview'),
            input: this.container.querySelector('input[type="file"]'),
            deleteInput: this.container.querySelector('.iu-delete-input'),
            sortInput: this.container.querySelector('.iu-sort-input'),
            addBtn: this.container.querySelector('.iu-add-btn')
        };
    }

    bindEvents() {
        const { area, input, placeholder, addBtn, preview } = this.ui;
        const trigger = () => input.click();
        placeholder.addEventListener('click', trigger);
        addBtn.addEventListener('click', trigger);

        input.addEventListener('change', (e) => this.handleNewFiles(e.target.files));

        // Drag-and-drop upload area: prevent default browser handling and accept dropped files
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evt => {
            area.addEventListener(evt, (e) => { e.preventDefault(); e.stopPropagation(); });
        });
        area.addEventListener('drop', (e) => this.handleNewFiles(e.dataTransfer.files));

        // Preview list drag-and-drop sorting
        preview.addEventListener('dragstart', (e) => this.handleSortStart(e));
        preview.addEventListener('dragover', (e) => this.handleSortOver(e));
        preview.addEventListener('drop', (e) => this.handleSortDrop(e));
    }

    setInitialImages(images) {
        if (!images || images.length === 0) return;
        this.toggleView(true);

        images.forEach(img => {
            const div = this.createPreviewItem(img.url, true);
            div.dataset.id = img.id; // Persist the server/database ID on the preview element
            this.ui.preview.appendChild(div);
        });
        this.updateSortInput();
    }

    handleNewFiles(files) {
        let hasNew = false;
        Array.from(files).forEach(file => {
            if (file.type.startsWith('image/')) {
                this.dt.items.add(file);
                hasNew = true;
                // Render a preview tile for each newly selected file
                const reader = new FileReader();
                reader.onload = (e) => {
                    const div = this.createPreviewItem(e.target.result, false);
                    this.ui.preview.appendChild(div);
                };
                reader.readAsDataURL(file);
            }
        });
        if (hasNew) {
            this.ui.input.files = this.dt.files;
            this.toggleView(true);
        }
    }

    createPreviewItem(src, isServerImage) {
        const div = document.createElement('div');
        div.className = 'iu-preview-wrapper';
        div.draggable = true; // Enable drag-and-drop sorting

        const img = document.createElement('img');
        img.src = src;
        img.className = 'iu-preview-item';
        img.alt = 'Image Preview';

        if (this.placeholderImg) {
            img.onerror = () => {
                img.onerror = null;
                img.src = this.placeholderImg;
            };
        }

        const delBtn = document.createElement('div');
        delBtn.className = 'iu-del-btn';
        delBtn.innerHTML = '<i class="ri-close-line"></i>';

        delBtn.onclick = (e) => {
            e.stopPropagation();
            div.remove();
            if (isServerImage) {
                this.deletedIds.add(div.dataset.id);
                this.ui.deleteInput.value = Array.from(this.deletedIds).join(',');
            }
            // For newly selected files we only remove the DOM tile; the backend should ignore extra files if needed
            if (this.ui.preview.children.length === 0) this.toggleView(false);
            this.updateSortInput();
        };

        div.appendChild(img);
        div.appendChild(delBtn);

        return div;
    }

    // Drag-and-drop sorting logic
    handleSortStart(e) {
        const item = e.target.closest('.iu-preview-wrapper');
        if (item) {
            e.dataTransfer.effectAllowed = 'move';
            item.classList.add('dragging');
            this.dragItem = item; // Keep a reference to the element being dragged
        }
    }

    handleSortOver(e) {
        e.preventDefault();
        const item = e.target.closest('.iu-preview-wrapper');
        if (item && item !== this.dragItem) {
            const bounding = item.getBoundingClientRect();
            const offset = bounding.x + bounding.width / 2;
            if (e.clientX - offset > 0) {
                item.after(this.dragItem);
            } else {
                item.before(this.dragItem);
            }
        }
    }

    handleSortDrop(e) {
        e.preventDefault();
        if (this.dragItem) {
            this.dragItem.classList.remove('dragging');
            this.dragItem = null;
            this.updateSortInput(); // Persist sort order after dropping
        }
    }

    // Write the current server image ID order to the hidden input (new/local files are excluded)
    updateSortInput() {
        const ids = [];
        this.ui.preview.querySelectorAll('.iu-preview-wrapper').forEach(div => {
            if (div.dataset.id) {
                ids.push(div.dataset.id);
            }
        });
        this.ui.sortInput.value = ids.join(',');
    }

    toggleView(hasContent) {
        this.ui.placeholder.style.display = hasContent ? 'none' : 'block';
        this.ui.preview.style.display = hasContent ? 'flex' : 'none';
        this.ui.addBtn.style.display = hasContent ? 'flex' : 'none';
    }
}