<!-- checkEmail.jsp // 이메일 중복 체크 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
	// 클라이언트로부터 email 파라미터 받음
    String email = request.getParameter("email");

	// 이메일이 DB에 존재하는지 확인
    Connection conn = ConnectionManager.getConnection();
    PreparedStatement pstmt = conn.prepareStatement(
        "SELECT email FROM playlist_iduser WHERE email=?"
    );
    pstmt.setString(1, email);
	
    // 조회 결과 받기
    ResultSet rs = pstmt.executeQuery();

    // 이메일 중복 여부 판단
    if (rs.next()) {
        out.print("<span style='color:red;'>이미 사용 중입니다.</span>");
    } else {
        out.print("<span style='color:green;'>사용 가능합니다!</span>");
    }

    rs.close();
    pstmt.close();
    conn.close();
%>
