package com.primego.order.dao;

import com.primego.common.util.DBUtil;
import com.primego.order.model.Order;
import com.primego.order.model.OrderItem;
import com.primego.product.dao.ProductDAO;
import com.primego.wallet.dao.WalletDAO; // ⭐ 1. 导入 WalletDAO

import java.sql.*;

public class OrderDAO {

    private ProductDAO productDAO = new ProductDAO();
    private WalletDAO walletDAO = new WalletDAO(); // ⭐ 2. 实例化 WalletDAO

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
            orderStmt.setString(3, "PENDING"); // 默认状态
            orderStmt.setString(4, "PAID");    // 假设下单即支付 (根据你的业务调整)
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
            // ⭐ Step 3: 钱包扣款 (新增关键步骤)
            // ---------------------------------------------------
            // 如果余额不足，WalletDAO 会抛出异常，触发 catch 块的回滚
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
}