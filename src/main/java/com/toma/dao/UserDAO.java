package com.toma.dao;

import java.sql.*;
import com.toma.db.ConnectionManager;

public class UserDAO {

    public static ResultSet getUserById(int userId) throws Exception {
        Connection conn = ConnectionManager.getConnection();
        String sql = "SELECT * FROM playlist_iduser WHERE user_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        return pstmt.executeQuery();
    }

    public static void updateProfile(int userId, String name, String intro,
                                     String profileImgPath, String bgImgPath) throws Exception {

        Connection conn = ConnectionManager.getConnection();

        StringBuilder sql = new StringBuilder("UPDATE playlist_iduser SET username=?, intro=?");

        if (profileImgPath != null)
            sql.append(", profile_img='").append(profileImgPath).append("'");

        if (bgImgPath != null)
            sql.append(", background_img='").append(bgImgPath).append("'");

        sql.append(" WHERE user_id=?");

        PreparedStatement pstmt = conn.prepareStatement(sql.toString());
        pstmt.setString(1, name);
        pstmt.setString(2, intro);
        pstmt.setInt(3, userId);

        pstmt.executeUpdate();
        pstmt.close();
        conn.close();
    }
}
