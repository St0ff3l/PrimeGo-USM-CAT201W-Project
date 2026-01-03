package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.user.model.UserAddress;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AddressDAO {

    public boolean addAddress(UserAddress address) {
        String sql = "INSERT INTO user_addresses (user_id, recipient_name, phone, province, city, district, detail, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            // If this is the first address, make it default automatically
            boolean isFirst = getAddressesByUserId(address.getUserId()).isEmpty();
            boolean isDefault = address.isDefaultAddress() || isFirst;

            if (isDefault) {
                // Determine if we need to unset other defaults strictly, but for insertion
                // logic usually handled later or by user choice
                // However, we can simply unset others first if this one is default
                resetDefaultAddress(address.getUserId(), conn);
            }

            stmt.setInt(1, address.getUserId());
            stmt.setString(2, address.getRecipientName());
            stmt.setString(3, address.getPhone());
            stmt.setString(4, address.getProvince());
            stmt.setString(5, address.getCity());
            stmt.setString(6, address.getDistrict());
            stmt.setString(7, address.getDetail());
            stmt.setBoolean(8, isDefault); // Use calculated default status

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<UserAddress> getAddressesByUserId(int userId) {
        List<UserAddress> addresses = new ArrayList<>();
        String sql = "SELECT * FROM user_addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC";

        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    addresses.add(mapResultSetToAddress(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return addresses;
    }

    public UserAddress getAddressById(int addressId) {
        String sql = "SELECT * FROM user_addresses WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, addressId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAddress(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateAddress(UserAddress address) {
        String sql = "UPDATE user_addresses SET recipient_name=?, phone=?, province=?, city=?, district=?, detail=?, is_default=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (address.isDefaultAddress()) {
                resetDefaultAddress(address.getUserId(), conn);
            }

            stmt.setString(1, address.getRecipientName());
            stmt.setString(2, address.getPhone());
            stmt.setString(3, address.getProvince());
            stmt.setString(4, address.getCity());
            stmt.setString(5, address.getDistrict());
            stmt.setString(6, address.getDetail());
            stmt.setBoolean(7, address.isDefaultAddress());
            stmt.setInt(8, address.getId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAddress(int addressId) {
        String sql = "DELETE FROM user_addresses WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, addressId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean setDefaultAddress(int userId, int addressId) {
        // Transaction needed to ensure atomicity
        String resetSql = "UPDATE user_addresses SET is_default = 0 WHERE user_id = ?";
        String setSql = "UPDATE user_addresses SET is_default = 1 WHERE id = ? AND user_id = ?";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement resetStmt = conn.prepareStatement(resetSql);
                    PreparedStatement setStmt = conn.prepareStatement(setSql)) {

                resetStmt.setInt(1, userId);
                resetStmt.executeUpdate();

                setStmt.setInt(1, addressId);
                setStmt.setInt(2, userId);
                int rows = setStmt.executeUpdate();

                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper to fetch default address directly
    public UserAddress getDefaultAddress(int userId) {
        String sql = "SELECT * FROM user_addresses WHERE user_id = ? AND is_default = 1";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToAddress(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // or return first available if strictly required
    }

    private void resetDefaultAddress(int userId, Connection conn) throws SQLException {
        String sql = "UPDATE user_addresses SET is_default = 0 WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }

    private UserAddress mapResultSetToAddress(ResultSet rs) throws SQLException {
        return new UserAddress(
                rs.getInt("id"),
                rs.getInt("user_id"),
                rs.getString("recipient_name"),
                rs.getString("phone"),
                rs.getString("province"),
                rs.getString("city"),
                rs.getString("district"),
                rs.getString("detail"),
                rs.getBoolean("is_default"));
    }
}
