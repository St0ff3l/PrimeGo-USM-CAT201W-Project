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
     * 4. 扣减 Wallet 余额 (新增)
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
    // ↓↓↓↓↓ 下面是 Profile 页面显示历史订单的方法 ↓↓↓↓↓
    // =========================================================================

    /**
     * 根据用户ID查询所有订单（包含订单项）
     */
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> orderList = new ArrayList<>();
        // 按创建时间倒序排列，最新的在前面
        String sql = "SELECT * FROM Orders WHERE Customer_Id = ? ORDER BY Orders_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    // 映射 Orders 表字段到 Order 对象
                    order.setOrdersId(rs.getInt("Orders_Id"));
                    order.setCustomerId(rs.getInt("Customer_Id"));
                    order.setTotalAmount(rs.getBigDecimal("Orders_Total_Amount"));
                    order.setOrderStatus(rs.getString("Orders_Order_Status"));
                    order.setPaymentStatus(rs.getString("Orders_Payment_Status"));
                    order.setAddress(rs.getString("Orders_Address"));
                    order.setCreatedAt(rs.getTimestamp("Orders_Created_At"));

                    // 关键：同时查询该订单下的所有商品项
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
     * ⭐⭐ 修改了此方法：查询单个订单的所有商品项，并关联查询图片 ⭐⭐
     */
    private List<OrderItem> getOrderItemsByOrderId(int ordersId) {
        List<OrderItem> items = new ArrayList<>();

        // ⭐ 修改 SQL：使用子查询从 Product_Image 表获取第一张图片 (LIMIT 1)
        // 这样前端 JSP 才能显示商品图片
        String sql = "SELECT oi.*, " +
                "(SELECT image_url FROM Product_Image pi WHERE pi.product_id = oi.Product_Id LIMIT 1) as main_image " +
                "FROM Order_Item oi WHERE oi.Orders_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ordersId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    // 映射 Order_Item 表字段到 OrderItem 对象
                    item.setOrderItemId(rs.getInt("Order_Item_Id"));
                    item.setOrdersId(rs.getInt("Orders_Id"));
                    item.setProductId(rs.getInt("Product_Id"));
                    item.setProductName(rs.getString("Order_Item_Product_Name"));
                    item.setPrice(rs.getBigDecimal("Order_Item_Price"));
                    item.setQuantity(rs.getInt("Order_Item_Quantity"));
                    item.setSubtotal(rs.getBigDecimal("Order_Item_Subtotal"));

                    // ⭐ 设置图片路径（需要你在 OrderItem.java 里加了 productImageUrl 字段）
                    String img = rs.getString("main_image");
                    // 如果数据库里没图，给一个默认值或空值
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
     * ⭐⭐ 新增方法：更新订单状态 (用于确认收货) ⭐⭐
     * @param orderId 订单ID
     * @param newStatus 新状态 (如 "COMPLETED")
     * @return 是否更新成功
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
}