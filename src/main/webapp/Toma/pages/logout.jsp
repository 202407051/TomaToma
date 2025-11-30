<!-- logout.jsp // 로그아웃 -->
<%
	//세션 삭제, 로그아웃 후 로그인 페이지로 이동
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
