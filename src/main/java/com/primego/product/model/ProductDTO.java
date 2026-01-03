package com.primego.product.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductDTO extends Product {
    private String categoryName;
    private String primaryImageUrl;
    private String merchantName; // 新增：用于存储关联查询到的卖家用户名

    // ⭐ 新增：库存数量字段，对应数据库的 Product_Stock_Quantity
    private int productStockQuantity;

    public ProductDTO() {
        super();
    }

    // ⭐ 新增：库存字段的 Getter 和 Setter
    public int getProductStockQuantity() {
        return productStockQuantity;
    }

    public void setProductStockQuantity(int productStockQuantity) {
        this.productStockQuantity = productStockQuantity;
    }

    // 原有的 Getter 和 Setter
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