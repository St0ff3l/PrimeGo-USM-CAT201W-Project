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

        // Hard limit for total tiles (server + local)
        const n = Number(config.maxImages);
        this.maxImages = Number.isFinite(n) && n > 0 ? Math.floor(n) : 9;

        this.dt = new DataTransfer();
        this.deletedIds = new Set();

        // Track local (new) files so delete/reorder keeps <input type="file"> in sync
        this.localFiles = new Map(); // key -> File
        this._localSeq = 0;

        this.render();
        this.bindEvents();

        this.updateCapacityUI();
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
        if (!Array.isArray(images) || images.length === 0) return;

        // Only render valid server images (must have an id and a non-empty url)
        const valid = images.filter(img => img && img.id != null && String(img.url || '').trim() !== '');
        if (valid.length === 0) return;

        this.toggleView(true);

        // Respect maxImages when rendering server images
        valid.slice(0, this.maxImages).forEach(img => {
            const div = this.createPreviewItem(String(img.url || ''), true);
            div.dataset.id = String(img.id);
            this.ui.preview.appendChild(div);
        });
        this.updateSortInput();
        this.updateCapacityUI();
    }

    getTotalImageCount() {
        return this.ui?.preview?.querySelectorAll('.iu-preview-wrapper').length || 0;
    }

    getRemainingSlots() {
        return Math.max(0, this.maxImages - this.getTotalImageCount());
    }

    updateCapacityUI() {
        if (!this.ui?.addBtn) return;
        const full = this.getTotalImageCount() >= this.maxImages;
        this.ui.addBtn.disabled = full;
        this.ui.addBtn.style.opacity = full ? '0.5' : '';
        this.ui.addBtn.style.pointerEvents = full ? 'none' : '';
    }

    handleNewFiles(files) {
        const picked = Array.from(files || []).filter(file => file && file.type && file.type.startsWith('image/'));
        if (picked.length === 0) {
            if (this.ui?.input) this.ui.input.value = '';
            return;
        }

        let remaining = this.getRemainingSlots();
        if (remaining <= 0) {
            // Already full; ignore new selection/drop
            this.updateCapacityUI();
            if (this.ui?.input) this.ui.input.value = '';
            return;
        }

        let hasNew = false;

        // Only accept up to remaining slots
        picked.slice(0, remaining).forEach(file => {
            // Re-check capacity in case async callbacks or external DOM changes happened
            if (this.getRemainingSlots() <= 0) return;

            const key = `local_${Date.now()}_${this._localSeq++}`;
            this.localFiles.set(key, file);
            hasNew = true;

            const reader = new FileReader();
            reader.onload = (e) => {
                // Guard again at callback time (prevents "undefined"/empty tiles occupying slots)
                if (this.getRemainingSlots() <= 0) return;

                const result = e && e.target ? e.target.result : null;
                if (typeof result !== 'string' || result.trim() === '') return;

                const div = this.createPreviewItem(result, false, key);
                this.ui.preview.appendChild(div);

                // Keep UI/input state consistent as items arrive
                this.rebuildDataTransferFromLocal();
                this.toggleView(true);
                this.updateCapacityUI();
            };
            reader.onerror = () => {
                // If reading fails, roll back the local file so it doesn't create a phantom slot
                this.localFiles.delete(key);
                this.rebuildDataTransferFromLocal();
                this.updateCapacityUI();
            };
            reader.readAsDataURL(file);
        });

        if (hasNew) {
            this.rebuildDataTransferFromLocal();
            this.toggleView(true);
            this.updateCapacityUI();
        }

        // Important: allow selecting the same file(s) again to trigger change
        if (this.ui?.input) this.ui.input.value = '';
    }

    createPreviewItem(src, isServerImage, localKey = null) {
        const div = document.createElement('div');
        div.className = 'iu-preview-wrapper';
        div.draggable = true; // Enable drag-and-drop sorting

        if (!isServerImage && localKey) {
            div.dataset.localKey = String(localKey);
        }

        // Ensure we always clear dragging state when drag ends (even if dropped outside)
        div.addEventListener('dragend', () => {
            div.classList.remove('dragging');
            if (this.dragItem === div) this.dragItem = null;

            // If user reordered, keep file input order consistent with tiles
            this.rebuildDataTransferFromLocal();
            this.updateSortInput();
            this.updateCapacityUI();
        });

        const img = document.createElement('img');
        img.src = (src == null) ? '' : String(src);
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

            // Track delete intent before removing tile
            if (isServerImage && div.dataset.id != null && div.dataset.id !== '') {
                this.deletedIds.add(String(div.dataset.id));
                this.ui.deleteInput.value = Array.from(this.deletedIds).join(',');
            }

            if (!isServerImage && div.dataset.localKey) {
                this.localFiles.delete(String(div.dataset.localKey));
            }

            div.remove();

            if (this.ui.preview.children.length === 0) this.toggleView(false);

            // Keep both hidden inputs and <input type=file> state consistent
            this.rebuildDataTransferFromLocal();
            this.updateSortInput();
            this.updateCapacityUI();
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

            // Persist server order + keep local file order consistent
            this.rebuildDataTransferFromLocal();
            this.updateSortInput();
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

    rebuildDataTransferFromLocal() {
        if (!this.ui?.input) return;

        const next = new DataTransfer();

        // Use current DOM order for local files
        this.ui.preview.querySelectorAll('.iu-preview-wrapper[data-local-key]').forEach(div => {
            const key = div.dataset.localKey;
            const file = this.localFiles.get(String(key));
            if (file) next.items.add(file);
        });

        this.dt = next;
        this.ui.input.files = this.dt.files;
    }

    toggleView(hasContent) {
        this.ui.placeholder.style.display = hasContent ? 'none' : 'block';
        this.ui.preview.style.display = hasContent ? 'flex' : 'none';
        this.ui.addBtn.style.display = hasContent ? 'flex' : 'none';
        this.updateCapacityUI();
    }
}