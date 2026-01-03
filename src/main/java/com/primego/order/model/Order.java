package com.primego.order.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class Order {
    private int ordersId;
    private int customerId;
    private BigDecimal totalAmount;
    private String orderStatus;    // PENDING, PAID, SHIPPED...
    private String paymentStatus;  // UNPAID, PAID
    private String address;
    private Timestamp createdAt;

    // 包含订单项列表
    private List<OrderItem> orderItems;

    // Getters and Setters
    public int getOrdersId() { return ordersId; }
    public void setOrdersId(int ordersId) { this.ordersId = ordersId; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }
}