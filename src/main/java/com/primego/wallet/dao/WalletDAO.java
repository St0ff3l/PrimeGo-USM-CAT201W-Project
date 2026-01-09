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
    // ⭐ 核心修复 1：余额计算 (包含退款逻辑 REFUND_IN 和 REFUND_OUT)
    // ==========================================
    public BigDecimal getBalance(int userId) {
        // 收入类：TOPUP, SALES, REFUND_IN
        // 支出类：WITHDRAW, PURCHASE, REFUND_OUT
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type IN ('TOPUP', 'SALES', 'REFUND_IN') THEN amount ELSE 0 END) - " +
                " SUM(CASE WHEN transaction_type IN ('WITHDRAW', 'PURCHASE', 'REFUND_OUT') THEN amount ELSE 0 END)) as balance " +
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

    // 辅助方法：事务内部使用 (同样更新了 SQL)
    public BigDecimal getBalance(Connection conn, int userId) throws SQLException {
        String sql = "SELECT " +
                "(SUM(CASE WHEN transaction_type IN ('TOPUP', 'SALES', 'REFUND_IN') THEN amount ELSE 0 END) - " +
                " SUM(CASE WHEN transaction_type IN ('WITHDRAW', 'PURCHASE', 'REFUND_OUT') THEN amount ELSE 0 END)) as balance " +
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
    // ⭐ 新增：退款处理 (商家 -> 用户)
    // ==========================================
    public boolean refundToCustomer(int merchantId, int customerId, BigDecimal amount) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // 开启事务

            // 1. 检查商家余额是否充足
            BigDecimal merchantBalance = getBalance(conn, merchantId);
            if (merchantBalance.compareTo(amount) < 0) {
                // 余额不足，回滚并返回失败
                throw new SQLException("Insufficient merchant balance for refund.");
            }

            // 2. 商家扣款 (记为 REFUND_OUT)
            String sqlMerchant = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'REFUND_OUT', 'APPROVED')";
            try (PreparedStatement ps = conn.prepareStatement(sqlMerchant)) {
                ps.setInt(1, merchantId);
                ps.setBigDecimal(2, amount);
                ps.executeUpdate();
            }

            // 3. 用户入账 (记为 REFUND_IN)
            String sqlCustomer = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'REFUND_IN', 'APPROVED')";
            try (PreparedStatement ps = conn.prepareStatement(sqlCustomer)) {
                ps.setInt(1, customerId);
                ps.setBigDecimal(2, amount);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
        }
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
        BigDecimal currentBalance = getBalance(conn, userId);
        if (currentBalance.compareTo(orderAmount) < 0) {
            throw new SQLException("Insufficient wallet balance. Current: " + currentBalance + ", Required: " + orderAmount);
        }

        String sqlDebit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'PURCHASE', 'APPROVED')";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlDebit)) {
            pstmt.setInt(1, userId);
            pstmt.setBigDecimal(2, orderAmount);
            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Failed to deduct user balance.");
        }

        String sqlCredit = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'SALES', 'APPROVED')";
        try (PreparedStatement pstmt = conn.prepareStatement(sqlCredit)) {
            pstmt.setInt(1, merchantId);
            pstmt.setBigDecimal(2, orderAmount);
            int rows = pstmt.executeUpdate();
            if (rows == 0) throw new SQLException("Failed to credit merchant balance.");
        }
    }

    public void payOrder(Connection conn, int userId, BigDecimal orderAmount) throws SQLException {
        payOrder(conn, userId, 2, orderAmount); // 默认商家ID，如有需要请修改
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

    // 4.1 获取所有交易记录
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

    // 6. 获取用户交易记录
    public List<WalletTransaction> getUserTransactions(int userId) {
        List<WalletTransaction> list = new ArrayList<>();
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
                    // 如果有扩展字段存放备注，可以在这里 setRemarks(rs.getString("remarks"));
                    list.add(t);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==========================================
    // ⭐ 新增：退款处理 (平台托管模式)
    // 说明：下单时用户已扣款(PURCHASE)，商家只有在用户确认收货时才入账(SALES)。
    // 因此退款时不应再扣商家，只需要把钱退回给用户(REFUND_IN)。
    // ==========================================
    public boolean refundFromEscrowToCustomer(int customerId, BigDecimal amount) {
        Connection conn = null;
        try {
            conn = getConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // 直接给用户入账
            String sqlCustomer = "INSERT INTO wallet_transactions (user_id, amount, transaction_type, status) VALUES (?, ?, 'REFUND_IN', 'APPROVED')";
            try (PreparedStatement ps = conn.prepareStatement(sqlCustomer)) {
                ps.setInt(1, customerId);
                ps.setBigDecimal(2, amount);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) {}
        }
    }
}