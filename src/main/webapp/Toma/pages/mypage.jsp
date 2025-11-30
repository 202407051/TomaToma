<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // 로그인 안 했으면 로그인 페이지로 이동
    Integer userId = (Integer) session.getAttribute("user_id");
    if(userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userName = "";
    String userIntro = "";
    String profileImg = "";
    String backgroundImg = "";

    // DB에서 사용자 정보 가져오기
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = ConnectionManager.getConnection();
        String sql = "SELECT username, intro, profile_img, background_img FROM playlist_iduser WHERE user_id=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        if(rs.next()) {
            userName = rs.getString("username");
            userIntro = rs.getString("intro") == null ? "소개글을 등록해주세요." : rs.getString("intro");
            profileImg = rs.getString("profile_img");
            backgroundImg = rs.getString("background_img");
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }

    java.util.List<String> likedSongs =
        java.util.Arrays.asList("노래1 - 아티스트A", "노래2 - 아티스트B", "노래3 - 아티스트C");
%>

<!-- 공통 header 포함 (메뉴 active = mypage) -->
<jsp:include page="../include/header.jsp">
    <jsp:param name="page" value="mypage"/>
</jsp:include>

<!-- ===== 마이페이지 본문 영역 ===== -->
<div class="container my-4" style="max-width:1200px;">

    <!-- 프로필 카드 -->
    <div class="profile-card" style="background-color:#fff; border-radius:15px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,0.1); margin-bottom:30px;">

        <!-- 배경 -->
        <div class="profile-header"
             style="background-image:url('<%=backgroundImg%>');
                    background-size:cover;
                    background-position:center;
                    height:150px;">
        </div>

        <!-- 프로필 정보 -->
        <div class="profile-info" style="display:flex; align-items:center; padding:20px;">

            <div class="profile-pic"
                 style="width:100px; height:100px; border-radius:50%; overflow:hidden;
                        border:3px solid #fff; margin-right:20px; position:relative; top:-50px;">
                <img src="<%=profileImg%>" style="width:100%; height:100%; object-fit:cover;">
                <button class="upload-btn w-100"
                        style="font-size:0.8rem; background-color:#D24949; color:white;
                               border:none; border-radius:10px; padding:4px 10px; margin-top:8px;">
                    사진 업로드
                </button>
            </div>

            <div>
                <h4 class="fw-bold mb-1"><%=userName%></h4>
                <p class="text-muted mb-1"><%=userIntro%></p>
                <a href="editprofile.jsp" class="btn btn-outline-danger btn-sm">프로필 수정</a>
            </div>
        </div>
    </div>

    <!-- 나의 플레이리스트 -->
    <div class="playlist-section"
         style="background-color:#fff; border-radius:15px; box-shadow:0 2px 10px rgba(0,0,0,0.05); padding:20px; margin-bottom:30px;">
        <h5 style="color:#d24949; font-weight:bold;">나의 플레이리스트</h5>

		<div class="list-group mt-3" id="mypage-playlist">
		    <!-- JS가 LocalStorage에서 자동으로 채움 -->
		</div>
        </div>
    </div>


<script>
    // 현재 로그인한 사용자 ID (JSP에서 가져옴)
    const CURRENT_USER_ID = "<%= session.getAttribute("user_id") %>";

    // 사용자별 LocalStorage 키
    let STORAGE_KEY = null;

    if (CURRENT_USER_ID && CURRENT_USER_ID !== "null") {
        STORAGE_KEY = "tomatoma_pl_user_" + CURRENT_USER_ID;
    } else {
        STORAGE_KEY = null;  // 로그아웃 상태
    }

    function getList(){
        if (!STORAGE_KEY) return [];
        return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    }

    // 🎯 마이페이지 플레이리스트 불러오기
    function loadMyPagePlaylist(){
        const list = getList();
        const container = document.getElementById("mypage-playlist");

        container.innerHTML = "";

        // 로그인 안 했을 때
        if (!STORAGE_KEY) {
            container.innerHTML =
                '<div class="list-group-item text-muted">로그인이 필요합니다.</div>';
            return;
        }

        if(list.length === 0){
            container.innerHTML =
                '<div class="list-group-item text-muted">플레이리스트가 없습니다.</div>';
            return;
        }

        list.forEach(function(p){
            container.innerHTML +=
                '<a href="playlist.jsp?id=' + p.id + '" ' +
                'class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">' +
                    '<span>' + p.title + '</span>' +
                    '<span class="badge bg-light text-dark">' + p.tracks.length + '</span>' +
                '</a>';
        });
    }

    // 🎯 마이페이지 전용 로더 실행
    document.addEventListener("DOMContentLoaded", loadMyPagePlaylist);
</script>



