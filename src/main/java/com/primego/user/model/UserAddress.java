package com.primego.user.model;

import java.sql.Timestamp;

/**
 * Represents a user's shipping address.
 * Includes recipient details and full location hierarchy.
 */
public class UserAddress {
    private int id;
    private int userId;
    private String recipientName;
    private String phone;
    private String province;
    private String city;
    private String district;
    private String detail;
    private boolean isDefaultAddress;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public UserAddress() {
    }

    /**
     * Constructs a new UserAddress.
     *
     * @param id               The address ID.
     * @param userId           The ID of the user owning this address.
     * @param recipientName    The name of the recipient.
     * @param phone            The contact phone number.
     * @param province         The state/province.
     * @param city             The city/municipality.
     * @param district         The district/area.
     * @param detail           The detailed address (street, unit, etc.).
     * @param isDefaultAddress Whether this is the default address.
     */
    public UserAddress(int id, int userId, String recipientName, String phone, String province, String city,
            String district, String detail, boolean isDefaultAddress) {
        this.id = id;
        this.userId = userId;
        this.recipientName = recipientName;
        this.phone = phone;
        this.province = province;
        this.city = city;
        this.district = district;
        this.detail = detail;
        this.isDefaultAddress = isDefaultAddress;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

    public boolean isDefaultAddress() {
        return isDefaultAddress;
    }

    public void setDefaultAddress(boolean isDefaultAddress) {
        this.isDefaultAddress = isDefaultAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    /**
     * Combines address components into a single formatted string.
     *
     * @return The full address string (Detail, District, City, Province).
     */
    public String getFullAddress() {
        StringBuilder sb = new StringBuilder();
        if (detail != null)
            sb.append(detail).append(", ");
        if (district != null && !district.isEmpty())
            sb.append(district).append(", ");
        if (city != null)
            sb.append(city).append(", ");
        if (province != null)
            sb.append(province);
        return sb.toString();
    }
}
