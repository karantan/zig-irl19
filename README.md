# SiteProbe — Zig Training Day

Hands-on intro to [Zig 0.16.0](https://ziglang.org/) for Python/Go web developers. By end of day you will run a small URL health-check API and a browser UI.

## Quick start

```bash
cd zig-irl19
devenv shell          # see docs/install.md — pins Zig 0.16.0

zig build test
zig build run

# In another terminal (also in devenv shell):
curl http://127.0.0.1:8080/health
open web/index.html
```

## Project layout

```text
zig-irl19/
  devenv.nix          # Zig 0.16.0 via devenv
  devenv.yaml
  build.zig           # zig build run | test | wasm
  src/
    main.zig          # HTTP server skeleton (GET /health works)
    probe.zig         # TODO: your afternoon work
    probe_test.zig    # tests (some fail until you implement)
  web/
    index.html        # browser UI (Pair C)
  wasm/
    lib.zig           # stretch: export validateUrl to WASM
  docs/               # guides + cheat sheet
```

> **Facilitators:** reference implementation is on branch `solution/siteprobe` — see [docs/facilitator.md](docs/facilitator.md). Do not share until the retro.

## Afternoon goal

Implement **SiteProbe**:

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Already works — returns `{"status":"ok"}` |
| `POST /probe` | Accept `{"url":"https://..."}`, return probe JSON |

See [docs/endpoint-contract.md](docs/endpoint-contract.md) and [docs/pair-tasks.md](docs/pair-tasks.md).

## Commands

| Command | Purpose |
|---------|---------|
| `devenv shell` | Enter pinned Zig 0.16.0 environment |
| `devenv test` | Run unit tests + smoke-test `/health` |
| `zig build run` | Start server on `http://127.0.0.1:8080` |
| `zig build test` | Run unit tests |
| `zig build wasm` | Build `web/probe.wasm` (stretch) |

## Schedule (7 hours)

| Time | Block |
|------|-------|
| 09:00–12:00 | Morning lessons — see [docs/morning-lesson.md](docs/morning-lesson.md) |
| 12:00–13:00 | Lunch |
| 13:00–16:15 | Pair project — see [docs/afternoon-guide.md](docs/afternoon-guide.md) |
| 16:15–17:00 | WASM stretch + demos — see [docs/close-guide.md](docs/close-guide.md) |

Full agenda: [docs/agenda.md](docs/agenda.md)

## Reference materials

- [Install guide](docs/install.md)
- [Go/Python → Zig cheat sheet](docs/cheat-sheet.md)
- [API contract](docs/endpoint-contract.md)
- [Pair task cards](docs/pair-tasks.md)
- [Demo URLs](docs/demo-urls.txt)

## Facilitators

See [docs/facilitator.md](docs/facilitator.md) for the solution branch and pre-flight setup.
