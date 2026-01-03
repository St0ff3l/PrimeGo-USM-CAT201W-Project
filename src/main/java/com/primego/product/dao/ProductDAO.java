package com.primego.product.dao;

import com.primego.common.util.DBUtil;
import com.primego.product.model.Product;
import com.primego.product.model.ProductDTO;
import com.primego.product.model.ProductImage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<ProductDTO> getProductsByMerchantId(int merchantId) {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.*, c.Category_Name, " +
                     "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                     "FROM Product p " +
                     "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                     "WHERE p.Merchant_Id = ? " +
                     "ORDER BY p.Product_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, merchantId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductDTO product = new ProductDTO();
                    product.setProductId(rs.getInt("Product_Id"));
                    product.setMerchantId(rs.getInt("Merchant_Id"));
                    product.setCategoryId(rs.getInt("Category_Id"));
                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));
                    product.setProductStatus(rs.getString("Product_Status"));
                    product.setProductCreatedAt(rs.getTimestamp("Product_Created_At"));
                    product.setProductUpdatedAt(rs.getTimestamp("Product_Updated_At"));

                    product.setCategoryName(rs.getString("Category_Name"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public List<ProductDTO> getAllProducts() {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.*, c.Category_Name, " +
                     "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                     "FROM Product p " +
                     "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                     "WHERE p.Product_Status = 'ON_SALE' " +
                     "ORDER BY p.Product_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProductDTO product = new ProductDTO();
                product.setProductId(rs.getInt("Product_Id"));
                product.setMerchantId(rs.getInt("Merchant_Id"));
                product.setCategoryId(rs.getInt("Category_Id"));
                product.setProductName(rs.getString("Product_Name"));
                product.setProductDescription(rs.getString("Product_Description"));
                product.setProductPrice(rs.getBigDecimal("Product_Price"));
                product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));
                product.setProductStatus(rs.getString("Product_Status"));
                product.setProductCreatedAt(rs.getTimestamp("Product_Created_At"));
                product.setProductUpdatedAt(rs.getTimestamp("Product_Updated_At"));

                product.setCategoryName(rs.getString("Category_Name"));
                product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                products.add(product);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public List<ProductDTO> getProductsByCategoryId(int categoryId) {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.*, c.Category_Name, " +
                     "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                     "FROM Product p " +
                     "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                     "WHERE p.Category_Id = ? AND p.Product_Status = 'ON_SALE' " +
                     "ORDER BY p.Product_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, categoryId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductDTO product = new ProductDTO();
                    product.setProductId(rs.getInt("Product_Id"));
                    product.setMerchantId(rs.getInt("Merchant_Id"));
                    product.setCategoryId(rs.getInt("Category_Id"));
                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));
                    product.setProductStatus(rs.getString("Product_Status"));
                    product.setProductCreatedAt(rs.getTimestamp("Product_Created_At"));
                    product.setProductUpdatedAt(rs.getTimestamp("Product_Updated_At"));

                    product.setCategoryName(rs.getString("Category_Name"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public List<ProductDTO> searchProducts(String keyword) {
        List<ProductDTO> products = new ArrayList<>();
        String sql = "SELECT p.*, c.Category_Name, " +
                     "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                     "FROM Product p " +
                     "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                     "WHERE (p.Product_Name LIKE ? OR p.Product_Description LIKE ?) AND p.Product_Status = 'ON_SALE' " +
                     "ORDER BY p.Product_Created_At DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductDTO product = new ProductDTO();
                    product.setProductId(rs.getInt("Product_Id"));
                    product.setMerchantId(rs.getInt("Merchant_Id"));
                    product.setCategoryId(rs.getInt("Category_Id"));
                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));
                    product.setProductStatus(rs.getString("Product_Status"));
                    product.setProductCreatedAt(rs.getTimestamp("Product_Created_At"));
                    product.setProductUpdatedAt(rs.getTimestamp("Product_Updated_At"));

                    product.setCategoryName(rs.getString("Category_Name"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));

                    products.add(product);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }

    public ProductDTO getProductById(int productId) {
        ProductDTO product = null;
        // 关键修复：
        // 1. 表名从 User 改为 users
        // 2. 关联字段从 u.User_Id 改为 u.id
        // 3. 卖家名字段从 u.User_Username 改为 u.username
        String sql = "SELECT p.*, c.Category_Name, u.username as Merchant_Name, " +
                "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                "FROM Product p " +
                "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                "LEFT JOIN users u ON p.Merchant_Id = u.id " +
                "WHERE p.Product_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    product = new ProductDTO();
                    product.setProductId(rs.getInt("Product_Id"));
                    product.setMerchantId(rs.getInt("Merchant_Id"));
                    product.setCategoryId(rs.getInt("Category_Id"));
                    product.setProductName(rs.getString("Product_Name"));
                    product.setProductDescription(rs.getString("Product_Description"));
                    product.setProductPrice(rs.getBigDecimal("Product_Price"));
                    product.setProductStockQuantity(rs.getInt("Product_Stock_Quantity"));
                    product.setProductStatus(rs.getString("Product_Status"));
                    product.setProductCreatedAt(rs.getTimestamp("Product_Created_At"));
                    product.setProductUpdatedAt(rs.getTimestamp("Product_Updated_At"));

                    product.setCategoryName(rs.getString("Category_Name"));
                    product.setPrimaryImageUrl(rs.getString("Primary_Image"));
                    // 这里对应的别名是 Merchant_Name
                    product.setMerchantName(rs.getString("Merchant_Name"));
                }
            }
        } catch (SQLException e) {
            // 打印具体错误到控制台
            System.err.println("Database Error in getProductById: " + e.getMessage());
            e.printStackTrace();
        }
        return product;
    }

    // Helper method to get Category ID by name (assuming Category table exists)
    // If Category table doesn't exist yet, this might need adjustment.
    // For now, we'll try to select. If it fails or returns 0, we might need to handle it.
    public int getCategoryIdByName(String categoryName) {
        String sql = "SELECT Category_Id FROM Category WHERE Category_Name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, categoryName);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("Category_Id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0; // Not found
    }

    // Insert Product and return the generated ID
    public int insertProduct(Product product) {
        String sql = "INSERT INTO Product (Merchant_Id, Category_Id, Product_Name, Product_Description, " +
                     "Product_Price, Product_Stock_Quantity, Product_Status) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, product.getMerchantId());
            pstmt.setInt(2, product.getCategoryId());
            pstmt.setString(3, product.getProductName());
            pstmt.setString(4, product.getProductDescription());
            pstmt.setBigDecimal(5, product.getProductPrice());
            pstmt.setInt(6, product.getProductStockQuantity());
            pstmt.setString(7, product.getProductStatus());

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
        return -1; // Failure
    }

    public boolean insertProductImage(ProductImage image) {
        String sql = "INSERT INTO Product_Image (Product_Id, Image_Url, Image_Is_Primary) VALUES (?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, image.getProductId());
            pstmt.setString(2, image.getImageUrl());
            pstmt.setBoolean(3, image.isImageIsPrimary());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
