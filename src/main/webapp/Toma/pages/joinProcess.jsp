<!-- joinProcess.jsp // 회원가입 처리 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    request.setCharacterEncoding("UTF-8");

	// 폼 입력값 가져오기
    String name = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    // DB 연결
    Connection conn = ConnectionManager.getConnection();
    // SQL 준비
    PreparedStatement pstmt = conn.prepareStatement(
        "INSERT INTO playlist_iduser(username, email, password) VALUES(?,?,?)"
    );

    // 값 채우기
    pstmt.setString(1, name);
    pstmt.setString(2, email);
    pstmt.setString(3, password);

    // SQL 실행
    int result = pstmt.executeUpdate();

    // 성공/실패 응답 처리
    if (result > 0) {
        out.println("<script>alert('회원가입 성공!'); location.href='login.jsp';</script>");
    } else {
        out.println("<script>alert('회원가입 실패'); history.back();</script>");
    }

    pstmt.close();
    conn.close();
%>
