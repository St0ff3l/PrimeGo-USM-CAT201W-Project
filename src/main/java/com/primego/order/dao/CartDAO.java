package com.primego.order.dao;

import com.primego.common.util.DBUtil;
import com.primego.order.model.Cart;
import com.primego.order.model.CartItem;
import com.primego.product.model.ProductDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    // Retrieves the user's cart id; creates a new cart row if none exists.
    public int getOrCreateCartId(int userId) {
        int cartId = getCartIdByUserId(userId);
        if (cartId == -1) {
            cartId = createCart(userId);
        }
        return cartId;
    }

    // Looks up the cart id for a user. Returns -1 when the user has no cart.
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

    // Creates an empty cart for the user and returns the generated cart id.
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

    // Adds an item to the cart; if the item already exists, increments its quantity.
    public void addItemToCart(int cartId, int productId, int quantity) {
        // If the item is already in the cart, increase its quantity; otherwise insert a new row.
        int existingQuantity = getItemQuantity(cartId, productId);
        if (existingQuantity > 0) {
            updateItemQuantity(cartId, productId, existingQuantity + quantity);
        } else {
            insertCartItem(cartId, productId, quantity);
        }
    }

    // Returns the quantity of a product currently in the cart. Returns 0 if not present.
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

    // Public wrapper around the internal quantity update helper.
    public void updateItemQuantityPublic(int cartId, int productId, int quantity) {
        updateItemQuantity(cartId, productId, quantity);
    }

    // Updates an item's quantity in the cart.
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

    // Inserts a new cart item row.
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

    // Removes a single product from the cart.
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

    // Removes all items from the cart.
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

    // Loads the cart for a user, including product details for each cart item.
    public Cart getCartByUserId(int userId) {
        Cart cart = new Cart();
        int cartId = getCartIdByUserId(userId);
        if (cartId == -1) return cart; // No cart found

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

                    // Merchant_Id is required by downstream order logic (for example, splitting an order by merchant).
                    product.setMerchantId(rs.getInt("Merchant_Id"));
                    // Category_Id is also included for completeness.
                    product.setCategoryId(rs.getInt("Category_Id"));

                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                    // Populate the product stock quantity.
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