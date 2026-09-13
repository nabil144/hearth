const KEY = 'hearth.v1';
const GAPS = [1, 3, 7, 30];
const lessons = new Map();
const cards = new Map();
const claims = new Map();
const sources = new Map();
const variants = new Map();
let cardList = [];
let written = [];
let cycleN = 12;
let state = { screen: 'tonight', lessonId: null, beat: 0 };
let progress = { heard: {}, cards: {} };
let session = blank();
let audioKey = '';

function blank() {
  return { queue: [], i: 0, held: 0, missed: 0, choice: null, feedback: null, review: false, timer: 0, silent: false, armed: '' };
}

function ymd(d = new Date()) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

function plusDays(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return ymd(d);
}

function esc(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

function load() {
  try {
    const raw = JSON.parse(localStorage.getItem(KEY) || '');
    if (raw?.heard && raw?.cards) progress = raw;
  } catch {}
}

function save() { localStorage.setItem(KEY, JSON.stringify(progress)); }
function nextLesson() { return written.find(l => !progress.heard[l.id]); }
function lesson() { return lessons.get(state.lessonId); }
function beat() { return lesson()?.beats[state.beat]; }
function voice() { return document.getElementById('voice'); }
function film() { return document.getElementById('film'); }
const FILMS = {
  'greek-04': 'shorts/greek-04-poc.mp4',
  'greek-09': 'shorts/became-father-imagegen-v1.mp4',
};
function filmSrc(id) { return FILMS[id] || ''; }

function worksOf(l) {
  return [...new Set(l.sources.map(id => sources.get(id)?.work).filter(Boolean))].join(', ');
}

function rec(id) {
  if (!progress.cards[id]) progress.cards[id] = { due: ymd(), held: 0, missed: 0 };
  return progress.cards[id];
}

function citeOf(id) {
  const s = sources.get(claims.get(id)?.source);
  return s ? `${s.work} ${s.locator}` : '';
}

function sideName(id) {
  return (sources.get(claims.get(id)?.source)?.work || '').split(/[\s,]/)[0];
}

function currentCard() {
  const b = beat();
  if (session.review || b?.kind === 'recall') return session.queue[session.i];
  if (b?.kind === 'check') return cards.get(b.card);
}

function heardClaims() {
  const set = new Set();
  for (const id of Object.keys(progress.heard)) {
    const L = lessons.get(id);
    if (L) for (const c of L.claims) set.add(c);
  }
  return set;
}

function dueAmong(allowed) {
  const now = ymd();
  return Object.entries(progress.cards)
    .filter(([id, r]) => r.due <= now && cards.has(id) && allowed.has(cards.get(id).claim))
    .sort((a, b) => a[1].due.localeCompare(b[1].due))
    .map(([id]) => cards.get(id));
}

function pickRecall(l) {
  const skip = l.beats.find(b => b.kind === 'check')?.card;
  const allowed = heardClaims();
  for (const c of l.claims) allowed.add(c);
  const fill = cardList.filter(c => l.claims.includes(c.claim) && c.id !== skip);
  const out = [];
  const seen = new Set();
  for (const c of [...dueAmong(allowed), ...fill]) {
    if (seen.has(c.id)) continue;
    seen.add(c.id);
    out.push(c);
    if (out.length === 3) break;
  }
  return out;
}

function stopAudio() {
  const el = voice();
  el.pause();
  el.removeAttribute('src');
  el.load();
  el.onended = null;
  el.onerror = null;
  audioKey = '';
}

function stopFilm() {
  const el = film();
  if (!el) return;
  el.pause();
  el.removeAttribute('src');
  el.load();
  el.classList.remove('up');
  el.hidden = true;
}

function startWatch(id) {
  if (!filmSrc(id)) return;
  clearTimeout(session.timer);
  stopAudio();
  session = blank();
  state = { screen: 'watch', lessonId: id, beat: 0 };
  render();
  const el = film();
  el.hidden = false;
  el.classList.add('up');
  el.src = filmSrc(id);
  el.play().catch(() => {}).finally(() => render());
}

function jumpFilm(n) {
  const el = film();
  if (!el?.src) return;
  const end = Number.isFinite(el.duration) ? el.duration : 0;
  el.currentTime = Math.max(0, Math.min(end, el.currentTime + n));
}

function toggleFilm() {
  const el = film();
  if (!el?.src) return;
  if (el.paused) el.play().catch(() => {});
  else el.pause();
  render();
}

function showAudioNote() {
  session.silent = true;
  const n = document.getElementById('ano');
  if (n) n.hidden = false;
}

function playAudio() {
  if (state.screen !== 'lesson' || !state.lessonId) return;
  const key = `${state.lessonId}:${state.beat}`;
  if (key === audioKey) { if (session.silent) showAudioNote(); return; }
  audioKey = key;
  session.silent = false;
  const el = voice();
  el.onended = () => { if (beat()?.kind === 'still') go(1); };
  el.onerror = showAudioNote;
  el.src = `audio/${state.lessonId}/${state.beat}.mp3`;
  el.play().catch(showAudioNote);
}

function startLesson(id) {
  clearTimeout(session.timer);
  session = blank();
  state = { screen: 'lesson', lessonId: id, beat: 0 };
  render();
}

function startReview() {
  const q = dueAmong(heardClaims());
  if (!q.length) return;
  clearTimeout(session.timer);
  session = blank();
  session.review = true;
  session.queue = q.slice(0, 3);
  state = { screen: 'lesson', lessonId: null, beat: 0 };
  render();
}

function goHome() {
  clearTimeout(session.timer);
  stopAudio();
  stopFilm();
  session = blank();
  state = { screen: 'tonight', lessonId: null, beat: 0 };
  render();
}

function finish() {
  clearTimeout(session.timer);
  stopAudio();
  if (state.lessonId && !session.review) {
    progress.heard[state.lessonId] = ymd();
    save();
  }
  state.screen = 'done';
  render();
}

function armRecall() {
  const l = lesson();
  if (!l || (session.queue.length && session.armed === l.id)) return;
  session.queue = pickRecall(l);
  session.i = 0;
  session.armed = l.id;
  if (!session.queue.length) finish();
}

function inQuiz() { return session.review || beat()?.kind === 'recall'; }

function go(dir) {
  clearTimeout(session.timer);
  stopAudio();
  session.choice = null;
  session.feedback = null;
  session.silent = false;
  if (inQuiz()) {
    if (dir > 0) { session.i++; if (session.i >= session.queue.length) return finish(); }
    else if (session.i > 0) session.i--;
    else if (session.review) return goHome();
    else state.beat = Math.max(0, state.beat - 1);
    render();
    return;
  }
  const l = lesson();
  if (!l) return;
  state.beat = Math.min(l.beats.length - 1, Math.max(0, state.beat + dir));
  if (beat()?.kind === 'recall') armRecall();
  render();
}

function canFwd() {
  const b = beat();
  if (session.review || b?.kind === 'recall' || b?.kind === 'check') return session.feedback?.kind === 'held';
  return b?.kind !== 'variant';
}

function grade(card, i) {
  if (session.choice != null) return;
  session.choice = i;
  const r = rec(card.id);
  if (i === card.answer) {
    r.held++;
    r.due = plusDays(GAPS[Math.min(r.held - 1, 3)]);
    session.held++;
    session.feedback = { kind: 'held' };
    save();
    render();
    session.timer = setTimeout(() => go(1), 1200);
    return;
  }
  r.missed++;
  r.due = plusDays(1);
  session.missed++;
  session.feedback = { kind: 'miss', text: claims.get(card.claim)?.text || '', cite: citeOf(card.claim) };
  save();
  render();
}

function onClick(e) {
  const el = e.target.closest('[data-act]');
  if (!el) return;
  const a = el.dataset.act;
  if (a === 'listen') startLesson(el.dataset.id);
  else if (a === 'watch') startWatch(el.dataset.id);
  else if (a === 'toggle-film') toggleFilm();
  else if (a === 'jump') jumpFilm(+el.dataset.n);
  else if (a === 'review') startReview();
  else if (a === 'home') goHome();
  else if (a === 'fwd') go(1);
  else if (a === 'back') go(-1);
  else if (a === 'opt' && currentCard()) grade(currentCard(), +el.dataset.i);
}

function onKey(e) {
  if (state.screen !== 'lesson') return;
  if (e.key === 'ArrowLeft') go(-1);
  if (e.key === 'ArrowRight' && canFwd()) go(1);
}

function fmtLong() {
  return new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long' });
}

function fmtHeard(iso) {
  if (iso === ymd()) return 'Today';
  const [y, m, d] = iso.split('-').map(Number);
  return new Date(y, m - 1, d).toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
}

function note() {
  return '<p class="meta audio-note" id="ano" hidden>no audio yet, tap to continue</p>';
}

function cardHTML(card, eyebrow, spoken) {
  const fb = session.feedback;
  const opts = card.options.map((o, i) => {
    let cls = 'opt';
    if (session.choice === i) cls += fb?.kind === 'held' ? ' right' : ' wrong';
    return `<button class="${cls}" data-act="opt" data-i="${i}">${esc(o)}</button>`;
  }).join('');
  let extra = '';
  if (fb?.kind === 'held') extra = '<p class="held">Held.</p>';
  if (fb?.kind === 'miss') extra = `<p class="why">${esc(fb.text)}</p><span class="cite">${esc(fb.cite)}</span><div class="actions"><button class="btn primary" data-act="fwd">Continue</button></div>`;
  return `${spoken ? `<p class="meta spoken">${esc(spoken)}</p>` : ''}<div class="card"><div class="eyebrow">${esc(eyebrow)}</div><div class="title q">${esc(card.prompt)}</div>${opts}${extra}</div>`;
}

function stillHTML(b) {
  const s = b.still;
  const k = lesson().beats.slice(0, state.beat + 1).filter(x => x.kind === 'still').length;
  const art = s?.src ? `<img src="${esc(s.src)}" alt="${esc(s.title || '')}">` : `<span class="label">Still ${k}</span>`;
  let cred = '';
  if (s && (s.title || s.credit)) {
    const label = [s.title, s.credit].filter(Boolean).join(', ');
    cred = s.url
      ? `<p class="credit"><a href="${esc(s.url)}" target="_blank" rel="noreferrer">${esc(label)}</a></p>`
      : `<p class="credit">${esc(label)}</p>`;
  }
  return `<div class="still">${art}<div class="tap"><div data-act="back"></div><div data-act="fwd"></div></div></div><p class="caption">${esc(b.text)}</p>${cred}${note()}`;
}

function variantHTML(b) {
  const v = variants.get(b.variant);
  const sides = (v?.claims || []).map(id =>
    `<div class="side"><b>${esc(sideName(id))}</b>${esc(claims.get(id)?.text || '')}<div class="cite">${esc(citeOf(id))}</div></div>`
  ).join('');
  return `<p class="meta spoken">${esc(b.text)}</p><div class="card"><div class="eyebrow">Two versions</div><div class="title q">${esc(v?.question || '')}</div><div class="fork">${sides}</div><p class="meta">${esc(v?.note || '')}</p><div class="actions"><button class="btn primary" data-act="fwd">Continue</button></div></div>${note()}`;
}

function watchPlay(id) {
  return `<button class="play" data-act="watch" data-id="${esc(id)}"><div class="disc">▣</div><div class="t"><b>Watch</b><span>Cartoon stills. Pause, skip ten seconds, exit.</span></div></button>`;
}

function tonightHTML() {
  const next = nextLesson();
  const warm = written.filter(l => progress.heard[l.id]);
  const date = next ? `${fmtLong()} · Greek, chapter ${next.n} of ${cycleN}` : fmtLong();
  let main;
  if (next) {
    const watch = filmSrc(next.id) ? watchPlay(next.id) : '';
    main = `<section class="card"><div class="eyebrow">Tonight's telling</div><div class="title">${esc(next.title)}</div><p class="hook">${esc(next.hook)}</p><div class="meta">${esc(worksOf(next))} · ${next.minutes} min</div><button class="play" data-act="listen" data-id="${esc(next.id)}"><div class="disc">▶</div><div class="t"><b>Listen</b><span>One family check halfway. Three recall cards after.</span></div></button>${watch}</section>`;
  } else {
    main = `<p class="quiet">You have heard everything written so far. More is being written.</p><div class="actions"><button class="btn primary" data-act="review">Review</button></div>`;
  }
  const otherFilms = [...lessons.values()].filter(l => filmSrc(l.id) && l.id !== next?.id);
  const films = otherFilms.length
    ? `<div class="section">Watch</div><section class="card">${otherFilms.map(l => `<div class="eyebrow">${esc(l.title)}</div>${watchPlay(l.id)}`).join('')}</section>`
    : '';
  const list = warm.length
    ? `<div class="section">Still warm</div><div class="card warm">${warm.map(l => `<div class="row"><div class="t"><b>${esc(l.title)}</b><span>${esc(fmtHeard(progress.heard[l.id]))}</span></div>${filmSrc(l.id) ? `<button class="btn" data-act="watch" data-id="${esc(l.id)}">Watch</button>` : ''}</div>`).join('')}</div>`
    : '';
  return `<main class="screen tonight"><h1>Tonight</h1><p class="sub">${esc(date)}</p>${main}${films}${list}</main>`;
}

function doneHTML() {
  const next = nextLesson();
  const line = next ? `Tomorrow: ${next.title}` : 'You have heard everything written so far.';
  return `<main class="screen done"><div class="eyebrow">Held</div><div class="title">That is tonight.</div><p class="sub">${esc(line)}</p><p class="meta">${session.held} held · ${session.missed} missed</p><div class="actions"><button class="btn primary" data-act="home">Back to tonight</button></div></main>`;
}

function watchHTML() {
  const paused = film()?.paused !== false;
  return `<main class="screen watch"><div class="watch-bar"><button class="btn" data-act="home">Exit</button><button class="btn" data-act="jump" data-n="-10">-10s</button><button class="btn primary" data-act="toggle-film">${paused ? 'Play' : 'Pause'}</button><button class="btn" data-act="jump" data-n="10">+10s</button></div></main>`;
}

function lessonHTML() {
  const quiz = (c, n) => c ? cardHTML(c, `Recall · ${session.i + 1} of ${n}`, '') + note() : '';
  if (session.review) return `<main class="screen lesson">${quiz(currentCard(), session.queue.length)}</main>`;
  const l = lesson();
  const b = beat();
  if (!l || !b) return '';
  const dots = `<div class="dots">${l.beats.map((_, i) => `<i class="${i < state.beat ? 'done' : i === state.beat ? 'now' : ''}"></i>`).join('')}</div>`;
  const head = `${dots}<div class="mini"><span>Chapter ${l.n} of ${cycleN} · <b>${esc(l.title)}</b></span><span>${state.beat + 1} / ${l.beats.length}</span></div>`;
  let body = '';
  if (b.kind === 'still') body = stillHTML(b);
  else if (b.kind === 'check') body = cardHTML(currentCard(), 'Family check', b.text) + note();
  else if (b.kind === 'variant') body = variantHTML(b);
  else if (b.kind === 'recall') body = quiz(currentCard(), session.queue.length);
  return `<main class="screen lesson">${head}${body}</main>`;
}

function render() {
  document.getElementById('root').innerHTML =
    state.screen === 'tonight' ? tonightHTML() :
    state.screen === 'done' ? doneHTML() :
    state.screen === 'watch' ? watchHTML() : lessonHTML();
  if (state.screen === 'lesson') playAudio();
  else stopAudio();
  if (state.screen !== 'watch') stopFilm();
}

async function main() {
  load();
  let data;
  try { data = await (await fetch('../content/greek.json')).json(); }
  catch { document.getElementById('root').textContent = 'Could not load the telling.'; return; }
  for (const x of data.lessons) lessons.set(x.id, x);
  for (const x of data.cards) cards.set(x.id, x);
  for (const x of data.claims) claims.set(x.id, x);
  for (const x of data.sources) sources.set(x.id, x);
  for (const x of data.variants) variants.set(x.id, x);
  cardList = data.cards;
  written = data.lessons.filter(l => l.beats?.length);
  cycleN = data.lessons.filter(l => l.tradition === (written[0]?.tradition || 'greek')).length || 12;
  const q = new URLSearchParams(location.search);
  const watchId = q.get('watch');
  const id = q.get('lesson');
  if (watchId && filmSrc(watchId)) {
    startWatch(watchId);
  } else if (id && lessons.get(id)?.beats?.length) {
    const n = lessons.get(id).beats.length;
    state = { screen: 'lesson', lessonId: id, beat: Math.max(0, Math.min(n - 1, Number(q.get('beat') ?? 0) || 0)) };
    if (beat()?.kind === 'recall') armRecall();
  }
  document.addEventListener('click', onClick);
  document.addEventListener('keydown', onKey);
  render();
}

main();
