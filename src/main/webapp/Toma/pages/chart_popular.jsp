<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    // [1] 장르 파라미터 처리: URL에서 genre 값 읽기 (request.getParameter 사용)
    String genre = request.getParameter("genre");
    if (genre == null) genre = "kpop";

    String titleText = "";
    if ("kpop".equals(genre))       titleText = "K-POP 인기차트";
    else if ("rap".equals(genre))   titleText = "한국 랩 / 힙합 인기차트";
    else if ("ballad".equals(genre))titleText = "한국 발라드 인기차트";
    else if ("band".equals(genre))  titleText = "한국 밴드 인기차트";
    else if ("indie".equals(genre)) titleText = "한국 인디 인기차트";
    else                            titleText = "인기차트";

    // [2] Spotify 토큰 발급: clientId/secret → access_token 받기 (Base64 + HttpURLConnection)
    String clientId     = "bb7cbbae7d4044ea9d0944a6ce53617c";
    String clientSecret = "c19cc7e8110b48a2add2726da9eefd9d";

    String auth = Base64.getEncoder()
            .encodeToString((clientId + ":" + clientSecret).getBytes("UTF-8"));

    URL tokenUrl = new URL("https://accounts.spotify.com/api/token");
    HttpURLConnection tokenConn = (HttpURLConnection) tokenUrl.openConnection();
    tokenConn.setRequestMethod("POST");
    tokenConn.setDoOutput(true);
    tokenConn.setRequestProperty("Authorization", "Basic " + auth);
    tokenConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    tokenConn.getOutputStream().write("grant_type=client_credentials".getBytes("UTF-8"));

    BufferedReader tokenBr;
    if (tokenConn.getResponseCode() >= 400) {
        tokenBr = new BufferedReader(new InputStreamReader(tokenConn.getErrorStream(), "UTF-8"));
    } else {
        tokenBr = new BufferedReader(new InputStreamReader(tokenConn.getInputStream(), "UTF-8"));
    }

    StringBuilder tokenSb = new StringBuilder();
    String tokenLine;
    while ((tokenLine = tokenBr.readLine()) != null) tokenSb.append(tokenLine);
    tokenBr.close();

    String accessToken = "";
    try {
        JSONObject tokenJson = new JSONObject(tokenSb.toString());
        accessToken = tokenJson.getString("access_token");
    } catch (Exception e) {
        accessToken = "";
    }

    // [3] 장르별 아티스트 ID 목록 세팅 (Arrays.asList로 고정 리스트 만듦)
    List<String> artistIds = new ArrayList<>();

    if ("kpop".equals(genre)) {
        artistIds = Arrays.asList(
            "3Nrfpe0tUJi4K4DXYWgMUX", // BTS
            "6RHTUrRF63xao58xh9FXYJ", // IVE
            "6YVMFz59CuY7ngCxTxjpxE", // aespa
            "6HvZYsbFfjnjFrWF950C9d", // NewJeans
            "70gP6Ry4Uo0Yx6uzPIdaiJ"  // BABYMONSTER
            
        );
    } else if ("rap".equals(genre)) {
        artistIds = Arrays.asList(
            "5NUVwRESNqYBUTRbiATjy7", // BE'O
            "4XpUIb8uuNlIWVKmgKZXC0", // ZICO
            "2e4G04F77jxVuDYo44TCSm", // Loco
            "2u7CP5T30c8ctenzXgEV1W", // pH-1
            "7cEaNXXTHx3LokbjUUyHal"  // BIG Naughty
        );
    } else if ("ballad".equals(genre)) {
        artistIds = Arrays.asList(
            "4dB2XmMpzPxsMRnt62TbF5",
            "7jFUYMpMUBDL4JQtMZ5ilc",
            "12AUp9oqeJDhNfO6IhQiNi",
            "16sxdaE9mk0Kis9CTP7Uot",
            "4qRXrzUmdy3p33lgvJEzdv"
        );
    } else if ("band".equals(genre)) {
        artistIds = Arrays.asList(
            "5TnQc2N1iKlFjYD7CPGvFc",
            "5WY88tCMFA6J6vqSN3MmDZ",
            "2SY6OktZyMLdOnscX3DCyS",
            "71kRpwy6xTeG2OXXkRJdkA",
            "07OePkse2fcvU9wlVftNMl"
        );
    } else if ("indie".equals(genre)) {
        artistIds = Arrays.asList(
            "7c1HgFDe8ogy5NOZ1ANCJQ",
            "57okaLdCtv3nVBSn5otJkp",
            "6NdzNrBP8Jbhzp6h7yojht",
            "6WeDO4GynFmK4OxwkBzMW8",
            "50Zu2bK9y5UAtD0jcqk5VX"
        );
    }

    // [4] 아티스트별 top-tracks 호출해서 Song 리스트 만들기 (JSONObject / JSONArray로 파싱)
    class Song {
    String id, title, artist, img;
    int popularity;

    Song(String id, String t, String a, String i, int p) {
        this.id = id;
        title = t;
        artist = a;
        img = i;
        popularity = p;
    }
}

    List<Song> songList = new ArrayList<>();

    if (!accessToken.equals("") && !artistIds.isEmpty()) {
        for (String artistId : artistIds) {

            String apiUrl = "https://api.spotify.com/v1/artists/" + artistId + "/top-tracks?market=KR";
            HttpURLConnection apiConn = (HttpURLConnection) new URL(apiUrl).openConnection();
            apiConn.setRequestProperty("Authorization", "Bearer " + accessToken);

            BufferedReader apiBr;
            if (apiConn.getResponseCode() >= 400) {
                apiBr = new BufferedReader(new InputStreamReader(apiConn.getErrorStream(), "UTF-8"));
            } else {
                apiBr = new BufferedReader(new InputStreamReader(apiConn.getInputStream(), "UTF-8"));
            }

            StringBuilder sb = new StringBuilder();
            String apiLine;
            while ((apiLine = apiBr.readLine()) != null) sb.append(apiLine);
            apiBr.close();

            try {
                JSONObject obj = new JSONObject(sb.toString());
                JSONArray tracks = obj.getJSONArray("tracks");

                List<Song> temp = new ArrayList<>();

                for (int i = 0; i < tracks.length(); i++) {
                    JSONObject t = tracks.getJSONObject(i);

                    String trackId = t.getString("id");         // ★ 트랙 ID
                    String title = t.getString("name");
                    String artistName = t.getJSONArray("artists").getJSONObject(0).getString("name");

                    JSONArray imgs = t.getJSONObject("album").getJSONArray("images");
                    String img = (imgs.length() > 0)
                            ? imgs.getJSONObject(0).getString("url")
                            : "https://via.placeholder.com/60";

                    int pop = t.optInt("popularity", 0);

                    temp.add(new Song(trackId, title, artistName, img, pop));  // ★ trackId 포함
                }

                // 아티스트 내부에서 인기순 정렬 후 상위 3곡만 사용
                temp.sort((a,b) -> b.popularity - a.popularity);

                int limit = Math.min(3, temp.size());
                for (int i = 0; i < limit; i++) songList.add(temp.get(i));

            } catch (Exception ignore) {}
        }
    }

    // [5] 전체 곡 인기순 정렬 후 Top 10만 남기기 (List.sort + subList)
    if (!songList.isEmpty()) {
        songList.sort((a,b) -> b.popularity - a.popularity);
        if (songList.size() > 15)
            songList = new ArrayList<>(songList.subList(0,15));
    } else {
        songList.add(new Song("no-id", "데이터 없음", "없음", "https://via.placeholder.com/60", 0));
    }

    String nowTitle  = songList.get(0).title;
    String nowArtist = songList.get(0).artist;

