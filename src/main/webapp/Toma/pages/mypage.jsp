<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 예시 데이터
    String userName = "최예나";
    String userIntro = "소개글을 등록해주세요.";
    String profileImg = "image/profile_sample.png";
    String backgroundImg = "image/profile_bg.png";

    java.util.List<String> myPlaylists = java.util.Arrays.asList("공부할 때 듣는 음악", "감성 팝", "드라이브 플레이리스트");
    java.util.List<String> likedSongs = java.util.Arrays.asList("노래1 - 아티스트A", "노래2 - 아티스트B", "노래3 - 아티스트C");
%>

<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TomaToma - 마이페이지</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">
  <style>
    body { background-color: #f8f9fa; font-family: 'Noto Sans KR', sans-serif; }

    /* 공통 상단 스타일 */
    .navbar-top { background-color: #fff; padding: 20px 0; }
    .navbar-top .container { max-width: 1200px; position: relative; }
    .navbar-brand span { font-family: 'Poppins', sans-serif; font-weight: 1000 !important; color: #d24949; font-size: 1.8rem; }
    .form-control { max-width: 400px; }
    .btn-main { background-color: #D24949; color: white; border-radius: 20px; }
    .btn-main:hover { background-color: #b03b3b; color: white; }
    .navbar-menu { background-color: #fff; border-bottom: 1px solid #f5c2c2; }
    .navbar-menu .nav-link.active { color: #e60023 !important; font-weight: bold; }

    /* 프로필 카드 */
    .profile-card {
      background-color: #fff;
      border-radius: 15px;
      overflow: hidden;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      margin-bottom: 30px;
    }
    .profile-header {
      background-image: url('<%=backgroundImg%>');
      background-size: cover;
      background-position: center;
      height: 150px;
      position: relative;
    }
    .profile-info {
      display: flex;
      align-items: center;
      padding: 20px;
    }
    .profile-pic {
      width: 100px;
      height: 100px;
      border-radius: 50%;
      overflow: hidden;
      border: 3px solid #fff;
      margin-right: 20px;
      position: relative;
      top: -50px;
      background-color: #f1f1f1;
    }
    .profile-pic img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .upload-btn {
      font-size: 0.8rem;
      background-color: #D24949;
      color: white;
      border: none;
      border-radius: 10px;
      padding: 4px 10px;
      margin-top: 8px;
    }
    .playlist-section, .liked-section {
      background-color: #fff;
      border-radius: 15px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
      padding: 20px;
      margin-bottom: 30px;
    }
    .playlist-section h5, .liked-section h5 {
      color: #d24949;
      font-weight: bold;
    }
  </style>
</head>
<body>

  <!-- 상단 로고 + 검색창 -->
  <nav class="navbar navbar-expand-lg navbar-top">
    <div class="container">
      <a class="navbar-brand d-flex align-items-center" href="index.jsp"><span>TomaToma</span></a>
      <form class="d-flex ms-3" role="search" style="flex-grow:1;">
        <input class="form-control form-control-sm me-2" type="search" placeholder="검색" aria-label="Search">
        <button class="btn btn-main btn-sm" type="submit">검색</button>
      </form>
      <img src="image/토마토.png" alt="작은 로고" style="height:80px; width:80px; position:absolute; right:0;">
    </div>
  </nav>

  <!-- 메뉴바 -->
  <nav class="navbar navbar-menu">
    <div class="container d-flex justify-content-center" style="max-width:1200px;">
      <ul class="navbar-nav d-flex flex-row">
        <li class="nav-item mx-3"><a class="nav-link" href="index.jsp">홈</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">인기차트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">최신곡</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">플레이리스트</a></li>
        <li class="nav-item mx-3"><a class="nav-link active" href="mypage.jsp">마이페이지</a></li>
      </ul>
    </div>
  </nav>

  <!-- 마이페이지 본문 -->
  <div class="container my-4" style="max-width:1200px;">

    <!-- 프로필 -->
    <div class="profile-card">
      <div class="profile-header"></div>
      <div class="profile-info">
        <div class="profile-pic">
          <img src="<%=profileImg%>" alt="프로필 사진">
          <button class="upload-btn w-100">사진 업로드</button>
        </div>
        <div>
          <h4 class="fw-bold mb-1"><%=userName%></h4>
          <p class="text-muted mb-1"><%=userIntro%></p>
		  <a href="editprofile.jsp" class="btn btn-outline-danger btn-sm">프로필 수정</a>
        </div>
      </div>
    </div>

    <!-- 나의 플레이리스트 -->
    <div class="playlist-section">
      <h5>나의 플레이리스트</h5>
      <div class="list-group mt-3">
        <% for(String pl : myPlaylists) { %>
          <a href="#" class="list-group-item list-group-item-action"><%=pl%></a>
        <% } %>
      </div>
    </div>

    <!-- 내가 좋아하는 곡 -->
    <div class="liked-section">
      <h5>내가 좋아하는 곡</h5>
      <ul class="list-group mt-3">
        <% for(String song : likedSongs) { %>
          <li class="list-group-item d-flex justify-content-between align-items-center">
            <%=song%>
            <button class="btn btn-sm btn-outline-danger">재생</button>
          </li>
        <% } %>
      </ul>
    </div>

  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
