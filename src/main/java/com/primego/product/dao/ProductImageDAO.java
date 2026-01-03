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
     * 1. 插入单张图片
     * @return boolean 是否插入成功
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
     * 2. 根据商品ID获取所有图片
     * (主图排在第一位)
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
     * 3. 根据图片ID删除图片
     * (用于编辑页面，用户点击垃圾桶删除某张旧图)
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
     * 4. 删除某个商品的所有图片
     * (用于“删除商品”功能)
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
     * 5. (可选) 将该商品下所有图片设置为“非主图”
     * 场景：你想设置一张新图片为主图前，先调用这个，防止出现两张主图。
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
     * 6. 更新/设置主图逻辑 (旧逻辑兼容)
     * 逻辑：尝试把原来的主图路径改掉；如果原来没有主图，就插一张新的。
     */
    public void updateProductPrimaryImage(int productId, String imageUrl) {
        // 尝试更新现有的主图记录
        String updateSql = "UPDATE Product_Image SET Image_Url = ?, Image_Upload_Time = NOW() " +
                "WHERE Product_Id = ? AND Image_Is_Primary = 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(updateSql)) {

            pstmt.setString(1, imageUrl);
            pstmt.setInt(2, productId);

            int rows = pstmt.executeUpdate();

            // 如果没有更新到任何行 (说明之前没有主图)，则执行插入
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
    // ⭐ 7. 新增：这是你报错缺失的方法！
    // ==========================================

    /**
     * 批量更新主图状态：将指定的图片设为主图，其余设为非主图
     * @param productId 商品ID
     * @param primaryImageId 要设为主图的图片ID
     */
    public void updatePrimaryImage(int productId, int primaryImageId) {
        // 使用 CASE WHEN 语句一次性更新所有图片的状态
        // 只有 ID 等于 primaryImageId 的图片会被设为 1 (true)，该商品下的其他图片会被设为 0 (false)
        String sql = "UPDATE Product_Image SET Image_Is_Primary = (CASE WHEN Image_Id = ? THEN 1 ELSE 0 END) WHERE Product_Id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, primaryImageId); // 第一个参数：要成为主图的 ID
            pstmt.setInt(2, productId);      // 第二个参数：商品 ID

            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}