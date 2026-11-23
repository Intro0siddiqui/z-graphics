const std = @import("std");
const shell = @import("shell.zig");

pub fn main(init: std.process.Init.Minimal) !void {
    return shell.runShellFromArgs(init);
}
