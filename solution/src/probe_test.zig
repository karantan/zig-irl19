const std = @import("std");
const probe = @import("probe");

test "isValidUrl accepts https URLs" {
    try std.testing.expect(probe.isValidUrl("https://example.com"));
}

test "isValidUrl accepts http URLs" {
    try std.testing.expect(probe.isValidUrl("http://example.com/path"));
}

test "isValidUrl rejects garbage" {
    try std.testing.expect(!probe.isValidUrl("not-a-url"));
}

test "isValidUrl rejects ftp URLs" {
    try std.testing.expect(!probe.isValidUrl("ftp://example.com"));
}

test "probeUrl rejects invalid URL" {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();

    var threaded = std.Io.Threaded.init(gpa.allocator(), .{});
    defer threaded.deinit();
    const io = threaded.io();

    const result = probe.probeUrl(gpa.allocator(), io, "ftp://example.com");
    try std.testing.expectError(probe.ProbeError.InvalidUrl, result);
}
