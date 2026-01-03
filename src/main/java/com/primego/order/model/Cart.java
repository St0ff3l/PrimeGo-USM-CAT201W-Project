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
        // Check if item already exists
        for (CartItem existingItem : items) {
            if (existingItem.getProduct().getProductId() == item.getProduct().getProductId()) {
                existingItem.setQuantity(existingItem.getQuantity() + item.getQuantity());
                return;
            }
        }
        items.add(item);
    }

    public void removeItem(int productId) {
        items.removeIf(item -> item.getProduct().getProductId() == productId);
    }

    public void updateQuantity(int productId, int quantity) {
        for (CartItem item : items) {
            if (item.getProduct().getProductId() == productId) {
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
