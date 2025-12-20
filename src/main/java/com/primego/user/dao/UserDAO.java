package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.common.util.PasswordUtil;
import com.primego.user.model.Role;
import com.primego.user.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
}
