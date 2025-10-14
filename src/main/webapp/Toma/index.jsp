<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 예시 데이터 (실제 DB 연결 후 List<Album>, List<Song> 등으로 교체)
    class Album { String cover, title, artist; Album(String c, String t, String a){cover=c;title=t;artist=a;} }
    class Song { int rank; String title, artist; Song(int r, String t, String a){rank=r;title=t;artist=a;} }
    class Playlist { String name; Playlist(String n){name=n;} }

    java.util.List<Album> albumList = new java.util.ArrayList<>();
    
    albumList.add(new Album("흰토마토.png","네모네모","최예나"));
    albumList.add(new Album("흰토마토.png","멋쟁이 토마토","동요"));
    albumList.add(new Album("https://via.placeholder.com/400x400","앨범3","아티스트C"));
    albumList.add(new Album("https://via.placeholder.com/400x400","앨범4","아티스트D"));
    albumList.add(new Album("https://via.placeholder.com/400x400","앨범5","아티스트E"));
    albumList.add(new Album("https://via.placeholder.com/400x400","앨범6","아티스트F"));

    java.util.List<Song> popularSongs = new java.util.ArrayList<>();
    popularSongs.add(new Song(1,"노래1","아티스트A"));
    popularSongs.add(new Song(2,"노래2","아티스트B"));
    popularSongs.add(new Song(3,"노래3","아티스트C"));

    java.util.List<Playlist> playlistList = new java.util.ArrayList<>();
    playlistList.add(new Playlist("플레이리스트1"));
    playlistList.add(new Playlist("플레이리스트2"));
    playlistList.add(new Playlist("플레이리스트3"));

    class CurrentSong { String title, artist; CurrentSong(String t,String a){title=t;artist=a;} }
    CurrentSong currentSong = new CurrentSong("노래1","아티스트A");
%>

<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TomaToma</title>
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

  <!-- 상단 로고 + 검색창 -->
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
        <li class="nav-item mx-3"><a class="nav-link active" href="#">홈</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">인기차트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">최신곡</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="#">플레이리스트</a></li>
        <li class="nav-item mx-3"><a class="nav-link" href="mypage.jsp">마이페이지</a></li>
      </ul>
    </div>
  </nav>

  <!-- 메인 컨텐츠 -->
  <div class="container my-4" style="max-width:1200px;">
    <div class="row">
      <div class="col-md-9">
        <h4 class="fw-bold mb-3">최신 앨범</h4>
        <div class="row g-3 mb-4">
          <% for(int i=0;i<albumList.size();i++) { 
                Album album = albumList.get(i); %>
            <div class="col-md-4 col-sm-6 album-card">
              <img src="<%=album.cover%>" class="w-100" alt="<%=album.title%>">
              <p class="mt-2 fw-bold text-center"><%=album.title%></p>
              <p class="text-muted text-center"><%=album.artist%></p>
            </div>
          <% } %>
        </div>

        <h4 class="fw-bold mb-3">인기곡</h4>
        <ul class="list-group mb-4">
          <% for(int i=0;i<popularSongs.size();i++) {
                Song song = popularSongs.get(i); %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              <%=song.rank%>. <%=song.title%> - <%=song.artist%>
              <button class="btn btn-main btn-sm">재생</button>
            </li>
          <% } %>
        </ul>
      </div>

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
              <% for(int i=0;i<playlistList.size();i++) {
                    Playlist plist = playlistList.get(i); %>
                <li class="list-group-item"><%=plist.name%></li>
              <% } %>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 하단 플레이어 -->
  <nav class="navbar fixed-bottom player-bar">
    <div class="container" style="max-width:1200px;">
      <div class="d-flex justify-content-between align-items-center w-100">
        <span class="text-dark">재생 중: <b><%=currentSong.title%></b> - <%=currentSong.artist%></span>
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
