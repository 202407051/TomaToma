CREATE DATABASE IF NOT EXISTS tomatoma
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_general_ci;

USE tomatoma;

-- ==========================================
-- 1) 사용자 정보
-- ==========================================
CREATE TABLE playlist_iduser (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 2) 트랙 정보 (Spotify 곡 데이터 캐시)
-- ==========================================
CREATE TABLE track (
    track_id INT AUTO_INCREMENT PRIMARY KEY,
    spotify_id VARCHAR(50) UNIQUE,
    title VARCHAR(200),
    artist VARCHAR(200),
    album VARCHAR(200),
    image_url VARCHAR(300),
    preview_url VARCHAR(300),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3) 사용자 플레이리스트
-- ==========================================
CREATE TABLE playlist (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    cover_img VARCHAR(300),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES playlist_iduser(user_id)  -- ✅ 수정됨!
);

-- ==========================================
-- 4) 플레이리스트 안 곡들
-- ==========================================
CREATE TABLE playlist_track (
    playlist_id INT NOT NULL,
    track_id INT NOT NULL,
    position INT DEFAULT 0,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, track_id),
    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);

-- ==========================================
-- 5) 사용자 프로필 추가 컬럼
-- ==========================================
ALTER TABLE playlist_iduser
ADD COLUMN profile_img VARCHAR(300) DEFAULT '/Toma/images/default_profile.png',
ADD COLUMN background_img VARCHAR(300) DEFAULT '/Toma/images/default_bg.png',
ADD COLUMN intro TEXT;
