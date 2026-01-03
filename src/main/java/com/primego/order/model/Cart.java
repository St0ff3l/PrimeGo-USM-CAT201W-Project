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
                int newQuantity = existingItem.getQuantity() + item.getQuantity();

                // ⭐ 库存校验：如果超过库存，强制设为最大库存
                int maxStock = existingItem.getProduct().getProductStockQuantity();
                if (newQuantity > maxStock) {
                    newQuantity = maxStock;
                }

                existingItem.setQuantity(newQuantity);
                return;
            }
        }

        // ⭐ 新增项校验：确保初始数量不超过库存
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
                // ⭐ 库存校验：如果更新数量超过库存，限制为最大库存
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