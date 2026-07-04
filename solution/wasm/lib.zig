const std = @import("std");

/// Validates that a URL starts with http:// or https:// and has a host part.
pub export fn validateUrl(ptr: [*]const u8, len: usize) bool {
    const url = ptr[0..len];
    if (!(std.mem.startsWith(u8, url, "http://") or std.mem.startsWith(u8, url, "https://")))
        return false;
    return url.len > "https://".len;
}
