const std = @import("std");
const file = @import("file/file.zig");
const cli = @import("cli/cli.zig");
const inspector = @import("file/inspector.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);

    const config = cli.parseArgs(args[1..]) catch |err| {
        if (err == error.Help) return;
        return;
    };

    try inspector.inspector(init.io, config.filename.?, config.verbose);
}
