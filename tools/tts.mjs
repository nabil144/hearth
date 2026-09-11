import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';

const root = new URL('../', import.meta.url);
const key = process.env.CARTESIA_API_KEY;
const voice = process.env.CARTESIA_VOICE_ID ?? 'db6b0ed5-d5d3-463d-ae85-518a07d3c2b4';
const model = process.env.CARTESIA_MODEL ?? 'sonic-3.5';
const headers = { Authorization: `Bearer ${key}`, 'Cartesia-Version': '2026-03-01', 'Content-Type': 'application/json' };
const args = process.argv.slice(2);

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

const only = new Set(args.filter((a) => !a.startsWith('--')));
const force = args.includes('--force');
const c = JSON.parse(readFileSync(new URL('content/greek.json', root), 'utf8'));
const cards = new Map(c.cards.map((k) => [k.id, k]));

const spoken = (b) => (b.kind === 'check' ? `${b.text} ${cards.get(b.card).prompt}` : b.text);

async function synth(text, out) {
  const r = await fetch('https://api.cartesia.ai/tts/bytes', {
    method: 'POST',
    headers,
    body: JSON.stringify({
      model_id: model,
      transcript: text,
      voice: { mode: 'id', id: voice },
      language: 'en',
      output_format: { container: 'mp3', sample_rate: 44100, bit_rate: 128000 },
    }),
  });
  if (!r.ok) throw new Error(`${out}: ${r.status} ${await r.text()}`);
  writeFileSync(out, Buffer.from(await r.arrayBuffer()));
}

let made = 0, kept = 0;
for (const l of c.lessons) {
  if (!l.beats.length || (only.size && !only.has(l.id))) continue;
  const dir = new URL(`app/audio/${l.id}/`, root);
  mkdirSync(dir, { recursive: true });
  for (const [i, b] of l.beats.entries()) {
    if (b.kind === 'recall') continue;
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
