<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DB Test</title>
</head>
<body>
<%
    Connection conn = ConnectionManager.getConnection();
    if (conn != null) {
        out.println("DB 연결 성공");
        conn.close();
    } else {
        out.println("DB 연결 실패");
    }
%>
</body>
</html>
