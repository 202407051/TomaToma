<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // [JSP 세션 처리]
    // 로그인 후 callback.jsp에서 저장한 'Access Token'을 꺼내옵니다.
    String accessToken = (String) session.getAttribute("accessToken");
    
    // 토큰이 없으면 null이 되므로, 빈 문자열로 바꿔서 에러를 방지합니다.
    // (빈 문자열이면 로그인 안 한 상태로 간주)
    if(accessToken == null) accessToken = "";
    
    // [경로 설정]
    // CSS나 이미지 파일 경로를 절대경로(/프로젝트명/css/...)로 잡기 위함입니다.
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>TomaToma - My Playlist</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/css/toma.css"> 
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* [스타일 정의] 토마토 테마 (#FF4B4B) */
        .pl-body { font-family: 'Malgun Gothic', 'Dotum', sans-serif; background-color: #fff; color: #333; padding-bottom: 120px; }
        
        /* 전체 레이아웃 컨테이너 */
        .pl-container { max-width: 1200px; margin: 0 auto; padding: 30px 12px; position: relative; }
        
        /* 유틸리티 클래스 */
        .hidden { display: none !important; } /* 화면 숨김용 */
        .text-tomato { color: #FF4B4B; font-weight: bold; } /* 강조 색상 */
        
        /* [버튼 스타일 커스터마이징] */
        .pl-btn { 
            display: inline-flex; align-items: center; justify-content: center;
            padding: 0 12px; height: 32px; 
            border: 1px solid #d1d1d1; background: #fff; 
            font-size: 12px; color: #555; border-radius: 4px; 
            vertical-align: middle; transition: 0.2s; text-decoration: none; cursor: pointer;
        }
        .pl-btn:hover { border-color: #FF4B4B; color: #FF4B4B; background: #fff5f5; }
        
        /* 강조 버튼 (빨간색) */
        .pl-btn-tomato { background: #FF4B4B; border: 1px solid #e03e3e; color: #fff; font-weight: bold; }
        .pl-btn-tomato:hover { background: #ff3333; color: #fff; border-color: #cc2929; }
        .pl-btn-big { height: 45px; font-size: 15px; padding: 0 30px; min-width: 120px; }

        /* 각 화면(View)의 헤더 타이틀 영역 */
        .pl-header-wrap { margin-bottom: 20px; border-bottom: 2px solid #FF4B4B; padding-bottom: 10px; display: flex; justify-content: space-between; align-items: flex-end; }
        .pl-page-title { font-size: 22px; font-weight: bold; color: #1a1a1a; margin: 0; }

        /* [리스트 테이블 스타일] */
        .tbl-list { width: 100%; border-collapse: collapse; border-top: 1px solid #d1d1d1; margin-top: 10px; }
        .tbl-list th { height: 40px; background: #f8f8f8; color: #666; font-size: 12px; border-bottom: 1px solid #ddd; font-weight: normal; text-align: center; }
        .tbl-list td { padding: 10px 0; border-bottom: 1px solid #f2f2f2; font-size: 13px; color: #333; text-align: center; background: #fff; }
        .tbl-list tr:hover td { background-color: #fff9f9; }

        /* 드래그 앤 드롭 시각 효과 */
        .draggable-row { cursor: grab; }
        .draggable-row:active { cursor: grabbing; background: #fff0f0; }
        .ui-sortable-helper { display: table; background: #fff; box-shadow: 0 4px 15px rgba(0,0,0,0.1); opacity: 0.95; }

        /* 테이블 내부 요소 */
        .td-info { text-align: left !important; padding-left: 10px !important; }
        .pl-cover { width: 50px; height: 50px; border-radius: 6px; object-fit: cover; margin-right: 12px; border: 1px solid #eee; }

        /* [만들기 화면] 스타일 */
        .create-wrap { background: #fbfbfb; border: 1px solid #ececec; padding: 20px; display: flex; gap: 20px; margin-bottom: 20px; border-radius: 8px; }
        
        /* 이미지 업로드 박스 */
        .img-upload-box { 
            width: 140px; height: 140px; border: 2px dashed #ccc; background: #fff; border-radius: 8px;
            display: flex; flex-direction: column; align-items: center; justify-content: center; 
            cursor: pointer; position: relative; overflow: hidden; color: #999; transition: 0.2s;
        }
        .img-upload-box:hover { border-color: #FF4B4B; color: #FF4B4B; }
        .img-upload-box img { width: 100%; height: 100%; object-fit: cover; position: absolute; top: 0; left: 0; }

        /* [선곡 영역] 듀얼 리스트 (왼쪽:검색 / 오른쪽:담기) */
        .dual-list { display: flex; height: 450px; gap: 15px; }
        .dl-left, .dl-right { border: 1px solid #ddd; display: flex; flex-direction: column; background: #fff; border-radius: 6px; overflow: hidden; }
        .dl-left { flex: 1.2; } .dl-right { flex: 0.8; border: 1px solid #FF4B4B; }
        
        /* 탭 메뉴 (검색/인기/최신) */
        .dl-tabs { display: flex; background: #f4f4f4; border-bottom: 1px solid #ddd; }
        .dl-tab { flex: 1; text-align: center; padding: 10px 0; font-size: 13px; color: #666; cursor: pointer; border-right: 1px solid #eee; background: #f9f9f9; }
        .dl-tab:hover { background: #fff; }
        .dl-tab.active { background: #fff; color: #FF4B4B; font-weight: bold; border-bottom: 2px solid #FF4B4B; }

        /* 검색창 및 리스트 아이템 */
        #toolbar-search { padding: 10px; border-bottom: 1px solid #eee; display: flex; gap: 8px; align-items: center; }
        #search-keyword { flex: 1; border: 1px solid #d1d1d1; padding: 8px; outline:none; border-radius:4px; }
        
        .track-item { display: flex; align-items: center; padding: 8px 10px; border-bottom: 1px solid #f6f6f6; font-size: 12px; }
        .track-item:hover { background: #fff5f5; }
        .track-img { width: 36px; height: 36px; border-radius: 4px; margin: 0 8px; }
        .track-info { flex: 1; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }

        /* [상세 화면] 상단 정보 */
        .detail-header { display: flex; padding: 20px; border: 1px solid #ddd; margin-bottom: 20px; background: #fff; border-radius: 8px; }
        .detail-cover { width: 140px; height: 140px; border: 1px solid #eee; margin-right: 20px; object-fit: cover; border-radius: 8px; }

        /* [플레이어] 하단 고정 */
        #player-container { position: fixed; bottom: 0; left: 0; width: 100%; height: 80px; background: #000; z-index: 9999; display: none; border-top: 3px solid #FF4B4B; }
        iframe { width: 100%; height: 100%; border: none; }
        
        /* 입력창 공통 */
        .pl-input { border: 1px solid #d1d1d1; padding: 8px; font-size: 13px; outline: none; background:#fdfdfd; border-radius: 4px; width:100%; }
        .pl-input:focus { border-color: #FF4B4B; background: #fff; }
        
        /* 오른쪽 사이드바 호환용 */
        .list-group-item { border: 1px solid #eee; }
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
                            <button class="pl-btn" onclick="deleteSelectedMain()"><i class="fas fa-trash-alt"></i> 삭제</button>
                            <button class="pl-btn" onclick="playSelectedMain()"><i class="fas fa-play"></i> 듣기</button>
                            <button class="pl-btn" onclick="saveOrderMain()"><i class="fas fa-save"></i> 순서저장</button>
                            <button class="pl-btn pl-btn-tomato" onclick="goCreateView()"><i class="fas fa-plus"></i> 만들기</button>
                        </div>
                    </div>
                    <div style="margin-bottom:8px; font-size:12px; color:#888;">총 <span class="text-tomato" id="total-cnt">0</span>개</div>
                    
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="50"><col width="*"><col width="150"><col width="80"></colgroup>
                        <thead><tr><th><input type="checkbox" id="chk-all-main"></th><th>NO</th><th>플레이리스트 정보</th><th>수록곡 미리보기</th><th>듣기</th></tr></thead>
                        <tbody id="playlist-tbody"></tbody>
                    </table>
                </div>

                <div id="view-create" class="hidden">
                    <div class="pl-header-wrap"><h3 class="pl-page-title">플레이리스트 만들기</h3></div>
                    
                    <div class="create-wrap">
                        <div class="img-upload-box" onclick="$('#file-input').click()">
                            <img src="" id="preview-img" class="hidden">
                            <div class="img-upload-placeholder" id="preview-placeholder" style="text-align:center;">
                                <i class="fas fa-camera" style="font-size:30px; margin-bottom:10px; display:block;"></i>커버 등록
                            </div>
                            <input type="file" id="file-input" accept="image/*" style="display:none;" onchange="handleImageUpload(this)">
                        </div>
                        <div style="flex:1; display:flex; flex-direction:column; gap:10px;">
                            <input type="text" id="input-title" class="pl-input" placeholder="제목을 입력해 주세요 (필수)">
                            <textarea id="input-desc" class="pl-input" placeholder="소개글을 입력해 주세요." style="flex:1; resize:none;"></textarea>
                        </div>
                    </div>
                    
                    <h4 style="font-size:16px; margin-bottom:10px; font-weight:bold;">수록곡 담기</h4>
                    
                    (우)선곡 -->
                    <div class="dual-list">
                        <div class="dl-left">
                            <div class="dl-tabs">
                                <div class="dl-tab active" onclick="switchTab('search')">곡 검색</div>
                                <div class="dl-tab" onclick="switchTab('popular')">인기차트</div>
                                <div class="dl-tab" onclick="switchTab('new')">최신곡</div>
                            </div>
                            
                            <div id="toolbar-search">
                                <input type="text" id="search-keyword" class="pl-input" placeholder="가수, 제목 검색..." onkeypress="if(event.keyCode==13) executeSearch()">
                                <button class="pl-btn" onclick="executeSearch()">검색</button>
                            </div>
                            <div id="toolbar-chart" class="hidden" style="padding:10px; text-align:right; border-bottom:1px solid #eee;">
                                <button class="pl-btn pl-btn-tomato" onclick="addCheckedItems()">+ 선택 담기</button>
                            </div>
                            
                            <div id="source-list" style="flex:1; overflow-y:auto;"></div>
                        </div>

                        <div class="dl-right">
                            <div style="padding:10px; background:#FF4B4B; color:white; font-weight:bold; display:flex; justify-content:space-between; align-items:center;">
                                <span>선곡 리스트 (<span id="sel-cnt">0</span>)</span>
                                <button style="color:white; border:1px solid white; font-size:11px; padding:2px 8px; border-radius:12px;" onclick="removeAllTemp()">전체삭제</button>
                            </div>
                            <div id="selected-list" style="flex:1; overflow-y:auto;"></div>
                        </div>
                    </div>
                    
                    <div style="text-align:center; margin-top:30px; display:flex; justify-content:center; gap:10px;">
                        <button class="pl-btn pl-btn-tomato pl-btn-big" onclick="savePlaylist()">저장</button>
                        <button class="pl-btn pl-btn-big" onclick="goMainView()">취소</button>
                    </div>
                </div>

                <div id="view-detail" class="hidden">
                    <button class="pl-btn" onclick="goMainView()" style="margin-bottom:15px;"> < 목록으로</button>
                    
                    <div class="detail-header">
                        <img src="" id="detail-img" class="detail-cover">
                        <div style="flex:1; display:flex; flex-direction:column; justify-content:center;">
                            <h3 id="detail-title" style="margin:0 0 10px 0; font-size:24px; font-weight:bold;">제목</h3>
                            <p id="detail-desc" style="color:#666; margin-bottom:10px;">소개글</p>
                            <div style="color:#888; font-size:13px;">총 <span id="detail-cnt" class="text-tomato">0</span>곡 | <span id="detail-date"></span></div>
                            <div style="margin-top:20px;">
                                <button class="pl-btn pl-btn-tomato" onclick="playAllInDetail()">▶ 전체듣기</button>
                                <button class="pl-btn" onclick="goEditView()">✎ 수정하기</button>
                            </div>
                        </div>
                    </div>
                    
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                        <div>
                            <button class="pl-btn" onclick="playSelectedTrack()"><i class="fas fa-play"></i> 선택 듣기</button>
                            <button class="pl-btn" onclick="deleteSelectedTrack()"><i class="fas fa-trash"></i> 선택 삭제</button>
                        </div>
                        <button class="pl-btn" onclick="saveTrackOrder()"><i class="fas fa-save"></i> 곡 순서 저장</button>
                    </div>
                    
                    <table class="tbl-list">
                        <colgroup><col width="40"><col width="50"><col width="*"><col width="200"><col width="80"></colgroup>
                        <thead><tr><th><input type="checkbox" id="chk-all-track"></th><th>NO</th><th>곡 정보 (드래그 가능)</th><th>아티스트</th><th>듣기</th></tr></thead>
                        <tbody id="detail-tbody"></tbody>
                    </table>
                </div>

            </div> <div class="col-md-3">
                <% if(accessToken.equals("")) { %>
                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <p class="mb-3 small text-muted">로그인하고 기능을 이용해보세요!</p>
                        <a href="index.jsp" class="btn btn-main w-100 mb-2" style="background:#FF4B4B; color:white;">로그인</a>
                    </div>
                </div>
                <% } else { %>
                <div class="card shadow-sm mb-4">
                    <div class="card-body text-center">
                        <h6 class="fw-bold">환영합니다! 👋</h6>
                        <button class="btn btn-outline-secondary btn-sm w-100 mt-2" onclick="location.href='logout.jsp'">로그아웃</button>
                    </div>
                </div>
                <% } %>

                <div class="card shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold m-0">나의 플레이리스트</h6>
                            <button class="btn btn-sm btn-outline-danger" onclick="goCreateView()">＋</button>
                        </div>
                        <ul class="list-group list-group-flush" id="sidebar-playlist">
                            <li class="list-group-item text-muted small text-center">로딩 중...</li>
                        </ul>
                    </div>
                </div>
            </div> </div> </div> <div id="player-container">
        <iframe id="spotify-iframe" src=""></iframe>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // [전역 변수]
        // JSP에서 받은 토큰을 JS 변수에 저장 (없으면 빈 문자열)
        const accessToken = "<%= accessToken %>";
        const STORAGE_KEY = 'tomatoma_final_v4'; // 로컬스토리지 저장 키
        
        // Spotify Playlist IDs (전세계 차트 사용으로 404 방지)
        const ID_POPULAR = "37i9dQZEVXbMDoHDwVN2tF"; 
        const ID_NEW = "37i9dQZF1DXcBWIGoYBM5M"; 

        let tempTracks = [], sourceTracks = [], editingId = null, tempImg = null;

        // [초기화] 문서 로드 시 실행
        $(document).ready(function(){
            goMainView(); // 메인 화면 표시
            // jQuery UI Sortable 활성화 (드래그 기능)
            $("#playlist-tbody, #selected-list, #detail-tbody").sortable({ cursor: "move", helper: "clone" });
            // 체크박스 전체선택 기능 연결
            $('#chk-all-main').change(function() { $('.chk-pl').prop('checked', $(this).prop('checked')); });
            $('#chk-all-track').change(function() { $('.chk-track').prop('checked', $(this).prop('checked')); });
            loadSidebar(); // 오른쪽 사이드바 로딩
        });

        // [사이드바] 오른쪽 미니 리스트 로드
        function loadSidebar() {
            const list = getList();
            const sb = $('#sidebar-playlist');
            sb.empty();
            if(list.length === 0) {
                sb.html('<li class="list-group-item text-muted small text-center">리스트가 없습니다.</li>');
            } else {
                // 최신 5개만 표시
                list.slice(0, 5).forEach(pl => {
                    sb.append(`<li class="list-group-item d-flex justify-content-between align-items-center" style="cursor:pointer;" onclick="goDetailView(\${pl.id})">
                        <div class="text-truncate" style="max-width:140px;">\${pl.title}</div>
                        <span class="badge bg-light text-dark rounded-pill">\${pl.tracks.length}</span>
                    </li>`);
                });
            }
        }

        // [화면 전환 함수]
        function hideAll() { $('#view-main, #view-create, #view-detail').addClass('hidden'); }
        
        function goMainView() { 
            hideAll(); $('#view-main').removeClass('hidden'); 
            renderMainList(); 
            loadSidebar(); 
        }
        
        function goCreateView(id=null) {
            // 만들기 화면 초기화 및 수정 모드 처리
            hideAll(); $('#view-create').removeClass('hidden');
            editingId = id; tempTracks = []; tempImg = null;
            $('#input-title').val(''); $('#input-desc').val('');
            $('#preview-img').addClass('hidden').attr('src', ''); $('#preview-placeholder').removeClass('hidden');

            if(id) { // 수정일 경우 기존 데이터 불러오기
                const pl = getList().find(p => p.id == id);
                if(pl) {
                    $('#input-title').val(pl.title); $('#input-desc').val(pl.desc);
                    tempTracks = [...pl.tracks];
                    if(pl.img) {
                        tempImg = pl.img;
                        $('#preview-img').attr('src', pl.img).removeClass('hidden');
                        $('#preview-placeholder').addClass('hidden');
                    }
                }
            }
            renderSelected(); switchTab('search');
        }

        function goDetailView(id) {
            hideAll(); $('#view-detail').removeClass('hidden'); $('#view-detail').data('id', id);
            const pl = getList().find(p => p.id == id);
            $('#detail-title').text(pl.title); $('#detail-desc').text(pl.desc);
            $('#detail-date').text(pl.date); $('#detail-cnt').text(pl.tracks.length);
            $('#detail-img').attr('src', pl.img || 'https://via.placeholder.com/180?text=No+Image');
            renderDetailTracks(pl.tracks);
        }
        
        function renderDetailTracks(tracks) {
            const tbody = $('#detail-tbody'); tbody.empty(); $('#chk-all-track').prop('checked', false);
            tracks.forEach((t, idx) => {
                tbody.append(`<tr class="draggable-row" data-id="\${t.id}"><td><input type="checkbox" class="chk-track" value="\${t.id}"></td><td>\${idx+1}</td><td class="td-info"><img src="\${t.img}" style="width:40px;height:40px;border-radius:4px;margin-right:10px;vertical-align:middle;">\${t.title}</td><td>\${t.artist}</td><td><button class="pl-btn" onclick="playOne('\${t.id}')">▶</button></td></tr>`);
            });
        }
        function goEditView() { goCreateView($('#view-detail').data('id')); }

        function renderMainList() {
            const list = getList(); $('#total-cnt').text(list.length);
            const tbody = $('#playlist-tbody'); tbody.empty(); $('#chk-all-main').prop('checked', false);
            if(list.length === 0) return tbody.html('<tr><td colspan="5" style="padding:50px; color:#999;">생성된 리스트가 없습니다.</td></tr>');
            list.forEach((pl, idx) => {
                let preview = pl.tracks.slice(0,2).map(t=>`<div>\${t.title}</div>`).join('');
                tbody.append(`<tr class="draggable-row" data-id="\${pl.id}"><td><input type="checkbox" class="chk-pl" value="\${pl.id}"></td><td>\${idx+1}</td><td class="td-info"><div style="display:flex;align-items:center;"><img src="\${pl.img||'https://via.placeholder.com/60'}" class="pl-cover" onclick="goDetailView(\${pl.id})"><div><div class="pl-page-title" style="font-size:14px; cursor:pointer;" onclick="goDetailView(\${pl.id})">\${pl.title}</div><div style="font-size:12px;color:#888;">\${pl.tracks.length}곡</div></div></div></td><td style="text-align:left;font-size:12px;color:#888;padding-left:20px;">\${preview}</td><td><button class="pl-btn" onclick="playAll(\${pl.id})">▶ 재생</button></td></tr>`);
            });
        }

        function deleteSelectedMain() {
            const chk = $('.chk-pl:checked');
            if(chk.length===0) return alert("삭제할 리스트를 선택하세요.");
            if(!confirm("삭제하시겠습니까?")) return;
            let list = getList();
            chk.each(function() { list = list.filter(p => p.id != $(this).val()); });
            saveList(list); renderMainList(); loadSidebar();
        }

        function saveOrderMain() {
            let list = getList(), newOrder = [];
            $('#playlist-tbody tr').each(function() {
                const id = $(this).data('id');
                const item = list.find(p => p.id == id);
                if(item) newOrder.push(item);
            });
            saveList(newOrder); renderMainList(); loadSidebar(); alert("순서 저장 완료");
        }
        function playSelectedMain() { const c=$('.chk-pl:checked'); if(c.length==0)return alert("선택된 리스트가 없습니다."); playAll(c.first().val()); }

        // [API 및 데이터 처리]
        function switchTab(t) {
            $('.dl-tab').removeClass('active');
            if(t==='search') { 
                $('.dl-tab:nth-child(1)').addClass('active'); 
                $('#toolbar-search').removeClass('hidden'); $('#toolbar-chart').addClass('hidden'); 
                if(!accessToken) $('#source-list').html('<div style="padding:30px;text-align:center;color:#999;">검색 기능은 로그인이 필요합니다.</div>');
                else $('#source-list').html('<div style="padding:30px;text-align:center;color:#999;">검색하세요.</div>'); 
            }
            else { 
                $('.dl-tab:nth-child('+(t==='popular'?2:3)+')').addClass('active'); 
                $('#toolbar-search').addClass('hidden'); $('#toolbar-chart').removeClass('hidden'); 
                fetchChart(t==='popular'?ID_POPULAR:ID_NEW); 
            }
        }

        async function fetchChart(pid) {
            if(!accessToken) { $('#source-list').html('<div style="padding:30px;text-align:center;color:#999;">차트 기능은 로그인이 필요합니다.</div>'); return; }
            $('#source-list').html('<div style="padding:20px;text-align:center;">차트 로딩 중...</div>');
            try {
                const res = await fetch(`https://api.spotify.com/v1/playlists/\${pid}/tracks?limit=20`, { headers: {'Authorization':'Bearer '+accessToken} });
                if(res.status===401) return alert("토큰 만료. 재로그인하세요.");
                const d = await res.json();
                sourceTracks = d.items.slice(0, 20).map(i=>({id:i.track.id, title:i.track.name.replace(/'/g,""), artist:i.track.artists[0].name.replace(/'/g,""), img:i.track.album.images[2]?.url}));
                renderSource(true);
            } catch(e) { $('#source-list').html('<div style="padding:30px;text-align:center;">로드 실패</div>'); }
        }

        async function executeSearch() {
            if(!accessToken) return alert("검색 기능은 로그인이 필요합니다.");
            const k = $('#search-keyword').val(); if(!k) return;
            try {
                const res = await fetch(`https://api.spotify.com/v1/search?q=\${encodeURIComponent(k)}&type=track&limit=20`, { headers: {'Authorization':'Bearer '+accessToken} });
                const d = await res.json();
                sourceTracks = d.tracks.items.map(t=>({id:t.id, title:t.name.replace(/'/g,""), artist:t.artists[0].name.replace(/'/g,""), img:t.album.images[2]?.url}));
                renderSource(false);
            } catch(e) { alert("검색 실패"); }
        }

        function renderSource(isChart) {
            const div = $('#source-list'); div.empty();
            sourceTracks.forEach((t,i) => {
                const left = isChart ? `<input type="checkbox" class="chk-src" value="\${i}">` : `<button class="pl-btn" onclick="addOne(\${i})">담기</button>`;
                div.append(`<div class="track-item"><div class="track-rank">\${left}</div><img src="\${t.img}" class="track-img"><div class="track-info"><b>\${t.title}</b><br>\${t.artist}</div><button class="pl-btn" onclick="playOne('\${t.id}')">▶</button></div>`);
            });
        }

        function addCheckedItems() { $('.chk-src:checked').each(function() { const t = sourceTracks[$(this).val()]; if(!tempTracks.some(x=>x.id==t.id)) tempTracks.push(t); }); renderSelected(); }
        function addOne(i) { const t = sourceTracks[i]; if(!tempTracks.some(x=>x.id==t.id)) tempTracks.push(t); renderSelected(); }
        function renderSelected() {
            const div = $('#selected-list'); div.empty(); $('#sel-cnt').text(tempTracks.length);
            tempTracks.forEach((t,i) => { div.append(`<div class="track-item" data-id="\${t.id}" style="cursor:move;"><div class="track-rank"><i class="fas fa-bars" style="color:#ccc;"></i></div><img src="\${t.img}" class="track-img"><div class="track-info"><b>\${t.title}</b><br>\${t.artist}</div><button onclick="removeTemp(\${i})" style="color:#aaa;">x</button></div>`); });
        }
        function removeTemp(i) { tempTracks.splice(i,1); renderSelected(); }
        function removeAllTemp() { tempTracks=[]; renderSelected(); }
        function handleImageUpload(inp) { if(inp.files && inp.files[0]) { const r = new FileReader(); r.onload = function(e) { tempImg = e.target.result; $('#preview-img').attr('src', tempImg).removeClass('hidden'); $('#preview-placeholder').addClass('hidden'); }; r.readAsDataURL(inp.files[0]); } }

        // [로컬스토리지 저장 및 관리]
        function getList() { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || []; }
        function saveList(d) { localStorage.setItem(STORAGE_KEY, JSON.stringify(d)); }

        function savePlaylist() {
            const title = $('#input-title').val(); if(!title) return alert("제목 입력");
            const newOrder = []; $('#selected-list .track-item').each(function(){ newOrder.push(tempTracks.find(x=>x.id==$(this).data('id'))); }); tempTracks = newOrder;
            let list = getList();
            let img = tempImg; if(!img && tempTracks.length > 0) img = tempTracks[0].img;
            const obj = { id: editingId||Date.now(), title: title, desc: $('#input-desc').val(), tracks: tempTracks, img: img, date: new Date().toISOString().slice(0,10) };
            if(editingId) { const idx = list.findIndex(p=>p.id==editingId); if(idx>=0) list[idx] = obj; } else list.push(obj);
            saveList(list); alert("저장 완료"); goMainView();
        }

        function saveTrackOrder() {
            const plId = $('#view-detail').data('id'); let list = getList(); const idx = list.findIndex(p => p.id == plId); if(idx === -1) return;
            let newTracks = []; $('#detail-tbody tr').each(function() { newTracks.push(list[idx].tracks.find(x => x.id == $(this).data('id'))); });
            list[idx].tracks = newTracks;
            if((!list[idx].img || list[idx].img.startsWith("http")) && newTracks.length > 0) list[idx].img = newTracks[0].img;
            saveList(list); renderDetailTracks(newTracks); $('#detail-img').attr('src', list[idx].img); loadSidebar(); alert("곡 순서 저장됨");
        }

        function playSelectedTrack() { const chk = $('.chk-track:checked'); if(chk.length===0) return alert("곡 선택"); playOne(chk.first().val()); }
        function deleteSelectedTrack() {
            const chk = $('.chk-track:checked'); if(chk.length===0) return; if(!confirm("삭제?")) return;
            const plId = $('#view-detail').data('id'); let list = getList(); const idx = list.findIndex(p => p.id == plId);
            chk.each(function() { const tid = $(this).val(); list[idx].tracks = list[idx].tracks.filter(t => t.id != tid); });
            saveList(list); $('#detail-cnt').text(list[idx].tracks.length); renderDetailTracks(list[idx].tracks); loadSidebar();
        }

        function playOne(id) { $('#player-container').show(); $('#spotify-iframe').attr('src', `https://open.spotify.com/embed/track/\${id}?utm_source=generator&theme=0&autoplay=1`); }
        function playAll(id) { const pl = getList().find(p=>p.id==id); if(pl && pl.tracks.length) playOne(pl.tracks[0].id); else alert("곡 없음"); }
        function playAllInDetail() { playAll($('#view-detail').data('id')); }
    </script>
</body>
</html>