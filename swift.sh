#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tc_root="$here/.toolchain"
if [ ! -d "$tc_root/swift-6.2.4-RELEASE-ubuntu24.04" ]; then
  tc_root="$HOME/life-is-a-game/.toolchain"
fi
tc="$tc_root/swift-6.2.4-RELEASE-ubuntu24.04/usr"
export LD_LIBRARY_PATH="$tc_root/shim${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$tc/bin:$PATH"
exec "$tc/bin/swift" "$@"
