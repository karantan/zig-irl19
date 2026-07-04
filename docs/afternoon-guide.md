# Afternoon pair project guide (13:45–16:15)

## Before pairs start (13:45)

1. Recap [endpoint contract](endpoint-contract.md) on whiteboard
2. Assign pairs using [pair-tasks.md](pair-tasks.md):
   - Pair A → probe core
   - Pair B → validation + POST handler
   - Pair C → web UI
   - Pair D → polish / float
3. Announce **scope guardrails** (no frameworks, no DB, sequential server OK)
4. Confirm everyone has `zig build run` serving `/health`

## During pairs (13:45–16:15)

**13:45–15:00** — First rotation

- Circulate; enforce allocator + `defer` at every allocation
- Common blockers:
  - Copied old HTTP API → point to starter `main.zig`
  - `GeneralPurposeAllocator` removed in 0.16 → use `DebugAllocator` or `page_allocator`
  - Tests need `std.Io.Threaded` → `threaded.io()` for HTTP client in tests

**15:00** — Rotate (if 4+ people)

- Anyone who only touched HTML should move to Zig pairs
- Merge work via git or pair swap — avoid one person on UI all day

**15:00–16:15** — Integration push

- Goal: curl + browser both work
- Run `zig build test` as gate
- Pairs that finish early → [Pair D tasks](pair-tasks.md) or WASM stretch prep

## Facilitator prompts when stuck

| Symptom | Hint |
|---------|------|
| Compile error in `std.http` | Compare with `src/main.zig` skeleton |
| Test can't do HTTP | Need `Threaded.init` + `.io()` in test |
| 400 always | Log parsed JSON; check `isValidUrl` |
| UI CORS error | Ensure `access-control-allow-origin: *` header in responses |
| Segfault / weird JSON | Use-after-free — duplicate strings before respond |

## Integration checklist (16:10)

```bash
zig build test          # all green
zig build run           # terminal 1
curl localhost:8080/health
curl -X POST localhost:8080/probe -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com"}'
open web/index.html     # terminal 2 — optional: python3 -m http.server in web/
```

Use URLs from [demo-urls.txt](demo-urls.txt) for demos.

## Reference

Full working code is on branch `solution/siteprobe` — facilitators only; see [facilitator.md](facilitator.md).
