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
     * 创建订单 (Transaction)
     * 1. 插入 Orders 表
     * 2. 插入 Order_Item 表
     * 3. 扣减 Product 库存
     * 4. 扣减 Wallet 余额
     * @return 成功返回生成的 ordersId，失败返回 -1
     */
    public int createOrder(Order order) {
        Connection conn = null;
        PreparedStatement orderStmt = null;
        PreparedStatement itemStmt = null;
        ResultSet generatedKeys = null;

        // SQL: 插入主订单
        String insertOrderSql = "INSERT INTO Orders (Customer_Id, Orders_Total_Amount, Orders_Order_Status, " +
                "Orders_Payment_Status, Orders_Address) VALUES (?, ?, ?, ?, ?)";

        // SQL: 插入订单项
        String insertItemSql = "INSERT INTO Order_Item (Orders_Id, Product_Id, Order_Item_Product_Name, " +
                "Order_Item_Price, Order_Item_Quantity, Order_Item_Subtotal) VALUES (?, ?, ?, ?, ?, ?)";

        try {
            conn = DBUtil.getConnection();
            // 开启事务：关闭自动提交
            conn.setAutoCommit(false);

            // ---------------------------------------------------
            // Step 1: 插入 Orders
            // ---------------------------------------------------
            orderStmt = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
            orderStmt.setInt(1, order.getCustomerId());
            orderStmt.setBigDecimal(2, order.getTotalAmount());

            // 状态为 PAID
            orderStmt.setString(3, "PAID");
            orderStmt.setString(4, "PAID");
            orderStmt.setString(5, order.getAddress());

            int affectedRows = orderStmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating order failed, no rows affected.");
            }

            // 获取生成的 ID
            int ordersId = 0;
            generatedKeys = orderStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                ordersId = generatedKeys.getInt(1);
            } else {
                throw new SQLException("Creating order failed, no ID obtained.");
            }

            // ---------------------------------------------------
            // Step 2: 循环插入 Items 并 扣减库存
            // ---------------------------------------------------
            itemStmt = conn.prepareStatement(insertItemSql);

            for (OrderItem item : order.getOrderItems()) {
                // A. 准备插入 Item
                itemStmt.setInt(1, ordersId);
                itemStmt.setInt(2, item.getProductId());
                itemStmt.setString(3, item.getProductName());
                itemStmt.setBigDecimal(4, item.getPrice());
                itemStmt.setInt(5, item.getQuantity());
                itemStmt.setBigDecimal(6, item.getSubtotal());
                itemStmt.addBatch(); // 加入批处理

                // B. 调用 ProductDAO 扣减库存 (使用同一个 connection)
                productDAO.decreaseStock(conn, item.getProductId(), item.getQuantity());
            }

            // 执行批量插入
            itemStmt.executeBatch();

            // ---------------------------------------------------
            // Step 3: 钱包扣款
            // ---------------------------------------------------
            walletDAO.payOrder(conn, order.getCustomerId(), order.getTotalAmount());

            // ---------------------------------------------------
            // Step 4: 提交事务
            // ---------------------------------------------------
            conn.commit();
            return ordersId;

        } catch (SQLException e) {
            // 发生错误，回滚
            if (conn != null) {
                try {
                    System.err.println("Order Transaction Failed. Rolling back... Reason: " + e.getMessage());
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return -1;
        } finally {
            // 恢复 AutoCommit 并关闭资源
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) { e.printStackTrace(); }
            }
            try { if (orderStmt != null) orderStmt.close(); } catch (SQLException e) {}
            try { if (itemStmt != null) itemStmt.close(); } catch (SQLException e) {}
        }
    }

    // =========================================================================
    // ↓↓↓↓↓ 查询与更新方法 ↓↓↓↓↓
    // =========================================================================

    /**
     * 1. 根据用户ID查询所有订单（顾客视角）
     */
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orderList = new ArrayList<>();
        String sql = "SELECT * FROM Orders WHERE Customer_Id = ? ORDER BY Orders_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    // 关键：查询该订单下的商品项
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
     * 2. 根据商家ID查询所有相关订单（商家视角）
     * 逻辑：通过 Order_Item -> Product 关联表，找到属于该商家的订单
     */
    public List<Order> getOrdersByMerchantId(int merchantId) {
        List<Order> orderList = new ArrayList<>();
        // DISTINCT 确保同一个订单如果包含多个该商家的商品，只显示一次
        String sql = "SELECT DISTINCT o.* FROM Orders o " +
                "JOIN Order_Item oi ON o.Orders_Id = oi.Orders_Id " +
                "JOIN Product p ON oi.Product_Id = p.Product_Id " +
                "WHERE p.merchant_id = ? " +
                "ORDER BY o.Orders_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    // 关键：查询该订单下的商品项
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
     * 3. 查询单个订单的所有商品项（带图片）
     */
    private List<OrderItem> getOrderItemsByOrderId(int ordersId) {
        List<OrderItem> items = new ArrayList<>();

        // 使用子查询获取商品图片 (LIMIT 1)
        String sql = "SELECT oi.*, " +
                "(SELECT image_url FROM Product_Image pi WHERE pi.product_id = oi.Product_Id LIMIT 1) as main_image " +
                "FROM Order_Item oi WHERE oi.Orders_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

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

                    // 设置图片路径
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

    /**
     * ⭐ 4. 新增：商家发货 (更新状态并填写快递单号)
     */
    public boolean shipOrder(int orderId, String trackingNumber) {
        String sql = "UPDATE Orders SET Orders_Order_Status = 'SHIPPED', Tracking_Number = ? WHERE Orders_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, trackingNumber);
            ps.setInt(2, orderId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 5. 原有的更新订单状态 (用于其他通用状态更改，如 COMPLETED)
     */
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

    // 辅助方法：将 ResultSet 映射到 Order 对象
    private Order mapRowToOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrdersId(rs.getInt("Orders_Id"));
        order.setCustomerId(rs.getInt("Customer_Id"));
        order.setTotalAmount(rs.getBigDecimal("Orders_Total_Amount"));
        order.setOrderStatus(rs.getString("Orders_Order_Status"));
        order.setPaymentStatus(rs.getString("Orders_Payment_Status"));
        order.setAddress(rs.getString("Orders_Address"));
        order.setCreatedAt(rs.getTimestamp("Orders_Created_At"));

        // ⭐ 新增：读取快递单号
        try {
            order.setTrackingNumber(rs.getString("Tracking_Number"));
        } catch (SQLException e) {
            // 防止旧表结构没更新导致报错，虽然这里应该已经改了表
            order.setTrackingNumber(null);
        }

        return order;
    }
}