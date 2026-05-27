-- Antic (minimal) schema
-- Этот файл импортируется автоматически MySQL при первом старте (пустой volume).

SET NAMES utf8mb4;
SET time_zone = '+00:00';

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

