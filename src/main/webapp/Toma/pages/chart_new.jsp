<!-- chart_new.jsp // 최신차트 화면 -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    /* ===============================
       [1] Spotify Token 발급
       - clientId + clientSecret을 Base64로 인코딩 후 POST 요청
       - 대표 메서드: Base64.getEncoder().encodeToString()
       → "clientId:secret"을 Base64 문자열로 변환

    =============================== */
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

    // grant_type 전달
    tokenConn.getOutputStream().write("grant_type=client_credentials".getBytes("UTF-8"));

    BufferedReader tokenBr =
            (tokenConn.getResponseCode() >= 400)
            ? new BufferedReader(new InputStreamReader(tokenConn.getErrorStream(), "UTF-8"))
            : new BufferedReader(new InputStreamReader(tokenConn.getInputStream(), "UTF-8"));

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
		
    /* ===============================
       [2] Spotify 최신곡 가져오기
       - /browse/new-releases 로 최신 발매 앨범 20개 로딩
       - 대표 메서드: apiConn.setRequestProperty("Authorization", "Bearer " + accessToken)
         → 모든 Spotify API 요청에 필요한 인증 헤더
    =============================== */
    class NewSong {
        String id, title, artist, img;
        NewSong(String id, String t, String a, String i){
            this.id = id;  // track ID!
            title = t;
            artist = a;
            img = i;
        }
    }


    List<NewSong> list = new ArrayList<>();

    if(!accessToken.equals("")) {

        String apiUrl = "https://api.spotify.com/v1/browse/new-releases?country=KR&limit=20";

        HttpURLConnection apiConn = (HttpURLConnection) new URL(apiUrl).openConnection();
        apiConn.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader apiBr =
                (apiConn.getResponseCode() >= 400)
                ? new BufferedReader(new InputStreamReader(apiConn.getErrorStream(), "UTF-8"))
                : new BufferedReader(new InputStreamReader(apiConn.getInputStream(), "UTF-8"));

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = apiBr.readLine()) != null) sb.append(line);
        apiBr.close();

        try {
            JSONObject obj = new JSONObject(sb.toString()); 
            JSONArray items = obj.getJSONObject("albums").getJSONArray("items");

            for (int i=0; i<items.length(); i++){
                JSONObject item = items.getJSONObject(i);

                String albumId = item.getString("id");     // 앨범 ID 가져오기
                String albumName = item.getString("name");
                String artist = item.getJSONArray("artists")
                                    .getJSONObject(0)
                                    .getString("name");

                JSONArray imgs = item.getJSONArray("images");
                String img = (imgs.length()>0)
                           ? imgs.getJSONObject(0).getString("url")
                           : "https://via.placeholder.com/60";

                /* 🎵 [신규] 앨범의 첫 번째 곡(track) ID 가져오기 */
                String trackId = "";

                try {
                    String trackApi = "https://api.spotify.com/v1/albums/" + albumId + "/tracks?market=KR&limit=1";
                    HttpURLConnection tConn = (HttpURLConnection) new URL(trackApi).openConnection();
                    tConn.setRequestProperty("Authorization", "Bearer " + accessToken);

                    BufferedReader tBr = new BufferedReader(new InputStreamReader(tConn.getInputStream(),"UTF-8"));
                    StringBuilder tSb = new StringBuilder();
                    String tLine;
                    while((tLine = tBr.readLine()) != null) tSb.append(tLine);
                    tBr.close();

                    JSONObject tObj = new JSONObject(tSb.toString());
                    JSONArray tItems = tObj.getJSONArray("items");

                    if(tItems.length() > 0){
                        trackId = tItems.getJSONObject(0).getString("id");
                    }
                } catch(Exception ignore){}

                /* 리스트에 trackId 포함하여 저장 */
                list.add(new NewSong(trackId, albumName, artist, img));
            }
        } catch(Exception ignore) {}
    }   // <-- accessToken if문 닫기
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>TomaToma - 최신곡</title>

    <jsp:include page="../include/header.jsp">
        <jsp:param name="page" value="new"/>
    </jsp:include>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">

    <style>
        .song-img {
            width: 70px; height: 70px;
            border-radius: 6px;
            object-fit: cover;
        }
    </style>
</head>

<body>

<div class="container my-4" style="max-width:1200px;">
    <div class="row">

        <!-- 왼쪽: 최신 발매 음악 목록 -->
        <div class="col-md-9">

            <h4 class="fw-bold mb-3">최신 음악</h4>

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
                    int idx=1;
                    for(NewSong s : list){
                %>
                    <tr>
                        <td><%= idx++ %></td>
                        <td><img src="<%= s.img %>" class="song-img"></td>
                        <td><%= s.title %></td>
                        <td><%= s.artist %></td>
                        <td><button class="btn btn-main btn-sm"
        					onclick="playOne('<%= s.id %>')">▶</button></td>
                    </tr>
                <% } %>
                </tbody>
            </table>

        </div>

        <!-- 오른쪽 사이드바 (index.jsp와 동일) -->
        <div class="col-md-3">

            <%
                Integer userId = (Integer) session.getAttribute("user_id");
                String username = (String) session.getAttribute("username");
            %>

            <% if (userId == null) { %>

                <!-- 로그인 X -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <p class="text-muted small mb-2">로그인하고 기능을 이용해보세요!</p>
                        <a href="login.jsp" class="btn btn-main w-100 mb-2">로그인</a>
                        <a href="join.jsp" class="d-block small text-muted">회원가입</a>
                    </div>
                </div>

            <% } else { %>

                <!-- 로그인 O -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <h6 class="fw-bold mb-1"><%= username %> 님</h6>
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
