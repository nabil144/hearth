import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = new URL('../', import.meta.url);
const W = 1080, H = 1920, FPS = 30;
const TAIL = 1.2;

function run(bin, args) {
  const r = spawnSync(bin, args, { encoding: 'utf8' });
  if (r.status !== 0) throw new Error(`${bin} ${args[0]}\n${r.stderr || r.stdout}`);
  return r.stdout;
}

function durationOf(file) {
  const n = Number(run('ffprobe', [
    '-v', 'error', '-show_entries', 'format=duration',
    '-of', 'default=noprint_wrappers=1:nokey=1', file,
  ]).trim());
  if (!Number.isFinite(n) || n <= 0) throw new Error(`${file}: bad duration`);
  return n;
}

function sizeOf(file) {
  const [w, h] = run('ffprobe', [
    '-v', 'error', '-select_streams', 'v:0',
    '-show_entries', 'stream=width,height', '-of', 'csv=p=0', file,
  ]).trim().split(',').map(Number);
  if (!w || !h) throw new Error(`${file}: no size`);
  return { w, h };
}

const prompts = JSON.parse(readFileSync(new URL('content/prompts.json', root), 'utf8'));
const key = process.argv[2] && !process.argv[2].startsWith('-') ? process.argv[2] : 'firstVideo';
const short = prompts[key];
if (!short?.shots?.length) throw new Error(`content/prompts.json has no ${key}.shots`);

const shots = short.shots.map((s, i) => {
  const image = fileURLToPath(new URL(s.file, root));
  const audioRel = s.audio || `web/shorts/${s.id}.mp3`;
  const audio = fileURLToPath(new URL(audioRel, root));
  if (!existsSync(image)) throw new Error(`missing still ${s.file}`);
  if (!existsSync(audio)) throw new Error(`missing voice ${audioRel}`);
  const duration = durationOf(audio) + (i === short.shots.length - 1 ? TAIL : 0);
  return { ...s, image, audio, duration, ...sizeOf(image) };
});

function filter(shot) {
  const frames = Math.max(2, Math.round(shot.duration * FPS));
  if (shot.w / shot.h > 1.15) {
    return `scale=-2:${H},crop=${W}:${H}:x='(iw-${W})*min(t/${shot.duration}\\,1)':y='(ih-${H})/2',fps=${FPS},setsar=1,format=yuv420p`;
  }
  const rise = (1.16 - 1).toFixed(5);
  return `scale=8000:-1,zoompan=z='1+${rise}*on/${frames - 1}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=${W}x${H}:fps=${FPS},setsar=1,format=yuv420p`;
}

const work = mkdtempSync(join(tmpdir(), 'hearth-short-'));
const segs = [];
try {
  for (const [i, shot] of shots.entries()) {
    const out = join(work, `${i}.mp4`);
    run('ffmpeg', [
      '-y', '-hide_banner', '-loglevel', 'error',
      '-loop', '1', '-i', shot.image, '-i', shot.audio,
      '-vf', filter(shot),
      '-t', String(shot.duration),
      '-c:v', 'libx264', '-preset', 'medium', '-crf', '18',
      '-c:a', 'aac', '-b:a', '192k', '-ar', '44100', '-ac', '2',
      '-shortest', '-movflags', '+faststart',
      out,
    ]);
    segs.push(out);
    console.log(`${shot.id}  ${shot.duration.toFixed(1)}s  ${shot.w}x${shot.h}`);
  }
  const list = join(work, 'list.txt');
  writeFileSync(list, segs.map((p) => `file '${p}'`).join('\n') + '\n');
  const dest = fileURLToPath(new URL(`web/shorts/${short.id}.mp4`, root));
  run('ffmpeg', [
    '-y', '-hide_banner', '-loglevel', 'error',
    '-f', 'concat', '-safe', '0', '-i', list, '-c', 'copy', dest,
  ]);
  const primed = dest.replace(/\.mp4$/, '.faststart.mp4');
  run('ffmpeg', [
    '-y', '-hide_banner', '-loglevel', 'error',
    '-i', dest, '-c', 'copy', '-movflags', '+faststart', primed,
  ]);
  run('mv', [primed, dest]);
  const total = durationOf(dest);
  console.log(`${dest}  ${total.toFixed(1)}s`);
} finally {
  rmSync(work, { recursive: true, force: true });
}
