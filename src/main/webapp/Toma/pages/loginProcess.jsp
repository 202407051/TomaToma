<!-- loginProcess.jsp // 로그인 처리 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    request.setCharacterEncoding("UTF-8");

	// 폼 입력값 가져오기
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    // DB 연결 준비
    Connection conn = ConnectionManager.getConnection();
    PreparedStatement pstmt = null;
    ResultSet rs = null;

	// SQL 준비
    String sql = "SELECT user_id, username FROM playlist_iduser WHERE email=? AND password=?";

	// 값 채우기
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, email);
    pstmt.setString(2, password);

    // SQL 실행
    rs = pstmt.executeQuery();

    // 로그인 성공 처리
    if(rs.next()) {
        // 세션 저장
        session.setAttribute("user_id", rs.getInt("user_id"));
        session.setAttribute("username", rs.getString("username"));

        // 로그인 성공 → 마이페이지 이동
        response.sendRedirect("mypage.jsp");
    } else {
        out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다.');history.back();</script>");
    }

    rs.close();
    pstmt.close();
    conn.close();
%>
