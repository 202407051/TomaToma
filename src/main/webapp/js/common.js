

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
