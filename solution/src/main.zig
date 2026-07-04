const std = @import("std");
const probe = @import("probe");

const Io = std.Io;
const log = std.log.scoped(.siteprobe);

const ProbeRequest = struct {
    url: []const u8,
};

const ErrorResponse = struct {
    @"error": []const u8,
};

const HealthResponse = struct {
    status: []const u8,
};

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const addr = try std.Io.net.IpAddress.parse("127.0.0.1", 8080);
    var server = try addr.listen(io, .{ .reuse_address = true });
    defer server.deinit(io);

    log.info("SiteProbe listening on http://127.0.0.1:8080", .{});

    while (true) {
        const stream = server.accept(io) catch |err| {
            log.err("accept failed: {s}", .{@errorName(err)});
            continue;
        };
        handleConnection(io, allocator, stream) catch |err| {
            log.err("connection error: {s}", .{@errorName(err)});
        };
        stream.close(io);
    }
}

fn handleConnection(io: Io, allocator: std.mem.Allocator, stream: std.Io.net.Stream) !void {
    var recv_buffer: [4096]u8 = undefined;
    var send_buffer: [4096]u8 = undefined;
    var stream_reader = stream.reader(io, &recv_buffer);
    var stream_writer = stream.writer(io, &send_buffer);
    var http_server = std.http.Server.init(&stream_reader.interface, &stream_writer.interface);

    while (http_server.reader.state == .ready) {
        var request = http_server.receiveHead() catch |err| switch (err) {
            error.HttpConnectionClosing => return,
            else => return err,
        };
        try dispatch(io, allocator, &request);
    }
}

fn dispatch(io: Io, allocator: std.mem.Allocator, request: *std.http.Server.Request) !void {
    const method = request.head.method;
    const target = request.head.target;

    if (method == .GET and std.mem.eql(u8, target, "/health")) {
        try respondJson(request, allocator, .ok, HealthResponse{ .status = "ok" });
        return;
    }

    if (method == .POST and std.mem.eql(u8, target, "/probe")) {
        try handleProbe(io, allocator, request);
        return;
    }

    try respondJson(request, allocator, .not_found, ErrorResponse{ .@"error" = "not found" });
}

fn handleProbe(io: Io, allocator: std.mem.Allocator, request: *std.http.Server.Request) !void {
    var body_buffer: [4096]u8 = undefined;
    const body_reader = request.readerExpectNone(&body_buffer);
    var body = std.Io.Writer.Allocating.init(allocator);
    defer body.deinit();
    _ = try body_reader.streamRemaining(&body.writer);

    const parsed = std.json.parseFromSlice(ProbeRequest, allocator, body.written(), .{}) catch {
        try respondJson(request, allocator, .bad_request, ErrorResponse{ .@"error" = "invalid json" });
        return;
    };
    defer parsed.deinit();

    const result = probe.probeUrl(allocator, io, parsed.value.url) catch |err| switch (err) {
        probe.ProbeError.InvalidUrl => {
            try respondJson(request, allocator, .bad_request, ErrorResponse{ .@"error" = "invalid url" });
            return;
        },
        probe.ProbeError.RequestFailed => {
            try respondJson(request, allocator, .bad_gateway, ErrorResponse{ .@"error" = "request failed" });
            return;
        },
        probe.ProbeError.OutOfMemory => {
            try respondJson(request, allocator, .internal_server_error, ErrorResponse{ .@"error" = "out of memory" });
            return;
        },
    };
    defer probe.freeProbeResult(allocator, result);

    try respondJson(request, allocator, .ok, result);
}

fn respondJson(
    request: *std.http.Server.Request,
    allocator: std.mem.Allocator,
    status: std.http.Status,
    value: anytype,
) !void {
    const body = try std.json.Stringify.valueAlloc(allocator, value, .{});
    defer allocator.free(body);

    try request.respond(body, .{
        .status = status,
        .extra_headers = &.{
            .{ .name = "content-type", .value = "application/json" },
            .{ .name = "access-control-allow-origin", .value = "*" },
        },
    });
}
