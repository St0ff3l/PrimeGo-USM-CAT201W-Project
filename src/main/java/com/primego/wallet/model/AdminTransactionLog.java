package com.primego.wallet.model;

import java.sql.Timestamp;

public class AdminTransactionLog {
    // Unique identifier for the log entry
    private int id;

    // The ID of the administrator who performed the action
    private int adminId;

    // The ID of the specific wallet transaction being modified
    private int walletTransactionId;

    // The type of action performed (e.g., "APPROVE", "REJECT", "MODIFY")
    private String actionType;

    // The transaction status before the action was taken
    private String previousStatus;

    // The transaction status after the action was completed
    private String currentStatus;

    // Optional remarks or notes provided by the administrator
    private String remarks;

    // Timestamp when the action was recorded
    private Timestamp createdAt;

    // Additional fields for display purposes (populated via joins)
    private String adminName;

    // Getters and Setters

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public int getWalletTransactionId() { return walletTransactionId; }
    public void setWalletTransactionId(int walletTransactionId) { this.walletTransactionId = walletTransactionId; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public String getPreviousStatus() { return previousStatus; }
    public void setPreviousStatus(String previousStatus) { this.previousStatus = previousStatus; }

    public String getCurrentStatus() { return currentStatus; }
    public void setCurrentStatus(String currentStatus) { this.currentStatus = currentStatus; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getAdminName() { return adminName; }
    public void setAdminName(String adminName) { this.adminName = adminName; }
}
