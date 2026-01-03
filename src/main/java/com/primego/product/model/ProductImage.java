package com.primego.product.model;

import java.sql.Timestamp;

public class ProductImage {
    private int imageId;
    private int productId;
    private String imageUrl;
    private boolean imageIsPrimary;
    private Timestamp imageUploadTime;

    public ProductImage() {}

    public ProductImage(int productId, String imageUrl, boolean imageIsPrimary) {
        this.productId = productId;
        this.imageUrl = imageUrl;
        this.imageIsPrimary = imageIsPrimary;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isImageIsPrimary() {
        return imageIsPrimary;
    }

    public void setImageIsPrimary(boolean imageIsPrimary) {
        this.imageIsPrimary = imageIsPrimary;
    }

    public Timestamp getImageUploadTime() {
        return imageUploadTime;
    }

    public void setImageUploadTime(Timestamp imageUploadTime) {
        this.imageUploadTime = imageUploadTime;
    }
}