%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>TomaToma - 인기차트</title>

    <jsp:include page="../include/header.jsp">
        <jsp:param name="page" value="popular"/>
    </jsp:include>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">

    <style>
        .song-img {
            width: 60px; height: 60px;
            border-radius: 6px;
            object-fit: cover;
        }
    </style>

</head>

<body>

<div class="container my-4" style="max-width:1200px;">
    <div class="row">

        <!-- 왼쪽: 장르 버튼 + 차트 테이블 -->
        <div class="col-md-9">

            <h4 class="fw-bold mb-3"><%= titleText %></h4>

            <!-- 장르 버튼 -->
            <div class="mb-3 d-flex align-items-center">
                <div class="btn-group">
                    <a href="chart_popular.jsp?genre=kpop" class="btn <%= "kpop".equals(genre) ? "btn-main" : "btn-outline-danger" %>">K-POP</a>
                    <a href="chart_popular.jsp?genre=rap" class="btn <%= "rap".equals(genre) ? "btn-main" : "btn-outline-danger" %>">랩/힙합</a>
                    <a href="chart_popular.jsp?genre=ballad" class="btn <%= "ballad".equals(genre) ? "btn-main" : "btn-outline-danger" %>">발라드</a>
                    <a href="chart_popular.jsp?genre=band" class="btn <%= "band".equals(genre) ? "btn-main" : "btn-outline-danger" %>">밴드</a>
                    <a href="chart_popular.jsp?genre=indie" class="btn <%= "indie".equals(genre) ? "btn-main" : "btn-outline-danger" %>">인디</a>
                </div>
            </div>

            <!-- 표 -->
            <table class="table table-hover align-middle">
                <thead class="table-danger">
                <tr>
                    <th>#</th>
                    <th>앨범</th>
                    <th>곡명</th>
                    <th>아티스트</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <%
                    int idx = 1;
                    for (Song s : songList) {
                %>
                <tr>
                    <td><%= idx++ %></td>
                    <td><img src="<%= s.img %>" class="song-img"></td>
                    <td><%= s.title %></td>
                    <td><%= s.artist %></td>
                    <td>
					    <button class="btn btn-main btn-sm"
					            onclick="playOne('<%= s.id %>')">▶</button>
					</td>
                </tr>
                <% } %>
                </tbody>
            </table>

        </div>

        <!-- 오른쪽: 로그인 박스 + 플레이리스트 -->
        <div class="col-md-3">

            <%
                Integer userId = (Integer) session.getAttribute("user_id");
                String username2 = (String) session.getAttribute("username");
            %>

            <% if (userId == null) { %>

                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <p class="text-muted small mb-2">로그인하고 기능을 이용해보세요!</p>
                        <a href="login.jsp" class="btn btn-main w-100 mb-2">로그인</a>
                        <a href="join.jsp" class="d-block small text-muted">회원가입</a>
                    </div>
                </div>

            <% } else { %>

                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <h6 class="fw-bold mb-1"><%= username2 %> 님</h6>
                        <p class="small text-muted mb-3">환영합니다!</p>
                        <a href="mypage.jsp" class="btn btn-main w-100 mb-2">마이페이지</a>
                        <a href="logout.jsp" class="d-block small text-muted">로그아웃</a>
                    </div>
                </div>

            <% } %>

            <!-- 오른쪽: 플레이리스트 -->
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 현재 로그인한 사용자 ID (JSP에서 가져옴)
    const CURRENT_USER_ID = "<%= session.getAttribute("user_id") %>";

    // 사용자별 LocalStorage 키
    let STORAGE_KEY = null;

    // 로그인한 경우만 고유 KEY를 만든다
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
