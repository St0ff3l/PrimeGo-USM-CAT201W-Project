package com.primego.order.dao;

import com.primego.common.util.DBUtil;
import com.primego.order.model.Order;
import com.primego.order.model.OrderItem;
import com.primego.product.dao.ProductDAO;
import com.primego.wallet.dao.WalletDAO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    private ProductDAO productDAO = new ProductDAO();
    private WalletDAO walletDAO = new WalletDAO();

    /**
     * ⭐ 核心新增：批量创建订单 (用于拆单逻辑)
     * 在一个数据库事务中，创建多个 Order，插入对应的 OrderItems，扣减库存，扣减钱包
     * 
     * @param orders 分组后的订单列表
     * @return 成功生成的订单ID列表，失败返回 null
     */
    public List<Integer> createOrdersBatch(List<Order> orders) {
        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet generatedKeys = null;
        List<Integer> createdOrderIds = new ArrayList<>();

        // SQL: 插入主订单
        String insertOrderSql = "INSERT INTO Orders (Customer_Id, Orders_Total_Amount, Orders_Order_Status, " +
                "Orders_Payment_Status, Orders_Address) VALUES (?, ?, ?, ?, ?)";

        // SQL: 插入订单项
        String insertItemSql = "INSERT INTO Order_Item (Orders_Id, Product_Id, Order_Item_Product_Name, " +
                "Order_Item_Price, Order_Item_Quantity, Order_Item_Subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try {
            conn = DBUtil.getConnection();
            // 1. 开启事务：关闭自动提交 (非常重要)
            conn.setAutoCommit(false);

            // 2. 循环处理每一个拆分后的子订单
            for (Order order : orders) {

                // ---------------------------------------------------
                // Step A: 插入 Orders 表
                // ---------------------------------------------------
                orderStmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
                orderStmt.setInt(1, order.getCustomerId());
                orderStmt.setBigDecimal(2, order.getTotalAmount());

                // 初始状态
                orderStmt.setString(3, "PAID");
                orderStmt.setString(4, "PAID");
                orderStmt.setString(5, order.getAddress());

                int affectedRows = orderStmt.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating order failed, no rows affected.");
                }

                int newOrderId = 0;
                generatedKeys = orderStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    newOrderId = generatedKeys.getInt(1);
                    createdOrderIds.add(newOrderId); // 记录生成的ID
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
                orderStmt.close(); // 关闭以便下一次循环使用

                // ---------------------------------------------------
                // Step B: 循环插入 Items 并 扣减库存
                // ---------------------------------------------------
                itemStmt = conn.prepareStatement(insertItemSql);

                for (OrderItem item : order.getOrderItems()) {
                    itemStmt.setInt(1, newOrderId);
                    itemStmt.setInt(2, item.getProductId());
                    itemStmt.setString(3, item.getProductName());
                    itemStmt.setBigDecimal(4, item.getPrice());
                    itemStmt.setInt(5, item.getQuantity());
                    itemStmt.setBigDecimal(6, item.getSubtotal());
                    itemStmt.addBatch(); // 加入批处理

                    // 调用 ProductDAO 扣减库存 (传入 conn 保持事务)
                    // 注意：ProductDAO 中必须有 decreaseStock(Connection conn, ...) 方法
                    productDAO.decreaseStock(conn, item.getProductId(), item.getQuantity());
                }

                // 执行批量插入 Items
                itemStmt.executeBatch();
                itemStmt.close();

                // ---------------------------------------------------
                // Step C: 钱包扣款 (只扣用户，不给商家)
                // ---------------------------------------------------
                // 修改：调用 deductUserBalance 而不是 payOrder
                walletDAO.deductUserBalance(conn, order.getCustomerId(), order.getTotalAmount());
            }

            // 3. 所有订单处理完毕，提交事务
            conn.commit();
            return createdOrderIds;

        } catch (SQLException e) {
            // 发生错误，回滚所有操作
            if (conn != null) {
                try {
                    System.err.println("Batch Order Transaction Failed. Rolling back... Reason: " + e.getMessage());
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return null; // 返回 null 表示失败
        } finally {
            // 恢复 AutoCommit 并关闭资源
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            try {
                if (orderStmt != null && !orderStmt.isClosed())
                    orderStmt.close();
            } catch (SQLException e) {
            }
            try {
                if (itemStmt != null && !itemStmt.isClosed())
                    itemStmt.close();
            } catch (SQLException e) {
            }
        }
    }

    /**
     * 原有的创建单个订单方法 (保留以兼容旧代码)
     */
    public int createOrder(Order order) {
        List<Order> singleList = new ArrayList<>();
        singleList.add(order);

        List<Integer> resultIds = createOrdersBatch(singleList);
        if (resultIds != null && !resultIds.isEmpty()) {
            return resultIds.get(0);
        }
        return -1;
    }

    // =========================================================================
    // ↓↓↓↓↓ 查询与更新方法 ↓↓↓↓↓
    // =========================================================================

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orderList = new ArrayList<>();
        String sql = "SELECT o.*, " +
                "r.Refund_Reason, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status, r.Refund_Type, " +
                "r.Return_Address, r.Return_Tracking_Number " +
                "FROM Orders o " +
                "LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id " +
                "WHERE o.Customer_Id = ? ORDER BY o.Orders_Created_At DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    mapRefundFields(order, rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderList;
    }

    /**
     * Get orders by user ID and status
     */
    /**
     * 根据状态查询订单 (已修改：查询 SHIPPED 时排除掉售后纠纷订单)
     */
    public List<Order> getOrdersByUserIdAndStatus(int userId, String status) {
        List<Order> orderList = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT o.*, ");
        sql.append("r.Refund_Reason, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status, r.Refund_Type, ");
        sql.append("r.Return_Address, r.Return_Tracking_Number ");
        sql.append("FROM Orders o ");
        sql.append("LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id ");
        sql.append("WHERE o.Customer_Id = ? AND o.Orders_Order_Status = ? ");

        // ⭐⭐⭐ 核心修改：如果是查询 SHIPPED (To Receive) 列表，排除掉有拒绝记录的订单 ⭐⭐⭐
        // 这样“被拒绝但回退为 SHIPPED”的订单就不会出现在 To Receive 里，只会出现在 Returns 里
        if ("SHIPPED".equals(status)) {
            sql.append("AND (r.Rejection_Count IS NULL OR r.Rejection_Count = 0) ");
        }

        sql.append("ORDER BY o.Orders_Created_At DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, userId);
            ps.setString(2, status);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);

                    // ✅ 统一映射 Refunds 字段（包含 Return_Address / Return_Tracking_Number）
                    mapRefundFields(order, rs);

                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);

                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderList;
    }

    /**
     * Get single order by ID
     */
    public Order getOrderById(int orderId) {
        Order order = null;
        String sql = "SELECT o.*, " +
                "r.Refund_Reason, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status, r.Refund_Type, " +
                "r.Return_Address, r.Return_Tracking_Number " +
                "FROM Orders o " +
                "LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id " +
                "WHERE o.Orders_Id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = mapRowToOrder(rs);
                    mapRefundFields(order, rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return order;
    }

    public List<Order> getOrdersByMerchantId(int merchantId) {
        List<Order> orderList = new ArrayList<>();
        // DISTINCT 确保同一个订单如果包含多个该商家的商品，只显示一次
        // ✅ 注意：mapRefundFields 需要 Refund_Reason/Refund_Status/Refund_Type 等字段都在 ResultSet 里
        String sql = "SELECT DISTINCT o.*, " +
                "r.Refund_Reason, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status, r.Refund_Type, " +
                "r.Return_Address, r.Return_Tracking_Number " +
                "FROM Orders o " +
                "JOIN Order_Item oi ON o.Orders_Id = oi.Orders_Id " +
                "JOIN Product p ON oi.Product_Id = p.Product_Id " +
                "LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id " +
                "WHERE p.merchant_id = ? " +
                "ORDER BY o.Orders_Created_At DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    mapRefundFields(order, rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderList;
    }

    private List<OrderItem> getOrderItemsByOrderId(int ordersId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, (SELECT image_url FROM Product_Image pi WHERE pi.product_id = oi.Product_Id LIMIT 1) as main_image FROM Order_Item oi WHERE oi.Orders_Id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ordersId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getInt("Order_Item_Id"));
                    item.setOrdersId(rs.getInt("Orders_Id"));
                    item.setProductId(rs.getInt("Product_Id"));
                    item.setProductName(rs.getString("Order_Item_Product_Name"));
                    item.setPrice(rs.getBigDecimal("Order_Item_Price"));
                    item.setQuantity(rs.getInt("Order_Item_Quantity"));
                    item.setSubtotal(rs.getBigDecimal("Order_Item_Subtotal"));
                    String img = rs.getString("main_image");
                    item.setProductImageUrl(img != null ? img : "");
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public boolean shipOrder(int orderId, String trackingNumber) {
        String sql = "UPDATE Orders SET Orders_Order_Status = 'SHIPPED', Tracking_Number = ? WHERE Orders_Id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNumber);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        // 🟢 修改逻辑：如果是完成订单，同时更新 completed_at 时间
        String sql = "UPDATE Orders SET Orders_Order_Status = ? WHERE Orders_Id = ?";
        if ("COMPLETED".equals(newStatus)) {
            sql = "UPDATE Orders SET Orders_Order_Status = ?, completed_at = NOW() WHERE Orders_Id = ?";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, orderId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }


    // 🟢 [修改] 用户申请退款
    public boolean requestRefund(int orderId, String reason, int userId) {
        return requestRefund(orderId, reason, userId, "MONEY_ONLY");
    }

    // 🟢 [新增] 用户申请退款 + 退款类型
    public boolean requestRefund(int orderId, String reason, int userId, String refundType) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // 开启事务

            // 1. 更新 Orders 表状态
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'RETURN_REQUESTED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // 2. 插入或更新 Refunds 表
            String rt = (refundType == null || refundType.trim().isEmpty()) ? "MONEY_ONLY" : refundType.trim();
            if (!"MONEY_ONLY".equals(rt) && !"RETURN_AND_REFUND".equals(rt)) {
                rt = "MONEY_ONLY";
            }

            // ⭐ 注意：Refund_Type 是 enum 且 NOT NULL，这里必须显式写入
            String refundSql = "INSERT INTO Refunds (Orders_Id, Customer_Id, Refund_Type, Refund_Reason, Refund_Amount, Refund_Status) " +
                    "VALUES (?, ?, ?, ?, (SELECT Orders_Total_Amount FROM Orders WHERE Orders_Id = ?), 'PENDING') " +
                    "ON DUPLICATE KEY UPDATE " +
                    "Refund_Status = 'PENDING', " +
                    "Refund_Type = VALUES(Refund_Type), " +
                    "Refund_Reason = VALUES(Refund_Reason), " +
                    "Merchant_Reject_Reason = NULL";

            try (PreparedStatement ps = conn.prepareStatement(refundSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                ps.setString(3, rt);
                ps.setString(4, reason);
                ps.setInt(5, orderId);
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


    // 🟢 [修改] 商家拒绝退款
    public boolean rejectRefund(int orderId, String merchantReason) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 更新 Refunds 表：状态=REJECTED, 次数+1, 记录拒绝理由
            String refundSql = "UPDATE Refunds SET Refund_Status = 'REJECTED', " +
                    "Rejection_Count = Rejection_Count + 1, " +
                    "Merchant_Reject_Reason = ? " +
                    "WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(refundSql)) {
                ps.setString(1, merchantReason);
                ps.setInt(2, orderId);
                ps.executeUpdate();
            }

            // 2. ⭐⭐ 关键修改：状态回退为 SHIPPED (而不是 COMPLETED) ⭐⭐
            // 这样用户在前端才能再次看到 "Apply Again" 按钮 (因为前端判断 if status == SHIPPED)
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'SHIPPED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
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


    // 🟢 [新增] 商家同意退款 (仅更新状态，钱在 WalletDAO 扣)
    public boolean approveRefundStatus(int orderId) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. 更新 Refunds 表
            String refundSql = "UPDATE Refunds SET Refund_Status = 'APPROVED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(refundSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // 2. 更新 Orders 表
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'REFUNDED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
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

    // 🟢 [新增] 商家同意退货 (写入退货地址 + 状态 WAITING_RETURN)
    public boolean agreeReturn(int orderId, String returnAddress) {
        String addr = (returnAddress == null) ? null : returnAddress.trim();
        if (addr == null || addr.isEmpty()) {
            addr = null;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) 更新 Refunds
            String sql = "UPDATE Refunds SET Refund_Status = 'WAITING_RETURN', Return_Address = ? WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, addr);
                ps.setInt(2, orderId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2) 保持 Orders 处于售后状态，确保两端列表都能看到
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'RETURN_REQUESTED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
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

    // 🟡 兼容旧调用：不传地址
    public boolean agreeReturn(int orderId) {
        return agreeReturn(orderId, null);
    }

    // 🟢 [新增] 买家确认已发货 (写入寄回单号 + 状态 RETURN_SHIPPED)
    public boolean buyerConfirmShipped(int orderId, String returnTrackingNumber) {
        String trk = (returnTrackingNumber == null) ? null : returnTrackingNumber.trim();
        if (trk == null || trk.isEmpty()) {
            trk = null;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) 更新 Refunds
            String sql = "UPDATE Refunds SET Refund_Status = 'RETURN_SHIPPED', Return_Tracking_Number = ? WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, trk);
                ps.setInt(2, orderId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2) 保持 Orders 处于售后状态
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'RETURN_REQUESTED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
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

    // 🟡 兼容旧调用：不传单号
    public boolean buyerConfirmShipped(int orderId) {
        return buyerConfirmShipped(orderId, null);
    }








    // 🟢 [新增] 专门用于查询 "售后/退款" 列表
    // 逻辑：查询 (状态是 申请中/已退款) 或者 (状态是 SHIPPED 且 拒绝次数 > 0)
    public List<Order> getReturnOrdersByUserId(int userId) {
        List<Order> orderList = new ArrayList<>();
        String sql = "SELECT o.*, " +
                "r.Refund_Reason, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status, r.Refund_Type, " +
                "r.Return_Address, r.Return_Tracking_Number " +
                "FROM Orders o " +
                "LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id " +
                "WHERE o.Customer_Id = ? " +
                "AND (" +
                "  o.Orders_Order_Status IN ('RETURN_REQUESTED', 'REFUNDED') " +
                "  OR (o.Orders_Order_Status = 'SHIPPED' AND r.Rejection_Count > 0)" +
                "  OR r.Refund_Status IN ('WAITING_RETURN', 'RETURN_SHIPPED')" +
                ") " +
                "ORDER BY o.Orders_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    mapRefundFields(order, rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderList;
    }

    // =========================================================================
    // ↓↓↓↓↓ 私有方法 ↓↓↓↓↓
    // =========================================================================

    private Order mapRowToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrdersId(rs.getInt("Orders_Id"));
        order.setCustomerId(rs.getInt("Customer_Id"));
        order.setTotalAmount(rs.getBigDecimal("Orders_Total_Amount"));
        order.setOrderStatus(rs.getString("Orders_Order_Status"));
        order.setPaymentStatus(rs.getString("Orders_Payment_Status"));
        order.setAddress(rs.getString("Orders_Address"));
        order.setCreatedAt(rs.getTimestamp("Orders_Created_At"));
        try {
            order.setTrackingNumber(rs.getString("Tracking_Number"));
        } catch (SQLException e) {
            order.setTrackingNumber(null);
        }

        try {
            order.setCompletedAt(rs.getTimestamp("completed_at"));
        } catch (SQLException e) {
            /* 忽略列不存在的情况 */
        }

        // ❌ 注意：不再从 Orders 表读取 refund_reason（已迁移到 Refunds 表）

        return order;
    }

    // 🟢 [新增辅助方法] 映射 Refunds 表的字段 (普通查询没 JOIN Refunds 时不会报错)
    private void mapRefundFields(Order order, ResultSet rs) {
        // ✅ Each column is optional depending on which query SELECTs it.
        // Read them independently so one missing column won't break the rest.
        try { order.setRefundReason(rs.getString("Refund_Reason")); } catch (Exception ignored) {}
        try { order.setRejectionCount(rs.getInt("Rejection_Count")); } catch (Exception ignored) {}
        try { order.setMerchantRejectReason(rs.getString("Merchant_Reject_Reason")); } catch (Exception ignored) {}
        try { order.setRefundStatus(rs.getString("Refund_Status")); } catch (Exception ignored) {}
        try { order.setRefundType(rs.getString("Refund_Type")); } catch (Exception ignored) {}
        try { order.setReturnAddress(rs.getString("Return_Address")); } catch (Exception ignored) {}
        try { order.setReturnTrackingNumber(rs.getString("Return_Tracking_Number")); } catch (Exception ignored) {}
    }

    public int countTotalTransactions() {
        String sql = "SELECT COUNT(*) FROM Orders WHERE Orders_Order_Status IN ('PAID', 'SHIPPED', 'COMPLETED', 'CANCELLED')";
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

    public List<Order> getOrdersByStatusForAdmin(String status) {
        List<Order> orderList = new ArrayList<>();
        String sql = "SELECT o.*, r.Rejection_Count, r.Merchant_Reject_Reason, r.Refund_Status " +
                "FROM Orders o " +
                "LEFT JOIN Refunds r ON o.Orders_Id = r.Orders_Id " +
                "WHERE o.Orders_Order_Status = ? ORDER BY o.Orders_Created_At DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    mapRefundFields(order, rs);
                    // For dashboard summary, we might not need items to improve performance,
                    // but let's include them for completeness if needed in modal detail
                    // order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orderList;
    }
}
