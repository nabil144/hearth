#!/usr/bin/env python3
"""Serve POC films on the LAN only. Token path, allow-list, Range requests."""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
CFG = json.loads((ROOT / "content" / "films.json").read_text())
SHORTS = (ROOT / "web" / "shorts").resolve()
TOKEN = CFG["token"]
ALLOW = set(CFG["lessons"].values())
HOST = CFG["host"]
PORT = int(CFG["port"])


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("%s %s\n" % (self.address_string(), fmt % args))

    def do_HEAD(self):
        self.send_film(True)

    def do_GET(self):
        self.send_film(False)

    def send_film(self, head):
        parts = self.path.split("?", 1)[0].strip("/").split("/")
        if len(parts) != 2 or parts[0] != TOKEN or parts[1] not in ALLOW:
            self.send_error(404, "Not found")
            return
        path = (SHORTS / parts[1]).resolve()
        if path.parent != SHORTS or not path.is_file():
            self.send_error(404, "Not found")
            return
        size = path.stat().st_size
        start, end = 0, size - 1
        rng = self.headers.get("Range")
        if rng and rng.startswith("bytes="):
            a, _, b = rng[6:].partition("-")
            try:
                if a:
                    start = int(a)
                if b:
                    end = int(b)
            except ValueError:
                self.send_error(416, "Range")
                return
            if start < 0 or end >= size or start > end:
                self.send_error(416, "Range")
                return
            self.send_response(206)
            self.send_header("Content-Range", f"bytes {start}-{end}/{size}")
        else:
            self.send_response(200)
        length = end - start + 1
        self.send_header("Content-Type", "video/mp4")
        self.send_header("Content-Length", str(length))
        self.send_header("Accept-Ranges", "bytes")
        self.send_header("Cache-Control", "private, no-store")
        self.end_headers()
        if head:
            return
        with path.open("rb") as f:
            f.seek(start)
            left = length
            while left:
                chunk = f.read(min(1024 * 256, left))
                if not chunk:
                    break
                self.wfile.write(chunk)
                left -= len(chunk)


if __name__ == "__main__":
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"film  {CFG['scheme']}://{HOST}:{PORT}/{TOKEN}/<file>", flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
