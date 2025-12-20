package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.common.util.PasswordUtil;
import com.primego.user.model.Role;
import com.primego.user.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class UserDAO {

    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            System.out.println("[DEBUG] Executing query: " + sql + " with username: " + username);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(Role.valueOf(rs.getString("role")));
                    user.setStatus(rs.getInt("status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setUpdatedAt(rs.getTimestamp("updated_at"));
                    
                    System.out.println("[DEBUG] User found: " + user.getUsername());
                    System.out.println("[DEBUG] Stored Hash: " + user.getPassword());
                    return user;
                } else {
                    System.out.println("[DEBUG] No user found with username: " + username);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

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

    public boolean createUser(User user, String email) {
        String insertUserSql = "INSERT INTO users (username, password, role, status) VALUES (?, ?, ?, ?)";
        String insertProfileSql = "INSERT INTO customer_profiles (user_id, email, full_name, phone, address) VALUES (?, ?, ?, '', '')";
        
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

            // 2. Insert into customer_profiles table (assuming default role is CUSTOMER for now)
            if (user.getRole() == Role.CUSTOMER) {
                try (PreparedStatement stmt = conn.prepareStatement(insertProfileSql)) {
                    stmt.setInt(1, userId);
                    stmt.setString(2, email);
                    stmt.setString(3, user.getUsername()); // Default full name to username
                    stmt.executeUpdate();
                }
            }

            conn.commit(); // Commit transaction
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            DBUtil.close(conn);
        }
    }
}
