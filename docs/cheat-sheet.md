# Go / Python → Zig cheat sheet

For web developers with Python + Go background. Zig 0.16.0 syntax.

## Zig basics & conventions

### Where does the program start?

**Go** — you need all three:

```go
package main          // special package name

func main() {         // entry point
```

Usually in `main.go` at the module root, or `cmd/myapp/main.go` for larger projects.

**Zig** — no `package` keyword. The **build system** picks the entry file:

| File | Role |
|------|------|
| `build.zig` | Defines targets (`zig build run`, `zig build test`) — think `go.mod` + Makefile |
| `src/main.zig` | Executable entry point for this repo |
| `src/probe.zig` | Separate module, imported as `@import("probe")` |

Entry point in 0.16:

```zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    // ...
}
```

- `pub` — must be public (see below)
- `!void` — may return an error (like `error` in Go, but in the type)
- `init.io` — I/O handle for networking, clocks, etc. (new in 0.16)

Run: `zig build run` (not `go run .` — Zig compiles via `build.zig`).

### Public vs private

**Go** — export by **capitalization**:

```go
func Public() {}   // exported
func private() {} // package-private only
```

**Zig** — export by **`pub` keyword** (letter case does not matter):

```zig
pub fn probeUrl(...) !ProbeResult { ... }  // visible to importers
fn dispatch(...) !void { ... }              // private to this file/module
pub const ProbeResult = struct { ... };     // public type
const helper = 42;                          // private constant
```

| Go | Zig |
|----|-----|
| `func Foo()` exported | `pub fn foo()` exported |
| `func foo()` private | `fn foo()` private |
| Capitalized type `ProbeResult` | `pub const ProbeResult = struct ...` |

When another file does `const probe = @import("probe")`, it only sees `pub` declarations from `probe.zig`.

### Naming conventions

| What | Convention | Example |
|------|------------|---------|
| Source files | `snake_case.zig` | `probe_test.zig`, `main.zig` |
| Functions | `snake_case` | `isValidUrl`, `probeUrl` |
| Types / structs | `PascalCase` | `ProbeResult`, `ProbeError` |
| Constants | `snake_case` or `PascalCase` for types | `const max_len = 4096` |
| Namespaced imports | `@import("name")` | `@import("std")`, `@import("probe")` |

Go's mixedCaps for exported names does **not** apply — use `pub` + `snake_case` instead.

### Project layout (this repo)

```text
zig-irl19/
  build.zig           # build config — modules, test target, wasm target
  src/
    main.zig          # HTTP server (executable root)
    probe.zig         # domain logic (imported module)
    probe_test.zig    # tests (import probe, run via zig build test)
  web/index.html      # static UI (not part of Zig build except wasm step)
  wasm/lib.zig        # optional WASM export
```

**Go equivalent mental model:**

| Go | Zig |
|----|-----|
| `go.mod` | `build.zig` + `build.zig.zon` (dependencies, if any) |
| `package main` + `main.go` | `src/main.zig` with `pub fn main` |
| `internal/probe/probe.go` | `src/probe.zig` + `build.zig` import mapping |
| `probe_test.go` | `probe_test.zig` or `test "..."` blocks inline |
| `go test ./...` | `zig build test` |
| `go run .` | `zig build run` |

### Other conventions worth knowing

- **Semicolons** — required after statements (Go mostly optional).
- **No classes** — use `struct` + functions; no inheritance.
- **No exceptions** — errors are values (`!T`, `error{...}`); use `try` / `catch`.
- **No hidden allocations** — pass an `Allocator` when you need heap memory.
- **Tests live anywhere** — `test "description" { ... }` blocks in any `.zig` file; this repo puts them in `probe_test.zig`.
- **Reserved words** — `error` is reserved; for a JSON field use `@"error"`.
- **Compile-time code** — `comptime` blocks run at compile time (generics-lite); skip deep dive on day 1.

### Minimal “hello” comparison

**Go**

```go
package main

import "fmt"

func main() {
    fmt.Println("hello")
}
```

**Zig**

```zig
const std = @import("std");

pub fn main() !void {
    try std.io.getStdOut().writer().print("hello\n", .{});
}
```

(In 0.16 with I/O changes, our server uses `main(init: std.process.Init)` — see HTTP section below.)

---

## Syntax parallels

