package com.primego.wallet.model;

import java.sql.Timestamp;

public class AdminTransactionLog {
    private int id;
    private int adminId;
    private int walletTransactionId;
    private String actionType;
    private String previousStatus;
    private String currentStatus;
    private String remarks;
    private Timestamp createdAt;
    
    // Additional fields for display (joined data)
    private String adminName;

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
