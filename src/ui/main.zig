const std = @import("std");
const shell = @import("shell.zig");

pub export fn Zawra_TakePendingDMABuf(_: *c_int, _: *u32, _: *u32, _: *u32, _: *u32, _: *u64) bool {
    return false;
}

pub export fn Zawra_ResizeViewport(_: u32, _: u32) void {}

pub fn main(init: std.process.Init.Minimal) !void {
    return shell.runShellFromArgs(init);
}
