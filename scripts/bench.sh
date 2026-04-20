set -euo pipefail

(( $# >= 4 )) || { echo 'Usage: ./bench.sh <c1> [c2 ...] "<command>" <port> [name]' >&2; exit 1; }

if [[ "${!#}" =~ ^[0-9]+$ ]]; then
  NAME=target; CMD="${@: -2:1}"; PORT="${!#}"; CONC=("${@:1:$#-2}")
else
  NAME="${!#}"; CMD="${@: -3:1}"; PORT="${@: -2:1}"; CONC=("${@:1:$#-3}")
fi

WARMUP=${WARMUP_SECS:-4}
BENCH=${BENCH_SECS:-20}
PIPE=${PIPELINING:-1}
PATH_=${URL_PATH:-/plaintext}
URL="http://localhost:$PORT$PATH_"

cleanup() { lsof -ti:"$PORT" 2>/dev/null | xargs -r kill -9 2>/dev/null || true; }
trap cleanup EXIT

printf '| %s | Conc | Req/s | Avg ms | p99 ms | Err | T/O | Non2xx |\n' "$NAME"
printf '|--------|-----:|------:|-------:|-------:|----:|----:|-------:|\n'

for c in "${CONC[@]}"; do
  cleanup; sleep 0.3
  eval "$CMD" >/dev/null 2>&1 & pid=$!
  for _ in {1..40}; do nc -z localhost "$PORT" 2>/dev/null && break; sleep 0.25; done

  autocannon -c "$c" -d "$WARMUP" -p "$PIPE" -q "$URL" >/dev/null 2>&1 || true
  out=$(autocannon -j -c "$c" -d "$BENCH" -p "$PIPE" "$URL" 2>/dev/null)
  kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true

  jq -r --arg n "$NAME" --arg c "$c" \
    '"| \($n) | \($c) | \(.requests.average) | \(.latency.average) | \(.latency.p99) | \(.errors) | \(.timeouts) | \(.non2xx) |"' \
    <<<"$out"
done
