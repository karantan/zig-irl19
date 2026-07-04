/// Stretch goal: URL validation compiled to WASM for the browser UI.
///
/// TODO: implement validateUrl and export it for JavaScript.
pub export fn validateUrl(ptr: [*]const u8, len: usize) bool {
    _ = ptr;
    _ = len;
    return false;
}
