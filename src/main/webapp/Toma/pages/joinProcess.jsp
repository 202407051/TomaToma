<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = ConnectionManager.getConnection();
    PreparedStatement pstmt = conn.prepareStatement(
        "INSERT INTO user(username, email, password) VALUES(?,?,?)"
    );

    pstmt.setString(1, name);
    pstmt.setString(2, email);
    pstmt.setString(3, password);

    int result = pstmt.executeUpdate();

    if (result > 0) {
        out.println("<script>alert('회원가입 성공!'); location.href='login.jsp';</script>");
    } else {
        out.println("<script>alert('회원가입 실패'); history.back();</script>");
    }

    pstmt.close();
    conn.close();
%>
