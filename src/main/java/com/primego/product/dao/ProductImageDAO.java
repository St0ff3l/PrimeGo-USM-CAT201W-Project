package com.primego.product.dao;

import com.primego.common.util.DBUtil;
import com.primego.product.model.ProductImage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProductImageDAO {

    /**
     * Inserts a single product image record.
     *
     * @return true if the insert succeeds
     */
    public boolean insertImage(ProductImage image) {
        String sql = "INSERT INTO Product_Image (Product_Id, Image_Url, Image_Is_Primary) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, image.getProductId());
            pstmt.setString(2, image.getImageUrl());
            pstmt.setBoolean(3, image.isImageIsPrimary());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns all images for a product id.
     * Primary images (if any) are ordered first.
     */
    public List<ProductImage> getImagesByProductId(int productId) {
        List<ProductImage> images = new ArrayList<>();
        String sql = "SELECT * FROM Product_Image WHERE Product_Id = ? ORDER BY Image_Is_Primary DESC, Image_Id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductImage img = new ProductImage();
                    img.setImageId(rs.getInt("Image_Id"));
                    img.setProductId(rs.getInt("Product_Id"));
                    img.setImageUrl(rs.getString("Image_Url"));
                    img.setImageIsPrimary(rs.getBoolean("Image_Is_Primary"));
                    images.add(img);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return images;
    }

    /**
     * Deletes a single image by its image id.
     * Typically used when removing an existing image from an edit page.
     */
    public boolean deleteImageById(int imageId) {
        String sql = "DELETE FROM Product_Image WHERE Image_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, imageId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Deletes all images for the given product id.
     * Typically used when a product is deleted.
     */
    public void deleteImagesByProductId(int productId) {
        String sql = "DELETE FROM Product_Image WHERE Product_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Clears the primary-image flag for all images of a product.
     * Call this before setting a new primary image to ensure there is only one.
     */
    public void unsetAllPrimaryImages(int productId) {
        String sql = "UPDATE Product_Image SET Image_Is_Primary = 0 WHERE Product_Id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Updates the existing primary image URL for a product.
     * If no primary image exists, inserts a new primary image record.
     */
    public void updateProductPrimaryImage(int productId, String imageUrl) {
        // Try updating the current primary image record.
        String updateSql = "UPDATE Product_Image SET Image_Url = ?, Image_Upload_Time = NOW() " +
                "WHERE Product_Id = ? AND Image_Is_Primary = 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(updateSql)) {

            pstmt.setString(1, imageUrl);
            pstmt.setInt(2, productId);

            int rows = pstmt.executeUpdate();

            // If no row was updated, insert a new primary image.
            if (rows == 0) {
                String insertSql = "INSERT INTO Product_Image (Product_Id, Image_Url, Image_Is_Primary) VALUES (?, ?, 1)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setInt(1, productId);
                    insertStmt.setString(2, imageUrl);
                    insertStmt.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ==========================================
    // Primary image update
    // ==========================================

    /**
     * Sets the specified image as the primary image for the product.
     * All other images for the product are set to non-primary.
     */
    public void updatePrimaryImage(int productId, int primaryImageId) {
        // Single statement update: set Image_Is_Primary based on whether the row id matches.
        String sql = "UPDATE Product_Image SET Image_Is_Primary = (CASE WHEN Image_Id = ? THEN 1 ELSE 0 END) WHERE Product_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, primaryImageId);
            pstmt.setInt(2, productId);

            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}