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
                // Step C: 钱包扣款 (针对该子订单扣款，生成对应的交易流水)
                // ---------------------------------------------------
                // 注意：WalletDAO 中必须有 payOrder(Connection conn, ...) 方法
                walletDAO.payOrder(conn, order.getCustomerId(), order.getTotalAmount());
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
                } catch (SQLException e) { e.printStackTrace(); }
            }
            try { if (orderStmt != null && !orderStmt.isClosed()) orderStmt.close(); } catch (SQLException e) {}
            try { if (itemStmt != null && !itemStmt.isClosed()) itemStmt.close(); } catch (SQLException e) {}
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
        String sql = "SELECT * FROM Orders WHERE Customer_Id = ? ORDER BY Orders_Created_At DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return orderList;
    }

    public List<Order> getOrdersByMerchantId(int merchantId) {
        List<Order> orderList = new ArrayList<>();
        // DISTINCT 确保同一个订单如果包含多个该商家的商品，只显示一次
        String sql = "SELECT DISTINCT o.* FROM Orders o " +
                "JOIN Order_Item oi ON o.Orders_Id = oi.Orders_Id " +
                "JOIN Product p ON oi.Product_Id = p.Product_Id " +
                "WHERE p.merchant_id = ? " +
                "ORDER BY o.Orders_Created_At DESC";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    order.setOrderItems(getOrderItemsByOrderId(order.getOrdersId()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
        } catch (SQLException e) { e.printStackTrace(); }
        return items;
    }

    public boolean shipOrder(int orderId, String trackingNumber) {
        String sql = "UPDATE Orders SET Orders_Order_Status = 'SHIPPED', Tracking_Number = ? WHERE Orders_Id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trackingNumber);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE Orders SET Orders_Order_Status = ? WHERE Orders_Id = ?";
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

    private Order mapRowToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrdersId(rs.getInt("Orders_Id"));
        order.setCustomerId(rs.getInt("Customer_Id"));
        order.setTotalAmount(rs.getBigDecimal("Orders_Total_Amount"));
        order.setOrderStatus(rs.getString("Orders_Order_Status"));
        order.setPaymentStatus(rs.getString("Orders_Payment_Status"));
        order.setAddress(rs.getString("Orders_Address"));
        order.setCreatedAt(rs.getTimestamp("Orders_Created_At"));
        try { order.setTrackingNumber(rs.getString("Tracking_Number")); } catch (SQLException e) { order.setTrackingNumber(null); }
        return order;
    }
}