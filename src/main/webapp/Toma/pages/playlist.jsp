<!-- playlist.jsp // 플레이리스트 화면 -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>
<%
    // [1] 로그인 세션 확인
    String loginUsername = (String) session.getAttribute("userName");
    boolean isLoggedIn = (loginUsername != null);

    // [2] Spotify API 서버 사이드 토큰 발급
    String clientId = "bb7cbbae7d4044ea9d0944a6ce53617c";
    String clientSecret = "c19cc7e8110b48a2add2726da9eefd9d";
    String serverAccessToken = "";

    try {
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

        serverAccessToken = new JSONObject(tokenSb.toString()).getString("access_token");
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>TomaToma - My Playlist</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css">
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* [CSS 스타일 정의 - Pretty Tomato Theme] */
        .pl-body { font-family: 'Noto Sans KR', sans-serif; background-color: #fdfdfd; padding-bottom: 120px; }
        .pl-container { max-width: 1200px; margin: 0 auto; padding: 30px 12px; }
        .hidden { display: none !important; }
        .text-tomato { color: #FF4B4B; font-weight: bold; }
        
        /* 상단 버튼 스타일 */
        .pl-btn { 
            display: inline-flex; align-items: center; justify-content: center; 
            padding: 0 16px; height: 38px; 
            border: 1px solid #ddd; background: #fff; 
            border-radius: 8px; 
            font-size: 13px; color: #555; cursor: pointer; 
            transition: all 0.2s ease; white-space: nowrap; flex-shrink: 0; 
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .pl-btn:hover { color: #FF4B4B; border-color: #FF4B4B; background: #fff5f5; transform: translateY(-1px); }
        .pl-btn i { margin-right: 8px; font-size: 14px; } 

        .pl-btn-tomato { background: #FF4B4B; color: #fff; border-color: #FF4B4B; font-weight: bold; }
        .pl-btn-tomato:hover { background: #ff3333; color: white; border-color: #ff3333; box-shadow: 0 4px 10px rgba(255, 75, 75, 0.3); }
        
        .pl-header-wrap { border-bottom: 2px solid #FF4B4B; padding-bottom: 15px; display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px; }
        .pl-page-title { font-size: 24px; font-weight: 700; margin: 0; color: #222; letter-spacing: -0.5px; }
        
        /* 테이블 스타일 */
        .tbl-list { width: 100%; border-collapse: separate; border-spacing: 0; margin-top: 10px; }
        .tbl-list th { background: #fafafa; height: 45px; font-weight: 600; font-size: 13px; border-bottom: 2px solid #eee; text-align: center; color: #666; }
        .tbl-list td { padding: 12px 0; border-bottom: 1px solid #f2f2f2; font-size: 14px; text-align: center; vertical-align: middle; background: #fff; }
        .tbl-list tr:hover td { background: #fffafb; }
        
        /* [수정] 예쁜 듣기 버튼 (빨강 원형) - 시각적 중심 보정(padding-left: 4px) */
        .btn-play-red {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: #fff;
            border: 1px solid #FF4B4B;
            color: #FF4B4B;
            display: inline-flex; align-items: center; justify-content: center;
            cursor: pointer; transition: 0.2s;
            padding-left: 4px; /* 삼각형을 오른쪽으로 밀어서 시각적 중앙 정렬 */
            font-size: 14px;
        }
        .btn-play-red:hover { background: #FF4B4B; color: white; transform: scale(1.1); box-shadow: 0 2px 8px rgba(255, 75, 75, 0.4); }

        /* 만들기 화면 스타일 */
        .create-wrap { background: #fff; border: 1px solid #eee; padding: 25px; display: flex; gap: 25px; margin-bottom: 25px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); }
        .img-upload-box { width: 150px; height: 150px; border: 2px dashed #ddd; background: #fafafa; border-radius: 12px; display: flex; align-items: center; justify-content: center; cursor: pointer; position: relative; overflow: hidden; flex-shrink: 0; transition: 0.2s; }
        .img-upload-box:hover { border-color: #FF4B4B; background: #fff; }
        .img-upload-box img { width: 100%; height: 100%; object-fit: cover; position: absolute; }
        
        /* 듀얼 리스트 스타일 */
        .dual-list-box { display: flex; gap: 20px; height: 550px; align-items: center; }
        .dl-panel { flex: 1; border: 1px solid #e1e1e1; height: 100%; display: flex; flex-direction: column; border-radius: 12px; overflow: hidden; background: #fff; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .dl-center-arrow { font-size: 28px; color: #FF4B4B; animation: arrowMove 1.5s infinite; }
        
        .dl-tabs { display: flex; background: #f8f8f8; border-bottom: 1px solid #e1e1e1; }
        .dl-tab { flex: 1; text-align: center; padding: 14px 0; cursor: pointer; font-size: 14px; color: #777; border-right: 1px solid #f0f0f0; transition: 0.2s; background: #fdfdfd;}
        .dl-tab:hover { background: #fff; color: #333; }
        .dl-tab.active { background: #fff; color: #FF4B4B; font-weight: bold; border-bottom: 3px solid #FF4B4B; }
        
        #toolbar-search { padding: 15px; display: flex; gap: 8px; border-bottom: 1px solid #eee; width: 100%; flex-wrap: nowrap; align-items: center; box-sizing: border-box; }
        #search-keyword { flex: 1; min-width: 0; height: 38px; }
        #toolbar-chart { padding: 12px 15px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; background: #fafafa; }
        
        .track-item { 
            display: flex; align-items: center; 
            padding: 10px 15px; 
            border-bottom: 1px solid #f6f6f6; 
            font-size: 13px; 
            transition: 0.1s;
            background: #fff;
        }
        .track-item:hover { background: #fff5f5; }
        
        /* 랭킹 숫자 */
        .track-rank { width: 30px; font-weight: 800; color: #FF4B4B; text-align: center; font-style: italic; font-size: 16px; margin-right: 8px; }
        
        .track-img { width: 48px; height: 48px; border-radius: 6px; margin-right: 12px; object-fit: cover; border: 1px solid #eee; flex-shrink: 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .track-info { flex: 1; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; display: flex; flex-direction: column; justify-content: center; gap: 2px; }
        
        .track-btns { display: flex; gap: 8px; margin-left: 10px; }
        
        /* [수정] 작은 원형 재생 버튼도 시각 보정 (padding-left: 2px) */
        .btn-icon-play {
            width: 32px; height: 32px; border-radius: 50%;
            background: #fff; border: 1px solid #ddd; color: #555;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; transition: 0.2s; padding-left: 3px;
        }
        .btn-icon-play:hover { border-color: #333; color: #333; transform: scale(1.1); }
        
        .btn-icon-add {
            width: 32px; height: 32px; border-radius: 50%;
            background: #fff0f0; border: 1px solid #ffcccc; color: #FF4B4B;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; transition: 0.2s;
        }
        .btn-icon-add:hover { background: #FF4B4B; color: white; border-color: #FF4B4B; transform: scale(1.1); box-shadow: 0 2px 6px rgba(255, 75, 75, 0.3); }

        .pl-input { border: 1px solid #ddd; padding: 10px; border-radius: 6px; width: 100%; outline: none; box-sizing: border-box; font-size: 14px; transition: 0.2s; }
        .pl-input:focus { border-color: #FF4B4B; box-shadow: 0 0 0 3px rgba(255, 75, 75, 0.1); }
        .pl-cover { width: 50px; height: 50px; border-radius: 6px; object-fit: cover; margin-right: 12px; border: 1px solid #eee; cursor: pointer; }
        
        #player-container { position: fixed; bottom: 0; left: 0; width: 100%; height: 80px; background: #000; z-index: 9999; display: none; border-top: 3px solid #FF4B4B; }
        iframe { width: 100%; height: 100%; border: none; }
        
        .btn-main { background-color: #FF4B4B; color: white; border-radius: 50px; border: none; font-weight: bold; transition: 0.2s; }
        .btn-main:hover { background-color: #e03e3e; color: white; box-shadow: 0 4px 12px rgba(255, 75, 75, 0.3); }
        
        @keyframes arrowMove { 0%, 100% { transform: translateX(0); opacity: 0.5; } 50% { transform: translateX(5px); opacity: 1; } }
    </style>
</head>
<body class="pl-body">

    <jsp:include page="../include/header.jsp">
        <jsp:param name="page" value="playlist"/>
    </jsp:include>
	<%
	    Integer userId = (Integer) session.getAttribute("user_id");
	%>
	
	<% if (userId == null) { %>
	
	    <!-- 🔒 로그아웃 상태: 플레이리스트 비활성화 -->
	    <div class="pl-container" style="text-align:center; padding:80px 20px;">
	        <p style="color:#777; margin-top:10px;">나만의 플레이리스트를 만들기 위해선 로그인이 필요해요.</p>
	        <a href="login.jsp" class="btn btn-main" style="margin-top:20px; padding:10px 30px;">로그인하기</a>
	    </div>
	
	<% } else { %>

    <div class="pl-container">
        <div class="row">
            <div class="col-md-9">
                
                <div id="view-main">
                    <div class="pl-header-wrap">
                        <h3 class="pl-page-title">내 플레이리스트</h3>
                        <div>
                            <button class="pl-btn" onclick="deleteMain()"><i class="fas fa-trash-alt"></i> 삭제</button>
                            <button class="pl-btn" onclick="playMain()"><i class="fas fa-play"></i> 듣기</button>
                            <button class="pl-btn" onclick="saveOrderMain()"><i class="fas fa-save"></i> 순서저장</button>
                            <button class="pl-btn pl-btn-tomato" onclick="goCreate()"><i class="fas fa-plus"></i> 만들기</button>
                        </div>
                    </div>
                    <div style="font-size:13px; color:#888; margin-bottom:10px;">총 <span class="text-tomato" id="total-cnt">0</span>개</div>
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="60"><col width="*"><col width="180"><col width="80"></colgroup>
                        <thead><tr><th><input type="checkbox" id="chk-all-main"></th><th>NO</th><th>플레이리스트 정보</th><th>수록곡 미리보기</th><th>듣기</th></tr></thead>
                        <tbody id="playlist-tbody"></tbody>
                    </table>
                </div>

                <div id="view-create" class="hidden">
                    <div class="pl-header-wrap"><h3 class="pl-page-title">플레이리스트 편집</h3></div>
                    <div class="create-wrap">
                        <div class="img-upload-box" onclick="$('#file-input').click()">
                            <img src="" id="preview-img" class="hidden">
                            <div id="preview-placeholder" style="text-align:center; color:#aaa;">
                                <i class="fas fa-camera" style="font-size:24px; margin-bottom:8px; display:block; color:#ddd;"></i>
                                <span style="font-size:12px; color:#999;">커버 등록</span>
                            </div>
                            <input type="file" id="file-input" accept="image/*" style="display:none;" onchange="handleImg(this)">
                        </div>
                        <div style="flex:1; display:flex; flex-direction:column; gap:12px;">
                            <input type="text" id="input-title" class="pl-input" placeholder="플레이리스트 제목을 입력하세요" style="font-weight:bold; font-size:16px;">
                            <textarea id="input-desc" class="pl-input" placeholder="어떤 분위기의 곡들인가요? 소개글을 적어주세요." style="flex:1; resize:none;"></textarea>
                        </div>
                    </div>

                    <h4 style="font-size:18px; font-weight:800; color:#333; margin-bottom:15px;">수록곡 담기 <span style="font-size:13px; font-weight:normal; color:#888; margin-left:5px;">원하는 곡을 검색하거나 차트에서 추가하세요.</span></h4>
                    
                    <div class="dual-list-box">
                        <div class="dl-panel">
                            <div class="dl-tabs">
                                <div class="dl-tab active" onclick="switchTab('search')">검색</div>
                                <div class="dl-tab" onclick="switchTab('popular')">인기차트</div>
                                <div class="dl-tab" onclick="switchTab('new')">최신곡</div>
                            </div>
                            
                            <div id="toolbar-search">
                                <input type="text" id="search-keyword" class="pl-input" placeholder="가수, 제목 검색..." onkeypress="if(event.keyCode==13) doSearch()">
                                <button class="pl-btn pl-btn-tomato" style="height:38px;" onclick="doSearch()">검색</button>
                            </div>
                            
                            <div id="toolbar-chart" class="hidden">
                                <div style="font-size:12px; color:#666;">
                                    <i class="far fa-clock"></i> 기준: <span id="chart-date" class="text-tomato fw-bold"></span>
                                </div>
                                <button class="pl-btn" style="width:34px; padding:0;" onclick="refreshChart()" title="새로고침">
                                    <i class="fas fa-sync-alt" style="margin:0;"></i>
                                </button>
                            </div>

                            <div id="source-list" style="flex:1; overflow-y:auto;"></div>
                        </div>

                        <div class="dl-center-arrow"><i class="fas fa-chevron-right"></i></div>

                        <div class="dl-panel" style="border-color:#FF4B4B; border-width:2px;">
                            <div style="padding:12px 15px; background:#FF4B4B; color:white; font-weight:bold; display:flex; justify-content:space-between; align-items:center;">
                                <span>선곡 리스트 (<span id="sel-cnt">0</span>)</span>
                                <button onclick="clearTemp()" style="background:rgba(255,255,255,0.2); border:1px solid rgba(255,255,255,0.5); color:white; border-radius:12px; font-size:11px; cursor:pointer; padding:2px 10px; transition:0.2s;">전체삭제</button>
                            </div>
                            <div id="selected-list" style="flex:1; overflow-y:auto; background:#fffbfb;"></div>
                        </div>
                    </div>

                    <div style="text-align:center; margin-top:30px; display:flex; justify-content:center; gap:10px;">
                        <button class="pl-btn pl-btn-tomato" style="width:140px; height:45px; font-size:15px;" onclick="savePlaylist()">저장하기</button>
                        <button class="pl-btn" style="width:140px; height:45px; font-size:15px;" onclick="goMainView()">취소</button>
                    </div>
                </div>

                <div id="view-detail" class="hidden">
                    <button class="pl-btn" onclick="goMainView()" style="margin-bottom:15px;"> <i class="fas fa-arrow-left"></i> 목록으로</button>
                    <div class="pl-header-wrap" style="border:none; align-items:flex-start; margin-bottom:0; padding-bottom:0;">
                        <img src="" id="detail-img" class="pl-cover" style="width:140px; height:140px; border-radius:12px; box-shadow:0 4px 10px rgba(0,0,0,0.1);">
                        <div style="flex:1; padding-left:25px; display:flex; flex-direction:column; justify-content:center; height:140px;">
                            <h3 id="detail-title" style="font-weight:800; font-size:28px; margin-bottom:10px; letter-spacing:-1px;"></h3>
                            <p id="detail-desc" style="color:#666; font-size:15px; margin-bottom:5px;"></p>
                            <div style="color:#999; font-size:13px;">총 <span id="detail-cnt" class="text-tomato fw-bold"></span>곡 수록 | 생성일: <span id="detail-date"></span></div>
                            <div style="margin-top:15px;">
                                <button class="pl-btn pl-btn-tomato" onclick="playAllDetail()"><i class="fas fa-play"></i> 전체듣기</button>
                                <button class="pl-btn" onclick="goEdit()"><i class="fas fa-pen"></i> 수정</button>
                            </div>
                        </div>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin:30px 0 10px; align-items:center;">
                        <div style="display:flex; gap:5px;">
                            <button class="pl-btn" onclick="playSelTrack()"><i class="fas fa-play"></i> 선택듣기</button>
                            <button class="pl-btn" onclick="delSelTrack()"><i class="fas fa-trash"></i> 선택삭제</button>
                        </div>
                        <button class="pl-btn" onclick="saveTrackOrder()"><i class="fas fa-save"></i> 순서저장</button>
                    </div>
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="60"><col width="*"><col width="200"><col width="80"></colgroup>
                        <thead><tr><th><input type="checkbox" id="chk-all-track"></th><th>NO</th><th>곡 정보 (드래그하여 순서 변경)</th><th>아티스트</th><th>듣기</th></tr></thead>
                        <tbody id="detail-tbody"></tbody>
                    </table>
                </div>
            </div>
            

        <!-- 오른쪽 사이드바 (index.jsp와 동일) -->
        <div class="col-md-3">

            <%
                Integer LuserId = (Integer) session.getAttribute("user_id");
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
                
                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold m-0">나의 플레이리스트</h6>
                            <button class="btn btn-sm btn-outline-danger" onclick="goCreate()">＋</button>
                        </div>
                        <ul class="list-group list-group-flush" id="sidebar-list"></ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
<% } %>

    <div id="player-container"><iframe id="spotify-iframe" src=""></iframe></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const accessToken = "<%= serverAccessToken %>";
     	// 로그인한 사용자 ID (null이면 로그아웃 상태)
        const CURRENT_USER_ID = "<%=session.getAttribute("user_id")%>";

    	 // 사용자별 LocalStorage Key
        let STORAGE_KEY = null;

        // CURRENT_USER_ID가 null도 아니고, "null" 문자도 아닐 때 = 로그인 상태
        if (CURRENT_USER_ID && CURRENT_USER_ID !== "null") {
            STORAGE_KEY = "tomatoma_pl_user_" + CURRENT_USER_ID;
        } else {
            STORAGE_KEY = null;   // 로그아웃 상태에서는 저장소를 사용하지 않음
        }


        const DEFAULT_IMG = "<%=request.getContextPath()%>/image/토마토.png"; 

        let tempTracks=[], sourceTracks=[], editId=null, tempImg=null;
        let currentTab = 'search'; 

        $(function(){
            goMainView();
            
            // [수정] 드래그 앤 드롭 즉시 순서 반영 (NO 업데이트)
            $("#playlist-tbody, #selected-list, #detail-tbody").sortable({
                cursor: "move", 
                helper: "clone", 
                opacity: 0.8,
                stop: function(event, ui) {
                    // 드래그가 끝나면 즉시 순서 번호를 다시 매깁니다.
                    updateNumbers($(this));
                }
            });
            
            $('#chk-all-main').change(function(){ $('.chk-pl').prop('checked', $(this).prop('checked')); });
            $('#chk-all-track').change(function(){ $('.chk-track').prop('checked', $(this).prop('checked')); });
            
            if(!accessToken || accessToken === "null") alert("⚠ API 토큰 발급에 실패했습니다. (새로고침 필요)");
        });

        // [추가] 순서 번호 자동 업데이트 함수
        function updateNumbers($tbody) {
            $tbody.find('tr').each(function(index) {
                // 두 번째 td (NO 컬럼)의 텍스트를 현재 순서(index+1)로 변경
                $(this).find('td').eq(1).text(index + 1);
            });
        }

        function hideAll(){ $('#view-main, #view-create, #view-detail').addClass('hidden'); }
        function getList(){
            if (!STORAGE_KEY) return [];   // 로그아웃 상태 → 무조건 빈값
            return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
        }
        function saveList(d){
            if (!STORAGE_KEY) return;  // 로그아웃 상태에서는 저장 불가
            localStorage.setItem(STORAGE_KEY, JSON.stringify(d));
        }

        
        // 1. 메인 화면
        function goMainView(){
            hideAll(); $('#view-main').removeClass('hidden');
            const list = getList();
            $('#total-cnt').text(list.length);
            const tb = $('#playlist-tbody').empty();
            $('#chk-all-main').prop('checked',false);
            
            if(list.length==0) tb.html('<tr><td colspan="5" style="padding:50px; color:#ccc;">리스트가 없습니다.<br>오른쪽 상단 [만들기] 버튼을 눌러보세요!</td></tr>');
            else list.forEach((p,i)=>{
                let pre = p.tracks.slice(0,2).map(t=> '<div><span style="color:#aaa;">♪</span> ' + t.title + '</div>').join('');
                // [디자인 적용] btn-play-red 적용
                tb.append('<tr class="draggable-row" data-id="' + p.id + '"><td><input type="checkbox" class="chk-pl" value="' + p.id + '"></td><td>' + (i+1) + '</td><td style="text-align:left; padding-left:15px;"><div style="display:flex;align-items:center;"><img src="' + (p.img||DEFAULT_IMG) + '" class="pl-cover" onclick="goDetail(' + p.id + ')"><div><div class="fw-bold" style="cursor:pointer; font-size:15px;" onclick="goDetail(' + p.id + ')">' + p.title + '</div><small class="text-muted">' + p.tracks.length + '곡</small></div></div></td><td style="text-align:left; font-size:12px; color:#666; padding-left:20px;">' + pre + '</td><td><button class="btn-play-red" onclick="playAll(' + p.id + ')"><i class="fas fa-play"></i></button></td></tr>');
            });
            loadSide();
        }

        // 2. 만들기 화면
        function goCreate(id=null){
            hideAll(); $('#view-create').removeClass('hidden');
            editId=id; tempTracks=[]; tempImg=null;
            $('#input-title').val(''); $('#input-desc').val('');
            $('#preview-img').addClass('hidden').attr('src',''); $('#preview-placeholder').removeClass('hidden');
            
            if(id){
                const p = getList().find(x=>x.id==id);
                if(p){
                    $('#input-title').val(p.title); $('#input-desc').val(p.desc);
                    tempTracks=[...p.tracks];
                    if(p.img){ tempImg=p.img; $('#preview-img').attr('src',p.img).removeClass('hidden'); $('#preview-placeholder').addClass('hidden'); }
                }
            }
            renderSel(); switchTab('search');
        }

        function switchTab(t){
            currentTab = t;
            $('.dl-tab').removeClass('active');
            $('#source-list').empty(); 

            if(t==='search'){
                $('.dl-tab:eq(0)').addClass('active'); 
                $('#toolbar-search').show(); 
                $('#toolbar-chart').addClass('hidden');
                $('#source-list').html('<div style="padding:40px; text-align:center; color:#ccc;"><i class="fas fa-search" style="font-size:30px; margin-bottom:10px; display:block;"></i>검색어를 입력하세요.</div>');
            } else {
                if(t==='popular') $('.dl-tab:eq(1)').addClass('active');
                else $('.dl-tab:eq(2)').addClass('active');
                
                $('#toolbar-search').hide(); 
                $('#toolbar-chart').removeClass('hidden');
                updateTime();
                
                if(t==='popular') fetchPopular();
                else fetchNewReleases();
            }
        }

        function updateTime() {
            const now = new Date();
            const timeStr = now.toLocaleDateString() + " " + now.toLocaleTimeString();
            $('#chart-date').text(timeStr);
        }

        function refreshChart() {
            updateTime();
            if(currentTab === 'popular') fetchPopular();
            else if(currentTab === 'new') fetchNewReleases();
        }

        async function fetchPopular(){
            if(!accessToken) return;
            $('#source-list').html('<div style="padding:20px; text-align:center;">인기 차트 로딩 중...</div>');
            try {
                const url = 'https://api.spotify.com/v1/search?q=\$' + encodeURIComponent('year:2025 k-pop') + '&type=track&limit=20';
                const res = await fetch(url, {headers:{'Authorization':'Bearer '+accessToken}});
                const d = await res.json();
                
                sourceTracks = d.tracks.items.map(t=>({
                    id:t.id, 
                    title:t.name.replace(/'/g,""), 
                    artist:t.artists[0].name.replace(/'/g,""), 
                    img: (t.album.images && t.album.images.length > 0) ? t.album.images[1]?.url || t.album.images[0].url : DEFAULT_IMG
                }));
                renderSrc('popular');
            } catch(e) {
                console.error(e);
                $('#source-list').html('<div style="padding:20px; text-align:center; color:red;">로드 실패</div>');
            }
        }

        async function fetchNewReleases(){
            if(!accessToken) return;
            $('#source-list').html('<div style="padding:20px; text-align:center;">최신 앨범 로딩 중...</div>');
            try {
                const url = 'https://api.spotify.com/v1/browse/new-releases?country=KR&limit=12';
                const res = await fetch(url, {headers:{'Authorization':'Bearer '+accessToken}});
                const d = await res.json();
                
                const items = d.albums ? d.albums.items : [];
                if(items.length === 0) throw new Error("No data");

                sourceTracks = items.map(i=>({
                    id: i.id, 
                    title: i.name.replace(/'/g,""), 
                    artist: i.artists && i.artists.length > 0 ? i.artists[0].name.replace(/'/g,"") : "Unknown", 
                    img: (i.images && i.images.length > 0) ? i.images[1]?.url || i.images[0].url : DEFAULT_IMG
                }));
                renderSrc('new');
            } catch(e){ 
                console.error(e); 
                $('#source-list').html('<div style="padding:20px; text-align:center; color:red;">로드 실패</div>'); 
            }
        }

        async function doSearch(){
            const k=$('#search-keyword').val(); if(!k) return;
            $('#source-list').html('<div style="padding:20px; text-align:center;">검색 중...</div>');
            try {
                const url = 'https://api.spotify.com/v1/search?q=\$' + encodeURIComponent(k) + '&type=track&limit=20';
                const res = await fetch(url, {headers:{'Authorization':'Bearer '+accessToken}});
                const d = await res.json();
                
                sourceTracks = d.tracks.items.map(t=>({
                    id:t.id, 
                    title:t.name.replace(/'/g,""), 
                    artist:t.artists[0].name.replace(/'/g,""), 
                    img: (t.album.images && t.album.images.length > 0) ? t.album.images[1]?.url || t.album.images[0].url : DEFAULT_IMG
                }));
                renderSrc('search');
            } catch(e){ 
                console.error(e);
                alert("검색 실패"); 
            }
        }

        function renderSrc(type){
            const d=$('#source-list').empty();
            if(sourceTracks.length === 0) { d.html('<div style="padding:20px; text-align:center;">결과가 없습니다.</div>'); return; }
            
            sourceTracks.forEach((t,i)=>{
                let rankHtml = '';
                if(type === 'popular') {
                    rankHtml = '<div class="track-rank">' + (i+1) + '</div>';
                }

                // [디자인 적용] btn-icon-play, btn-icon-add 사용
                const btns = '<div class="track-btns">' + 
                             '<button class="btn-icon-play" onclick="playOne(\'' + t.id + '\')"><i class="fas fa-play"></i></button>' +
                             '<button class="btn-icon-add" onclick="addOne(' + i + ')"><i class="fas fa-plus"></i></button>' +
                             '</div>';

                d.append('<div class="track-item">' + 
                            rankHtml + 
                            '<img src="' + t.img + '" class="track-img">' + 
                            '<div class="track-info"><b>' + t.title + '</b><br><span style="color:#888;">' + t.artist + '</span></div>' + 
                            btns + 
                         '</div>');
            });
        }

        function addOne(i){ const t=sourceTracks[i]; if(!tempTracks.some(x=>x.id==t.id)) tempTracks.push(t); renderSel(); }
        
        function renderSel(){
            const d=$('#selected-list').empty(); $('#sel-cnt').text(tempTracks.length);
            tempTracks.forEach((t,i)=> d.append('<div class="track-item" data-id="' + t.id + '" style="background:white; border-radius:8px; margin-bottom:6px; box-shadow:0 1px 3px rgba(0,0,0,0.05);"><div style="width:30px; text-align:center; color:#ccc;"><i class="fas fa-bars"></i></div><img src="' + t.img + '" class="track-img"><div class="track-info"><b>' + t.title + '</b><br><span style="color:#999;">' + t.artist + '</span></div><button onclick="tempTracks.splice(' + i + ',1);renderSel()" style="border:none; background:transparent; color:#aaa; font-size:16px;">×</button></div>'));
            d.scrollTop(d[0].scrollHeight);
        }
        function clearTemp(){ tempTracks=[]; renderSel(); }
        function handleImg(inp){ if(inp.files[0]){ const r=new FileReader(); r.onload=e=>{tempImg=e.target.result; $('#preview-img').attr('src',tempImg).removeClass('hidden'); $('#preview-placeholder').addClass('hidden');}; r.readAsDataURL(inp.files[0]); } }
        
        function savePlaylist(){
            const ti=$('#input-title').val(); if(!ti) return alert("제목 입력 필수");
            const newOrder=[]; $('#selected-list .track-item').each(function(){ newOrder.push(tempTracks.find(x=>x.id==$(this).data('id'))); });
            tempTracks = newOrder; 
            
            let lst=getList(), img=tempImg; 
            if(!img && tempTracks.length>0) img=tempTracks[0].img;
            
            const obj={id:editId||Date.now(), title:ti, desc:$('#input-desc').val(), tracks:tempTracks, img:img, date:new Date().toISOString().slice(0,10)};
            if(editId){ const idx=lst.findIndex(x=>x.id==editId); if(idx>=0) lst[idx]=obj; } else lst.push(obj);
            
            saveList(lst); goMainView();
        }

        // 3. 상세 화면
        function goDetail(id){
            hideAll(); $('#view-detail').removeClass('hidden').data('id',id);
            const p=getList().find(x=>x.id==id);
            $('#detail-title').text(p.title); $('#detail-desc').text(p.desc); $('#detail-cnt').text(p.tracks.length); $('#detail-date').text(p.date);
            $('#detail-img').attr('src', p.img||DEFAULT_IMG);
            renderDetailTr(p.tracks);
        }
        function renderDetailTr(tr){
            const tb=$('#detail-tbody').empty(); $('#chk-all-track').prop('checked',false);
            tr.forEach((t,i)=> tb.append('<tr class="draggable-row" data-id="' + t.id + '"><td><input type="checkbox" class="chk-track" value="' + t.id + '"></td><td>' + (i+1) + '</td><td style="text-align:left; padding-left:15px;"><div style="display:flex; align-items:center;"><img src="' + t.img + '" style="width:40px;height:40px;border-radius:4px;margin-right:12px;vertical-align:middle; border:1px solid #eee;"><span>' + t.title + '</span></div></td><td>' + t.artist + '</td><td><button class="btn-play-red" onclick="playOne(\'' + t.id + '\')"><i class="fas fa-play"></i></button></td></tr>'));
        }
        function goEdit(){ goCreate($('#view-detail').data('id')); }
        
        function playOne(id){ 
            $('#player-container').show(); 
            $('#spotify-iframe').attr('src', 'https://open.spotify.com/embed/track/' + id + '?utm_source=generator&theme=0&autoplay=1'); 
        }
        function playAll(id){ const p=getList().find(x=>x.id==id); if(p&&p.tracks.length) playOne(p.tracks[0].id); else alert("곡이 없습니다."); }
        function playAllDetail(){ playAll($('#view-detail').data('id')); }
        
        function deleteMain(){ const c=$('.chk-pl:checked'); if(!c.length)return; if(confirm("선택한 플레이리스트를 삭제하시겠습니까?")){ let l=getList(); c.each(function(){l=l.filter(x=>x.id!=$(this).val())}); saveList(l); goMainView(); } }
        function saveOrderMain(){ let l=getList(), n=[]; $('#playlist-tbody tr').each(function(){ n.push(l.find(x=>x.id==$(this).data('id'))); }); saveList(n); goMainView(); }
        function playMain(){ const c=$('.chk-pl:checked'); if(c.length) playAll(c.val()); }
        
        function saveTrackOrder(){ 
            const pid=$('#view-detail').data('id'); let l=getList(), idx=l.findIndex(x=>x.id==pid);
            let nt=[]; $('#detail-tbody tr').each(function(){ nt.push(l[idx].tracks.find(x=>x.id==$(this).data('id'))); });
            l[idx].tracks=nt; 
            if(nt.length > 0) l[idx].img = nt[0].img;
            saveList(l); 
            renderDetailTr(nt); 
            $('#detail-img').attr('src', l[idx].img);
            loadSide(); 
            alert("순서가 저장되었습니다.");
        }
        
        function delSelTrack(){
            const c=$('.chk-track:checked'); if(!c.length)return; if(confirm("선택한 곡을 삭제하시겠습니까?")){
                const pid=$('#view-detail').data('id'); let l=getList(), idx=l.findIndex(x=>x.id==pid);
                c.each(function(){ const tid=$(this).val(); l[idx].tracks=l[idx].tracks.filter(t=>t.id!=tid); });
                saveList(l); goDetail(pid); loadSide();
            }
        }
        function playSelTrack(){ const c=$('.chk-track:checked'); if(c.length) playOne(c.val()); }
        
        function loadSide(){
            const ul=$('#sidebar-list').empty(), l=getList();
            if(!l.length) ul.html('<li class="list-group-item small text-center text-muted">없음</li>');
            else l.slice(0,5).forEach(p=>ul.append('<li class="list-group-item d-flex justify-content-between" style="cursor:pointer;" onclick="goDetail(' + p.id + ')"><span class="text-truncate" style="max-width:120px;">' + p.title + '</span><span class="badge bg-light text-dark">' + p.tracks.length + '</span></li>'));
        }
    </script>
</body>
</html>