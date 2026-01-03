package com.primego.product.model;

import java.sql.Timestamp;

public class Category {
    private int categoryId;
    private String categoryName;
    private int categoryStatus;
    private Timestamp categoryCreatedAt;

    public Category() {}

    public Category(int categoryId, String categoryName) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getCategoryStatus() {
        return categoryStatus;
    }

    public void setCategoryStatus(int categoryStatus) {
        this.categoryStatus = categoryStatus;
    }

    public Timestamp getCategoryCreatedAt() {
        return categoryCreatedAt;
    }

    public void setCategoryCreatedAt(Timestamp categoryCreatedAt) {
        this.categoryCreatedAt = categoryCreatedAt;
    }
}
