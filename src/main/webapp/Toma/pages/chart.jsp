<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 컨텍스트 경로와 style.css 마지막 수정시각으로 캐시버스터 생성
    String ctx = request.getContextPath(); // 예: /JSP22
    long v = 1L;
    try {
        java.net.URL res = application.getResource("/css/style.css");
        if (res != null) {
            java.net.URLConnection conn = res.openConnection();
            v = conn.getLastModified(); // 파일이 바뀌면 자동으로 쿼리스트링 변경
        }
    } catch (Exception ignore) {}
%>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <title>인기차트</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=3" />
</head>
<body class="page-chart">

 <nav class="navbar navbar-expand-lg navbar-top">
    <div class="container">
      <a class="navbar-brand d-flex align-items-center" href="#"><span>TomaToma</span></a>
      <form class="d-flex ms-3" role="search" style="flex-grow:1;">
        <input class="form-control form-control-sm me-2" type="search" placeholder="검색" aria-label="Search">
        <button class="btn btn-main btn-sm" type="submit">검색</button>
      </form>
      <img src="image/토마토.png" alt="작은 로고" style="height:80px; width:80px;" class="top-right-logo">
    </div>
  </nav>

  <!-- 메뉴바 -->
  <nav class="navbar navbar-menu">
    <div class="container d-flex justify-content-center" style="max-width:1200px;">
      <ul class="navbar-nav d-flex flex-row">
        <li class="nav-item mx-3"><a class="nav-link active" href="/Toma/index.jsp">홈</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">인기차트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">최신곡</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">플레이리스트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">마이페이지</a></li>
      </ul>
    </div>
  </nav>
      <!-- 다크모드 토글 -->
      <button class="tt-dark-toggle" type="button" aria-pressed="false" aria-label="다크 모드 전환" id="darkToggle">🌓</button>

      <!-- 모바일 메뉴 버튼 -->
      <button class="tt-menu-toggle" type="button" aria-controls="mobileNav" aria-expanded="false" id="menuToggle">☰</button>
    </div>

    <!-- 모바일 내비 -->
    <nav id="mobileNav" class="tt-nav-mobile" hidden>
      <ul>
        <li><a href="index.jsp">홈</a></li>
        <li class="active"><a href="#popular">인기차트</a></li>
        <li><a href="#latest">최신차트</a></li>
        <li><a href="#artists">인기 아티스트</a></li>
        <li><a href="#playlist">내 플레이리스트</a></li>
      </ul>
    </nav>
  </header>

  <!-- 메인 -->
  <main id="popular" class="tt-main">
  <section class="chart-section">
    <h2 class="chart-title">인기차트 TOP10</h2>
    <p class="chart-time">2025.10.01 <span class="highlight">18:00</span></p>

    <ul class="chart-list">
      <li class="chart-item">
        <span class="rank">1</span>
        <div class="info">
          <p class="song">Golden</p>
          <p class="artist">HUNTR/X, EJAE, AUDREY NUNA</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">2</span>
        <div class="info">
          <p class="song">뛰어(JUMP)</p>
          <p class="artist">BLACKPINK</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">3</span>
        <div class="info">
          <p class="song">Supernova</p>
          <p class="artist">aespa</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">4</span>
        <div class="info">
          <p class="song">Love 119</p>
          <p class="artist">RIIZE</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">5</span>
        <div class="info">
          <p class="song">Seven</p>
          <p class="artist">정국 (Jungkook) feat. Latto</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">6</span>
        <div class="info">
          <p class="song">Spicy</p>
          <p class="artist">aespa</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">7</span>
        <div class="info">
          <p class="song">Ditto</p>
          <p class="artist">NewJeans</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">8</span>
        <div class="info">
          <p class="song">Drama</p>
          <p class="artist">aespa</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">9</span>
        <div class="info">
          <p class="song">ETA</p>
          <p class="artist">NewJeans</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
      <li class="chart-item">
        <span class="rank">10</span>
        <div class="info">
          <p class="song">Shut Down</p>
          <p class="artist">BLACKPINK</p>
        </div>
         <button class="play-btn" onclick="playMusic('Seven')">▶</button>
      </li>
    </ul>
  </section>
</main>


  <!-- JS -->
  <script>
    const root = document.documentElement;
    const darkBtn = document.getElementById('darkToggle');
    const saved = localStorage.getItem('tt-theme');
    if (saved === 'dark') root.classList.add('dark');
    if (darkBtn) {
      const syncPressed = () => darkBtn.setAttribute('aria-pressed', root.classList.contains('dark'));
      syncPressed();
      darkBtn.addEventListener('click', () => {
        root.classList.toggle('dark');
        localStorage.setItem('tt-theme', root.classList.contains('dark') ? 'dark' : 'light');
        syncPressed();
      });
    }

    const menuBtn = document.getElementById('menuToggle');
    const mobileNav = document.getElementById('mobileNav');
    if (menuBtn && mobileNav) {
      menuBtn.addEventListener('click', () => {
        const open = mobileNav.hasAttribute('hidden') === false;
        if (open) {
          mobileNav.setAttribute('hidden', '');
          menuBtn.setAttribute('aria-expanded', 'false');
        } else {
          mobileNav.removeAttribute('hidden');
          menuBtn.setAttribute('aria-expanded', 'true');
        }
      });
    }
  </script>
</body>
</html>
