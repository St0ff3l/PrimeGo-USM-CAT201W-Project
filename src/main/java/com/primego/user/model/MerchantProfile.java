package com.primego.user.model;

/**
 * Represents the profile of a merchant.
 */
public class MerchantProfile {
    private int userId;
    private String storeName;
    private String businessLicense;
    private String contactInfo;

    public MerchantProfile() {
    }

    /**
     * Constructs a new MerchantProfile.
     *
     * @param userId          The associated user ID.
     * @param storeName       The name of the store.
     * @param businessLicense The business license number.
     * @param contactInfo     The contact information for the store.
     */
    public MerchantProfile(int userId, String storeName, String businessLicense, String contactInfo) {
        this.userId = userId;
        this.storeName = storeName;
        this.businessLicense = businessLicense;
        this.contactInfo = contactInfo;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

    public String getBusinessLicense() {
        return businessLicense;
    }

    public void setBusinessLicense(String businessLicense) {
        this.businessLicense = businessLicense;
    }

    public String getContactInfo() {
        return contactInfo;
    }

    public void setContactInfo(String contactInfo) {
        this.contactInfo = contactInfo;
    }
}
