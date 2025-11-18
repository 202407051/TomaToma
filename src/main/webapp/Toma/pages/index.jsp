<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
    // Spotify Access Token
    String clientId = "bb7cbbae7d4044ea9d0944a6ce53617c";
    String clientSecret = "c19cc7e8110b48a2add2726da9eefd9d";
    String auth = Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes());

    URL url = new URL("https://accounts.spotify.com/api/token");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    conn.setRequestProperty("Authorization", "Basic " + auth);
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

    String body = "grant_type=client_credentials";
    conn.getOutputStream().write(body.getBytes());

    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String line, apiResponse = "";
    while ((line = br.readLine()) != null) apiResponse += line;
    br.close();

    String token = new JSONObject(apiResponse).getString("access_token");

    // Spotify – 신규 앨범 8개
    URL apiUrl = new URL("https://api.spotify.com/v1/browse/new-releases?country=KR&limit=8");
    HttpURLConnection apiConn = (HttpURLConnection) apiUrl.openConnection();
    apiConn.setRequestProperty("Authorization", "Bearer " + token);

    BufferedReader br2 = new BufferedReader(new InputStreamReader(apiConn.getInputStream()));
    String res = "", line2;
    while ((line2 = br2.readLine()) != null) res += line2;
    br2.close();

    JSONObject json = new JSONObject(res);
    JSONArray albums = json.getJSONObject("albums").getJSONArray("items");

    class Album { String cover, title, artist; Album(String c, String t, String a){cover=c;title=t;artist=a;} }
    List<Album> albumList = new ArrayList<>();
    for (int i = 0; i < albums.length(); i++) {
        JSONObject item = albums.getJSONObject(i);
        String title = item.getString("name");
        String artist = item.getJSONArray("artists").getJSONObject(0).getString("name");
        String cover = item.getJSONArray("images").getJSONObject(0).getString("url");
        albumList.add(new Album(cover, title, artist));
    }

    // 예시 인기곡 / 플레이리스트 / 현재재생
    class Song { int rank; String title, artist; Song(int r,String t,String a){rank=r;title=t;artist=a;} }
    class Playlist { String name; Playlist(String n){name=n;} }
    class CurrentSong { String title, artist; CurrentSong(String t,String a){title=t;artist=a;} }

    java.util.List<Song> popularSongs = new java.util.ArrayList<>();
    popularSongs.add(new Song(1,"노래1","아티스트A"));
    popularSongs.add(new Song(2,"노래2","아티스트B"));
    popularSongs.add(new Song(3,"노래3","아티스트C"));

    java.util.List<Playlist> playlistList = new java.util.ArrayList<>();
    playlistList.add(new Playlist("플레이리스트1"));
    playlistList.add(new Playlist("플레이리스트2"));
    playlistList.add(new Playlist("플레이리스트3"));

    CurrentSong currentSong = new CurrentSong("노래1","아티스트A");
%>

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
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">
</head>
<body>

<%@ include file="../include/header.jsp" %>


  <!-- 메인: 최신 앨범(회색 박스)만 회색, 나머지는 흰색 -->
  <div class="container my-4" style="max-width:1200px;">
    <div class="row">

      <!-- 왼쪽: 최신 앨범 + 인기곡 -->
      <div class="col-md-9">

        <!-- 최신 앨범 회색 박스 (정사각형 앨범 이미지, 4열 -> col-md-3) -->
        <div class="new-album-section mb-4">
          <h4 class="fw-bold mb-3">최신 앨범</h4>
          <div class="row g-3">
            <% for(int i=0;i<albumList.size();i++) { Album a = albumList.get(i); %>
              <div class="col-6 col-sm-4 col-md-3 album-card text-center">
                <img src="<%=a.cover%>" alt="<%=a.title%>" class="album-square">
                <p class="mt-2 fw-bold"><%=a.title%></p>
                <p class="text-muted"><%=a.artist%></p>
              </div>
            <% } %>
          </div>
        </div>

        <!-- 인기곡 (바깥 배경은 페이지 기본 — 흰색) -->
        <h4 class="fw-bold mb-3">인기곡</h4>
        <ul class="list-group mb-4">
          <% for(int i=0;i<popularSongs.size();i++){ Song s = popularSongs.get(i); %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
              <span><%=s.rank%>. <%=s.title%> - <%=s.artist%></span>
              <button class="btn btn-main btn-sm">재생</button>
            </li>
          <% } %>
        </ul>

      </div>

      <!-- 오른쪽: 로그인 / 나의 플레이리스트 (원래대로) -->
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
              <% for(int i=0;i<playlistList.size();i++){ %>
                <li class="list-group-item"><%=playlistList.get(i).name%></li>
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
