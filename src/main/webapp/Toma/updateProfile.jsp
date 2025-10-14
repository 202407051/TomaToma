<%@ page contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    String name = request.getParameter("name");
    String bio = request.getParameter("bio");

    // 파일 업로드는 나중에 구현 (지금은 텍스트만)
    session.setAttribute("userName", name);
    session.setAttribute("userBio", bio);

    response.sendRedirect("mypage.jsp");
%>
