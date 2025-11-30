// common.js — 모든 페이지 공통 스크립트

const STORAGE_KEY = 'tomatoma_pl_v6';

// LocalStorage 읽기
function getList() {
    try {
        return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    } catch(e){
        console.error("LocalStorage read error:", e);
        return [];
    }
}

// 오른쪽 사이드바 로딩
function loadSidebarPlaylist() {
    const ul = document.getElementById("sidebar-playlist");

    // 사이드바가 없는 페이지에서는 무시
    if (!ul) return;

    const list = getList();
    ul.innerHTML = "";

    if (list.length === 0) {
        ul.innerHTML = '<li class="list-group-item small text-center text-muted">없음</li>';
        return;
    }

    list.slice(0, 5).forEach(p => {
        ul.innerHTML +=
            '<li class="list-group-item d-flex justify-content-between align-items-center" ' +
            ' style="cursor:pointer;" ' +
            ' onclick="location.href=\'playlist.jsp?id=' + p.id + '\'">' +
            ' <span class="text-truncate" style="max-width:120px;">' + p.title + '</span>' +
            ' <span class="badge bg-light text-dark">' + p.tracks.length + '</span>' +
            '</li>';
    });
}

// DOM 로딩 완료 시 자동 실행
document.addEventListener("DOMContentLoaded", loadSidebarPlaylist);


// ==============================
// Spotify 미리듣기 재생 기능
// ==============================

function playOne(id) {
    const container = document.getElementById("player-container");
    const frame = document.getElementById("spotify-iframe");

    if (!container || !frame) {
        console.error("⚠ player-container 또는 spotify-iframe이 페이지에 없습니다.");
        return;
    }

    container.style.display = "block";
    frame.src = "https://open.spotify.com/embed/track/" + id + "?utm_source=generator&theme=0&autoplay=1";
}

// 전체 플레이 (첫 번째 트랙 재생)
function playAll(tracks){
    if(!tracks || tracks.length === 0){
        alert("곡이 없습니다.");
        return;
    }
    playOne(tracks[0].id);
}
