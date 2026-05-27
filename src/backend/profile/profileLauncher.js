const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const { getPool } = require('../db');

/** profileId -> { child, runId } */
const activeSessions = new Map();

async function loadProfileRow(profileId) {
  const pool = getPool();
  const [rows] = await pool.query(
    `SELECT id, name, description, browserEngine, osFamily, fingerprintJson, automationJson
     FROM profiles WHERE id = :id AND isArchived = 0 LIMIT 1`,
    { id: profileId },
  );
  return rows[0] || null;
}

function rowToProfileJson(row) {
  return {
    id: row.id,
    name: row.name,
    description: row.description,
    browserEngine: row.browserEngine,
    osFamily: row.osFamily,
    fingerprint:
      typeof row.fingerprintJson === 'string'
        ? JSON.parse(row.fingerprintJson)
        : row.fingerprintJson,
    automation:
      typeof row.automationJson === 'string'
        ? JSON.parse(row.automationJson)
        : row.automationJson,
  };
}

async function startProfile(profileId, targetUrl) {
  const row = await loadProfileRow(profileId);
  if (!row) {
    const err = new Error('Profile not found');
    err.statusCode = 404;
    throw err;
  }

  const url = targetUrl || process.env.DEFAULT_TARGET_URL || 'https://example.com/';
  const execution = (process.env.PROFILE_EXECUTION || 'local').toLowerCase();

  // Профиль открывается на ПК пользователя; сервер только отдаёт конфиг и пишет статус в БД.
  if (execution === 'local') {
    const pool = getPool();
    const runId = `run_${Date.now()}`;
    await pool.query(
      `INSERT INTO runs (id, scriptId, profileId, status, startedAt)
       VALUES (:id, 's1', :profileId, 'running', NOW(3))`,
      { id: runId, profileId },
    );
    return {
      ok: true,
      mode: 'local',
      status: 'running',
      runId,
      targetUrl: url,
      profile: rowToProfileJson(row),
    };
  }

  if (activeSessions.has(profileId)) {
    return { ok: true, status: 'running', already: true, mode: 'server' };
  }

  const configDir = process.env.PROFILE_CONFIG_DIR || '/tmp/antic-config';
  fs.mkdirSync(configDir, { recursive: true });
  const configPath = path.join(configDir, `${profileId}.json`);
  fs.writeFileSync(configPath, JSON.stringify(rowToProfileJson(row), null, 2));

  const pool = getPool();
  const runId = `run_${Date.now()}`;
  await pool.query(
    `INSERT INTO runs (id, scriptId, profileId, status, startedAt)
     VALUES (:id, 's1', :profileId, 'running', NOW(3))`,
    { id: runId, profileId },
  );

  const keepAlive = String(process.env.PROFILE_KEEP_ALIVE_SECONDS || '120');

  const child = spawn(process.execPath, [path.join(__dirname, 'profile-runner.js')], {
    env: {
      ...process.env,
      PROFILE_ID: profileId,
      PROFILE_CONFIG_PATH: configPath,
      TARGET_URL: url,
      KEEP_ALIVE_SECONDS: keepAlive,
      PROFILES_DIR: process.env.PROFILES_DIR || '/profiles',
      ARTIFACTS_DIR: process.env.ARTIFACTS_DIR || '/artifacts',
    },
    stdio: ['ignore', 'pipe', 'pipe'],
    detached: false,
  });

  activeSessions.set(profileId, { child, runId });

  const finish = async (status, errorMessage) => {
    activeSessions.delete(profileId);
    try {
      await pool.query(
        `UPDATE runs SET status = :status, finishedAt = NOW(3), errorMessage = :errorMessage
         WHERE id = :id`,
        { id: runId, status, errorMessage: errorMessage || null },
      );
    } catch (e) {
      console.error('[antic] run update failed', e.message);
    }
  };

  child.stdout.on('data', (d) => process.stdout.write(`[profile ${profileId}] ${d}`));
  child.stderr.on('data', (d) => process.stderr.write(`[profile ${profileId}] ${d}`));
  child.on('exit', (code) => {
    if (code === 0) finish('completed');
    else finish('failed', `exit code ${code}`);
  });

  return { ok: true, status: 'running', runId, targetUrl: url, mode: 'server' };
}

async function stopProfile(profileId) {
  const execution = (process.env.PROFILE_EXECUTION || 'local').toLowerCase();
  if (execution === 'local') {
    const pool = getPool();
    await pool.query(
      `UPDATE runs SET status = 'failed', finishedAt = NOW(3), errorMessage = 'stopped by user'
       WHERE profileId = :profileId AND status = 'running'`,
      { profileId },
    );
    return { ok: true, status: 'stopped', mode: 'local' };
  }

  const session = activeSessions.get(profileId);
  if (!session) {
    return { ok: true, status: 'stopped', already: true };
  }

  session.child.kill('SIGTERM');
  activeSessions.delete(profileId);

  const pool = getPool();
  await pool.query(
    `UPDATE runs SET status = 'failed', finishedAt = NOW(3), errorMessage = 'stopped by user'
     WHERE id = :id`,
    { id: session.runId },
  );

  return { ok: true, status: 'stopped' };
}

function isProfileRunning(profileId) {
  return activeSessions.has(profileId);
}

module.exports = { startProfile, stopProfile, isProfileRunning, activeSessions };
