const std = @import("std");

pub const ProbeError = error{
    InvalidUrl,
    RequestFailed,
    OutOfMemory,
};

pub const ProbeResult = struct {
    url: []const u8,
    status: u16,
    elapsed_ms: u32,
    ok: bool,
    content_type: ?[]const u8 = null,
};

pub fn isValidUrl(url: []const u8) bool {
    if (!(std.mem.startsWith(u8, url, "http://") or std.mem.startsWith(u8, url, "https://")))
        return false;
    return url.len > "https://".len;
}

pub fn probeUrl(
    allocator: std.mem.Allocator,
    io: std.Io,
    url: []const u8,
) ProbeError!ProbeResult {
    if (!isValidUrl(url)) return ProbeError.InvalidUrl;

    const started = std.Io.Clock.Timestamp.now(io, .awake);

    var client: std.http.Client = .{
        .allocator = allocator,
        .io = io,
    };
    defer client.deinit();

    var redirect_buffer: [8 * 1024]u8 = undefined;

    const response = client.fetch(.{
        .location = .{ .url = url },
        .method = .GET,
        .redirect_buffer = &redirect_buffer,
        .headers = .{
            .user_agent = .{ .override = "SiteProbe/0.1" },
        },
    }) catch return ProbeError.RequestFailed;

    const elapsed = started.untilNow(io);
    const elapsed_ms: u32 = @intCast(@max(
        @divTrunc(elapsed.raw.nanoseconds, std.time.ns_per_ms),
        0,
    ));

    const url_copy = try allocator.dupe(u8, url);
    errdefer allocator.free(url_copy);

    const status_class = response.status.class();
    const ok = status_class == .success or status_class == .redirect;

    return ProbeResult{
        .url = url_copy,
        .status = @intFromEnum(response.status),
        .elapsed_ms = elapsed_ms,
        .ok = ok,
        .content_type = null,
    };
}

pub fn freeProbeResult(allocator: std.mem.Allocator, result: ProbeResult) void {
    allocator.free(result.url);
}
