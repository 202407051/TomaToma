<!-- login.jsp // 로그인 화면 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>TomaToma - 로그인</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css?v=999">
</head>
<body>
<!-- 공통 헤더 메뉴바 -->
<jsp:include page="../include/header.jsp">
    <jsp:param name="page" value="login"/>
</jsp:include>

<!-- 중앙 로그인 박스 -->
<div class="container my-5" style="max-width: 500px;">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold text-center mb-4" style="color:#d24949;">로그인</h3>

		<!-- 로그인 폼 -->
        <form action="loginProcess.jsp" method="post">
        	<!-- 이메일 -->
            <label class="fw-bold mb-1">이메일</label>
            <input class="form-control mb-3" type="email" name="email" required>

			<!-- 비밀번호 -->
            <label class="fw-bold mb-1">비밀번호</label>
            <input class="form-control mb-4" type="password" name="password" required>

			<!-- 로그인 버튼 -->
            <button class="btn btn-main w-100" type="submit">로그인</button>

			<!-- 회원가입 안내 문구 -->
            <p class="text-center mt-3 small">
                아직 계정이 없나요?
                <a href="join.jsp" class="text-danger fw-bold">회원가입</a>
            </p>
        </form>
    </div>
</div>

</body>
</html>
