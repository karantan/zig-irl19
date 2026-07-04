# Close session guide (16:15–17:00)

## §1 — WASM stretch (16:15–16:45, optional)

For pairs that finished early or whole-group demo.

**Goal:** Call Zig from the browser before hitting the API.

**Steps**

```bash
cd zig-irl19
zig build wasm    # produces web/probe.wasm
```

1. Implement `validateUrl` in `wasm/lib.zig` (facilitators: see reference on `solution/siteprobe` branch)
2. Load in `web/index.html`:

```javascript
const bytes = new TextEncoder().encode(url);
const mem = new Uint8Array(wasmExports.memory.buffer);
mem.set(bytes, 0);
wasmExports.validateUrl(0, bytes.length);
```

3. Validate client-side, then `fetch('/probe')` server-side

**References**

- [Zig WASM guide](https://vexcess.github.io/blog/zig-for-webassembly-guide.html)
- [zig-wasm-browser tutorials](https://github.com/rajeshpillai/zig-wasm-browser)

**Time box:** 30 minutes max — do not block people still finishing POST /probe.

**Facilitator demo (if no pair finishes WASM)**

Use the reference on `solution/siteprobe` — see [facilitator.md](facilitator.md):

```bash
cd solution
zig build wasm
python3 -m http.server -d zig-out/web 8888
# open http://localhost:8888/index.html
```

---

## §2 — Demos + retro (16:45–17:00)

**Demo format (3 min per pair)**

1. Live probe of one URL from [demo-urls.txt](demo-urls.txt)
2. One **aha** (something that clicked)
3. One **footgun** (allocator, stale docs, API change, etc.)

**Retro prompts**

- Where would Zig fit in our stack?
- Where would we still pick Go/Python?
- Vote on follow-up:
  - CLI wrapper (batch probe from JSON file)
  - Thread pool for concurrent probes
  - WASM module in an existing web app

**Reveal solution**

See [facilitator.md](facilitator.md) — merge or diff `solution/siteprobe` vs `main`, then walk through `probe.zig` + POST handler.

---

## Exit survey (optional, 1 min)

Ask verbally:

1. Confidence reading Zig 1–5?
2. Would you reach for Zig in the next 3 months? For what?

---

## Post-day resources

- [Zig language reference](https://ziglang.org/documentation/master/)
- [0.15.1 HTTP release notes](https://ziglang.org/download/0.15.1/release-notes.html)
- [Zig Cookbook](https://cookbook.ziglang.cc/)
