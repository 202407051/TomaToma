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
    
    // ===============================
    // Spotify 인기곡 API (K-POP 상위 10곡)
    // ===============================

    // 인기 아티스트 5명
    List<String> artistIds2 = Arrays.asList(
        "3Nrfpe0tUJi4K4DXYWgMUX", // BTS
        "6RHTUrRF63xao58xh9FXYJ", // IVE
        "6YVMFz59CuY7ngCxTxjpxE", // aespa
        "6HvZYsbFfjnjFrWF950C9d", // NewJeans
        "70gP6Ry4Uo0Yx6uzPIdaiJ"  // BABYMONSTER
    );

    class ChartSong {
        String title, artist, img;
        int popularity;
        ChartSong(String t, String a, String i, int p) {
            title = t; artist = a; img = i; popularity = p;
        }
    }

    List<ChartSong> chartSongs = new ArrayList<>();

    if (!token.equals("")) {
        for (String artistId : artistIds2) {
            URL topUrl = new URL("https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=KR");
            HttpURLConnection topConn = (HttpURLConnection) topUrl.openConnection();
            topConn.setRequestProperty("Authorization", "Bearer " + token);

            BufferedReader topBr = new BufferedReader(new InputStreamReader(topConn.getInputStream()));
            StringBuilder sbTop = new StringBuilder();
            String lineTop;
            while ((lineTop = topBr.readLine()) != null) sbTop.append(lineTop);
            topBr.close();

            try {
                JSONArray tracks = new JSONObject(sbTop.toString()).getJSONArray("tracks");

                List<ChartSong> temp = new ArrayList<>();
                for (int i = 0; i < tracks.length(); i++) {
                    JSONObject t = tracks.getJSONObject(i);

                    String title = t.getString("name");
                    String artist = t.getJSONArray("artists").getJSONObject(0).getString("name");
                    String img = t.getJSONObject("album").getJSONArray("images").getJSONObject(0).getString("url");
                    int pop = t.optInt("popularity", 0);

                    temp.add(new ChartSong(title, artist, img, pop));
                }

                // 인기순 정렬
                temp.sort((a, b) -> b.popularity - a.popularity);

                // 상위 3곡만 가져오기
                for (int i = 0; i < 3 && i < temp.size(); i++) {
                    chartSongs.add(temp.get(i));
                }

            } catch (Exception ignore) {}
        }
    }

    // 전체 인기순 정렬 후 10곡만 사용
    chartSongs.sort((a, b) -> b.popularity - a.popularity);
    if (chartSongs.size() > 5)
        chartSongs = new ArrayList<>(chartSongs.subList(0, 5));
%>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>TomaToma</title>

	<jsp:include page="../include/header.jsp">
	    <jsp:param name="page" value="home" />
	</jsp:include>
</head>
<body>

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
	
	<h4 class="fw-bold mb-3 d-flex justify-content-between align-items-center">
	    인기곡
	    <a href="chart_popular.jsp?genre=kpop" class="small text-danger text-decoration-none">
	        더 보러가기 >>
	    </a>
	</h4>
	
	<ul class="list-group mb-4">
	    <% int rank2 = 1; %>
	    <% for (ChartSong s : chartSongs) { %>
	        <li class="list-group-item d-flex justify-content-between align-items-center">
	            <div>
	                <b><%= rank2++ %></b>
	                <img src="<%= s.img %>" style="width:40px; height:40px; border-radius:6px; margin-right:10px;">
	                <%= s.title %> - <%= s.artist %>
	            </div>
	            <button class="btn btn-main btn-sm" 
	                    onclick="playOne('<%= s.title %>')">▶</button>
	        </li>
	    <% } %>
	</ul>


      </div>

      <!-- 오른쪽: 로그인 / 나의 플레이리스트 (원래대로) -->
	   <div class="col-md-3">
	
		<%
		    Integer userId = (Integer) session.getAttribute("user_id");
		    String username = (String) session.getAttribute("username");
		
		    if(userId == null) {
		%>
		
		    <!-- 로그인 안 된 상태 -->
		    <div class="card shadow-sm mb-4">
		      <div class="card-body text-center">
		       <p class="text-muted small mb-2">로그인하고 기능을 이용해보세요!</p>
		        <a href="login.jsp" class="btn btn-main w-100 mb-2 text-center">로그인</a>
		        <a href="join.jsp" class="d-block small text-muted">회원가입</a>
		      </div>
		    </div>
		
		<%
		    } else {
		%>
		
		    <!-- 로그인 된 상태: 내 정보 표시 -->
		    <div class="card shadow-sm mb-4">
		      <div class="card-body text-center">
		
		        <h6 class="fw-bold mb-1"><%= username %> 님</h6>
		        <p class="small text-muted mb-3">환영합니다!</p>
		
		        <a href="mypage.jsp" class="btn btn-main w-100 mb-2">마이페이지</a>
		        <a href="logout.jsp" class="d-block small text-muted">로그아웃</a>
		      </div>
		    </div>
		
		<%
		    }
		%>
		
        <div class="card shadow-sm">
          <div class="card-body">
            <div class="playlist-header">
              <h6 class="fw-bold mb-3">나의 플레이리스트</h6>
              <button class="btn btn-sm btn-outline-danger">＋</button>
            </div>
				<ul class="list-group list-group-flush" id="sidebar-playlist">
				    <!-- JS로 자동 채워짐 -->
				</ul>

          </div>
       	 </div>
		</div>
    </div>
  </div>



<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const STORAGE_KEY = 'tomatoma_pl_v6';

    // LocalStorage 불러오기
    function getList(){
        return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    }

    function loadSidebarPlaylist(){
        const list = getList();
        const ul = document.getElementById("sidebar-playlist");

        ul.innerHTML = "";

        if(list.length === 0){
            ul.innerHTML = '<li class="list-group-item small text-center text-muted">없음</li>';
            return;
        }

        list.slice(0,5).forEach(function(p){
            ul.innerHTML +=
              '<li class="list-group-item d-flex justify-content-between align-items-center" ' +
              'style="cursor:pointer;" ' +
              'onclick="location.href=\'playlist.jsp?id=' + p.id + '\'">' +
                '<span class="text-truncate" style="max-width:120px;">' + p.title + '</span>' +
                '<span class="badge bg-light text-dark">' + p.tracks.length + '</span>' +
              '</li>';
        });
    }


    document.addEventListener("DOMContentLoaded", loadSidebarPlaylist);
</script>
</body>
</html>
