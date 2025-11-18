<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 예시: 기존 사용자 정보 (DB 연동 전 임시 데이터)
    String userName = "최예나";
    String userIntro = "소개글을 등록해주세요.";
    String profileImg = "image/profile_sample.png";
    String backgroundImg = "image/profile_bg.png";
%>

<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TomaToma - 프로필 수정</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">
  <style>
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
      <a class="navbar-brand d-flex align-items-center" href="index.jsp"><span>TomaToma</span></a>
      <img src="image/토마토.png" alt="작은 로고" style="height:80px; width:80px; position:absolute; right:0;">
    </div>
  </nav>

  <!-- 프로필 수정 폼 -->
  <div class="form-section">
    <h4>프로필 수정</h4>

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

      <!-- 이름 -->
      <div class="mb-3">
        <label class="form-label fw-bold">이름</label>
        <input type="text" class="form-control" name="userName" value="<%=userName%>" required>
      </div>

      <!-- 소개글 -->
      <div class="mb-3">
        <label class="form-label fw-bold">소개글</label>
        <textarea class="form-control" name="userIntro" rows="3"><%=userIntro%></textarea>
      </div>

      <div class="d-flex justify-content-between mt-4">
        <a href="mypage.jsp" class="btn btn-outline-secondary">취소</a>
        <button type="submit" class="btn btn-main">저장하기</button>
      </div>
    </form>
  </div>

  <script>
    // 미리보기 기능
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
