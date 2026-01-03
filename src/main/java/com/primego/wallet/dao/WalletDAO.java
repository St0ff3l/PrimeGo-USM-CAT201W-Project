package com.primego.wallet.dao;

import com.primego.wallet.model.WalletTransaction;
import com.primego.common.util.DBUtil; // 确认这个 import 是对的
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class WalletDAO {

    /**
     * 获取数据库连接
     * 修复点：移除了 try-catch，因为 DBUtil 可能内部处理了异常，或者没有抛出 Checked Exception
     * 如果 DBUtil 确实抛出 SQLException，编译器会提示你加回来，到时候再加
     */
    protected Connection getConnection() {
        try {
            return DBUtil.getConnection();
        } catch (Exception e) { // 使用 Exception 捕获所有可能的异常，最保险
            e.printStackTrace();
            System.err.println("WalletDAO: 数据库连接失败");
            return null;
        }
    }

    // 1. 保存充值请求
    public boolean requestTopUp(WalletTransaction transaction) {
        String sql = "INSERT INTO wallet_transactions (user_id, amount, status, receipt_image, transaction_type) VALUES (?, ?, ?, ?, 'TOPUP')";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            if (connection == null) return false;

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

            if (connection == null) return false;

            statement.setInt(1, transaction.getUserId());
            statement.setBigDecimal(2, transaction.getAmount());
            statement.setString(3, transaction.getStatus());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 3. 查询当前余额
    public BigDecimal getBalance(int userId) {
        String sql = "SELECT " +
                "SUM(CASE WHEN transaction_type = 'TOPUP' THEN amount ELSE 0 END) - " +
                "SUM(CASE WHEN transaction_type = 'WITHDRAW' THEN amount ELSE 0 END) as balance " +
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

    // 4. 获取待审核列表 (Admin)
    public List<WalletTransaction> getPendingTransactions() {
        List<WalletTransaction> list = new ArrayList<>();
        String sql = "SELECT * FROM wallet_transactions WHERE status = 'PENDING' ORDER BY created_at ASC";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {

            if (connection == null) return list;

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

            if (connection == null) return false;

            statement.setString(1, newStatus);
            statement.setInt(2, transactionId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
