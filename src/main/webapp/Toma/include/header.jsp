<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 상단 로고 + 검색창 -->
<nav class="navbar navbar-expand-lg navbar-top">
  <div class="container position-relative d-flex align-items-center">
    
    <!-- 로고 -->
    <a class="navbar-brand d-flex align-items-center ms-3" href="#">
      <span>TomaToma</span>
    </a>

    <!-- 검색창 + 버튼: 로고 바로 옆 -->
    <div class="d-flex align-items-center ms-3 flex-grow-1" style="max-width: 1000px;">
      <input class="form-control search-input" type="search" placeholder="감성 팝 플레이리스트" aria-label="Search" style="font-size:0.9rem; padding:6px 16px;">
      <button class="btn btn-main ms-2" type="submit">검색</button>
    </div>

    <!-- 오른쪽 고정 작은 로고 -->
    <img src="<%=request.getContextPath()%>/image/토마토.png" alt="작은 로고" class="top-right-logo">
  </div>
</nav>

<!-- 메뉴바: 얇은 빨간선 -->
<nav class="navbar navbar-menu">
  <div class="container" style="max-width:1200px;">
    <ul class="navbar-nav d-flex flex-row">
      <li class="nav-item mx-3"><a class="nav-link active" href="#">홈</a></li>
      <li class="nav-item mx-3"><a class="nav-link" href="chart.jsp">인기차트</a></li>
      <li class="nav-item mx-3"><a class="nav-link" href="#">최신음악</a></li>
      <li class="nav-item mx-3"><a class="nav-link" href="#">플레이리스트</a></li>
      <li class="nav-item mx-3"><a class="nav-link" href="mypage.jsp">마이페이지</a></li>
    </ul>
  </div>
</nav>
