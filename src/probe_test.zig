const std = @import("std");
const probe = @import("probe");

test "ProbeResult struct can be constructed" {
    const result = probe.ProbeResult{
        .url = "https://example.com",
        .status = 200,
        .elapsed_ms = 10,
        .ok = true,
    };
    try std.testing.expect(result.ok);
}

test "isValidUrl accepts https URLs (TODO: implement isValidUrl)" {
    // Expected to fail until Pair B implements isValidUrl.
    try std.testing.expect(probe.isValidUrl("https://example.com"));
}

test "isValidUrl rejects garbage (TODO: implement isValidUrl)" {
    try std.testing.expect(!probe.isValidUrl("not-a-url"));
}

test "probeUrl rejects invalid URL (TODO: implement probeUrl)" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    var threaded = std.Io.Threaded.init(gpa.allocator(), .{});
    defer threaded.deinit();
    const io = threaded.io();

    const result = probe.probeUrl(gpa.allocator(), io, "ftp://example.com");
    try std.testing.expectError(probe.ProbeError.InvalidUrl, result);
}
