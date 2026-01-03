package com.primego.order.dao;

import com.primego.common.util.DBUtil;
import com.primego.order.model.Cart;
import com.primego.order.model.CartItem;
import com.primego.product.model.ProductDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    // Get or Create Cart for User
    public int getOrCreateCartId(int userId) {
        int cartId = getCartIdByUserId(userId);
        if (cartId == -1) {
            cartId = createCart(userId);
        }
        return cartId;
    }

    private int getCartIdByUserId(int userId) {
        String sql = "SELECT Cart_Id FROM Cart WHERE User_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Cart_Id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    private int createCart(int userId) {
        String sql = "INSERT INTO Cart (User_Id) VALUES (?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, userId);
            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    // Add Item to Cart
    public void addItemToCart(int cartId, int productId, int quantity) {
        // Check if item exists
        int existingQuantity = getItemQuantity(cartId, productId);
        if (existingQuantity > 0) {
            updateItemQuantity(cartId, productId, existingQuantity + quantity);
        } else {
            insertCartItem(cartId, productId, quantity);
        }
    }

    private int getItemQuantity(int cartId, int productId) {
        String sql = "SELECT Cart_Item_Quantity FROM Cart_Item WHERE Cart_Id = ? AND Product_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Cart_Item_Quantity");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void updateItemQuantityPublic(int cartId, int productId, int quantity) {
        updateItemQuantity(cartId, productId, quantity);
    }

    private void updateItemQuantity(int cartId, int productId, int quantity) {
        String sql = "UPDATE Cart_Item SET Cart_Item_Quantity = ? WHERE Cart_Id = ? AND Product_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, quantity);
            pstmt.setInt(2, cartId);
            pstmt.setInt(3, productId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void insertCartItem(int cartId, int productId, int quantity) {
        String sql = "INSERT INTO Cart_Item (Cart_Id, Product_Id, Cart_Item_Quantity) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, productId);
            pstmt.setInt(3, quantity);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Remove Item
    public void removeItemFromCart(int cartId, int productId) {
        String sql = "DELETE FROM Cart_Item WHERE Cart_Id = ? AND Product_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartId);
            pstmt.setInt(2, productId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Clear Cart
    public void clearCart(int cartId) {
        String sql = "DELETE FROM Cart_Item WHERE Cart_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Get Cart Items (with Product details)
    public Cart getCartByUserId(int userId) {
        Cart cart = new Cart();
        int cartId = getCartIdByUserId(userId);
        if (cartId == -1) return cart; // Empty cart

        String sql = "SELECT ci.Cart_Item_Quantity, p.*, " +
                "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                "FROM Cart_Item ci " +
                "JOIN Product p ON ci.Product_Id = p.Product_Id " +
                "WHERE ci.Cart_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, cartId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductDTO product = new ProductDTO();
                    product.setProductId(rs.getInt("Product_Id"));
                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                    // ⭐ 关键修改：必须设置库存数量，否则前端获取到的库存为0，无法操作
                    product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));

                    CartItem item = new CartItem(product, rs.getInt("Cart_Item_Quantity"));
                    cart.addItem(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cart;
    }
}