<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>TomaToma</title>

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">

  <!-- custom CSS -->
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css?v=998">
</head>

<body>
<div style="width:100%; height:5px; background:#d24949;"></div>
<div style="height:10px;"></div>

<!-- ===== 상단 로고 + 검색창 ===== -->
<nav class="navbar navbar-expand-lg navbar-top">
  <div class="container position-relative d-flex align-items-center">

    <!-- 메인 로고 -->
    <a class="navbar-brand d-flex align-items-center ms-3" href="<%=request.getContextPath()%>/Toma/pages/index.jsp">
      <img src="<%=request.getContextPath()%>/Toma/images/logo.png" height="55" alt="logo">
    </a>

    <!-- 검색창 -->
    <div class="d-flex align-items-center ms-3 flex-grow-1" style="max-width: 1000px;">
      <input class="form-control search-input" type="search" placeholder="감성 팝 플레이리스트">
      <button class="btn btn-main ms-2">검색</button>
    </div>

    <!-- 오른쪽 작은 로고 -->
    <img src="<%=request.getContextPath()%>/Toma/images/tomato.png"
         class="top-right-logo"
         alt="작은 로고">
  </div>
</nav>

<!-- ===== 메뉴바 ===== -->
<nav class="navbar navbar-menu">
  <div class="container" style="max-width:1200px;">
    <ul class="navbar-nav d-flex flex-row w-100">

      <!-- 메뉴 간 간격 넓히기: mx-4 또는 mx-5 -->
      <li class="nav-item mx-4">
        <a class="nav-link <%= request.getParameter("page").equals("home") ? "active" : "" %>"
           href="<%=request.getContextPath()%>/Toma/pages/index.jsp">홈</a>
      </li>

      <li class="nav-item mx-4">
        <a class="nav-link <%= request.getParameter("page").equals("chart") ? "active" : "" %>"
           href="<%=request.getContextPath()%>/Toma/pages/chart_popular.jsp">인기차트</a>
      </li>

      <li class="nav-item mx-4">
        <a class="nav-link <%= request.getParameter("page").equals("new") ? "active" : "" %>"
           href="<%=request.getContextPath()%>/Toma/pages/chart_new.jsp">최신곡</a>
      </li>

      <li class="nav-item mx-4">
        <a class="nav-link <%= request.getParameter("page").equals("playlist") ? "active" : "" %>"
           href="<%=request.getContextPath()%>/Toma/pages/playlist.jsp">플레이리스트</a>
      </li>

      <!-- 마이페이지 오른쪽 끝으로 보내기 -->
      <li class="nav-item ms-auto mx-4">
        <a class="nav-link <%= request.getParameter("page").equals("mypage") ? "active" : "" %>"
           href="<%=request.getContextPath()%>/Toma/pages/mypage.jsp">마이페이지</a>
      </li>

    </ul>
  </div>
</nav>

