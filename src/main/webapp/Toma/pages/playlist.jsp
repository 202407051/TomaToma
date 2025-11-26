<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.net.*, java.util.*, org.json.*" %>
<%
    // [1] 로그인 세션 확인 (사이드바 처리를 위한 변수 설정)
    // 세션에서 사용자 이름(또는 ID)을 가져옵니다. "userName"은 실제 프로젝트 세션 키값에 맞춰주세요.
    String username = (String) session.getAttribute("userName");
    boolean isLoggedIn = (username != null);

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
        /* [CSS 스타일 정의] */
        .pl-body { font-family: 'Noto Sans KR', sans-serif; background-color: #fff; padding-bottom: 120px; }
        .pl-container { max-width: 1200px; margin: 0 auto; padding: 30px 12px; }
        .hidden { display: none !important; }
        .text-tomato { color: #FF4B4B; font-weight: bold; }
        
        /* 버튼 스타일 */
        .pl-btn { display: inline-flex; align-items: center; justify-content: center; padding: 0 14px; height: 34px; border: 1px solid #d1d1d1; background: #fff; border-radius: 4px; font-size: 13px; color: #555; cursor: pointer; transition: 0.2s; white-space: nowrap; flex-shrink: 0; }
        .pl-btn:hover { color: #FF4B4B; border-color: #FF4B4B; background: #fff5f5; }
        .pl-btn-tomato { background: #FF4B4B; color: #fff; border-color: #e03e3e; font-weight: bold; }
        .pl-btn-tomato:hover { background: #ff3333; color: white; }
        
        /* [수정 1] 버튼 내부 아이콘과 글자 간격 벌리기 */
        .pl-btn i { margin-right: 6px; }
        
        .pl-header-wrap { border-bottom: 2px solid #FF4B4B; padding-bottom: 10px; display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 20px; }
        .pl-page-title { font-size: 22px; font-weight: bold; margin: 0; color: #333; }
        
        /* 테이블 */
        .tbl-list { width: 100%; border-collapse: collapse; margin-top: 10px; border-top: 1px solid #d1d1d1; }
        .tbl-list th { background: #f8f8f8; height: 40px; font-weight: normal; font-size: 12px; border-bottom: 1px solid #ddd; text-align: center; }
        .tbl-list td { padding: 10px 0; border-bottom: 1px solid #f2f2f2; font-size: 13px; text-align: center; }
        .tbl-list tr:hover td { background: #fff9f9; }
        
        /* 만들기 화면 */
        .create-wrap { background: #fbfbfb; border: 1px solid #ececec; padding: 20px; display: flex; gap: 20px; margin-bottom: 20px; border-radius: 8px; }
        .img-upload-box { width: 140px; height: 140px; border: 2px dashed #ccc; background: #fff; border-radius: 8px; display: flex; align-items: center; justify-content: center; cursor: pointer; position: relative; overflow: hidden; flex-shrink: 0; }
        .img-upload-box img { width: 100%; height: 100%; object-fit: cover; position: absolute; }
        
        /* 듀얼 리스트 */
        .dual-list-box { display: flex; gap: 15px; height: 500px; align-items: center; }
        .dl-panel { flex: 1; border: 1px solid #ddd; height: 100%; display: flex; flex-direction: column; border-radius: 6px; overflow: hidden; background: #fff; }
        .dl-center-arrow { font-size: 24px; color: #FF4B4B; animation: arrowMove 1.5s infinite; }
        @keyframes arrowMove { 0%, 100% { transform: translateX(0); opacity: 0.5; } 50% { transform: translateX(5px); opacity: 1; } }
        
        .dl-tabs { display: flex; background: #f4f4f4; border-bottom: 1px solid #ddd; }
        .dl-tab { flex: 1; text-align: center; padding: 10px 0; cursor: pointer; font-size: 13px; color: #666; border-right: 1px solid #eee; }
        .dl-tab.active { background: #fff; color: #FF4B4B; font-weight: bold; border-bottom: 2px solid #FF4B4B; }
        
        /* 검색창 레이아웃 고정 */
        #toolbar-search { padding: 10px; display: flex; gap: 5px; border-bottom: 1px solid #eee; width: 100%; flex-wrap: nowrap; align-items: center; box-sizing: border-box; }
        #search-keyword { flex: 1; min-width: 0; }
        
        .track-item { display: flex; align-items: center; padding: 8px 10px; border-bottom: 1px solid #f6f6f6; font-size: 13px; }
        .track-item:hover { background: #fff5f5; }
        .track-img { width: 40px; height: 40px; border-radius: 4px; margin: 0 10px; object-fit: cover; border: 1px solid #eee; flex-shrink: 0; }
        .track-info { flex: 1; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }

        .pl-input { border: 1px solid #d1d1d1; padding: 8px; border-radius: 4px; width: 100%; outline: none; box-sizing: border-box; }
        .pl-input:focus { border-color: #FF4B4B; }
        .pl-cover { width: 50px; height: 50px; border-radius: 6px; object-fit: cover; margin-right: 12px; border: 1px solid #eee; cursor: pointer; }
        #player-container { position: fixed; bottom: 0; left: 0; width: 100%; height: 80px; background: #000; z-index: 9999; display: none; border-top: 3px solid #FF4B4B; }
        iframe { width: 100%; height: 100%; border: none; }
        
        /* [수정 2] 로그인 버튼 스타일 (둥근 모양) */
        .btn-main { background-color: #FF4B4B; color: white; border-radius: 50px; border: none; font-weight: bold; transition: 0.2s; }
        .btn-main:hover { background-color: #e03e3e; color: white; }
    </style>
</head>
<body class="pl-body">

    <jsp:include page="../include/header.jsp">
        <jsp:param name="page" value="playlist"/>
    </jsp:include>

    <div class="container pl-container">
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
                    <div style="font-size:12px; color:#888; margin-bottom:8px;">총 <span class="text-tomato" id="total-cnt">0</span>개</div>
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="50"><col width="*"><col width="150"><col width="80"></colgroup>
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
                                <i class="fas fa-camera" style="font-size:24px; margin-bottom:5px; display:block;"></i>커버
                            </div>
                            <input type="file" id="file-input" accept="image/*" style="display:none;" onchange="handleImg(this)">
                        </div>
                        <div style="flex:1; display:flex; flex-direction:column; gap:10px;">
                            <input type="text" id="input-title" class="pl-input" placeholder="제목 (필수)" style="font-weight:bold;">
                            <textarea id="input-desc" class="pl-input" placeholder="소개글" style="flex:1; resize:none;"></textarea>
                        </div>
                    </div>

                    <h4 style="font-size:16px; font-weight:bold; color:#555; margin-bottom:10px;">수록곡 담기</h4>
                    
                    <div class="dual-list-box">
                        <div class="dl-panel">
                            <div class="dl-tabs">
                                <div class="dl-tab active" onclick="switchTab('search')">검색</div>
                                <div class="dl-tab" onclick="switchTab('popular')">인기차트</div>
                                <div class="dl-tab" onclick="switchTab('new')">최신곡</div>
                            </div>
                            <div id="toolbar-search">
                                <input type="text" id="search-keyword" class="pl-input" placeholder="가수, 제목..." onkeypress="if(event.keyCode==13) doSearch()">
                                <button class="pl-btn" onclick="doSearch()">검색</button>
                            </div>
                            <div id="toolbar-chart" class="hidden" style="padding:10px; text-align:right; border-bottom:1px solid #eee;">
                                <button class="pl-btn pl-btn-tomato" onclick="addChecked()">+ 선택 담기</button>
                            </div>
                            <div id="source-list" style="flex:1; overflow-y:auto;"></div>
                        </div>

                        <div class="dl-center-arrow"><i class="fas fa-chevron-right"></i></div>

                        <div class="dl-panel" style="border-color:#FF4B4B;">
                            <div style="padding:10px; background:#FF4B4B; color:white; font-weight:bold; display:flex; justify-content:space-between;">
                                <span>선곡 리스트 (<span id="sel-cnt">0</span>)</span>
                                <button onclick="clearTemp()" style="background:none; border:1px solid white; color:white; border-radius:10px; font-size:11px; cursor:pointer;">전체삭제</button>
                            </div>
                            <div id="selected-list" style="flex:1; overflow-y:auto; background:#fffbfb;"></div>
                        </div>
                    </div>

                    <div style="text-align:center; margin-top:20px;">
                        <button class="pl-btn pl-btn-tomato" style="width:120px; height:40px;" onclick="savePlaylist()">저장</button>
                        <button class="pl-btn" style="width:120px; height:40px;" onclick="goMainView()">취소</button>
                    </div>
                </div>

                <div id="view-detail" class="hidden">
                    <button class="pl-btn" onclick="goMainView()" style="margin-bottom:15px;"> < 목록</button>
                    <div class="pl-header-wrap" style="border:none; align-items:flex-start; margin-bottom:0;">
                        <img src="" id="detail-img" class="pl-cover" style="width:120px; height:120px;">
                        <div style="flex:1; padding-left:20px;">
                            <h3 id="detail-title" style="font-weight:bold; margin-bottom:10px;"></h3>
                            <p id="detail-desc" style="color:#666; font-size:14px;"></p>
                            <div style="color:#888; font-size:13px;">총 <span id="detail-cnt" class="text-tomato"></span>곡 | <span id="detail-date"></span></div>
                            <div style="margin-top:15px;">
                                <button class="pl-btn pl-btn-tomato" onclick="playAllDetail()">▶ 전체듣기</button>
                                <button class="pl-btn" onclick="goEdit()">✎ 수정</button>
                            </div>
                        </div>
                    </div>
                    <div style="display:flex; justify-content:space-between; margin:20px 0 10px;">
                        <div>
                            <button class="pl-btn" onclick="playSelTrack()">▶ 선택듣기</button>
                            <button class="pl-btn" onclick="delSelTrack()">🗑 선택삭제</button>
                        </div>
                        <button class="pl-btn" onclick="saveTrackOrder()">💾 순서저장</button>
                    </div>
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="50"><col width="*"><col width="200"><col width="80"></colgroup>
                        <thead><tr><th><input type="checkbox" id="chk-all-track"></th><th>NO</th><th>곡 정보</th><th>아티스트</th><th>듣기</th></tr></thead>
                        <tbody id="detail-tbody"></tbody>
                    </table>
                </div>

            </div>
            
            <div class="col-md-3">
                <% if (!isLoggedIn) { %>
                <div class="card shadow-sm mb-4">
                  <div class="card-body text-center">
                    <p class="text-muted small mb-3">로그인하고 기능을 이용해보세요!</p>
                    <a href="login.jsp" class="btn btn-main w-100 mb-2 text-center shadow-sm">로그인</a>
                    <a href="join.jsp" class="d-block small text-muted text-decoration-underline">회원가입</a>
                  </div>
                </div>
                <% } else { %>
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
    <div id="player-container"><iframe id="spotify-iframe" src=""></iframe></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const accessToken = "<%= serverAccessToken %>";
        const STORAGE_KEY = 'tomatoma_pl_v6';
        const DEFAULT_IMG = "<%=request.getContextPath()%>/image/토마토.png"; 

        let tempTracks=[], sourceTracks=[], editId=null, tempImg=null;

        $(function(){
            goMainView();
            $("#playlist-tbody, #selected-list, #detail-tbody").sortable({cursor:"move", helper:"clone", opacity:0.8});
            $('#chk-all-main').change(function(){ $('.chk-pl').prop('checked', $(this).prop('checked')); });
            $('#chk-all-track').change(function(){ $('.chk-track').prop('checked', $(this).prop('checked')); });
            
            if(!accessToken || accessToken === "null") console.error("Spotify 토큰 발급 실패");
        });

        function hideAll(){ $('#view-main, #view-create, #view-detail').addClass('hidden'); }
        function getList(){ return JSON.parse(localStorage.getItem(STORAGE_KEY))||[]; }
        function saveList(d){ localStorage.setItem(STORAGE_KEY, JSON.stringify(d)); }
        
        // 1. 메인 화면
        function goMainView(){
            hideAll(); $('#view-main').removeClass('hidden');
            const list = getList();
            $('#total-cnt').text(list.length);
            const tb = $('#playlist-tbody').empty();
            $('#chk-all-main').prop('checked',false);
            
            if(list.length==0) tb.html('<tr><td colspan="5" style="padding:40px; color:#ccc;">리스트가 없습니다.</td></tr>');
            else list.forEach((p,i)=>{
                let pre = p.tracks.slice(0,2).map(t=>`<div>- \${t.title}</div>`).join('');
                tb.append(`<tr class="draggable-row" data-id="\${p.id}"><td><input type="checkbox" class="chk-pl" value="\${p.id}"></td><td>\${i+1}</td><td style="text-align:left; padding-left:10px;"><div style="display:flex;align-items:center;"><img src="\${p.img||DEFAULT_IMG}" class="pl-cover" onclick="goDetail(\${p.id})"><div><div class="fw-bold" style="cursor:pointer;" onclick="goDetail(\${p.id})">\${p.title}</div><small class="text-muted">\${p.tracks.length}곡</small></div></div></td><td style="text-align:left; font-size:12px; color:#888;">\${pre}</td><td><button class="pl-btn" onclick="playAll(\${p.id})">▶</button></td></tr>`);
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
            $('.dl-tab').removeClass('active');
            if(t==='search'){
                $('.dl-tab:eq(0)').addClass('active'); $('#toolbar-search').show(); $('#toolbar-chart').addClass('hidden');
                $('#source-list').html('<div style="padding:20px; text-align:center; color:#999;">검색어를 입력하세요.</div>');
            } else {
                $('.dl-tab:eq('+(t==='popular'?1:2)+')').addClass('active'); $('#toolbar-search').hide(); $('#toolbar-chart').removeClass('hidden');
                fetchData(t==='popular'?"37i9dQZEVXbMDoHDwVN2tF":"37i9dQZF1DXcBWIGoYBM5M", true);
            }
        }

        async function fetchData(pid, isChart){
            if(!accessToken) return alert("API 토큰이 없습니다.");
            $('#source-list').html('<div style="padding:20px; text-align:center;">로딩 중...</div>');
            try {
                const res = await fetch(`https://api.spotify.com/v1/playlists/\${pid}/tracks?limit=20`, {headers:{'Authorization':'Bearer '+accessToken}});
                const d = await res.json();
                sourceTracks = d.items.slice(0,20).map(i=>({
                    id:i.track.id, 
                    title:i.track.name.replace(/'/g,""), 
                    artist:i.track.artists[0].name.replace(/'/g,""), 
                    img:i.track.album.images[1]?.url||DEFAULT_IMG
                }));
                renderSrc(true);
            } catch(e){ console.log(e); $('#source-list').html('데이터 로드 실패'); }
        }

        async function doSearch(){
            const k=$('#search-keyword').val(); if(!k) return;
            $('#source-list').html('<div style="padding:20px; text-align:center;">검색 중...</div>');
            try {
                const res = await fetch(`https://api.spotify.com/v1/search?q=\${encodeURIComponent(k)}&type=track&limit=20`, {headers:{'Authorization':'Bearer '+accessToken}});
                const d = await res.json();
                sourceTracks = d.tracks.items.map(t=>({
                    id:t.id, 
                    title:t.name.replace(/'/g,""), 
                    artist:t.artists[0].name.replace(/'/g,""), 
                    img:t.album.images[1]?.url||DEFAULT_IMG
                }));
                renderSrc(false);
            } catch(e){ alert("검색 실패"); }
        }

        function renderSrc(isChart){
            const d=$('#source-list').empty();
            if(sourceTracks.length === 0) { d.html('<div style="padding:20px; text-align:center;">결과가 없습니다.</div>'); return; }
            sourceTracks.forEach((t,i)=>{
                const btn = isChart ? `<input type="checkbox" class="chk-src" value="\${i}">` : `<button class="pl-btn" onclick="addOne(\${i})">+</button>`;
                d.append(`<div class="track-item"><div style="width:30px; text-align:center;">\${btn}</div><img src="\${t.img}" class="track-img"> <div class="track-info"><b>\${t.title}</b><br><span style="color:#888;">\${t.artist}</span></div> <button class="pl-btn" onclick="playOne('\${t.id}')">▶</button></div>`);
            });
        }

        function addOne(i){ const t=sourceTracks[i]; if(!tempTracks.some(x=>x.id==t.id)) tempTracks.push(t); renderSel(); }
        function addChecked(){ $('.chk-src:checked').each(function(){ addOne($(this).val()); }); }
        
        function renderSel(){
            const d=$('#selected-list').empty(); $('#sel-cnt').text(tempTracks.length);
            tempTracks.forEach((t,i)=> d.append(`<div class="track-item" data-id="\${t.id}" style="background:white; border-radius:4px; margin-bottom:5px;"><div style="width:30px; text-align:center;"><i class="fas fa-bars" style="color:#ccc;"></i></div><img src="\${t.img}" class="track-img"><div class="track-info"><b>\${t.title}</b><br>\${t.artist}</div><button onclick="tempTracks.splice(\${i},1);renderSel()" style="border:none; background:transparent;">×</button></div>`));
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
            tr.forEach((t,i)=> tb.append(`<tr class="draggable-row" data-id="\${t.id}"><td><input type="checkbox" class="chk-track" value="\${t.id}"></td><td>\${i+1}</td><td style="text-align:left; padding-left:10px;"><img src="\${t.img}" style="width:40px;height:40px;border-radius:4px;margin-right:10px;vertical-align:middle;">\${t.title}</td><td>\${t.artist}</td><td><button class="pl-btn" onclick="playOne('\${t.id}')">▶</button></td></tr>`));
        }
        function goEdit(){ goCreate($('#view-detail').data('id')); }
        
        function playOne(id){ 
            $('#player-container').show(); 
            $('#spotify-iframe').attr('src', `https://open.spotify.com/embed/track/\${id}?utm_source=generator&theme=0&autoplay=1`); 
        }
        function playAll(id){ const p=getList().find(x=>x.id==id); if(p&&p.tracks.length) playOne(p.tracks[0].id); else alert("곡이 없습니다."); }
        function playAllDetail(){ playAll($('#view-detail').data('id')); }
        
        function deleteMain(){ const c=$('.chk-pl:checked'); if(!c.length)return; if(confirm("삭제?")){ let l=getList(); c.each(function(){l=l.filter(x=>x.id!=$(this).val())}); saveList(l); goMainView(); } }
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
            const c=$('.chk-track:checked'); if(!c.length)return; if(confirm("삭제?")){
                const pid=$('#view-detail').data('id'); let l=getList(), idx=l.findIndex(x=>x.id==pid);
                c.each(function(){ const tid=$(this).val(); l[idx].tracks=l[idx].tracks.filter(t=>t.id!=tid); });
                saveList(l); goDetail(pid); loadSide();
            }
        }
        function playSelTrack(){ const c=$('.chk-track:checked'); if(c.length) playOne(c.val()); }
        
        function loadSide(){
            const ul=$('#sidebar-list').empty(), l=getList();
            if(!l.length) ul.html('<li class="list-group-item small text-center text-muted">없음</li>');
            else l.slice(0,5).forEach(p=>ul.append(`<li class="list-group-item d-flex justify-content-between" style="cursor:pointer;" onclick="goDetail(\${p.id})"><span class="text-truncate" style="max-width:120px;">\${p.title}</span><span class="badge bg-light text-dark">\${p.tracks.length}</span></li>`));
        }
    </script>
</body>
</html>