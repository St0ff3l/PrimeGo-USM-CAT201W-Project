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
    private Timestamp completedAt;
    private String refundReason;
    private int rejectionCount;
    private String merchantRejectReason;

    // After-sales sub-status (PENDING, REJECTED, APPROVED)
    private String refundStatus;

    // Refund type (MONEY_ONLY / RETURN_AND_REFUND)
    private String refundType;

    // Shipment tracking number (maps to the database field "Tracking_Number")
    private String trackingNumber;

    // Return-and-refund details: merchant return address and buyer return tracking number
    private String returnAddress;
    private String returnTrackingNumber;

    // Order items included in this order
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
    public Timestamp getCompletedAt() { return completedAt; }
    public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
    public String getRefundReason() { return refundReason; }
    public void setRefundReason(String refundReason) { this.refundReason = refundReason; }
    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }
    public List<OrderItem> getOrderItems() { return orderItems; }
    public void setOrderItems(List<OrderItem> orderItems) { this.orderItems = orderItems; }
    public int getRejectionCount() { return rejectionCount; }
    public void setRejectionCount(int rejectionCount) { this.rejectionCount = rejectionCount; }
    public String getMerchantRejectReason() { return merchantRejectReason; }
    public void setMerchantRejectReason(String merchantRejectReason) { this.merchantRejectReason = merchantRejectReason; }

    public String getRefundStatus() { return refundStatus; }
    public void setRefundStatus(String refundStatus) { this.refundStatus = refundStatus; }

    public String getRefundType() { return refundType; }
    public void setRefundType(String refundType) { this.refundType = refundType; }

    public String getReturnAddress() { return returnAddress; }
    public void setReturnAddress(String returnAddress) { this.returnAddress = returnAddress; }

    public String getReturnTrackingNumber() { return returnTrackingNumber; }
    public void setReturnTrackingNumber(String returnTrackingNumber) { this.returnTrackingNumber = returnTrackingNumber; }
}
