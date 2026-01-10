package com.primego.order.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class Cart {
    private List<CartItem> items;

    public Cart() {
        this.items = new ArrayList<>();
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public void addItem(CartItem item) {
        // If the product already exists in the cart, merge quantities.
        for (CartItem existingItem : items) {
            if (existingItem.getProduct().getProductId() == item.getProduct().getProductId()) {
                int newQuantity = existingItem.getQuantity() + item.getQuantity();

                // Stock validation: cap the quantity at the product's available stock.
                int maxStock = existingItem.getProduct().getProductStockQuantity();
                if (newQuantity > maxStock) {
                    newQuantity = maxStock;
                }

                existingItem.setQuantity(newQuantity);
                return;
            }
        }

        // Stock validation for new items: ensure the initial quantity does not exceed stock.
        int maxStock = item.getProduct().getProductStockQuantity();
        if (item.getQuantity() > maxStock) {
            item.setQuantity(maxStock);
        }

        items.add(item);
    }

    public void removeItem(int productId) {
        items.removeIf(item -> item.getProduct().getProductId() == productId);
    }

    public void updateQuantity(int productId, int quantity) {
        for (CartItem item : items) {
            if (item.getProduct().getProductId() == productId) {
                // Stock validation: cap the updated quantity at the product's available stock.
                int maxStock = item.getProduct().getProductStockQuantity();
                if (quantity > maxStock) {
                    quantity = maxStock;
                }

                item.setQuantity(quantity);
                return;
            }
        }
    }

    public BigDecimal getTotalPrice() {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            total = total.add(item.getTotalPrice());
        }
        return total;
    }

    public int getItemCount() {
        return items.size();
    }

    public void clear() {
        items.clear();
    }
}