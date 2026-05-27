const express = require('express');
const cors = require('cors');
const { randomUUID } = require('crypto');

const { getPool } = require('./db');

const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', async (_req, res) => {
  try {
    const pool = getPool();
    await pool.query('SELECT 1');
    res.json({ ok: true, db: true });
  } catch (err) {
    res.status(503).json({ ok: false, db: false, error: err.message });
  }
});

app.get('/api/profiles', async (_req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(
      `SELECT p.id, p.name, p.description,
              EXISTS(
                SELECT 1 FROM runs r
                WHERE r.profileId = p.id AND r.status = 'running'
              ) AS running
       FROM profiles p
       WHERE p.isArchived = 0
       ORDER BY p.updatedAt DESC`,
    );
    res.json(
      rows.map((r) => ({
        id: r.id,
        name: r.name,
        description: r.description,
        running: Boolean(r.running),
      })),
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/profiles/:id', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(
      `SELECT id, name, description, browserEngine, osFamily,
              fingerprintJson, automationJson, createdAt, updatedAt
       FROM profiles WHERE id = :id LIMIT 1`,
      { id: req.params.id },
    );
    if (!rows.length) {
      res.status(404).json({ error: 'Profile not found' });
      return;
    }
    const row = rows[0];
    res.json({
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
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/profiles', async (req, res) => {
  try {
    const name = String(req.body?.name || '').trim();
    if (!name) {
      res.status(400).json({ error: 'name is required' });
      return;
    }

    const id = `p_${randomUUID().slice(0, 8)}`;
    const description = req.body?.description ?? null;

    const fingerprint = {
      canvas: { mode: 'original' },
      webgl: { mode: 'original' },
      webrtc: { mode: 'disabled' },
      fonts: { enabled: false },
      navigator: {
        userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
      screen: { width: 1280, height: 720 },
      timezone: { tzIanaName: 'Europe/Moscow' },
    };

    const automation = {
      scriptIds: [],
      minDelayMs: 500,
      maxDelayMs: 1500,
    };

    const pool = getPool();
    await pool.query(
      `INSERT INTO profiles
        (id, name, description, browserEngine, osFamily, fingerprintJson, automationJson)
       VALUES
        (:id, :name, :description, 'chromium', 'windows', :fingerprintJson, :automationJson)`,
      {
        id,
        name,
        description,
        fingerprintJson: JSON.stringify(fingerprint),
        automationJson: JSON.stringify(automation),
      },
    );

    res.status(201).json({ id, name, description, running: false });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/scripts', async (_req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(
      `SELECT id, name, description FROM scripts ORDER BY updatedAt DESC`,
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/runs', async (req, res) => {
  try {
    const scriptId = String(req.body?.scriptId || '').trim();
    const profileId = String(req.body?.profileId || '').trim();
    if (!scriptId || !profileId) {
      res.status(400).json({ error: 'scriptId and profileId are required' });
      return;
    }

    const id = `run_${randomUUID().slice(0, 8)}`;
    const pool = getPool();
    await pool.query(
      `INSERT INTO runs (id, scriptId, profileId, status, startedAt)
       VALUES (:id, :scriptId, :profileId, 'queued', NOW(3))`,
      { id, scriptId, profileId },
    );

    // Пока нет воркера — сразу помечаем completed (чтобы UI видел реакцию).
    await pool.query(
      `UPDATE runs SET status = 'completed', finishedAt = NOW(3) WHERE id = :id`,
      { id },
    );

    res.status(201).json({
      id,
      scriptId,
      profileId,
      status: 'completed',
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT ? Number(process.env.PORT) : 3000;
app.listen(port, () => {
  console.log(`Backend listening on :${port}`);
});
