<!-- search.jsp // 검색 기능 -->
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>

<%
	// 기본 설정, 검색어 받기
    request.setCharacterEncoding("UTF-8");

    String query = request.getParameter("q");
    if(query == null) query = "";
    String encodedQuery = java.net.URLEncoder.encode(query, "UTF-8");

    // Spotify Token
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

    BufferedReader tokenBr = new BufferedReader(new InputStreamReader(tokenConn.getInputStream(), "UTF-8"));
    String tokenRaw = "", tLine;
    while((tLine = tokenBr.readLine()) != null) tokenRaw += tLine;
    tokenBr.close();

    String accessToken = new JSONObject(tokenRaw).getString("access_token");

    // Spotify 검색 API 호출
    List<Map<String,String>> results = new ArrayList<>();
    try {
        String apiUrl = "https://api.spotify.com/v1/search?q=" + encodedQuery + "&type=track&limit=30&market=KR";
        HttpURLConnection conn2 = (HttpURLConnection) new URL(apiUrl).openConnection();
        conn2.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader br = new BufferedReader(new InputStreamReader(conn2.getInputStream(), "UTF-8"));
        String raw = "", line2;
        while((line2 = br.readLine()) != null) raw += line2;
        br.close();

        JSONObject obj = new JSONObject(raw);
        //Spotify에서 반환되는 JSON을 읽은 뒤 파싱
        JSONArray items = obj.getJSONObject("tracks").getJSONArray("items");

        for(int i=0; i < items.length(); i++){
            JSONObject tr = items.getJSONObject(i);

            // 각 검색 결과마다 필요한 데이터만 추출해서 map에 저장
            Map<String,String> map = new HashMap<>();
            map.put("id", tr.getString("id"));
            map.put("title", tr.getString("name"));
            map.put("artist", tr.getJSONArray("artists").getJSONObject(0).getString("name"));
            map.put("img", tr.getJSONObject("album").getJSONArray("images").getJSONObject(0).getString("url"));

            results.add(map);
        }

    } catch(Exception e) { e.printStackTrace(); }
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>TomaToma - 검색 결과</title>

	<!-- 공통 헤더 메뉴바 -->
    <jsp:include page="../include/header.jsp">
        <jsp:param name="page" value="search"/>
    </jsp:include>

    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">

    <style>
        <!-- CSS -->
        .song-card {
            display:flex;
            align-items:center;
            padding:12px 15px;
            border-radius:12px;
            background:#fff;
            margin-bottom:12px;
            box-shadow:0 2px 6px rgba(0,0,0,0.06);
            transition:0.2s;
            cursor:pointer;
        }
        .song-card:hover {
            transform: translateY(-3px);
            box-shadow:0 4px 10px rgba(0,0,0,0.12);
        }

        .song-img {
            width:58px;
            height:58px;
            border-radius:10px;
            object-fit:cover;
            margin-right:15px;
        }

        .song-title {
            font-weight:600;
            font-size:17px;
        }

        .song-artist {
            color:#777;
            font-size:14px;
        }

        .play-btn {
            background:#d24949;
            color:white;
            border:none;
            border-radius:50%;
            width:38px;
            height:38px;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:16px;
            transition:0.2s;
        }

        .play-btn:hover {
            background:#b93c3c;
        }
        
		.search-title {
		    font-size: 17px;
		    font-weight: 600;
		    color: #333;
		    padding-left: 12px;
		    border-left: 4px solid #D24949;
		    margin-top: 10px;
		}
		
		.search-title .keyword {
		    color: #D24949;
		    font-weight: 700;
		}

    </style>

</head>

<body>
<!-- 검색 결과 강조 -->
<div class="container my-4" style="max-width:1150px;">
    <div class="search-title mb-4">
	    검색 결과 <span class="keyword">"<%=query%>"</span>
	</div>

	<!-- 검색 결과 없는 경우 -->
    <% if(results.size() == 0){ %>
        <p class="text-muted">검색 결과가 없습니다.</p>
    <% } else { %>

		<!-- 검색 결과 카드 출력 -->
        <% for(Map<String,String> s : results){ %>
        <div class="song-card">
            <img src="<%= s.get("img") %>" class="song-img">

            <div style="flex-grow:1;">
                <div class="song-title"><%= s.get("title") %></div>
                <div class="song-artist"><%= s.get("artist") %></div>
            </div>

            <button class="play-btn"
                    onclick="playOne('<%= s.get("id") %>')">▶</button>
        </div>
        <% } %>

    <% } %>
</div>

</body>
</html>
