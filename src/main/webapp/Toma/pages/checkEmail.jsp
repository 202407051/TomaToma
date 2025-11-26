<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String email = request.getParameter("email");

    Connection conn = ConnectionManager.getConnection();
    PreparedStatement pstmt = conn.prepareStatement(
        "SELECT email FROM playlist_iduser WHERE email=?"
    );
    pstmt.setString(1, email);

    ResultSet rs = pstmt.executeQuery();

    if (rs.next()) {
        out.print("<span style='color:red;'>이미 사용 중입니다.</span>");
    } else {
        out.print("<span style='color:green;'>사용 가능합니다!</span>");
    }

    rs.close();
    pstmt.close();
    conn.close();
%>
