package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.common.util.PasswordUtil;
import com.primego.user.model.Role;
import com.primego.user.model.MerchantProfile;

import com.primego.user.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    /**
     * Finds a user by their username.
     *
     * @param username The username to search for.
     * @return The User object if found, null otherwise.
     */
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            System.out.println("[DEBUG] Executing query: " + sql + " with username: " + username);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                } else {
                    System.out.println("[DEBUG] No user found with username: " + username);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Validates user credentials.
     *
     * @param username The username.
     * @param password The raw password.
     * @return The User object if credentials are valid, null otherwise.
     */
    public User validateCredentials(String username, String password) {
        System.out.println("[DEBUG] Validating credentials for: " + username);
        User user = findByUsername(username);
        if (user != null) {
            boolean passwordMatch = PasswordUtil.checkPassword(password, user.getPassword());
            System.out.println("[DEBUG] Password match result: " + passwordMatch);
            if (passwordMatch) {
                return user;
            }
        }
        return null;
    }

    /**
     * Creates a new user with the specified role (currently defaults to CUSTOMER
     * logic in profile creation).
     *
     * @param user  The user object containing username, password, role, etc.
     * @param email The email address for the customer profile.
     * @throws SQLException If a database error occurs.
     */
    public void createUser(User user, String email) throws SQLException {
        String insertUserSql = "INSERT INTO users (username, password, role, status) VALUES (?, ?, ?, ?)";
        String insertProfileSql = "INSERT INTO customer_profiles (user_id, email, full_name, phone) VALUES (?, ?, ?, '')";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into users table
            int userId = -1;
            try (PreparedStatement stmt = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, user.getUsername());
                stmt.setString(2, PasswordUtil.hashPassword(user.getPassword())); // Hash password before saving
                stmt.setString(3, user.getRole().toString());
                stmt.setInt(4, user.getStatus());

                int affectedRows = stmt.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating user failed, no rows affected.");
                }

                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("Creating user failed, no ID obtained.");
                    }
                }
            }

            // 2. Insert into customer_profiles table (assuming default role is CUSTOMER for
            // now)
            if (user.getRole() == Role.CUSTOMER) {
                try (PreparedStatement stmt = conn.prepareStatement(insertProfileSql)) {
                    stmt.setInt(1, userId);
                    stmt.setString(2, email);
                    stmt.setString(3, user.getUsername()); // Default full name to username
                    stmt.executeUpdate();
                }
            }

            conn.commit(); // Commit transaction

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e; // Rethrow exception to be handled by caller
        } finally {
            DBUtil.close(conn);
        }
    }

    /**
     * Creates a new merchant user and their associated merchant profile.
     *
     * @param user    The user object.
     * @param profile The merchant profile details.
     * @throws SQLException If a database error occurs.
     */
    public void createMerchant(User user, MerchantProfile profile) throws SQLException {
        String insertUserSql = "INSERT INTO users (username, password, role, status) VALUES (?, ?, ?, ?)";
        String insertMerchantSql = "INSERT INTO merchant_profiles (user_id, store_name, contact_info) VALUES (?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into users table
            int userId = -1;
            try (PreparedStatement stmt = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setString(1, user.getUsername());
                stmt.setString(2, PasswordUtil.hashPassword(user.getPassword()));
                stmt.setString(3, Role.MERCHANT.toString());
                stmt.setInt(4, user.getStatus());

                int affectedRows = stmt.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating merchant user failed, no rows affected.");
                }

                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    } else {
                        throw new SQLException("Creating merchant user failed, no ID obtained.");
                    }
                }
            }

            // 2. Insert into merchant_profiles table
            try (PreparedStatement stmt = conn.prepareStatement(insertMerchantSql)) {
                stmt.setInt(1, userId);
                stmt.setString(2, profile.getStoreName());
                stmt.setString(3, profile.getContactInfo());
                stmt.executeUpdate();
            }

            conn.commit();

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            DBUtil.close(conn);
        }
    }

    /**
     * Retrieves all users from the database.
     *
     * @return A list of all User objects.
     */
    public List<User> findAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id DESC";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setRole(Role.valueOf(rs.getString("role")));
        user.setStatus(rs.getInt("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    /**
     * Updates a user's password.
     *
     * @param userId      The ID of the user.
     * @param newPassword The new raw password (will be hashed).
     * @return true if the update was successful, false otherwise.
     */
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, PasswordUtil.hashPassword(newPassword));
            stmt.setInt(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Updates a user's username.
     *
     * @param userId      The ID of the user.
     * @param newUsername The new username.
     * @return true if the update was successful, false otherwise.
     */
    public boolean updateUsername(int userId, String newUsername) {
        String sql = "UPDATE users SET username = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newUsername);
            stmt.setInt(2, userId);

            // Note: In a real app we should check for duplicate username exception here
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false; // Likely duplicate entry
        }
    }

    /**
     * Counts the total number of users.
     *
     * @return The total count of users.
     */
    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Counts the number of users with a specific role.
     *
     * @param role The role to filter by.
     * @return The count of users with the specified role.
     */
    public int countUsersByRole(Role role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role.toString());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
