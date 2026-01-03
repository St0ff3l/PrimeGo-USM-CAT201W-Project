package com.primego.order.model;

import com.primego.product.model.ProductDTO;
import java.math.BigDecimal;

public class CartItem {
    private ProductDTO product;
    private int quantity;

    public CartItem() {}

    public CartItem(ProductDTO product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    public ProductDTO getProduct() {
        return product;
    }

    public void setProduct(ProductDTO product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getTotalPrice() {
        if (product != null && product.getProductPrice() != null) {
            return product.getProductPrice().multiply(new BigDecimal(quantity));
        }
        return BigDecimal.ZERO;
    }
}
