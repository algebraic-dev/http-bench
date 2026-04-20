set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCH="$ROOT/scripts/bench.sh"

read -ra CONC <<< "${CONC:-1 10 100 500 1000}"
LEAN_CMD="${LEAN_CMD:-$ROOT/lean/server}"
NODE_CMD="${NODE_CMD:-node $ROOT/node/server.js}"
LEAN_PORT="${LEAN_PORT:-4000}"
NODE_PORT="${NODE_PORT:-3000}"

[[ -x "$ROOT/lean/server" ]] || echo "warning: $ROOT/lean/server not found or not executable" >&2
[[ -f "$ROOT/node/server.js" ]] || { echo "error: $ROOT/node/server.js not found" >&2; exit 1; }

sweep() {
  local path=$1 label=$2
  echo
  echo "### $label"
  URL_PATH="$path" "$BENCH" "${CONC[@]}" "$LEAN_CMD" "$LEAN_PORT" Lean
  echo
  URL_PATH="$path" "$BENCH" "${CONC[@]}" "$NODE_CMD" "$NODE_PORT" Node
}

sweep /plaintext 'plaintext — "Hello, World!" (13 B)'
sweep /blob      'blob — 1 MiB of 0x58'
