import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';

const root = new URL('../', import.meta.url);
const API = 'https://collectionapi.metmuseum.org/public/collection/v1/objects/';
process.on('unhandledRejection', (e) => { console.error(e.message); process.exit(1); });

const manifest = JSON.parse(readFileSync(new URL('content/stills.json', root), 'utf8'));
const contentFile = new URL('content/greek.json', root);
const c = JSON.parse(readFileSync(contentFile, 'utf8'));
const lessons = new Map(c.lessons.map((l) => [l.id, l]));

const beatOf = (key) => {
  const [lessonId, index] = key.split('/');
  const beat = lessons.get(lessonId)?.beats[Number(index)];
  if (beat?.kind !== 'still') throw new Error(`${key}: not a still beat`);
  return beat;
};
const stills = Object.entries(manifest).map(([key, id]) => ({ key, id, beat: beatOf(key) }));

const missing = c.lessons.flatMap((l) => l.beats.flatMap((b, i) => (b.kind === 'still' && !(`${l.id}/${i}` in manifest) ? [`${l.id}/${i}`] : [])));
if (missing.length) throw new Error(`still beats with no manifest entry: ${missing.join(', ')}`);
const dupes = stills.map((s) => s.id).filter((id, i, all) => all.indexOf(id) !== i);
if (dupes.length) throw new Error(`object used twice: ${[...new Set(dupes)].join(', ')}`);

async function fetchOk(url) {
  for (let attempt = 0; ; attempt++) {
    const r = await fetch(url);
    const blocked = r.headers.get('content-type')?.includes('text/html');
    if (r.ok && !blocked) return r;
    if (attempt === 4) throw new Error(`${url}: HTTP ${r.status}${blocked ? ' (rate limited)' : ''}`);
    await new Promise((done) => setTimeout(done, 1500 * (attempt + 1)));
  }
}

mkdirSync(new URL('app/stills/', root), { recursive: true });
for (const { key, id, beat } of stills) {
  const o = await (await fetchOk(`${API}${id}`)).json();
  if (o.isPublicDomain !== true) throw new Error(`${key}: object ${id} "${o.title}" is not public domain`);
  if (!o.primaryImageSmall) throw new Error(`${key}: object ${id} "${o.title}" has no primaryImageSmall`);
  const src = `stills/${key.replace('/', '-')}.jpg`;
  const file = new URL(`app/${src}`, root);
  if (!existsSync(file)) writeFileSync(file, Buffer.from(await (await fetchOk(o.primaryImageSmall)).arrayBuffer()));
  beat.still = {
    src,
    title: o.title,
    maker: o.artistDisplayName || o.culture || '',
    date: o.objectDate,
    credit: 'The Metropolitan Museum of Art, CC0',
    url: o.objectURL,
  };
  console.log(`${key}  ${id}  ${o.title}`);
}
writeFileSync(contentFile, JSON.stringify(c, null, 2) + '\n');
