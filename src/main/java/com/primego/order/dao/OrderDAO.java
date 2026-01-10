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
     * Creates multiple orders in a single database transaction.
     *
     * This method is designed for split-order scenarios:
     * - Insert each order into the Orders table
     * - Insert corresponding Order_Item rows
     * - Decrease product stock
     * - Deduct the customer's wallet balance
     *
     * If any step fails, the entire transaction is rolled back.
     *
     * @param orders grouped/split orders to persist
     * @return list of generated order IDs; returns null on failure
     */
    public List<Integer> createOrdersBatch(List<Order> orders) {
        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet generatedKeys = null;
        List<Integer> createdOrderIds = new ArrayList<>();

        // SQL: insert an order (header)
        String insertOrderSql = "INSERT INTO Orders (Customer_Id, Orders_Total_Amount, Orders_Order_Status, " +
                "Orders_Payment_Status, Orders_Address) VALUES (?, ?, ?, ?, ?)";

        // SQL: insert an order item (line)
        String insertItemSql = "INSERT INTO Order_Item (Orders_Id, Product_Id, Order_Item_Product_Name, " +
                "Order_Item_Price, Order_Item_Quantity, Order_Item_Subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try {
            conn = DBUtil.getConnection();
            // Begin transaction.
            conn.setAutoCommit(false);

            // Process each split order.
            for (Order order : orders) {

                // ---------------------------------------------------
                // Step A: Insert into Orders
                // ---------------------------------------------------
                orderStmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
                orderStmt.setInt(1, order.getCustomerId());
                orderStmt.setBigDecimal(2, order.getTotalAmount());

                // Initial status for a successfully paid order.
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
                    createdOrderIds.add(newOrderId); // Track generated order IDs
                } else {
                    throw new SQLException("Creating order failed, no ID obtained.");
                }
                orderStmt.close(); // Close so the next loop iteration can recreate it cleanly

                // ---------------------------------------------------
                // Step B: Insert items and decrease stock
                // ---------------------------------------------------
                itemStmt = conn.prepareStatement(insertItemSql);

                for (OrderItem item : order.getOrderItems()) {
                    itemStmt.setInt(1, newOrderId);
                    itemStmt.setInt(2, item.getProductId());
                    itemStmt.setString(3, item.getProductName());
                    itemStmt.setBigDecimal(4, item.getPrice());
                    itemStmt.setInt(5, item.getQuantity());
                    itemStmt.setBigDecimal(6, item.getSubtotal());
                    itemStmt.addBatch();

                    // Decrease stock using the same connection to keep everything in one transaction.
                    // ProductDAO is expected to provide decreaseStock(Connection conn, ...).
                    productDAO.decreaseStock(conn, item.getProductId(), item.getQuantity());
                }

                // Batch insert items.
                itemStmt.executeBatch();
                itemStmt.close();

                // ---------------------------------------------------
                // Step C: Deduct wallet balance (customer only)
                // ---------------------------------------------------
                // Deduct the customer's balance for this order amount.
                walletDAO.deductUserBalance(conn, order.getCustomerId(), order.getTotalAmount());
            }

            // Commit if all orders succeed.
            conn.commit();
            return createdOrderIds;

        } catch (SQLException e) {
            // Roll back the entire batch on any failure.
            if (conn != null) {
                try {
                    System.err.println("Batch Order Transaction Failed. Rolling back... Reason: " + e.getMessage());
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return null;
        } finally {
            // Restore auto-commit and close resources.
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
     * Creates a single order.
     *
     * This is a compatibility wrapper that delegates to createOrdersBatch.
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
    // Query and update methods
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
     * Returns orders for a given user filtered by order status.
     *
     * Special handling: when querying SHIPPED ("To Receive"), exclude orders that have refund rejection history,
     * so they appear only in the returns/refund list.
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

        // If querying SHIPPED, exclude orders that were rejected in after-sales flow.
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

                    // Map Refunds columns (including return address and tracking number) when present.
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
     * Returns a single order by its ID.
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
        // DISTINCT ensures an order appears only once even if it contains multiple items from the same merchant.
        // mapRefundFields expects refund-related columns to be available when the query selects them.
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
        // When completing an order, also write the completion timestamp.
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


    // Customer requests a refund.
    public boolean requestRefund(int orderId, String reason, int userId) {
        return requestRefund(orderId, reason, userId, "MONEY_ONLY");
    }

    // Customer requests a refund with an explicit refund type.
    public boolean requestRefund(int orderId, String reason, int userId, String refundType) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // Begin transaction

            // 1) Update Orders status
            String orderSql = "UPDATE Orders SET Orders_Order_Status = 'RETURN_REQUESTED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // 2) Insert or update Refunds row
            String rt = (refundType == null || refundType.trim().isEmpty()) ? "MONEY_ONLY" : refundType.trim();
            if (!"MONEY_ONLY".equals(rt) && !"RETURN_AND_REFUND".equals(rt)) {
                rt = "MONEY_ONLY";
            }

            // Refund_Type is an enum and NOT NULL, so it must always be written explicitly.
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


    // Merchant rejects a refund and records the rejection reason.
    public boolean rejectRefund(int orderId, String merchantReason) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) Update Refunds: status=REJECTED, increment rejection count, store rejection reason
            String refundSql = "UPDATE Refunds SET Refund_Status = 'REJECTED', " +
                    "Rejection_Count = Rejection_Count + 1, " +
                    "Merchant_Reject_Reason = ? " +
                    "WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(refundSql)) {
                ps.setString(1, merchantReason);
                ps.setInt(2, orderId);
                ps.executeUpdate();
            }

            // 2) Revert Orders status to SHIPPED so the user can submit another request when applicable.
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


    // Merchant approves a refund (status only; the wallet operation is handled elsewhere).
    public boolean approveRefundStatus(int orderId) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) Update Refunds
            String refundSql = "UPDATE Refunds SET Refund_Status = 'APPROVED' WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(refundSql)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }

            // 2) Update Orders
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

    // Merchant agrees to a return: write return address and mark Refund_Status as WAITING_RETURN.
    public boolean agreeReturn(int orderId, String returnAddress) {
        String addr = (returnAddress == null) ? null : returnAddress.trim();
        if (addr == null || addr.isEmpty()) {
            addr = null;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) Update Refunds
            String sql = "UPDATE Refunds SET Refund_Status = 'WAITING_RETURN', Return_Address = ? WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, addr);
                ps.setInt(2, orderId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2) Keep Orders in an after-sales state so both sides can still see it in their lists.
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

    // Backward-compatible overload: agree to return without providing an address.
    public boolean agreeReturn(int orderId) {
        return agreeReturn(orderId, null);
    }

    // Buyer confirms the return shipment: write tracking number and set Refund_Status to RETURN_SHIPPED.
    public boolean buyerConfirmShipped(int orderId, String returnTrackingNumber) {
        String trk = (returnTrackingNumber == null) ? null : returnTrackingNumber.trim();
        if (trk == null || trk.isEmpty()) {
            trk = null;
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) Update Refunds
            String sql = "UPDATE Refunds SET Refund_Status = 'RETURN_SHIPPED', Return_Tracking_Number = ? WHERE Orders_Id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, trk);
                ps.setInt(2, orderId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2) Keep Orders in an after-sales state
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

    // Backward-compatible overload: confirm return shipment without providing a tracking number.
    public boolean buyerConfirmShipped(int orderId) {
        return buyerConfirmShipped(orderId, null);
    }






    // Query specifically for the user's returns/refunds list.
    // Logic: include (RETURN_REQUESTED/REFUNDED) OR (SHIPPED with rejection history) OR waiting/return-shipped states.
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
    // Private helpers
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
            /* Ignore when the column does not exist */
        }

        // Note: refund fields are no longer read from Orders; they come from the Refunds table.

        return order;
    }

    // Helper to map Refunds columns when the current query includes them.
    private void mapRefundFields(Order order, ResultSet rs) {
        // Each column is optional depending on which query SELECTs it.
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
                    // For dashboard summaries we might skip loading items for performance,
                    // but items can be loaded for detailed views if needed.
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
