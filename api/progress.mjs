const PLAYER_ID_RE = /^[A-Za-z0-9_.-]{1,128}$/;

function normalizeTursoUrl(raw) {
  let url = String(raw || '').trim();
  if (url.startsWith('libsql://')) {
    url = 'https://' + url.slice('libsql://'.length);
  }
  return url.replace(/\/+$/, '');
}

function sendJson(res, status, payload) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(payload));
}

async function readJsonBody(req) {
  if (req.body && typeof req.body === 'object') {
    return req.body;
  }
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(typeof chunk === 'string' ? Buffer.from(chunk) : chunk);
  }
  const raw = Buffer.concat(chunks).toString('utf8').trim();
  return raw ? JSON.parse(raw) : {};
}

function argText(v) {
  return { type: 'text', value: String(v ?? '') };
}

function argInt(v) {
  const n = Number.parseInt(String(v ?? 0), 10);
  return { type: 'integer', value: String(Number.isFinite(n) ? n : 0) };
}

function decodeCell(cell) {
  if (!cell || cell.type === 'null') return null;
  if (cell.type === 'integer') return Number.parseInt(String(cell.value ?? '0'), 10);
  if (cell.type === 'float') return Number(cell.value ?? 0);
  return String(cell.value ?? '');
}

function safeJsonParse(raw, fallback) {
  try {
    const parsed = JSON.parse(String(raw ?? ''));
    return parsed ?? fallback;
  } catch {
    return fallback;
  }
}

function buildUpsertProgressStmt(snapshot) {
  const settings = {
    auto_collect_flame: Boolean(snapshot.auto_collect_flame ?? true),
    sound_muted: Boolean(snapshot.sound_muted ?? false),
    audio_layers:
      snapshot.audio_layers && typeof snapshot.audio_layers === 'object'
        ? snapshot.audio_layers
        : { music: true, ambience: true, sfx: true },
  };
  const updatedAt = Number.isFinite(Number(snapshot.updated_at))
    ? Math.trunc(Number(snapshot.updated_at))
    : Math.floor(Date.now() / 1000);

  return {
    type: 'execute',
    stmt: {
      sql: `
        INSERT INTO player_progress (
          player_id, unlocked_level, jade_gems, level_stars_json,
          selected_deck_json, previous_deck_json, unlocked_upgrades_json,
          settings_json, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(player_id) DO UPDATE SET
          unlocked_level = excluded.unlocked_level,
          jade_gems = excluded.jade_gems,
          level_stars_json = excluded.level_stars_json,
          selected_deck_json = excluded.selected_deck_json,
          previous_deck_json = excluded.previous_deck_json,
          unlocked_upgrades_json = excluded.unlocked_upgrades_json,
          settings_json = excluded.settings_json,
          updated_at = excluded.updated_at;
      `.trim(),
      args: [
        argText(snapshot.player_id),
        argInt(snapshot.unlocked_level ?? 1),
        argInt(snapshot.jade_gems ?? 15),
        argText(JSON.stringify(snapshot.level_stars ?? {})),
        argText(JSON.stringify(Array.isArray(snapshot.selected_deck) ? snapshot.selected_deck : [])),
        argText(JSON.stringify(Array.isArray(snapshot.previous_deck) ? snapshot.previous_deck : [])),
        argText(JSON.stringify(Array.isArray(snapshot.unlocked_upgrades) ? snapshot.unlocked_upgrades : [])),
        argText(JSON.stringify(settings)),
        argInt(updatedAt),
      ],
    },
  };
}

async function runTursoPipeline(baseUrl, authToken, requests) {
  const resp = await fetch(`${baseUrl}/v2/pipeline`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${authToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ requests }),
  });
  if (!resp.ok) {
    throw new Error(`Turso HTTP ${resp.status}`);
  }
  const data = await resp.json();
  const failed = Array.isArray(data.results) ? data.results.find((r) => r?.type === 'error') : null;
  if (failed) {
    throw new Error(failed.error?.message || 'Turso SQL error');
  }
  return data;
}

