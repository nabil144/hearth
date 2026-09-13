import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const here = fileURLToPath(new URL('.', import.meta.url));
const extra = process.argv.slice(2);

function run(file, args) {
  const r = spawnSync(process.execPath, [file, ...args], { stdio: 'inherit' });
  if (r.status) process.exit(r.status ?? 1);
}

run(`${here}tts.mjs`, ['--short', ...extra]);
const key = extra.find((a, i) => !a.startsWith('-') && extra[i - 1] !== '--voice') ?? 'firstVideo';
run(`${here}assemble.mjs`, [key]);
