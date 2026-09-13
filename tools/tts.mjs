import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';

const root = new URL('../', import.meta.url);
const envFile = new URL('.env', root);
if (existsSync(envFile)) {
  for (const line of readFileSync(envFile, 'utf8').split('\n')) {
    const t = line.trim();
    if (!t || t.startsWith('#')) continue;
    const i = t.indexOf('=');
    if (i < 0) continue;
    const k = t.slice(0, i).trim();
    const v = t.slice(i + 1).trim().replace(/^['"]|['"]$/g, '');
    if (k && process.env[k] == null) process.env[k] = v;
  }
}

const key = process.env.CARTESIA_API_KEY;
const model = process.env.CARTESIA_MODEL ?? 'sonic-3.5';
const headers = { Authorization: `Bearer ${key}`, 'Cartesia-Version': '2026-03-01', 'Content-Type': 'application/json' };
const args = process.argv.slice(2);
const voiceArg = (() => {
  const i = args.indexOf('--voice');
  if (i >= 0 && args[i + 1] && !args[i + 1].startsWith('--')) return args[i + 1];
})();
let voice = voiceArg ?? process.env.CARTESIA_VOICE_ID ?? 'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4';

if (!key) {
  console.error('Set CARTESIA_API_KEY (sk_car_...). Optional: CARTESIA_VOICE_ID, CARTESIA_MODEL.');
  process.exit(2);
}

if (args[0] === '--voices') {
  const r = await fetch('https://api.cartesia.ai/voices/', { headers });
  if (!r.ok) throw new Error(`voices: ${r.status} ${await r.text()}`);
  const body = await r.json();
  const list = Array.isArray(body) ? body : body.data ?? [];
  for (const v of list) console.log(`${v.id}  ${v.language ?? ''}  ${v.name}  ${v.description ?? ''}`.trim());
  process.exit(0);
}

const force = args.includes('--force');

async function synth(text, out, extra = {}) {
  const id = extra.voice ?? voice;
  const body = {
    model_id: model,
    transcript: text,
    voice: { mode: 'id', id },
    language: 'en',
    output_format: { container: 'mp3', sample_rate: 44100, bit_rate: 128000 },
  };
  if (extra.speed != null) body.generation_config = { speed: extra.speed };
  const r = await fetch('https://api.cartesia.ai/tts/bytes', {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  if (!r.ok) throw new Error(`${out}: ${r.status} ${await r.text()}`);
  writeFileSync(out, Buffer.from(await r.arrayBuffer()));
}

if (args.includes('--short')) {
  const i = args.indexOf('--short');
  const shortKey = args[i + 1] && !args[i + 1].startsWith('--') ? args[i + 1] : 'firstVideo';
  const prompts = JSON.parse(readFileSync(new URL('content/prompts.json', root), 'utf8'));
  const short = prompts[shortKey];
  const shots = short?.shots ?? [];
  if (!shots.length) {
    console.error(`content/prompts.json has no ${shortKey}.shots`);
    process.exit(2);
  }
  if (!voiceArg && short.voice) voice = short.voice;
  const speed = short.speed;
  const dir = new URL('web/shorts/', root);
  mkdirSync(dir, { recursive: true });
  let made = 0, kept = 0;
  for (const shot of shots) {
    const text = shot.spoken;
    if (!text) throw new Error(`${shot.id}: no spoken`);
    const hash = createHash('sha1').update(`${model}|${voice}|${speed ?? ''}|${text}`).digest('hex').slice(0, 12);
    const mp3 = new URL(`${shot.id}.mp3`, dir), tag = new URL(`${shot.id}.sha1`, dir);
    if (!force && existsSync(mp3) && existsSync(tag) && readFileSync(tag, 'utf8') === hash) { kept++; continue; }
    await synth(text, mp3, { speed });
    writeFileSync(tag, hash);
    made++;
    console.log(`${shot.id}  ${text.split(/\s+/).length} words`);
  }
  console.log(`${made} generated, ${kept} unchanged. Voice ${voice}, model ${model}${speed != null ? `, speed ${speed}` : ''}.`);
  process.exit(0);
}

const only = new Set(args.filter((a) => !a.startsWith('--')));
if (args.includes('--sample')) only.add('greek-04/0');
const onlyLesson = new Set();
const onlyBeat = new Map();
for (const x of only) {
  const [id, n] = x.split('/');
  onlyLesson.add(id);
  if (n !== undefined) {
    if (!onlyBeat.has(id)) onlyBeat.set(id, new Set());
    onlyBeat.get(id).add(Number(n));
  }
}
const c = JSON.parse(readFileSync(new URL('content/greek.json', root), 'utf8'));
const cards = new Map(c.cards.map((k) => [k.id, k]));

const spoken = (b) => (b.kind === 'check' ? `${b.text} ${cards.get(b.card).prompt}` : b.text);

let made = 0, kept = 0;
for (const l of c.lessons) {
  if (!l.beats.length || (only.size && !onlyLesson.has(l.id))) continue;
  const dir = new URL(`web/audio/${l.id}/`, root);
  mkdirSync(dir, { recursive: true });
  for (const [i, b] of l.beats.entries()) {
    if (b.kind === 'recall') continue;
    if (onlyBeat.has(l.id) && !onlyBeat.get(l.id).has(i)) continue;
    const text = spoken(b);
    const hash = createHash('sha1').update(`${model}|${voice}|${text}`).digest('hex').slice(0, 12);
    const mp3 = new URL(`${i}.mp3`, dir), tag = new URL(`${i}.sha1`, dir);
    if (!force && existsSync(mp3) && existsSync(tag) && readFileSync(tag, 'utf8') === hash) { kept++; continue; }
    await synth(text, mp3);
    writeFileSync(tag, hash);
    made++;
    console.log(`${l.id}/${i}  ${text.split(/\s+/).length} words`);
  }
}
console.log(`${made} generated, ${kept} unchanged. Voice ${voice}, model ${model}.`);
