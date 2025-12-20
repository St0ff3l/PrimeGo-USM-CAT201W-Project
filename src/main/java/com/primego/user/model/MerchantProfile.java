package com.primego.user.model;

public class MerchantProfile {
    private int userId;
    private String storeName;
    private String businessLicense;
    private String contactInfo;

    public MerchantProfile() {}

    public MerchantProfile(int userId, String storeName, String businessLicense, String contactInfo) {
        this.userId = userId;
        this.storeName = storeName;
        this.businessLicense = businessLicense;
        this.contactInfo = contactInfo;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getStoreName() { return storeName; }
    public void setStoreName(String storeName) { this.storeName = storeName; }

    public String getBusinessLicense() { return businessLicense; }
    public void setBusinessLicense(String businessLicense) { this.businessLicense = businessLicense; }

    public String getContactInfo() { return contactInfo; }
    public void setContactInfo(String contactInfo) { this.contactInfo = contactInfo; }
}
