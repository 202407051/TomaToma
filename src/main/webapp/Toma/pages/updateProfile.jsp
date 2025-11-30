<%@ page import="com.toma.dao.UserDAO" %>
<%@ page import="java.io.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String email = (String) session.getAttribute("loginUser");
    if(email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String uploadPath = application.getRealPath("/uploads");
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    String username = request.getParameter("userName");
    String intro = request.getParameter("userIntro");

    String profileImg = null;
    String backgroundImg = null;

    // 프로필 이미지 업로드
    if(request.getPart("profileImg") != null && request.getPart("profileImg").getSize() > 0){
        String fileName = System.currentTimeMillis() + "_profile.png";
        request.getPart("profileImg").write(uploadPath + "/" + fileName);
        profileImg = "uploads/" + fileName;
    }

    // 배경 이미지 업로드
    if(request.getPart("backgroundImg") != null && request.getPart("backgroundImg").getSize() > 0){
        String fileName = System.currentTimeMillis() + "_bg.png";
        request.getPart("backgroundImg").write(uploadPath + "/" + fileName);
        backgroundImg = "uploads/" + fileName;
    }

    UserDAO.updateProfile(email, username, intro, profileImg, backgroundImg);

    response.sendRedirect("mypage.jsp");
%>
