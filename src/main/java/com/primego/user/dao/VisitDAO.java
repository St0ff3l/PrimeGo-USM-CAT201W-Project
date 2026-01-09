package com.primego.user.dao;

import com.primego.common.util.DBUtil;
import java.sql.*;
import java.time.LocalDate;

public class VisitDAO {

    public VisitDAO() {
        createTableIfNotExists();
    }

    private void createTableIfNotExists() {
        String sql = "CREATE TABLE IF NOT EXISTS daily_visits (" +
                "visit_date DATE PRIMARY KEY, " +
                "visit_count INT DEFAULT 0" +
                ")";
        try (Connection conn = DBUtil.getConnection();
                Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void incrementVisit() {
        // MySQL-specific syntax for upsert
        String sql = "INSERT INTO daily_visits (visit_date, visit_count) VALUES (?, 1) " +
                "ON DUPLICATE KEY UPDATE visit_count = visit_count + 1";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, Date.valueOf(LocalDate.now()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getTodayVisits() {
        String sql = "SELECT visit_count FROM daily_visits WHERE visit_date = ?";
        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, Date.valueOf(LocalDate.now()));
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

    public java.util.Map<LocalDate, Integer> getLast7DaysVisits() {
        java.util.Map<LocalDate, Integer> visitsMap = new java.util.HashMap<>();

        // 1. Get raw data from DB
        LocalDate sevenDaysAgo = LocalDate.now().minusDays(6);
        String sql = "SELECT visit_date, visit_count FROM daily_visits WHERE visit_date >= ?";

        try (Connection conn = DBUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, Date.valueOf(sevenDaysAgo));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    visitsMap.put(rs.getDate("visit_date").toLocalDate(), rs.getInt("visit_count"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // 2. Fill in missing days with 0 and sort
        java.util.Map<LocalDate, Integer> result = new java.util.TreeMap<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = sevenDaysAgo.plusDays(i);
            result.put(date, visitsMap.getOrDefault(date, 0));
        }
        return result;
    }
}
