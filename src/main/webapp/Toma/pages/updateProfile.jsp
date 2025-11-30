<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // 로그인 체크
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 업로드 저장 경로 (★ 네 폴더 구조 기준)
    String savePath = application.getRealPath("/Toma/uploads/profile");
    int maxSize = 10 * 1024 * 1024; // 10MB

    // MultipartRequest 생성
    MultipartRequest multi = new MultipartRequest(
        request,
        savePath,
        maxSize,
        "UTF-8",
        new DefaultFileRenamePolicy()
    );

    // 업로드된 파일명
    String newBg = multi.getFilesystemName("backgroundImg");
    String newProfile = multi.getFilesystemName("profileImg");

    // 텍스트 데이터
    String userName = multi.getParameter("userName");
    String userIntro = multi.getParameter("userIntro");

    // 기존 DB 값 불러오기
    String oldBg = "";
    String oldProfile = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = ConnectionManager.getConnection();

        // 기존 이미지 경로 조회
        String sql = "SELECT profile_img, background_img FROM playlist_iduser WHERE user_id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            oldProfile = rs.getString("profile_img");
            oldBg = rs.getString("background_img");
        }

        // 새 파일이 없으면 기존 파일 유지
        String profilePath = (newProfile != null)
                ? "/DBtest/Toma/uploads/profile/" + newProfile
                : oldProfile;

        String backgroundPath = (newBg != null)
                ? "/DBtest/Toma/uploads/profile/" + newBg
                : oldBg;

        // DB 업데이트
        sql = "UPDATE playlist_iduser SET username=?, intro=?, profile_img=?, background_img=? WHERE user_id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userName);
        pstmt.setString(2, userIntro);
        pstmt.setString(3, profilePath);
        pstmt.setString(4, backgroundPath);
        pstmt.setInt(5, userId);
        pstmt.executeUpdate();

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }

    // 저장 후 마이페이지 이동
    response.sendRedirect("mypage.jsp");
%>
