<%@ page import="java.sql.*" %>
<%@ page import="com.toma.db.ConnectionManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
	// 🔥 여기에 로그인 체크 삽입!
	Integer userId = (Integer) session.getAttribute("user_id");
	if(userId == null) {
	    response.sendRedirect("login.jsp");
	    return;
	}
	

    // 예시 데이터
    String userName = "최예나";
    String userIntro = "소개글을 등록해주세요.";
    String profileImg = request.getContextPath() + "/Toma/images/profile_sample.png";
    String backgroundImg = request.getContextPath() + "/Toma/images/profile_bg.png";

    java.util.List<String> myPlaylists =
        java.util.Arrays.asList("공부할 때 듣는 음악", "감성 팝", "드라이브 플레이리스트");

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

        <div class="list-group mt-3">
        <% for(String pl : myPlaylists) { %>
            <a href="#" class="list-group-item list-group-item-action"><%=pl%></a>
        <% } %>
        </div>
    </div>

    <!-- 내가 좋아하는 곡 -->
    <div class="liked-section"
         style="background-color:#fff; border-radius:15px; box-shadow:0 2px 10px rgba(0,0,0,0.05); padding:20px;">
        <h5 style="color:#d24949; font-weight:bold;">내가 좋아하는 곡</h5>

        <ul class="list-group mt-3">
        <% for(String song : likedSongs) { %>
            <li class="list-group-item d-flex justify-content-between align-items-center">
                <%=song%>
                <button class="btn btn-sm btn-outline-danger">재생</button>
            </li>
        <% } %>
        </ul>
    </div>

</div>
