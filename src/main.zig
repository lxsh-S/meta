const std = @import("std");
const print = std.debug.print;

// define the layout of permission bits
pub const UnixPermissions = packed struct(u9) {
    other_execute: bool,
    other_write: bool,
    other_read: bool,

    group_execute: bool,
    group_write: bool,
    group_read: bool,

    owner_execute: bool,
    owner_write: bool,
    owner_read: bool,
};

// our file struct
pub const File = struct { size: u8, permission: UnixPermissions };

pub fn main(init: std.process.Init) !void {
    var stderr_buf: [1024]u8 = undefined;

    var stderr_file = std.Io.File.stderr().writerStreaming(init.io, &stderr_buf);
    const stderr = &stderr_file.interface;

    // collect arguments
    var arguments = try init.minimal.args.iterateAllocator(init.gpa);
    defer arguments.deinit();
    _ = arguments.next();

    var filename: ?[]const u8 = null;

    // we'll loop through individual arguments
    while (arguments.next()) |argument| {
        if (std.mem.startsWith(u8, argument, "-")) {
            print("{s}\n", .{argument});
        } else {
            if (filename != null) {
                try stderr.print("error: unknown {s}", .{argument});

                // must flush
                try stderr_file.flush();

                try printHelp();

                std.process.exit(1);
            }
            filename = argument;
            print("{s}\n", .{filename.?});
        }
    }
}

fn printHelp() !void {
    print("HELP!", .{});
}
