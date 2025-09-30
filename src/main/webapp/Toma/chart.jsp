<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.net.*, java.io.*, java.util.Base64" %>

<%-- ================= [선언부: 전역 변수/메서드] ================= --%>
<%!
    String CLIENT_ID     = "YOUR_CLIENT_ID";
    String CLIENT_SECRET = "YOUR_CLIENT_SECRET";
    String COUNTRY       = "KR";

    String getToken() throws Exception {
        URL url = new URL("https://accounts.spotify.com/api/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        String basic = Base64.getEncoder().encodeToString((CLIENT_ID + ":" + CLIENT_SECRET).getBytes("UTF-8"));
        conn.setRequestProperty("Authorization", "Basic " + basic);
        try (OutputStream os = conn.getOutputStream()) { os.write("grant_type=client_credentials".getBytes("UTF-8")); }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            StringBuilder sb = new StringBuilder(); String line;
            while ((line = br.readLine()) != null) sb.append(line);
            String json = sb.toString();
            int i = json.indexOf("\"access_token\":\""); if (i < 0) throw new RuntimeException("No access_token");
            int s = i + 16; int e = json.indexOf('\"', s); return json.substring(s, e);
        }
    }

    String getJson(String endpoint, String token) throws Exception {
        URL url = new URL(endpoint);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestProperty("Authorization", "Bearer " + token);
        conn.setRequestProperty("Accept", "application/json");
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"))) {
            StringBuilder sb = new StringBuilder(); String line;
            while ((line = br.readLine()) != null) sb.append(line);
            return sb.toString();
        }
    }

    String extractFirstPlaylistId(String playlistsJson) {
        int itemsIdx = playlistsJson.indexOf("\"items\""); if (itemsIdx < 0) return null;
        int idIdx = playlistsJson.indexOf("\"id\":\"", itemsIdx); if (idIdx < 0) return null;
        int start = idIdx + 6; int end = playlistsJson.indexOf("\"", start);
        return (end > start) ? playlistsJson.substring(start, end) : null;
    }
%>

<%-- ================= [스크립틀릿: 실행 코드] ================= --%>
<%
    String tracksJson = "{}";
    try {
        String accessToken = getToken();

        String toplists = getJson(
            "https://api.spotify.com/v1/browse/categories/toplists/playlists?country=" + COUNTRY + "&limit=1",
            accessToken
        );
        String playlistId = extractFirstPlaylistId(toplists);

        if (playlistId != null) {
            tracksJson = getJson(
                "https://api.spotify.com/v1/playlists/" + playlistId + "/tracks?limit=50&market=" + COUNTRY,
                accessToken
            );
        } else {
            tracksJson = "{\"items\":[]}";
        }
    } catch (Exception ex) {
        tracksJson = "{\"error\":\"" + ex.getMessage().replace("\"","\\\"") + "\"}";
    }
%>

<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>인기 차트</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link href="css/bootstrap.min.css" rel="stylesheet" />
  <link href="css/chart.css" rel="stylesheet" />
</head>
<body>
  <div class="container py-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <h1 class="h3 m-0">인기 차트</h1>
      <a href="index.jsp" class="btn btn-sm btn-outline-light">← 홈으로</a>
    </div>

    <script type="application/json" id="tracksData"><%= tracksJson %></script>
    <div id="list"></div>
  </div>

  <script>
    function text(el, t){ el.appendChild(document.createTextNode(t)); }
    const raw = document.getElementById('tracksData').textContent.trim();
    let data; try { data = JSON.parse(raw); } catch(e){ data = { items: [] }; }
    const list = document.getElementById('list');
    const items = (data && data.items) || [];

    items.forEach((item, idx) => {
      const t = item.track || {};
      const name = t.name || 'Unknown';
      const artists = (t.artists || []).map(a => a.name).join(', ');
      const url = (t.external_urls && t.external_urls.spotify) || '#';
      const img = (t.album && t.album.images && t.album.images[2] ? t.album.images[2].url
                 : (t.album && t.album.images && t.album.images[0] ? t.album.images[0].url : ''));

      const card = document.createElement('div'); card.className = 'track-card';
      const rank = document.createElement('div'); rank.className = 'rank'; text(rank, (idx+1).toString());
      const cover = document.createElement('img'); cover.className = 'cover'; cover.src = img;

      const info = document.createElement('div');
      const title = document.createElement('div'); title.className = 'title';
      const link = document.createElement('a'); link.href=url; link.target='_blank'; link.rel='noopener'; link.className='link'; link.textContent=name;
      title.appendChild(link);
      const artist = document.createElement('div'); artist.className='artist'; text(artist, artists);

      info.appendChild(title); info.appendChild(artist);
      card.appendChild(rank); card.appendChild(cover); card.appendChild(info);
      list.appendChild(card);
    });

    if (items.length === 0) {
      const p = document.createElement('p');
      p.textContent = '표시할 차트가 없습니다. (토큰/권한 또는 네트워크 확인)';
      list.appendChild(p);
    }
  </script>
</body>
</html>
