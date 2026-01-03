package com.primego.user.model;

public class CustomerProfile {
    private int userId;
    private String fullName;
    private String email;
    private String phone;
    private String address;

    private String paymentPin;

    public CustomerProfile() {
    }

    public CustomerProfile(int userId, String fullName, String email, String phone, String address, String paymentPin) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
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

    // Helper to get Area Code (assuming format "+AreaCode PhoneNumber" or just
    // "PhoneNumber")
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

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    // Address Format: Street||Unit||City||State||Zip||Country
    private String[] getAddressParts() {
        if (address == null)
            return new String[] { "", "", "", "", "", "" };
        String[] parts = address.split("\\|\\|");
        if (parts.length < 6) {
            // Pad with empty strings if incomplete
            String[] padded = new String[6];
            System.arraycopy(parts, 0, padded, 0, parts.length);
            for (int i = parts.length; i < 6; i++)
                padded[i] = "";
            return padded;
        }
        return parts;
    }

    public String getStreet() {
        return getAddressParts()[0];
    }

    public String getUnit() {
        return getAddressParts()[1];
    }

    public String getCity() {
        return getAddressParts()[2];
    }

    public String getState() {
        return getAddressParts()[3];
    }

    public String getZip() {
        return getAddressParts()[4];
    }

    public String getCountry() {
        return getAddressParts()[5];
    }

    // Helper for display
    public String getFormattedAddress() {
        if (address == null || address.isEmpty())
            return "No address set";
        String[] parts = getAddressParts();
        StringBuilder sb = new StringBuilder();
        if (!parts[0].isEmpty())
            sb.append(parts[0]);
        if (!parts[1].isEmpty())
            sb.append(", ").append(parts[1]);
        if (!parts[2].isEmpty())
            sb.append("\n").append(parts[2]);
        if (!parts[3].isEmpty())
            sb.append(", ").append(parts[3]);
        if (!parts[4].isEmpty())
            sb.append(" ").append(parts[4]);
        if (!parts[5].isEmpty())
            sb.append("\n").append(parts[5]);
        return sb.toString();
    }
}
