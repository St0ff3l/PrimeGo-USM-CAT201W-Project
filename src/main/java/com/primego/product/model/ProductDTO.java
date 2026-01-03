package com.primego.product.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductDTO extends Product {
    private String categoryName;
    private String primaryImageUrl;
    private String merchantName; // 新增：用于存储关联查询到的卖家用户名

    public ProductDTO() {
        super();
    }

    // 新增 MerchantName 的 Getter 和 Setter
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