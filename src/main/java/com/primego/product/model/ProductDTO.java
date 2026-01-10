package com.primego.product.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductDTO extends Product {
    private String categoryName;
    private String primaryImageUrl;
    // Merchant username retrieved from a joined query.
    private String merchantName;

    // Inventory quantity (maps to database column Product_Stock_Quantity).
    private int productStockQuantity;

    // Indicates whether this product has ever been approved.
    // true: an update request for an existing product
    // false: a new product listing
    private boolean hasBeenApproved;

    public ProductDTO() {
        super();
    }

    // Getter and setter for approval status.
    public boolean isHasBeenApproved() {
        return hasBeenApproved;
    }

    public void setHasBeenApproved(boolean hasBeenApproved) {
        this.hasBeenApproved = hasBeenApproved;
    }

    // Getter and setter for inventory quantity.
    public int getProductStockQuantity() {
        return productStockQuantity;
    }

    public void setProductStockQuantity(int productStockQuantity) {
        this.productStockQuantity = productStockQuantity;
    }

    // Existing getters and setters.
    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getPrimaryImageUrl() {
        return primaryImageUrl;
    }

    public void setPrimaryImageUrl(String primaryImageUrl) {
        this.primaryImageUrl = primaryImageUrl;
    }
}