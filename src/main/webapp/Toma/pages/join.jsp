<!-- join.jsp // 회원가입 화면 -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>TomaToma - 회원가입</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&family=Poppins:wght@600&display=swap" rel="stylesheet">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/toma.css?v=999">
</head>
<body>

<!-- 공통 헤더 메뉴바 -->
<jsp:include page="../include/header.jsp">
    <jsp:param name="page" value="join"/>
</jsp:include>

<!-- 본문 -->
<div class="container my-5" style="max-width: 500px;">

    <div class="card shadow-sm p-4">

        <h3 class="fw-bold text-center mb-4" style="color:#d24949;">회원가입</h3>

        <!-- 회원가입 폼 -->
        <form action="joinProcess.jsp" method="post">

            <!-- 이름 -->
            <label class="fw-bold mb-1">이름</label>
            <input class="form-control mb-3" type="text" name="username" required placeholder="이름을 입력하세요">

            <!-- 이메일 -->
            <label class="fw-bold mb-1">이메일</label>
            <div class="input-group mb-2">
                <input class="form-control" type="email" id="email" name="email" required placeholder="example@email.com">
                <button class="btn btn-outline-danger" type="button" onclick="checkEmail()">중복확인</button>
            </div>
            <div id="email_msg" class="small" style="min-height:18px;"></div>

            <!-- 비밀번호 -->
            <label class="fw-bold mb-1 mt-3">비밀번호</label>
            <input class="form-control mb-4" type="password" name="password" required placeholder="비밀번호 입력">

            <!-- 회원가입 버튼 -->
            <button class="btn btn-main w-100" type="submit">회원가입</button>
        </form>

    </div>
</div>

<script>
function checkEmail() {
    let email = document.getElementById("email").value;
    if (email.trim() === "") {
        alert("이메일을 입력하세요!");
        return;
    }

    fetch("checkEmail.jsp?email=" + email)
        .then(res => res.text())
        .then(text => {
            document.getElementById("email_msg").innerHTML = text;
        });
}
</script>

</body>
</html>
