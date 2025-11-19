<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    class ChartSong {
        int rank; String title, artist;
        ChartSong(int r, String t, String a){ rank=r; title=t; artist=a; }
    }
    java.util.List<ChartSong> chart = new java.util.ArrayList<>();
    chart.add(new ChartSong(1,  "Golden",      "HUNTR/X, EJAE, AUDREY NUNA"));
    chart.add(new ChartSong(2,  "뛰어(JUMP)",   "BLACKPINK"));
    chart.add(new ChartSong(3,  "Supernova",   "aespa"));
    chart.add(new ChartSong(4,  "Love 119",    "RIIZE"));
    chart.add(new ChartSong(5,  "Seven",       "정국 (Jungkook) feat. Latto"));
    chart.add(new ChartSong(6,  "Spicy",       "aespa"));
    chart.add(new ChartSong(7,  "Ditto",       "NewJeans"));
    chart.add(new ChartSong(8,  "Drama",       "aespa"));
    chart.add(new ChartSong(9,  "ETA",         "NewJeans"));
    chart.add(new ChartSong(10, "Shut Down",   "BLACKPINK"));
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>TomaToma - 인기차트</title>

  <!-- Bootstrap & 폰트 (index.jsp와 동일하게) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">

  <style>
    body { background-color: #f8f9fa; font-family: 'Noto Sans KR', sans-serif; }
    .navbar-top { background-color: #fff; padding: 20px 0; }
    .navbar-top .container { max-width: 1200px; position: relative; }
    .navbar-brand span { font-family: 'Poppins', sans-serif; font-weight: 1000 !important; color: #d24949; font-size: 1.8rem; }
    .form-control { max-width: 400px; }
    .btn-main { background-color: #D24949; color: white; border-radius: 20px; }
    .btn-main:hover { background-color: #b03b3b; color: white; }
    .top-right-logo { width:40px; height:40px; object-fit:cover; position:absolute; top:50%; right:0; transform:translateY(-50%); }
    .navbar-menu { background-color: #fff; border-bottom: 1px solid #f5c2c2; }
    .navbar-menu .nav-link.active { color: #e60023 !important; font-weight: bold; }
    .album-card img { border-radius: 10px; transition: transform 0.3s ease; }
    .album-card:hover img { transform: scale(1.05); box-shadow: 0 4px 12px rgba(0,0,0,0.2); }
    .playlist-header { display: flex; justify-content: space-between; align-items: center; }
    .player-bar { background-color: #ffffff; border-top: 3px solid #d24949; }
  </style>
</head>
<body>


  <nav class="navbar navbar-expand-lg navbar-top">
    <div class="container">
      <a class="navbar-brand d-flex align-items-center" href="index.jsp"><span>TomaToma</span></a>
      <form class="d-flex ms-3" role="search" style="flex-grow:1;">
        <input class="form-control form-control-sm me-2" type="search" placeholder="검색" aria-label="Search">
        <button class="btn btn-main btn-sm" type="submit">검색</button>
      </form>
      <img src="image/토마토.png" alt="작은 로고" class="top-right-logo">
    </div>
  </nav>

  <!-- 메뉴바 (여기서만 ‘인기차트’에 active) -->
  <nav class="navbar navbar-menu">
    <div class="container d-flex justify-content-center" style="max-width:1200px;">
      <ul class="navbar-nav d-flex flex-row">
        <li class="nav-item mx-3"><a class="nav-link" href="index.jsp">홈</a></li>
        <li class="nav-item mx-3"><a class="nav-link active" href="chart.jsp">인기차트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">최신곡</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">플레이리스트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">마이페이지</a></li>
      </ul>
    </div>
  </nav>

  <div class="container my-4" style="max-width:1200px;">
    <div class="row">
      <!-- 왼쪽: 인기차트 -->
      <div class="col-md-9">
        <h4 class="fw-bold mb-1">인기차트 TOP10</h4>
        <p class="text-muted small mb-3">
          2025.10.01 <span class="text-danger fw-semibold">18:00</span>
        </p>

        <ul class="list-group mb-4">
          <% for(ChartSong s : chart) { %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              <span>
                <strong><%=s.rank%>.</strong>
                <%=s.title%> - <span class="text-muted"><%=s.artist%></span>
              </span>
              <button class="btn btn-main btn-sm">▶</button>
            </li>
          <% } %>
        </ul>
      </div>

      <!-- 오른쪽: 로그인 / 플레이리스트 -->
      <div class="col-md-3">
        <div class="card shadow-sm mb-4">
          <div class="card-body text-center">
            <h6 class="fw-bold mb-3">로그인</h6>
            <button class="btn btn-main w-100 mb-2">로그인</button>
            <a href="#" class="d-block small text-muted">회원가입</a>
          </div>
        </div>

        <div class="card shadow-sm">
          <div class="card-body">
            <div class="playlist-header">
              <h6 class="fw-bold mb-3">나의 플레이리스트</h6>
              <button class="btn btn-sm btn-outline-danger">＋</button>
            </div>
            <ul class="list-group list-group-flush">
              <li class="list-group-item">플레이리스트1</li>
              <li class="list-group-item">플레이리스트2</li>
              <li class="list-group-item">플레이리스트3</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 하단 플레이어 (index.jsp 거 그대로, currentSong 같은거 안 씀) -->
  <nav class="navbar fixed-bottom player-bar">
    <div class="container" style="max-width:1200px;">
      <div class="d-flex justify-content-between align-items-center w-100">
        <span class="text-dark">재생 중: <b>선택된 곡 없음</b></span>
        <div>
          <button class="btn btn-outline-danger btn-sm">⏮</button>
          <button class="btn btn-outline-danger btn-sm">▶</button>
          <button class="btn btn-outline-danger btn-sm">⏭</button>
        </div>
      </div>
    </div>
  </nav>

  <!-- Bootstrap JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