| Idea | Go | Python | Zig |
|------|----|--------|-----|
| Immutable binding | `x := 1` | `x = 1` (no const) | `const x = 1;` |
| Mutable binding | `var x = 1` | `x = 1` | `var x: i32 = 1;` |
| Function | `func f() error` | `def f():` | `fn f() !void` |
| String type | `string` | `str` | `[]const u8` |
| Slice | `[]int` | `list[int]` | `[]i32` |
| Struct | `type T struct{}` | `@dataclass` | `const T = struct {};` |
| Defer cleanup | `defer f()` | `with` / `try/finally` | `defer allocator.free(x);` |
| Nil / null | `nil` | `None` | `null` |
| Pointer | `*T` | (rare) | `*T` or `[*]T` for C ABI |

## Error handling

**Go**

```go
if err != nil {
    return err
}
```

**Zig**

```zig
try doThing();                    // propagate error
const x = doThing() catch 0;     // default value
doThing() catch |err| { ... };   // handle explicitly
```

Return type `!T` means `T` or an error union. `void` errors use `!void`.

Define errors:

```zig
const MyError = error{ NotFound, InvalidInput };
fn f() MyError!i32 { ... }
```

## Memory (biggest mindset shift)

Python and Go: GC cleans up for you.

Zig: you choose an **allocator** and free what you allocate.

```zig
const allocator = std.heap.page_allocator;  // fine for training day

const copy = try allocator.dupe(u8, "hello");
defer allocator.free(copy);
```

Rules of thumb:

- Every `try allocator.alloc...` / `dupe` / `allocPrint` → matching `defer allocator.free(...)`
- `defer` runs when scope exits (like Go, but deterministic)
- Slices (`[]const u8`) do not own memory — know who owns the backing buffer

## Collections

Slices are views — no `.append()`.

```zig
var list: std.ArrayList(u32) = .empty;
defer list.deinit(allocator);
try list.append(allocator, 42);
```

## Testing

```zig
test "addition" {
    try std.testing.expectEqual(@as(i32, 4), 2 + 2);
}
```

Run: `zig build test`

Table-driven tests feel like Go:

```zig
const cases = [_]struct { in: []const u8, want: bool }{
    .{ .in = "https://x.com", .want = true },
    .{ .in = "ftp://x.com", .want = false },
};
for (cases) |c| {
    try std.testing.expectEqual(c.want, isValidUrl(c.in));
}
```

## HTTP server (0.16 pattern)

Entry point:

```zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    // ...
}
```

Listen + accept:

```zig
const addr = try std.Io.net.IpAddress.parse("127.0.0.1", 8080);
var server = try addr.listen(io, .{ .reuse_address = true });
const stream = try server.accept(io);
defer stream.close(io);
```

Per-connection HTTP (simplified):

```zig
var recv: [4096]u8 = undefined;
var send: [4096]u8 = undefined;
var reader = stream.reader(io, &recv);
var writer = stream.writer(io, &send);
var http = std.http.Server.init(&reader.interface, &writer.interface);
var request = try http.receiveHead();
try request.respond("ok", .{});
```

## HTTP client

```zig
var client: std.http.Client = .{ .allocator = allocator, .io = io };
defer client.deinit();

var redirect_buffer: [8192]u8 = undefined;
const response = try client.fetch(.{
    .location = .{ .url = "https://example.com" },
    .redirect_buffer = &redirect_buffer,
});
// response.status is std.http.Status
```

## JSON

Parse:

```zig
const Payload = struct { url: []const u8 };
const parsed = try std.json.parseFromSlice(Payload, allocator, body, .{});
defer parsed.deinit();
// parsed.value.url
```

Stringify:

```zig
const json = try std.json.Stringify.valueAlloc(allocator, value, .{});
defer allocator.free(json);
```

Reserved word: use `@"error"` for a JSON field named `error`.

## Timing (0.16)

`std.time.nanoTimestamp()` is gone. Use I/O clocks:

```zig
const started = std.Io.Clock.Timestamp.now(io, .awake);
// ... work ...
const elapsed = started.untilNow(io);
const ms = @divTrunc(elapsed.raw.nanoseconds, std.time.ns_per_ms);
```

## Comptime teaser

```zig
comptime {
    @compileLog(@TypeOf(myVar));
}
```

Generics in Zig are mostly **comptime** parameters — don't dive deep on day 1.

## Footguns to watch for

1. Stale tutorials (pre-0.15 HTTP API)
2. Forgetting `defer` after allocation
3. Returning slices that point at freed request buffers
4. Using `error` as a struct field name (reserved — use `@"error"`)
5. Blocking server handles one connection at a time (OK for today)
