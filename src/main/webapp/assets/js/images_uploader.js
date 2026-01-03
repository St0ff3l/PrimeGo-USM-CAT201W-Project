/**
 * Images Uploader Component (With Drag & Drop Sorting)
 * 功能：支持多图上传、预览、删除、以及 **拖拽排序**
 */
class ImagesUploader {
    constructor(containerSelector, config = {}) {
        this.container = document.querySelector(containerSelector);
        if (!this.container) return;

        this.inputName = config.inputName || 'newImages'; // 新文件的 input name
        this.deleteInputName = config.deleteInputName || 'deleteImageIds'; // 删除的 ID
        this.sortInputName = config.sortInputName || 'imageSortOrder'; // 排序后的 ID 列表

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

        // 拖拽文件上传区域
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evt => {
            area.addEventListener(evt, (e) => { e.preventDefault(); e.stopPropagation(); });
        });
        area.addEventListener('drop', (e) => this.handleNewFiles(e.dataTransfer.files));

        // === 新增：预览列表的拖拽排序事件 ===
        preview.addEventListener('dragstart', (e) => this.handleSortStart(e));
        preview.addEventListener('dragover', (e) => this.handleSortOver(e));
        preview.addEventListener('drop', (e) => this.handleSortDrop(e));
    }

    setInitialImages(images) {
        if (!images || images.length === 0) return;
        this.toggleView(true);

        images.forEach(img => {
            const div = this.createPreviewItem(img.url, true);
            div.dataset.id = img.id; // 绑定数据库 ID
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
                // 渲染预览
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
        div.draggable = true; // 允许拖拽
        div.innerHTML = `
            <img src="${src}" class="iu-preview-item">
            <div class="iu-del-btn"><i class="ri-close-line"></i></div>
        `;

        // 删除逻辑
        div.querySelector('.iu-del-btn').onclick = (e) => {
            e.stopPropagation();
            div.remove();
            if (isServerImage) {
                this.deletedIds.add(div.dataset.id);
                this.ui.deleteInput.value = Array.from(this.deletedIds).join(',');
            }
            // 如果是新文件，逻辑比较复杂这里简化处理：仅移除DOM，后端会忽略多余的file
            if (this.ui.preview.children.length === 0) this.toggleView(false);
            this.updateSortInput();
        };
        return div;
    }

    // === 拖拽排序逻辑 ===
    handleSortStart(e) {
        const item = e.target.closest('.iu-preview-wrapper');
        if (item) {
            e.dataTransfer.effectAllowed = 'move';
            item.classList.add('dragging');
            this.dragItem = item; // 记录当前拖拽的元素
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
            this.updateSortInput(); // 排序结束后更新 input
        }
    }

    // 更新排序后的 ID 列表 (只针对服务器已有图片)
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