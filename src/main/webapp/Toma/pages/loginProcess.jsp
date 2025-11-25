<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    request.setCharacterEncoding("UTF-8");

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = ConnectionManager.getConnection();
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String sql = "SELECT user_id, username FROM user WHERE email=? AND password=?";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, email);
    pstmt.setString(2, password);

    rs = pstmt.executeQuery();

    if(rs.next()) {
        session.setAttribute("user_id", rs.getInt("user_id"));
        session.setAttribute("username", rs.getString("username"));

        response.sendRedirect("mypage.jsp");
    } else {
        out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다.');history.back();</script>");
    }

    rs.close();
    pstmt.close();
    conn.close();
%>
