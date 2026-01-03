package com.primego.product.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class ProductDTO extends Product {
    private String categoryName;
    private String primaryImageUrl;

    public ProductDTO() {
        super();
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
