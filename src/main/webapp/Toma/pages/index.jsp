<!-- index.jsp // 메인 홈 화면 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
    // Spotify Access Token
    String clientId = "bb7cbbae7d4044ea9d0944a6ce53617c";
    String clientSecret = "c19cc7e8110b48a2add2726da9eefd9d";
    String auth = Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes());

    URL url = new URL("https://accounts.spotify.com/api/token");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    // POST 방식으로 토큰 요청 보냄
    conn.setRequestMethod("POST");
    conn.setDoOutput(true);
    conn.setRequestProperty("Authorization", "Basic " + auth);
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

    // Stream에 바디 데이터 입력
    String body = "grant_type=client_credentials";
    conn.getOutputStream().write(body.getBytes());

    // 응답(JSON) 전체 읽어 Access 토큰 추출
    BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String line, apiResponse = "";
    while ((line = br.readLine()) != null) apiResponse += line;
    br.close();

    String token = new JSONObject(apiResponse).getString("access_token");

    // Spotify – 신규 앨범 8개 불러오기
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

    // track id, 제목, 아티스트명, 이미지, popularity 가져온 뒤 클래스에 담음
    class ChartSong {
        String id;
        String title;
        String artist;
        String img;
        int popularity;

        ChartSong(String id, String title, String artist, String img, int popularity) {
            this.id = id;
            this.title = title;
            this.artist = artist;
            this.img = img;
            this.popularity = popularity;
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

                    String trackId = t.getString("id");
                    String title = t.getString("name");
                    String artist = t.getJSONArray("artists").getJSONObject(0).getString("name");
                    String img = t.getJSONObject("album").getJSONArray("images").getJSONObject(0).getString("url");
                    int pop = t.optInt("popularity", 0);

                    temp.add(new ChartSong(trackId, title, artist, img, pop));
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

    // 전체 인기순 정렬 후 5곡만 사용
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
	<!-- 공통 헤더 메뉴바 -->
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
			<a href="chart_popular.jsp?genre=kpop"
			   class="text-danger text-decoration-none"
			   style="font-size: 13px; opacity: .7; margin-top: 4px;">
			    더보기 >
			</a>

	</h4>
	
	<ul class="list-group mb-4">
	    <% int rank2 = 1; %>
	    <% for (ChartSong s : chartSongs) { %>
	        <li class="list-group-item d-flex justify-content-between align-items-center">
	            <div>
					<b class="rank-number"><%= rank2++ %><span style="color:transparent;">...</span></b>
	                <img src="<%= s.img %>" style="width:40px; height:40px; border-radius:6px; margin-right:10px;">
	                <%= s.title %> - <%= s.artist %>
	            </div>
	            <!-- 플레이 버튼(▶) 클릭 시 Spotify 트랙 ID를 JS로 보냄 -->
	            <button class="btn btn-main btn-sm" 
	                    onclick="playOne('<%= s.id %>')">▶</button>
	        </li>
	    <% } %>
	</ul>


      </div>

      <!-- 오른쪽: 로그인 / 나의 플레이리스트 -->
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
    // 현재 로그인한 사용자 ID (JSP에서 가져옴)
    const CURRENT_USER_ID = "<%= session.getAttribute("user_id") %>";

    // 사용자별 LocalStorage 키
    let STORAGE_KEY = null;

    // 로그인한 경우만 고유 KEY를 만듦
    if (CURRENT_USER_ID && CURRENT_USER_ID !== "null") {
        STORAGE_KEY = "tomatoma_pl_user_" + CURRENT_USER_ID;
    } else {
        STORAGE_KEY = null;  // 로그아웃 상태
    }

    function getList(){
        if (!STORAGE_KEY) return [];  // 로그인 안 되어 있으면 플레이리스트 없음
        return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    }

    function loadSidebarPlaylist(){
        const list = getList();
        const ul = document.getElementById("sidebar-playlist");
        ul.innerHTML = "";

        // 로그인 안 한 경우
        if (!STORAGE_KEY) {
            ul.innerHTML = '<li class="list-group-item small text-center text-muted">로그인이 필요합니다.</li>';
            return;
        }

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
