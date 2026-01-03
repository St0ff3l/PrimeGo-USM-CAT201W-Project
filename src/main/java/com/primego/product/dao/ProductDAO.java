package com.primego.product.dao;

import com.primego.common.util.DBUtil;
import com.primego.product.model.Product;
import com.primego.product.model.ProductDTO;
import com.primego.product.model.ProductImage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    // ==========================================
    // 查询方法 (保持不变)
    // ==========================================

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

    public List<ProductDTO> searchProductsWithFilter(String keyword, Integer categoryId, Double minPrice, Double maxPrice) {
        List<ProductDTO> products = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.*, c.Category_Name, " +
                "(SELECT Image_Url FROM Product_Image pi WHERE pi.Product_Id = p.Product_Id AND pi.Image_Is_Primary = 1 LIMIT 1) as Primary_Image " +
                "FROM Product p " +
                "LEFT JOIN Category c ON p.Category_Id = c.Category_Id " +
                "WHERE p.Product_Status = 'ON_SALE' ");

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.Product_Name LIKE ? OR p.Product_Description LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (categoryId != null) {
            sql.append("AND p.Category_Id = ? ");
            params.add(categoryId);
        }

        if (minPrice != null) {
            sql.append("AND p.Product_Price >= ? ");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append("AND p.Product_Price <= ? ");
            params.add(maxPrice);
        }

        sql.append("ORDER BY p.Product_Created_At DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

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
                    product.setMerchantName(rs.getString("Merchant_Name"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Database Error in getProductById: " + e.getMessage());
            e.printStackTrace();
        }
        return product;
    }

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

    // ==========================================
    // 插入方法 (保持不变)
    // ==========================================

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



    // ==========================================
    // ⭐ 新增：更新方法 (用于 product_edit.jsp)
    // ==========================================

    /**
     * 更新商品基本信息
     */
    public boolean updateProduct(Product product) {
        String sql = "UPDATE Product SET " +
                "Category_Id = ?, Product_Name = ?, Product_Description = ?, " +
                "Product_Price = ?, Product_Stock_Quantity = ?, Product_Status = ?, " +
                "Product_Updated_At = NOW() " +
                "WHERE Product_Id = ? AND Merchant_Id = ?"; // 增加Merchant_Id校验防止越权

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, product.getCategoryId());
            pstmt.setString(2, product.getProductName());
            pstmt.setString(3, product.getProductDescription());
            pstmt.setBigDecimal(4, product.getProductPrice());
            pstmt.setInt(5, product.getProductStockQuantity());
            pstmt.setString(6, product.getProductStatus());

            // WHERE 条件
            pstmt.setInt(7, product.getProductId());
            pstmt.setInt(8, product.getMerchantId());

            int rows = pstmt.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}