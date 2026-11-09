const std = @import("std");
const file = @import("file.zig");

const print = std.debug.print;

pub fn inspector(io: anytype, filename: []const u8, verbose: bool) !void {
    const cwd = std.Io.Dir.cwd();

    //  openFile
    const target_file = cwd.openFile(io, filename, .{}) catch {
        print("error: could not open file '{s}'\n", .{filename});
        return;
    };

    // close
    defer target_file.close(io);

    // metadata
    const stat = try target_file.stat(io);

    // basic output(non-verbose)
    print("File: {s}\n", .{filename});
    print("Size: {} bytes\n", .{stat.size});

    // verbose output
    if (verbose) {
        const mode = stat.permissions.toMode();
        print("Permissions(octal): 0o{o}\n", .{mode});

        // formatted like 'ls'
        var buf: [10]u8 = undefined;
        const perm: file.UnixPermissions = @bitCast(@as(u9, @truncate(mode)));
        const formatted = perm.formatLs(&buf);
        print("Permissions(string): {s}\n", .{formatted});

        // timestamps
        print("Timestamps:\n", .{});

        // as timestamps in zig are Io.Timestamp structs we use 'any'
        if (@hasField(@TypeOf(stat), "atime")) {
            print("    Accessed: {any}\n", .{stat.atime});
        }

        if (@hasField(@TypeOf(stat), "mtime")) {
            print("    Modified: {any}\n", .{stat.mtime});
        }

        if (@hasField(@TypeOf(stat), "ctime")) {
            print("    Created: {any}\n", .{stat.ctime});
        }
    }
}
