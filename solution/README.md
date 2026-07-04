# SiteProbe — reference solution

Complete implementation for facilitators. Participants on `main` do not have this directory — it lives on branch **`solution/siteprobe`** only.

See [../docs/facilitator.md](../docs/facilitator.md) for worktree setup and how to reveal the answer at retro.

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

## Diff from starter (on `main`)

| File | Changes |
|------|---------|
| `src/probe.zig` | Full `isValidUrl`, `probeUrl`, `freeProbeResult` |
| `src/main.zig` | POST /probe JSON parse + error handling |
| `src/probe_test.zig` | All tests pass with `Threaded.io()` |
| `wasm/lib.zig` | Exported `validateUrl` |
| `web/index.html` | WASM pre-check + polished UI |

Compare against `main`:

```bash
git diff main..solution/siteprobe -- src/ web/ wasm/
```
