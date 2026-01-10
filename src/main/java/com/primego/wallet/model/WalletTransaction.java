package com.primego.wallet.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class WalletTransaction {
    private int id;
    private int userId;
    private BigDecimal amount;
    private String status;          // e.g., "PENDING", "APPROVED", "REJECTED"
    private String transactionType; // e.g., "TOPUP", "WITHDRAW"
    private String receiptImage;    // Only present for top-ups; null for withdrawals
    private Timestamp createdAt;
    private String remarks;         // Administrator remarks

    // Default constructor
    public WalletTransaction() {}

    // Constructor for Top-Up requests
    public WalletTransaction(int userId, BigDecimal amount, String receiptImage) {
        this.userId = userId;
        this.amount = amount;
        this.receiptImage = receiptImage;
        this.status = "PENDING";
        this.transactionType = "TOPUP";
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }

    public String getReceiptImage() { return receiptImage; }
    public void setReceiptImage(String receiptImage) { this.receiptImage = receiptImage; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
}
