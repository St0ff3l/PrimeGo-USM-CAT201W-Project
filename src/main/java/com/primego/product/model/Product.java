package com.primego.product.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {
    private int productId;
    private int merchantId;
    private int categoryId;
    private String productName;
    private String productDescription;
    private BigDecimal productPrice;
    private int productStockQuantity;
    private String contactWhatsapp;
    private String productStatus; // 'ON_SALE', 'OFF_SALE'
    private Timestamp productCreatedAt;
    private Timestamp productUpdatedAt;

    // Admin audit fields (DB: Audit_Status, Audit_Message)
    private String auditStatus; // 'PENDING', 'APPROVED', 'REJECTED'
    private String auditMessage;


    // Constructors
    public Product() {}

    public Product(int merchantId, int categoryId, String productName, String productDescription, 
                   BigDecimal productPrice, int productStockQuantity, String productStatus) {
        this.merchantId = merchantId;
        this.categoryId = categoryId;
        this.productName = productName;
        this.productDescription = productDescription;
        this.productPrice = productPrice;
        this.productStockQuantity = productStockQuantity;
        this.productStatus = productStatus;
    }

    // Getters and Setters
    public String getContactWhatsapp() {
        return contactWhatsapp;
    }

    public void setContactWhatsapp(String contactWhatsapp) {
        this.contactWhatsapp = contactWhatsapp;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(int merchantId) {
        this.merchantId = merchantId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductDescription() {
        return productDescription;
    }

    public void setProductDescription(String productDescription) {
        this.productDescription = productDescription;
    }

    public BigDecimal getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(BigDecimal productPrice) {
        this.productPrice = productPrice;
    }

    public int getProductStockQuantity() {
        return productStockQuantity;
    }

    public void setProductStockQuantity(int productStockQuantity) {
        this.productStockQuantity = productStockQuantity;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }

    public Timestamp getProductCreatedAt() {
        return productCreatedAt;
    }

    public void setProductCreatedAt(Timestamp productCreatedAt) {
        this.productCreatedAt = productCreatedAt;
    }

    public Timestamp getProductUpdatedAt() {
        return productUpdatedAt;
    }

    public void setProductUpdatedAt(Timestamp productUpdatedAt) {
        this.productUpdatedAt = productUpdatedAt;
    }

    public String getAuditStatus() {
        return auditStatus;
    }

    public void setAuditStatus(String auditStatus) {
        this.auditStatus = auditStatus;
    }

    public String getAuditMessage() {
        return auditMessage;
    }

    public void setAuditMessage(String auditMessage) {
        this.auditMessage = auditMessage;
    }
}
