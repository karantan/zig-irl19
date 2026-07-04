const std = @import("std");
const log = std.log.scoped(.siteprobe);

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = std.heap.page_allocator;

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

fn handleConnection(io: std.Io, allocator: std.mem.Allocator, stream: std.Io.net.Stream) !void {
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

fn dispatch(_: std.Io, allocator: std.mem.Allocator, request: *std.http.Server.Request) !void {
    const method = request.head.method;
    const target = request.head.target;

    if (method == .GET and std.mem.eql(u8, target, "/health")) {
        try respondJson(request, allocator, .ok, "{\"status\":\"ok\"}");
        return;
    }

    if (method == .POST and std.mem.eql(u8, target, "/probe")) {
        // TODO (Pairs A + B): read JSON body, call probe.probeUrl, return JSON result.
        try respondJson(request, allocator, .not_implemented, "{\"error\":\"POST /probe not implemented yet\"}");
        return;
    }

    try respondJson(request, allocator, .not_found, "{\"error\":\"not found\"}");
}

fn respondJson(
    request: *std.http.Server.Request,
    allocator: std.mem.Allocator,
    status: std.http.Status,
    body: []const u8,
) !void {
    const owned = try allocator.dupe(u8, body);
    defer allocator.free(owned);

    try request.respond(owned, .{
        .status = status,
        .extra_headers = &.{
            .{ .name = "content-type", .value = "application/json" },
            .{ .name = "access-control-allow-origin", .value = "*" },
        },
    });
}
