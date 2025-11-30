<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
    // ===============================
    // 1) Spotify Token 발급
    // ===============================
    String clientId = "bb7cbbae7d4044ea9d0944a6ce53617c";
    String clientSecret = "c19cc7e8110b48a2add2726da9eefd9d";

    String auth = Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes());

    URL tokenUrl = new URL("https://accounts.spotify.com/api/token");
    HttpURLConnection conn = (HttpURLConnection) tokenUrl.openConnection();
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    conn.setRequestProperty("Authorization", "Basic " + auth);
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    conn.getOutputStream().write("grant_type=client_credentials".getBytes());

    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
    StringBuilder tokenSb = new StringBuilder();
    String tline;
    while ((tline = br.readLine()) != null) tokenSb.append(tline);
    br.close();

    String accessToken = new JSONObject(tokenSb.toString()).getString("access_token");

    // ===============================
    // 2) new-releases → 앨범 리스트 받아오기
    // ===============================
    URL relUrl = new URL("https://api.spotify.com/v1/browse/new-releases?country=KR&limit=12");

    HttpURLConnection relConn = (HttpURLConnection) relUrl.openConnection();
    relConn.setRequestMethod("GET");
    relConn.setRequestProperty("Authorization", "Bearer " + accessToken);

    BufferedReader br2 = new BufferedReader(new InputStreamReader(relConn.getInputStream(), "UTF-8"));
    StringBuilder relSb = new StringBuilder();
    String line;
    while ((line = br2.readLine()) != null) relSb.append(line);
    br2.close();

    JSONArray albums = new JSONObject(relSb.toString())
            .getJSONObject("albums")
            .getJSONArray("items");

    // ===============================
    // 3) 최신곡을 1곡씩 추출
    // ===============================
    class Song {
        String title, artist, img;
        Song(String t, String a, String i){ title=t; artist=a; img=i; }
    }

    List<Song> newSongs = new ArrayList<>();

    for (int i = 0; i < albums.length(); i++) {
        JSONObject album = albums.getJSONObject(i);
        String albumId = album.getString("id");
        String albumImg = album.getJSONArray("images").getJSONObject(1).getString("url");

        // 앨범별 첫 번째 곡 가져오기
        URL trackUrl = new URL("https://api.spotify.com/v1/albums/" + albumId + "/tracks?limit=1");
        HttpURLConnection trackConn = (HttpURLConnection) trackUrl.openConnection();
        trackConn.setRequestMethod("GET");
        trackConn.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader br3 = new BufferedReader(new InputStreamReader(trackConn.getInputStream(), "UTF-8"));
        StringBuilder tsb = new StringBuilder();
        String temp;
        while ((temp = br3.readLine()) != null) tsb.append(temp);
        br3.close();

        JSONArray tracks = new JSONObject(tsb.toString()).getJSONArray("items");
        if (tracks.length() == 0) continue;

        JSONObject track = tracks.getJSONObject(0);
        String title = track.getString("name");
        String artist = track.getJSONArray("artists").getJSONObject(0).getString("name");

        newSongs.add(new Song(title, artist, albumImg));
    }

    String nowTitle = newSongs.get(0).title;
    String nowArtist = newSongs.get(0).artist;
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8" />
    <title>TomaToma - 최신곡</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">

    <style>
      .song-img { width: 60px; height: 60px; border-radius: 6px; object-fit: cover; }
    </style>
</head>

<body>

<jsp:include page="../include/header.jsp">
    <jsp:param name="page" value="new"/>
</jsp:include>

<div class="container my-4" style="max-width:1200px;">

  <h4 class="fw-bold mb-3">✨ 최신곡 (곡 단위)</h4>

  <table class="table table-hover align-middle">
    <thead class="table-danger">
      <tr>
        <th>#</th>
        <th>앨범</th>
        <th>제목</th>
        <th>아티스트</th>
        <th></th>
      </tr>
    </thead>

    <tbody>
      <% int idx = 1; for (Song s : newSongs) { %>
      <tr>
        <td><%=idx++%></td>
        <td><img src="<%=s.img%>" class="song-img"></td>
        <td><%=s.title%></td>
        <td><%=s.artist%></td>
        <td><button class="btn btn-main btn-sm" onclick="playOne('4iV5W9uYEdYUVa79Axb7Rh')">▶</button></td>
      </tr>
      <% } %>
    </tbody>
  </table>

</div>

<nav class="navbar fixed-bottom player-bar">
  <div class="container d-flex justify-content-between align-items-center">

    <span class="text-dark">
      재생 중: <b><%=nowTitle%></b> - <%=nowArtist %>
    </span>

    <div>
      <button class="btn btn-outline-danger btn-sm">⏮</button>
      <button class="btn btn-outline-danger btn-sm">▶</button>
      <button class="btn btn-outline-danger btn-sm">⏭</button>
    </div>
  </div>
</nav>

</body>
</html>
