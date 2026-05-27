-- Импортируй этот файл в свою MySQL на сервере (phpMyAdmin / CLI).
-- Замени `antic` на имя своей базы, если другое.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS profiles (
  id            VARCHAR(64)  NOT NULL PRIMARY KEY,
  name          VARCHAR(128) NOT NULL,
  description   TEXT         NULL,
  browserEngine ENUM('chromium','firefox','webkit') NOT NULL DEFAULT 'chromium',
  osFamily      ENUM('windows','macos','linux','android','ios') NOT NULL DEFAULT 'windows',
  fingerprintJson JSON       NOT NULL,
  automationJson  JSON       NOT NULL,
  isArchived    TINYINT(1)   NOT NULL DEFAULT 0,
  createdAt     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updatedAt     TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scripts (
  id          VARCHAR(64)  NOT NULL PRIMARY KEY,
  name        VARCHAR(128) NOT NULL,
  description TEXT         NULL,
  stepsJson   JSON         NOT NULL,
  createdAt   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updatedAt   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS runs (
  id          VARCHAR(64)  NOT NULL PRIMARY KEY,
  scriptId    VARCHAR(64)  NOT NULL,
  profileId   VARCHAR(64)  NOT NULL,
  status      ENUM('queued','running','completed','failed') NOT NULL DEFAULT 'queued',
  errorMessage TEXT        NULL,
  startedAt   TIMESTAMP(3) NULL,
  finishedAt  TIMESTAMP(3) NULL,
  createdAt   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updatedAt   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_runs_script FOREIGN KEY (scriptId) REFERENCES scripts(id) ON DELETE CASCADE,
  CONSTRAINT fk_runs_profile FOREIGN KEY (profileId) REFERENCES profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO scripts (id, name, description, stepsJson) VALUES
('s1', 'Open URL', 'Демо: открыть страницу', JSON_ARRAY(JSON_OBJECT('id','st1','type','open_url','url','https://example.com/'))),
('s2', 'Screenshot', 'Демо: сделать скриншот', JSON_ARRAY(
  JSON_OBJECT('id','st1','type','open_url','url','https://example.com/'),
  JSON_OBJECT('id','st2','type','wait','ms',800),
  JSON_OBJECT('id','st3','type','screenshot','fileName','example.png','fullPage',true)
));

INSERT IGNORE INTO profiles (id, name, description, browserEngine, osFamily, fingerprintJson, automationJson) VALUES
('p1', 'Готика-1', 'Демо профиль', 'chromium', 'windows',
 JSON_OBJECT(
   'canvas', JSON_OBJECT('mode','original'),
   'webgl', JSON_OBJECT('mode','original'),
   'webrtc', JSON_OBJECT('mode','disabled'),
   'fonts', JSON_OBJECT('enabled', false),
   'navigator', JSON_OBJECT('userAgent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'),
   'screen', JSON_OBJECT('width',1280,'height',720),
   'timezone', JSON_OBJECT('tzIanaName','Europe/Moscow')
 ),
 JSON_OBJECT('scriptIds', JSON_ARRAY('s1','s2'), 'minDelayMs', 500, 'maxDelayMs', 1500)
);
