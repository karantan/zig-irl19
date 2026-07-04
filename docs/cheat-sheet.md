# Go / Python → Zig cheat sheet

For web developers with Python + Go background. Zig 0.16.0 syntax.

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
