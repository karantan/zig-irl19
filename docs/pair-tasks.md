# Pair task cards — SiteProbe afternoon

Split into pairs at 13:45. Rotate at 15:00 if you have 4+ people so everyone touches Zig.

**Done when:** `zig build test` passes, `POST /probe` works from curl and `web/index.html`.

---

## Pair A — Probe core

**Files:** `src/probe.zig`, wire-up in `src/main.zig`

**Goal:** Implement `probeUrl(allocator, io, url)`.

**Steps:**

1. Call `isValidUrl` first; return `ProbeError.InvalidUrl` if false
2. Record start time with `std.Io.Clock.Timestamp.now(io, .awake)`
3. Create `std.http.Client` with `.allocator` and `.io`
4. `client.fetch` with GET, `redirect_buffer` on stack
5. Compute `elapsed_ms`, set `ok` from status class (2xx/3xx)
6. Duplicate URL string into result (caller frees via `freeProbeResult`)

**Verify:**

```bash
zig build test
curl -s -X POST localhost:8080/probe -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com"}'
```

---

## Pair B — Validation + errors

**Files:** `src/probe.zig` (`isValidUrl`), `src/main.zig` (`POST /probe` handler)

**Goal:** Input validation and JSON error responses.

**Steps:**

1. Implement `isValidUrl`: must start with `http://` or `https://`, non-empty host
2. Parse POST body JSON: `{ "url": "..." }`
3. Return 400 + `{"error":"invalid url"}` or `{"error":"invalid json"}`
4. Make failing tests in `probe_test.zig` pass

**Verify:**

```bash
zig build test
curl -s -X POST localhost:8080/probe -H 'Content-Type: application/json' \
  -d '{"url":"ftp://example.com"}'
# {"error":"invalid url"}
```

---

## Pair C — Web UI

**Files:** `web/index.html`

**Goal:** Friendly UI calling the API.

**Steps:**

1. Form with URL input + submit
2. `fetch('http://127.0.0.1:8080/probe', { method: 'POST', ... })`
3. Pretty-print JSON response; show errors clearly
4. Hint when server is down ("is `zig build run` running?")

**Verify:** Open `web/index.html` in browser (file:// or `python3 -m http.server` from `web/`).

---

## Pair D — Polish (pick one)

**Files:** your choice

**Options:**

- Add `content_type` from response headers to `ProbeResult`
- Naive `<title>` extraction from response body (string search, no library)
- Structured logging with `std.log`
- Update README with your pair's notes

---

## Stretch — WASM validation

**Files:** `wasm/lib.zig`, `web/index.html`, `build.zig` (`zig build wasm`)

1. Implement `validateUrl` in `wasm/lib.zig`
2. Build: `zig build wasm` → `web/probe.wasm`
3. Load in browser; validate before calling API

Facilitators: full WASM + UI reference is on `solution/siteprobe` — see [facilitator.md](facilitator.md).

---

## Scope guardrails

Do **not** spend time on:

- httpz / zap / other frameworks
- Thread pool / async
- Auth, TLS, database
- Perfect HTML parsing

Do spend time on:

- Allocators + `defer`
- Passing tests
- Live demo at 16:45
