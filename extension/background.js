// background.js — Synap Extension (Final version with Supabase sync)
// ══════════════════════════════════════════════════════════════

// ⚠️  REPLACE THESE with your actual Supabase values:
const SUPABASE_URL = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_KEY = 'YOUR_ANON_KEY';

const TOOLS = {
  chatgpt_gpt4o: { name:'ChatGPT GPT-4o', emoji:'🤖', limit:40,  resetHours:3,  switchTo:'Claude'     },
  claude:        { name:'Claude',          emoji:'✦',  limit:40,  resetHours:24, switchTo:'ChatGPT'    },
  gemini:        { name:'Gemini Pro',      emoji:'♊',  limit:60,  resetHours:24, switchTo:'Perplexity' },
  perplexity:    { name:'Perplexity Pro',  emoji:'🔍', limit:5,   resetHours:24, switchTo:'Gemini'     },
};

// ── Messages from content scripts ────────────────────────────
chrome.runtime.onMessage.addListener((msg, _, sendResponse) => {
  if (msg.action === 'usage')    { handleUsage(msg.toolId, msg.count||1).then(()=>sendResponse({ok:true})); return true; }
  if (msg.action === 'getAll')   { getAllData().then(sendResponse); return true; }
  if (msg.action === 'reset')    { resetTool(msg.toolId).then(sendResponse); return true; }
  if (msg.action === 'setExact') { setExact(msg.toolId, msg.count).then(sendResponse); return true; }
});

// ── Core: handle usage event ──────────────────────────────────
async function handleUsage(toolId, count) {
  const tool = TOOLS[toolId];
  if (!tool) return;

  const now     = Date.now();
  const data    = await getData(toolId);
  const resetMs = tool.resetHours * 3600000;

  // Auto-reset if period expired
  if (data.lastReset && (now - data.lastReset) >= resetMs) {
    data.used      = 0;
    data.lastReset = now;
    notify(`🔄 ${tool.name} reset!`, `${tool.limit} free uses back!`, toolId);
  }

  const wasLow   = (data.used / tool.limit) >= 0.8;
  const wasEmpty = data.used >= tool.limit;

  data.used      = Math.min((data.used||0) + count, tool.limit);
  data.lastReset = data.lastReset || now;
  data.lastUsed  = now;

  await save(toolId, data);

  // Alerts
  const pct = data.used / tool.limit;
  if (!wasLow   && pct>=0.8 && pct<1) notify(`⚠️ ${tool.name} running low!`, `${tool.limit-data.used} left — switch to ${tool.switchTo}`, toolId);
  if (!wasEmpty && pct>=1)            notify(`🔴 ${tool.name} limit reached!`, `Resets in ${timeLabel(data.lastReset, resetMs)} — use ${tool.switchTo}`, toolId);

  // Badge
  const ex = await countExhausted();
  chrome.action.setBadgeText({ text: ex>0 ? String(ex) : '' });
  chrome.action.setBadgeBackgroundColor({ color: '#FF4F6A' });

  // ── Sync to Supabase → Flutter app reads this ────────────
  await syncToSupabase();
}

// ── Supabase sync ─────────────────────────────────────────────
async function syncToSupabase() {
  try {
    const all    = await getAllData();
    const userId = await getUserId();

    await fetch(`${SUPABASE_URL}/rest/v1/extension_sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Prefer': 'resolution=merge-duplicates',
      },
      body: JSON.stringify({
        user_id:    userId,
        payload:    all,
        updated_at: new Date().toISOString(),
      }),
    });
  } catch (e) {
    console.log('[Synap] Sync skipped:', e.message);
  }
}

async function getUserId() {
  const r = await chrome.storage.local.get('synap_uid');
  if (r.synap_uid) return r.synap_uid;
  const uid = 'ext_' + Math.random().toString(36).slice(2, 10);
  await chrome.storage.local.set({ synap_uid: uid });
  return uid;
}

// ── Helpers ───────────────────────────────────────────────────
async function getData(id) {
  const r = await chrome.storage.local.get(`s_${id}`);
  return r[`s_${id}`] || { used:0, lastReset:null, lastUsed:null };
}

async function save(id, data) {
  await chrome.storage.local.set({ [`s_${id}`]: data });
}

async function getAllData() {
  const result = {};
  const now    = Date.now();
  for (const [id, tool] of Object.entries(TOOLS)) {
    const d       = await getData(id);
    const resetMs = tool.resetHours * 3600000;
    const diff    = d.lastReset ? Math.max(0, (d.lastReset + resetMs) - now) : 0;
    const h = Math.floor(diff/3600000), m = Math.floor((diff%3600000)/60000);
    result[id] = {
      ...tool,
      used:      d.used || 0,
      remaining: Math.max(0, tool.limit - (d.used||0)),
      pct:       Math.min((d.used||0) / tool.limit, 1),
      isLow:     (d.used||0) / tool.limit >= 0.8,
      isEmpty:   (d.used||0) >= tool.limit,
      resetIn:   diff>0 ? (h>0 ? `${h}h ${m}m` : `${m}m`) : 'Ready',
      lastUsed:  d.lastUsed,
    };
  }
  return result;
}

async function resetTool(id) {
  await save(id, { used:0, lastReset:Date.now(), lastUsed:null });
  await syncToSupabase();
  return { ok:true };
}

async function setExact(id, count) {
  const d = await getData(id);
  d.used  = Math.min(count, TOOLS[id]?.limit||999);
  await save(id, d);
  await syncToSupabase();
  return { ok:true };
}

async function countExhausted() {
  let n=0;
  for (const id of Object.keys(TOOLS)) {
    const d = await getData(id);
    if ((d.used||0) >= TOOLS[id].limit) n++;
  }
  return n;
}

function timeLabel(lastReset, resetMs) {
  const diff = Math.max(0, (lastReset+resetMs) - Date.now());
  const h=Math.floor(diff/3600000), m=Math.floor((diff%3600000)/60000);
  return h>0 ? `${h}h ${m}m` : `${m}m`;
}

function notify(title, message, toolId) {
  chrome.notifications.create(`synap_${toolId}_${Date.now()}`, {
    type:'basic', iconUrl:'icons/icon48.png', title, message, priority:2,
  });
}

// ── Auto-reset every 5 min ────────────────────────────────────
chrome.alarms.create('check', { periodInMinutes:5 });
chrome.alarms.onAlarm.addListener(async ({name}) => {
  if (name !== 'check') return;
  for (const [id, tool] of Object.entries(TOOLS)) {
    const d = await getData(id);
    const resetMs = tool.resetHours * 3600000;
    if (d.lastReset && (Date.now()-d.lastReset) >= resetMs && (d.used||0)>0) {
      await resetTool(id);
      notify(`🔄 ${tool.emoji} ${tool.name} reset!`, `${tool.limit} uses available again.`, id);
    }
  }
});
