package com.toma.db;

import java.sql.Connection;
import java.sql.DriverManager;

public class ConnectionManager {

    private static final String URL =
            "jdbc:mysql://localhost:3306/tomatoma?serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASS = "1234";  // 네 비밀번호로

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASS);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}
