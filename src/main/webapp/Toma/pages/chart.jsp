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

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">

  <!-- 공통 CSS -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">
</head>
<body>

<!-- ★ header.jsp 그대로 포함 -->
<%@ include file="../include/header.jsp" %>

<!-- 메뉴바 active 설정을 위해 간단히 JS로 처리 -->
<script>
  // chart.jsp일 경우 "인기차트" 메뉴 활성화
  document.addEventListener("DOMContentLoaded", () => {
    const links = document.querySelectorAll(".navbar-menu .nav-link");
    links.forEach(link => {
      if (link.textContent.includes("인기차트")) {
        link.classList.add("active");
      }
    });
  });
</script>

<div class="container my-4" style="max-width:1200px;">
  <div class="row">

    <!-- 왼쪽 영역 -->
    <div class="col-md-9">
      <h4 class="fw-bold mb-1">인기차트 TOP 10</h4>

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

    <!-- 오른쪽(로그인 + 플레이리스트) → index.jsp 그대로 유지 -->
    <div class="col-md-3">
      <div class="card shadow-sm mb-4">
        <div class="card-body text-center">
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

<!-- index.jsp와 동일한 플레이어 바 -->
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
