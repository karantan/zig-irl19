# Morning lesson guide (09:00–12:00)

Facilitator script for the whole-group morning block. Live-code in the starter repo unless noted.

---

## §1 — Why Zig + setup (09:00–09:30)

**Talking points**

- Zig: general-purpose, no hidden control flow, no hidden allocations ([ziglang.org](https://ziglang.org/))
- Good fit: CLI tools, native services, WASM modules, C interop
- Not today: replacing Python scripts or building Django/Flask-style apps
- Team context: you already build HTTP tooling in Go — today asks "what if this hot path were native?"

**Live demo**

```bash
cd zig-irl19
devenv shell
zig build run
# another terminal:
curl http://127.0.0.1:8080/health
zig build test   # 2 pass, 2 fail — intentional
```

**5-minute exercise**

1. Change log message in `src/main.zig`
2. Add a failing test in `src/probe_test.zig`
3. Fix it — run `zig build test`

---

## §2 — Memory, errors, slices (09:30–10:30)

**Whiteboard:** stack vs heap; who owns a `[]const u8`

**Topics**

| Topic | Show |
|-------|------|
| `const` / `var` | Immutable vs mutable |
| Strings | `[]const u8`, not a special type |
| Slices | Like Go, but no GC |
| Allocators | `page_allocator` for today; always `defer free` |
| Errors | `!T`, `try`, `catch`, error sets |
| `defer` | Deterministic cleanup |

**Live code snippet** (new file or scratch):

```zig
const std = @import("std");

pub fn splitUrls(allocator: std.mem.Allocator, line: []const u8) ![][]const u8 {
    var urls: std.ArrayList([]const u8) = .empty;
    errdefer urls.deinit(allocator);

    var parts = std.mem.splitScalar(u8, line, ',');
    while (parts.next()) |part| {
        const trimmed = std.mem.trim(u8, part, " ");
        if (!std.mem.startsWith(u8, trimmed, "http"))
            return error.InvalidUrl;
        try urls.append(allocator, trimmed);
    }
    return urls.toOwnedSlice(allocator);
}
```

**Micro-exercise (pairs, 15 min)**

Parse `"https://a.com,https://b.com"` — return error if any segment lacks `http` prefix.

Reference: [cheat-sheet.md](cheat-sheet.md)

---

## §3 — Structs, testing, comptime teaser (10:45–12:00)

**Introduce SiteProbe domain model** — open `src/probe.zig`:

```zig
pub const ProbeResult = struct {
    url: []const u8,
    status: u16,
    elapsed_ms: u32,
    ok: bool,
};
```

**Testing** — walk through `src/probe_test.zig`:

- One passing test (`ProbeResult struct`) — example pattern
- Failing tests — TDD for afternoon

**20-minute exercise**

Implement `isValidUrl` so https/http tests pass. Do not implement `probeUrl` yet.

**Comptime teaser (10 min max)**

```zig
comptime {
    @compileLog(@TypeOf(ProbeResult));
}
```

"This is Zig's metaprogramming — generics++ — skip for today unless you're curious."

---

## §4 — HTTP + JSON preview (13:00–13:45, after lunch)

*This section is repeated after lunch; skim at end of morning if time allows.*

Walk through `src/main.zig`:

1. `main(init: std.process.Init)` — new 0.16 entry point
2. TCP listen on 8080
3. `std.http.Server` per connection
4. Route `GET /health` (working) vs `POST /probe` (501 stub)

Draw [endpoint contract](endpoint-contract.md) on whiteboard.

Show solution `probeUrl` on screen **without giving away full main.zig** — just the HTTP client pattern:

```zig
var client: std.http.Client = .{ .allocator = allocator, .io = io };
defer client.deinit();
const response = try client.fetch(.{
    .location = .{ .url = url },
    .redirect_buffer = &redirect_buffer,
});
```

**Footguns to mention**

- Pre-0.15 HTTP tutorials are wrong
- `error` is reserved — use `@"error"` in structs
- JSON response must not reference freed request memory

---

## Teaching tactics

1. Go parallels first, Python second
2. Mob one allocator bug (forget `defer`) — high learning value
3. Keep comptime shallow
4. Point to [Zig Cookbook HTTP](https://cookbook.ziglang.cc/05-03-http-server-std/) when stuck
