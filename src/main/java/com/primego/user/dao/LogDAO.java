package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import com.primego.user.model.SystemLog;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LogDAO {

    public LogDAO() {
        createTableIfNotExists();
    }

    private void createTableIfNotExists() {
        String sql = "CREATE TABLE IF NOT EXISTS system_logs (" +
                "id INT AUTO_INCREMENT PRIMARY KEY, " +
                "level VARCHAR(20) NOT NULL, " +
                "message TEXT NOT NULL, " +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")";
        try (Connection conn = DBUtil.getConnection();
                Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void addLog(String level, String message) {
        String sql = "INSERT INTO system_logs (level, message) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, level);
            stmt.setString(2, message);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<SystemLog> getRecentLogs(int limit) {
        List<SystemLog> logs = new ArrayList<>();
        String sql = "SELECT * FROM system_logs ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    SystemLog log = new SystemLog();
                    log.setId(rs.getInt("id"));
                    log.setLevel(rs.getString("level"));
                    log.setMessage(rs.getString("message"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}
