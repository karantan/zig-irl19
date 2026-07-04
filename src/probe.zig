const std = @import("std");

pub const ProbeError = error{
    InvalidUrl,
    RequestFailed,
};

pub const ProbeResult = struct {
    url: []const u8,
    status: u16,
    elapsed_ms: u32,
    ok: bool,
    content_type: ?[]const u8 = null,
};

/// Returns true when the URL looks like an absolute HTTP(S) URL.
///
/// TODO (Pair B): tighten validation if you have time (non-empty host, etc.).
pub fn isValidUrl(url: []const u8) bool {
    _ = url;
    // TODO: implement — should accept http:// and https:// URLs.
    return false;
}

/// Fetches `url`, measures elapsed time, and returns status metadata.
///
/// TODO (Pair A): implement using std.http.Client.fetch.
/// TODO: pass `io` through if your Zig version requires it for networking.
pub fn probeUrl(
    allocator: std.mem.Allocator,
    io: std.Io,
    url: []const u8,
) ProbeError!ProbeResult {
    _ = allocator;
    _ = io;
    _ = url;
    // TODO: return ProbeError.InvalidUrl when isValidUrl fails.
    // TODO: perform GET request, fill ProbeResult, set ok from status class.
    return error.RequestFailed;
}
