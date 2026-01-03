package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.user.model.AdminProfile;
import com.primego.user.model.CustomerProfile;
import com.primego.user.model.MerchantProfile;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ProfileDAO {

    private AddressDAO addressDAO = new AddressDAO();

    public CustomerProfile getCustomerProfile(int userId) {
        String sql = "SELECT * FROM customer_profiles WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("user_id");
                    return new CustomerProfile(
                            id,
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            addressDAO.getDefaultAddress(id),
                            rs.getString("payment_pin"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateCustomerProfile(CustomerProfile profile) {
        String sql = "UPDATE customer_profiles SET full_name = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, profile.getFullName());
            stmt.setString(2, profile.getPhone());
            stmt.setInt(3, profile.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePaymentPin(int userId, String hashedPin) {
        String sql = "UPDATE customer_profiles SET payment_pin = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPin);
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public MerchantProfile getMerchantProfile(int userId) {
        String sql = "SELECT * FROM merchant_profiles WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new MerchantProfile(
                            rs.getInt("user_id"),
                            rs.getString("store_name"),
                            rs.getString("business_license"),
                            rs.getString("contact_info"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public AdminProfile getAdminProfile(int userId) {
        String sql = "SELECT * FROM admin_profiles WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new AdminProfile(
                            rs.getInt("user_id"),
                            rs.getString("department"),
                            rs.getInt("level"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateAdminProfile(AdminProfile profile) {
        String sql = "UPDATE admin_profiles SET department = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, profile.getDepartment());
            stmt.setInt(2, profile.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
