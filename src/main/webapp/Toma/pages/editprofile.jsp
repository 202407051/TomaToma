<!-- editprofile.jsp // 프로필 수정 화면 -->
<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
	// 로그인 체크 / 로그인 안 했으면 로그인 페이지로 이동
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 프로필 기본 변수 선언
    String userName = "";
    String userIntro = "";
    String profileImg = "";
    String backgroundImg = "";

    // DB에서 사용자 정보 불러오기
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
    	// DB 연결 생성
        conn = ConnectionManager.getConnection();
		// SQL 준비 (로그인한 id로 프로필 정보 가져옴)
    	String sql = "SELECT username, intro, profile_img, background_img FROM playlist_iduser WHERE user_id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        // 불러온 데이터 변수에 저장
        if(rs.next()) {
            userName = rs.getString("username");
            userIntro = rs.getString("intro") == null ? "" : rs.getString("intro");
            profileImg = rs.getString("profile_img");
            backgroundImg = rs.getString("background_img");
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs!=null) rs.close();
        if(pstmt!=null) pstmt.close();
        if(conn!=null) conn.close();
    }
%>

<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TomaToma - 프로필 수정</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">
  <style>
    <!-- CSS -->
    body { background-color: #f8f9fa; font-family: 'Noto Sans KR', sans-serif; }

    .navbar-top { background-color: #fff; padding: 20px 0; }
    .navbar-top .container { max-width: 1200px; position: relative; }
    .navbar-brand span { font-family: 'Poppins', sans-serif; font-weight: 1000 !important; color: #d24949; font-size: 1.8rem; }
    .btn-main { background-color: #D24949; color: white; border-radius: 20px; }
    .btn-main:hover { background-color: #b03b3b; color: white; }

    .form-section {
      background-color: #fff;
      border-radius: 15px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      padding: 30px;
      max-width: 800px;
      margin: 40px auto;
    }

    .form-section h4 {
      color: #d24949;
      font-weight: bold;
      margin-bottom: 25px;
    }

    .preview-img {
      width: 120px;
      height: 120px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #ddd;
      display: block;
      margin-bottom: 10px;
    }

    .preview-bg {
      width: 100%;
      height: 150px;
      border-radius: 10px;
      object-fit: cover;
      margin-bottom: 10px;
    }
  </style>
</head>
<body>

	<!-- 상단 로고 -->
	<nav class="navbar navbar-expand-lg navbar-top">
	  <div class="container">
	    <a class="navbar-brand d-flex align-items-center" href="index.jsp">
	      <img src="<%=request.getContextPath()%>/Toma/images/logo.png" 
	           alt="TomaToma Logo" 
	           style="height: 55px;">
	    </a>
	  </div>
	</nav>

  <!-- 프로필 수정 폼 -->
  <div class="form-section">
    <h4>프로필 수정</h4>
    
	<!-- submit 시 updateProfile.jsp로 전송됨 -->
    <form action="updateProfile.jsp" method="post" enctype="multipart/form-data">
      <!-- 배경 사진 -->
      <div class="mb-4">
        <label class="form-label fw-bold">배경 사진</label>
        <img src="<%=backgroundImg%>" class="preview-bg" id="bgPreview">
        <input type="file" class="form-control" name="backgroundImg" accept="image/*" onchange="previewImage(event, 'bgPreview')">
      </div>

      <!-- 프로필 사진 -->
      <div class="mb-4">
        <label class="form-label fw-bold">프로필 사진</label>
        <img src="<%=profileImg%>" class="preview-img" id="profilePreview">
        <input type="file" class="form-control" name="profileImg" accept="image/*" onchange="previewImage(event, 'profilePreview')">
      </div>

      <!-- 이름 / DB에서 불러온 이름 자동으로 입력됨 -->
      <div class="mb-3">
        <label class="form-label fw-bold">이름</label>
        <input type="text" class="form-control" name="userName" value="<%=userName%>" required>
      </div>

      <!-- 소개글 -->
      <div class="mb-3">
        <label class="form-label fw-bold">소개글</label>
        <textarea class="form-control" name="userIntro" rows="3"><%=userIntro%></textarea>
      </div>

	  <!-- 저장버튼 -->
      <div class="d-flex justify-content-between mt-4">
        <a href="mypage.jsp" class="btn btn-outline-secondary">취소</a>
        <button type="submit" class="btn btn-main">저장하기</button>
      </div>
    </form>
  </div>

  <script>
    // 이미지 미리보기 기능(js)
    function previewImage(event, previewId) {
      const reader = new FileReader();
      reader.onload = function(){
        const output = document.getElementById(previewId);
        output.src = reader.result;
      };
      reader.readAsDataURL(event.target.files[0]);
    }
  </script>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
