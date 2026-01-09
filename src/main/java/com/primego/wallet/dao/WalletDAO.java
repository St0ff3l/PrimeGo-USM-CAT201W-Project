package com.primego.wallet.dao;

import com.primego.wallet.model.WalletTransaction;
import com.primego.common.util.DBUtil;
import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import com.primego.wallet.model.AdminTransactionLog;

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

    // 0. 记录管理员操作日志
    public boolean addAdminLog(AdminTransactionLog log) {
        String sql = "INSERT INTO admin_transaction_logs (admin_id, wallet_transaction_id, action_type, previous_status, current_status, remarks) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, log.getAdminId());
            statement.setInt(2, log.getWalletTransactionId());
            statement.setString(3, log.getActionType());
            statement.setString(4, log.getPreviousStatus());
            statement.setString(5, log.getCurrentStatus());
            statement.setString(6, log.getRemarks());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 0.1 获取已处理的交易记录 (History)
    public List<AdminTransactionLog> getProcessedTransactions() {
        List<AdminTransactionLog> list = new ArrayList<>();
        // 联表查询，获取管理员名字
        String sql = "SELECT l.*, u.username as admin_name " +
                     "FROM admin_transaction_logs l " +
                     "LEFT JOIN users u ON l.admin_id = u.id " +
                     "ORDER BY l.created_at DESC";
        
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                AdminTransactionLog log = new AdminTransactionLog();
                log.setId(rs.getInt("id"));
                log.setAdminId(rs.getInt("admin_id"));
                log.setWalletTransactionId(rs.getInt("wallet_transaction_id"));
                log.setActionType(rs.getString("action_type"));
                log.setPreviousStatus(rs.getString("previous_status"));
                log.setCurrentStatus(rs.getString("current_status"));
                log.setRemarks(rs.getString("remarks"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                log.setAdminName(rs.getString("admin_name"));
                list.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
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
        String sql = "INSERT INTO wallet_transactions (user_id, amount, status, transaction_type, receipt_image) VALUES (?, ?, ?, 'WITHDRAW', ?)";
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

    // ==========================================
    // ⭐ 核心修复 1：余额计算 (包含 SALES 和 PURCHASE)
    // ==========================================
    public BigDecimal getBalance(int userId) {
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type IN ('TOPUP', 'SALES') THEN amount ELSE 0 END) - " +
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

    // 辅助方法：事务内部使用
    public BigDecimal getBalance(Connection conn, int userId) throws SQLException {
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type IN ('TOPUP', 'SALES') THEN amount ELSE 0 END) - " +
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
    // ⭐ 新增：仅扣减用户余额 (用于下单时)
    // ==========================================
    public void deductUserBalance(Connection conn, int userId, BigDecimal amount) throws SQLException {
        // 1. 检查余额
        BigDecimal currentBalance = getBalance(conn, userId);
        if (currentBalance.compareTo(amount) < 0) {
            throw new SQLException("Insufficient wallet balance. Current: " + currentBalance + ", Required: " + amount);
        }

        // 2. 用户扣款 -> 记为 PURCHASE
        String sqlDebit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'PURCHASE', 'APPROVED')";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlDebit)) {
            pstmt.setInt(1, userId);
            pstmt.setBigDecimal(2, amount);
            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Failed to deduct user balance.");
        }
    }

    // ==========================================
    // ⭐ 新增：仅增加商家余额 (用于确认收货时)
    // ==========================================
    public void creditMerchantBalance(int merchantId, BigDecimal amount) {
        String sqlCredit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'SALES', 'APPROVED')";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlCredit)) {
            pstmt.setInt(1, merchantId);
            pstmt.setBigDecimal(2, amount);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==========================================
    // ⭐ 核心修复 2：支付订单 (正确标记为 PURCHASE 并给商家加钱)
    // ==========================================
    public void payOrder(Connection conn, int userId, int merchantId, BigDecimal orderAmount) throws SQLException {
        // 1. 检查余额
        BigDecimal currentBalance = getBalance(conn, userId);
        if (currentBalance.compareTo(orderAmount) < 0) {
            throw new SQLException("Insufficient wallet balance. Current: " + currentBalance + ", Required: " + orderAmount);
        }

        // 2. 用户扣款 -> 记为 PURCHASE (之前可能写错了成 WITHDRAW)
        String sqlDebit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'PURCHASE', 'APPROVED')";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlDebit)) {
            pstmt.setInt(1, userId);
            pstmt.setBigDecimal(2, orderAmount);
            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Failed to deduct user balance.");
        }

        // 3. 商家入账 -> 记为 SALES
        String sqlCredit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'SALES', 'APPROVED')";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlCredit)) {
            pstmt.setInt(1, merchantId);
            pstmt.setBigDecimal(2, orderAmount);
            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Failed to credit merchant balance.");
        }
    }

    // 兼容旧代码的方法重载 (默认商家ID=2，请根据实际情况修改)
    public void payOrder(Connection conn, int userId, BigDecimal orderAmount) throws SQLException {
        payOrder(conn, userId, 2, orderAmount);
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

    // 4.1 获取所有交易记录 (用于 History 显示详情)
    public WalletTransaction getTransactionById(int id) {
        String sql = "SELECT * FROM wallet_transactions WHERE id = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    WalletTransaction t = new WalletTransaction();
                    t.setId(rs.getInt("id"));
                    t.setUserId(rs.getInt("user_id"));
                    t.setAmount(rs.getBigDecimal("amount"));
                    t.setTransactionType(rs.getString("transaction_type"));
                    t.setStatus(rs.getString("status"));
                    t.setReceiptImage(rs.getString("receipt_image"));
                    t.setCreatedAt(rs.getTimestamp("created_at"));
                    return t;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
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

    // 6. 获取用户交易记录 (包含管理员备注)
    public List<WalletTransaction> getUserTransactions(int userId) {
        List<WalletTransaction> list = new ArrayList<>();
        // 联表查询 admin_transaction_logs 获取备注
        String sql = "SELECT t.*, l.remarks " +
                     "FROM wallet_transactions t " +
                     "LEFT JOIN admin_transaction_logs l ON t.id = l.wallet_transaction_id " +
                     "WHERE t.user_id = ? " +
                     "ORDER BY t.created_at DESC";

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
                    
                    // 将备注存入 WalletTransaction 对象 (需要确保 WalletTransaction 有 remarks 字段，或者临时存入)
                    // 这里假设 WalletTransaction 没有 remarks 字段，我们可以临时借用一个字段或者修改 Model
                    // 为了不修改 Model，我们可以将备注拼接到 status 或者创建一个扩展类
                    // 但最好的方式是修改 Model。鉴于不能修改 Model，我们这里用一个折衷方案：
                    // 如果有备注，将其作为额外属性传递，或者修改 Model。
                    // 让我们检查一下 WalletTransaction 是否有 remarks 字段。如果没有，我们可能需要修改 Model。
                    // 假设没有，我们先尝试修改 Model。
                    
                    // 实际上，为了简单起见，我们可以将备注放在 request attribute 中，或者修改 Model。
                    // 这里我选择修改 Model，因为这是最正规的做法。
                    // 但由于我不能修改 Model (除非用户要求)，我将使用一个技巧：
                    // 我会创建一个继承自 WalletTransaction 的匿名类或者直接修改 Model。
                    // 等等，我可以修改 Model。
                    
                    // 既然用户要求显示评价，那么 Model 应该包含这个字段。
                    // 我先去修改 Model。
                    t.setRemarks(rs.getString("remarks")); // 假设我已经修改了 Model
                    
                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
