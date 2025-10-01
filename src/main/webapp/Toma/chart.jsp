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
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>TomaToma | 인기차트</title>

  <!-- 이 줄이 핵심: 모든 상대경로의 기준을 /JSP22/ 로 고정 -->
  <base href="<%= ctx %>/" />

  <!-- CSS: /JSP22/css/style.css 로 정확히 로드 + 캐시 무효화 -->
   <link rel="stylesheet" href="css/style.css?v=<%= v %>" />

  <!-- 파비콘/이미지도 이제 상대경로로 OK (기준은 /JSP22/) -->
  <link rel="icon" href="images/favicon.svg" type="image/svg+xml" />
</head>
<body>
  <!-- 헤더 -->
  <header class="tt-header">
    <div class="tt-wrap">
      <!-- 로고 -->
      <a class="tt-logo" href="/JSP22/index.jsp" aria-label="TomaToma 홈">
        <img src="images/logo-toma.svg" alt="TomaToma"
             onerror="this.closest('.tt-logo').classList.add('text'); this.remove();" />
        <span class="tt-logo-text">TomaToma</span>
      </a>

      <!-- 내비 -->
      <nav class="tt-nav" aria-label="주요 메뉴">
        <ul>
          <li><a href="index.jsp">홈</a></li>
          <li class="active"><a href="#popular">인기차트</a></li>
          <li><a href="#latest">최신차트</a></li>
          <li><a href="#artists">인기 아티스트</a></li>
          <li><a href="#playlist">내 플레이리스트</a></li>
        </ul>
      </nav>

      <!-- 검색 -->
      <form class="tt-search" role="search" action="search" method="get">
        <label for="q" class="sr-only">검색어</label>
        <input id="q" name="q" type="search" placeholder="곡/아티스트 검색" />
        <button type="submit">검색</button>
      </form>

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
      </li>
      <li class="chart-item">
        <span class="rank">2</span>
        <div class="info">
          <p class="song">뛰어(JUMP)</p>
          <p class="artist">BLACKPINK</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">3</span>
        <div class="info">
          <p class="song">Supernova</p>
          <p class="artist">aespa</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">4</span>
        <div class="info">
          <p class="song">Love 119</p>
          <p class="artist">RIIZE</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">5</span>
        <div class="info">
          <p class="song">Seven</p>
          <p class="artist">정국 (Jungkook) feat. Latto</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">6</span>
        <div class="info">
          <p class="song">Spicy</p>
          <p class="artist">aespa</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">7</span>
        <div class="info">
          <p class="song">Ditto</p>
          <p class="artist">NewJeans</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">8</span>
        <div class="info">
          <p class="song">Drama</p>
          <p class="artist">aespa</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">9</span>
        <div class="info">
          <p class="song">ETA</p>
          <p class="artist">NewJeans</p>
        </div>
      </li>
      <li class="chart-item">
        <span class="rank">10</span>
        <div class="info">
          <p class="song">Shut Down</p>
          <p class="artist">BLACKPINK</p>
        </div>
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
