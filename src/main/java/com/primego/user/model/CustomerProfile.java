package com.primego.user.model;

public class CustomerProfile {
    private int userId;
    private String fullName;
    private String email;
    private String phone;
    private UserAddress defaultAddress;
    private String paymentPin;

    public CustomerProfile() {
    }

    public CustomerProfile(int userId, String fullName, String email, String phone, UserAddress defaultAddress,
            String paymentPin) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.defaultAddress = defaultAddress;
        this.paymentPin = paymentPin;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPaymentPin() {
        return paymentPin;
    }

    public void setPaymentPin(String paymentPin) {
        this.paymentPin = paymentPin;
    }

    public UserAddress getDefaultAddress() {
        return defaultAddress;
    }

    public void setDefaultAddress(UserAddress defaultAddress) {
        this.defaultAddress = defaultAddress;
    }

    // Helper to get First Name (everything before the last space)
    public String getFirstName() {
        if (fullName == null || fullName.isEmpty())
            return "";
        int lastSpace = fullName.lastIndexOf(' ');
        if (lastSpace == -1)
            return fullName;
        return fullName.substring(0, lastSpace);
    }

    // Helper to get Last Name (everything after the last space)
    public String getLastName() {
        if (fullName == null || fullName.isEmpty())
            return "";
        int lastSpace = fullName.lastIndexOf(' ');
        if (lastSpace == -1)
            return "";
        return fullName.substring(lastSpace + 1);
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    // Helper to get Area Code
    public String getPhoneAreaCode() {
        if (phone == null || !phone.contains(" "))
            return "";
        return phone.split(" ")[0];
    }

    public String getPhoneNumberOnly() {
        if (phone == null)
            return "";
        if (!phone.contains(" "))
            return phone;
        return phone.substring(phone.indexOf(" ") + 1);
    }

    // DELEGATION METHODS FOR BACKWARD COMPATIBILITY
    // Accessing fields from defaultAddress

    public String getStreet() {
        return defaultAddress != null ? (defaultAddress.getDetail() != null ? defaultAddress.getDetail() : "") : "";
    }

    public String getUnit() {
        // District can be used as generic "extra" or just return empty if mapped
        // differently.
        // Creating mapping: Detail -> Street, District -> Unit (optional mapping)
        return defaultAddress != null ? (defaultAddress.getDistrict() != null ? defaultAddress.getDistrict() : "") : "";
    }

    public String getCity() {
        return defaultAddress != null ? (defaultAddress.getCity() != null ? defaultAddress.getCity() : "") : "";
    }

    public String getState() {
        // Mapping Province -> State
        return defaultAddress != null ? (defaultAddress.getProvince() != null ? defaultAddress.getProvince() : "") : "";
    }

    public String getZip() {
        return ""; // Zip is not explicitly in new schema user_addresses (only
                   // province/city/district/detail).
                   // If requested schema didn't have zip, we return empty or need to add it.
                   // Based on user request: `province`, `city`, `district`, `detail`. No zip
                   // column.
    }

    public String getCountry() {
        return "Malaysia"; // Default or not in schema. Schema has no country column.
    }

    // Helper for display
    public String getFormattedAddress() {
        if (defaultAddress == null)
            return "No address set";
        return defaultAddress.getFullAddress();
    }
}
