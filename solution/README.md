# SiteProbe — reference solution

Complete implementation for facilitators. Do not share with participants until the retro.

## Run

From the project root (where `devenv.nix` lives):

```bash
cd zig-irl19
devenv shell

cd solution
zig build test
zig build run
```

```bash
curl http://127.0.0.1:8080/health
curl -X POST http://127.0.0.1:8080/probe \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com"}'
```

## WASM stretch

```bash
zig build wasm
python3 -m http.server -d zig-out/web 8888
# http://localhost:8888/index.html
```

## Diff from starter

| File | Changes |
|------|---------|
| `src/probe.zig` | Full `isValidUrl`, `probeUrl`, `freeProbeResult` |
| `src/main.zig` | POST /probe JSON parse + error handling |
| `src/probe_test.zig` | All tests pass with `Threaded.io()` |
| `wasm/lib.zig` | Exported `validateUrl` |
| `web/index.html` | WASM pre-check + polished UI |

## Git branch (optional)

To keep solution hidden on a branch:

```bash
git checkout -b solution/siteprobe
git add solution/
git commit -m "Add SiteProbe training day solution"
# Switch participants back to main/starter
```

Participants use the repo root (starter); facilitators cherry-pick or merge from `solution/siteprobe` when revealing.
