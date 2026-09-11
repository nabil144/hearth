import { readFileSync } from 'node:fs';

const file = process.argv[2] ?? new URL('./greek.json', import.meta.url);
const c = JSON.parse(readFileSync(file, 'utf8'));
const ids = (list) => new Set(list.map((x) => x.id));
const traditions = ids(c.traditions), sources = ids(c.sources), entities = ids(c.entities), claims = ids(c.claims), variants = ids(c.variants);
const shipping = new Set(c.traditions.filter((t) => t.sensitivity !== 'do-not-ship').map((t) => t.id));
const errors = [];
const need = (ok, msg) => { if (!ok) errors.push(msg); };

for (const s of c.sources) need(traditions.has(s.tradition), `source ${s.id}: unknown tradition ${s.tradition}`);
for (const e of c.entities) for (const p of e.parents) need(entities.has(p), `entity ${e.id}: unknown parent ${p}`);
for (const k of c.claims) {
  need(sources.has(k.source), `claim ${k.id}: unknown source ${k.source}`);
  need(['attested', 'common-version', 'variant', 'later-invention'].includes(k.confidence), `claim ${k.id}: bad confidence ${k.confidence}`);
  for (const e of k.entities) need(entities.has(e), `claim ${k.id}: unknown entity ${e}`);
}
for (const v of c.variants) {
  need(v.claims.length >= 2, `variant ${v.id}: needs two or more claims`);
  for (const k of v.claims) need(claims.has(k), `variant ${v.id}: unknown claim ${k}`);
}
const seen = new Set();
for (const l of c.lessons) {
  need(shipping.has(l.tradition), `lesson ${l.id}: tradition ${l.tradition} is do-not-ship or unknown`);
  need(!seen.has(l.n), `lesson ${l.id}: chapter number ${l.n} used twice`);
  seen.add(l.n);
  for (const s of l.sources) need(sources.has(s), `lesson ${l.id}: unknown source ${s}`);
  for (const k of l.claims) need(claims.has(k), `lesson ${l.id}: unknown claim ${k}`);
  if (l.variant) need(variants.has(l.variant), `lesson ${l.id}: unknown variant ${l.variant}`);
  if (l.check) {
    need(l.claims.includes(l.check.claim), `lesson ${l.id}: check asks about ${l.check.claim}, which the chapter never says`);
    need(l.check.options.length === 4 && l.check.answer >= 0 && l.check.answer < 4, `lesson ${l.id}: check needs four options and a valid answer`);
  }
}

if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}
console.log(`${c.lessons.length} lessons, ${c.claims.length} claims, ${c.sources.length} sources, ${c.entities.length} entities, ${c.variants.length} variants. All bound.`);
