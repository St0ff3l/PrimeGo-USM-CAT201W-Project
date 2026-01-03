package com.primego.wallet.dao;

import com.primego.wallet.model.WalletTransaction;
import com.primego.common.util.DBUtil;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class WalletDAO {

    // 辅助方法：获取连接
    protected Connection getConnection() {
        try {
            return DBUtil.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 1. 保存充值请求
    public boolean requestTopUp(WalletTransaction transaction) {
        String sql = "INSERT INTO wallet_transactions (user_id, amount, status, receipt_image, transaction_type) VALUES (?, ?, ?, ?, 'TOPUP')";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transaction.getUserId());
            statement.setBigDecimal(2, transaction.getAmount());
            statement.setString(3, transaction.getStatus());
            statement.setString(4, transaction.getReceiptImage());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 2. 保存提现请求
    public boolean requestWithdraw(WalletTransaction transaction) {
        String sql = "INSERT INTO wallet_transactions (user_id, amount, status, transaction_type) VALUES (?, ?, ?, 'WITHDRAW')";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transaction.getUserId());
            statement.setBigDecimal(2, transaction.getAmount());
            statement.setString(3, transaction.getStatus());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==========================================
    // ⭐ 修改点 1：更新余额计算公式，加入 PURCHASE (消费)
    // ==========================================
    public BigDecimal getBalance(int userId) {
        // 逻辑：余额 = (充值总额) - (提现总额 + 消费总额)
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type = 'TOPUP' THEN amount ELSE 0 END) - " +
                " SUM(CASE WHEN transaction_type IN ('WITHDRAW', 'PURCHASE') THEN amount ELSE 0 END)) as balance " +
                "FROM wallet_transactions WHERE user_id = ? AND status = 'APPROVED'";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            if (connection == null) return BigDecimal.ZERO;
            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    BigDecimal balance = rs.getBigDecimal("balance");
                    return balance != null ? balance : BigDecimal.ZERO;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    // 辅助方法：给事务内部使用（根据 Connection 查询余额）
    public BigDecimal getBalance(Connection conn, int userId) throws SQLException {
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type = 'TOPUP' THEN amount ELSE 0 END) - " +
                " SUM(CASE WHEN transaction_type IN ('WITHDRAW', 'PURCHASE') THEN amount ELSE 0 END)) as balance " +
                "FROM wallet_transactions WHERE user_id = ? AND status = 'APPROVED'";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BigDecimal balance = rs.getBigDecimal("balance");
                    return balance != null ? balance : BigDecimal.ZERO;
                }
            }
        }
        return BigDecimal.ZERO;
    }

    // ==========================================
    // ⭐ 修改点 2：新增支付方法 (供 OrderDAO 调用)
    // ==========================================
    public void payOrder(Connection conn, int userId, BigDecimal orderAmount) throws SQLException {
        // 1. 检查余额
        BigDecimal currentBalance = getBalance(conn, userId);
        if (currentBalance.compareTo(orderAmount) < 0) {
            throw new SQLException("Insufficient wallet balance. Current: " + currentBalance + ", Required: " + orderAmount);
        }

        // 2. 插入消费记录 (PURCHASE)
        String sql = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'PURCHASE', 'APPROVED')";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setBigDecimal(2, orderAmount); // 这里存正数，余额计算公式里会减去它

            int rows = pstmt.executeUpdate();
            if (rows == 0) {
                throw new SQLException("Failed to record wallet transaction.");
            }
        }
    }

    // 4. 获取待审核列表
    public List<WalletTransaction> getPendingTransactions() {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM wallet_transactions WHERE status = 'PENDING' ORDER BY created_at ASC";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                WalletTransaction t = new WalletTransaction();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setTransactionType(rs.getString("transaction_type"));
                t.setStatus(rs.getString("status"));
                t.setReceiptImage(rs.getString("receipt_image"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. 更新状态
    public boolean updateTransactionStatus(int transactionId, String newStatus) {
        String sql = "UPDATE wallet_transactions SET status = ? WHERE id = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, newStatus);
            statement.setInt(2, transactionId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ==========================================
    // ⭐ 【新增】获取某个用户的所有交易记录 (修复 500 错误)
    // ==========================================
    public List<WalletTransaction> getUserTransactions(int userId) {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM wallet_transactions WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            if (connection == null) return list;

            statement.setInt(1, userId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    WalletTransaction t = new WalletTransaction();
                    t.setId(rs.getInt("id"));
                    t.setUserId(rs.getInt("user_id"));
                    t.setAmount(rs.getBigDecimal("amount"));
                    t.setTransactionType(rs.getString("transaction_type"));
                    t.setStatus(rs.getString("status"));
                    t.setReceiptImage(rs.getString("receipt_image"));
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
