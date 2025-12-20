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

    public CustomerProfile getCustomerProfile(int userId) {
        String sql = "SELECT * FROM customer_profiles WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new CustomerProfile(
                        rs.getInt("user_id"),
                        rs.getString("full_name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("address")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
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
                        rs.getString("contact_info")
                    );
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
                        rs.getInt("level")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
