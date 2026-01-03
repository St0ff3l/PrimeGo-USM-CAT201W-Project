package com.primego.product.dao;

import com.primego.common.util.DBUtil;
import com.primego.product.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findAll() {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT * FROM Category WHERE Category_Status = 1 ORDER BY Category_Id ASC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("Category_Id"));
                category.setCategoryName(rs.getString("Category_Name"));
                category.setCategoryStatus(rs.getInt("Category_Status"));
                category.setCategoryCreatedAt(rs.getTimestamp("Category_Created_At"));
                categories.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }
}