function extractProgressRow(pipelineResp) {
  const execRes = pipelineResp?.results?.[0]?.response?.result;
  const cols = execRes?.cols || [];
  const rows = execRes?.rows || [];
  if (!cols.length || !rows.length) return null;

  const rawMap = {};
  const row = rows[0];
  for (let i = 0; i < Math.min(cols.length, row.length); i++) {
    rawMap[cols[i].name] = decodeCell(row[i]);
  }
  return {
    player_id: String(rawMap.player_id || ''),
    unlocked_level: Number(rawMap.unlocked_level ?? 1),
    jade_gems: Number(rawMap.jade_gems ?? 15),
    updated_at: Number(rawMap.updated_at ?? 0),
    level_stars: safeJsonParse(rawMap.level_stars_json, {}),
    selected_deck: safeJsonParse(rawMap.selected_deck_json, []),
    previous_deck: safeJsonParse(rawMap.previous_deck_json, []),
    unlocked_upgrades: safeJsonParse(rawMap.unlocked_upgrades_json, []),
    settings: safeJsonParse(rawMap.settings_json, {}),
  };
}

export default async function handler(req, res) {
  const baseUrl = normalizeTursoUrl(process.env.TURSO_URL);
  const authToken = String(process.env.TURSO_AUTH_TOKEN || '').trim();
  if (!baseUrl || !authToken) {
    return sendJson(res, 503, { ok: false, error: 'Turso environment variables are not configured' });
  }

  try {
    if (req.method === 'GET') {
      const parsedUrl = new URL(req.url || '/api/progress', 'http://localhost');
      const playerId = String(
        parsedUrl.searchParams.get('player_id') ||
          parsedUrl.searchParams.get('user_id') ||
          parsedUrl.searchParams.get('uuid') ||
          '',
      ).trim();
      if (!PLAYER_ID_RE.test(playerId)) {
        return sendJson(res, 400, { ok: false, error: 'Invalid player_id' });
      }
      const data = await runTursoPipeline(baseUrl, authToken, [
        {
          type: 'execute',
          stmt: {
            sql: `
              SELECT player_id, unlocked_level, jade_gems, level_stars_json,
                     selected_deck_json, previous_deck_json, unlocked_upgrades_json,
                     settings_json, updated_at
              FROM player_progress
              WHERE player_id = ?
              LIMIT 1;
            `.trim(),
            args: [argText(playerId)],
          },
        },
        { type: 'close' },
      ]);
      return sendJson(res, 200, { ok: true, progress: extractProgressRow(data) });
    }

    if (req.method === 'POST') {
      const body = await readJsonBody(req);
      const action = String(body.action || 'sync');
      const snapshot = body.snapshot && typeof body.snapshot === 'object' ? body.snapshot : null;
      const playerId = String(snapshot?.player_id || '').trim();
      if (!snapshot || !PLAYER_ID_RE.test(playerId)) {
        return sendJson(res, 400, { ok: false, error: 'Invalid snapshot or player_id' });
      }

      if (action === 'completion') {
        const completedAt = Number.isFinite(Number(snapshot.updated_at))
          ? Math.trunc(Number(snapshot.updated_at))
          : Math.floor(Date.now() / 1000);
        const deck = Array.isArray(body.deck) ? body.deck : [];
        await runTursoPipeline(baseUrl, authToken, [
          {
            type: 'execute',
            stmt: {
              sql: `
                INSERT INTO level_completions
                  (player_id, level_id, level_name, stars, jade_reward, deck_json, completed_at)
                VALUES (?, ?, ?, ?, ?, ?, ?);
              `.trim(),
              args: [
                argText(playerId),
                argInt(body.level_id ?? 1),
                argText(body.level_name ?? ''),
                argInt(body.stars ?? 0),
                argInt(body.jade_reward ?? 0),
                argText(JSON.stringify(deck)),
                argInt(completedAt),
              ],
            },
          },
          buildUpsertProgressStmt(snapshot),
          { type: 'close' },
        ]);
        return sendJson(res, 200, { ok: true });
      }

      await runTursoPipeline(baseUrl, authToken, [buildUpsertProgressStmt(snapshot), { type: 'close' }]);
      return sendJson(res, 200, { ok: true });
    }

    res.setHeader('Allow', 'GET, POST');
    return sendJson(res, 405, { ok: false, error: 'Method not allowed' });
  } catch (err) {
    return sendJson(res, 502, { ok: false, error: err?.message || 'Upstream Turso error' });
  }
}
