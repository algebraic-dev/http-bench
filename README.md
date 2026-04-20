# http-bench

A small harness for comparing HTTP server implementations under a plaintext
workload.

## Requirements

- [autocannon](https://github.com/mcollina/autocannon) (`npm install -g autocannon`)
- jq, nc and lsof
- Node.js ≥ 18 (for the Node server)
- Lean 4 toolchain that provides `Std.Internal.Http`

### Benchmark

Compile `Main.lean` to `./lean/server` and run `scripts/run-all.sh`.