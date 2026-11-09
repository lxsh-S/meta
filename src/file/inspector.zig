const std = @import("std");
const file = @import("file.zig");

const print = std.debug.print;

pub fn inspector(filename: []const u8, verbose: bool) !void {
    // in current working fir
    const target_file = std.fs.cwd().openFile(filename, .{}) catch {
        print("error: meta could not read '{}'\n", .{filename});
        return;
    };
    // close
    defer target_file.close();

    // metadata
    const stat = try target_file.stat();

    // basic output (non-verbose)
    print("File: {s}\n", .{filename});
    print("Size: {} bytes\n", .{stat.Size});

    // verbose
    if (verbose) {
        print("Permissions(octal): 0o{}\n", .{stat.Permissions});

        var buf: [10]u8 = undefined;

        const perms: file.UnixPermissions = @bitCast(@as(u9, @truncate(stat.mode)));
        const lsFormatted = perms.formatLs(&buf);
        print("Permissions(string): {s}\n", .{lsFormatted});
    }
}
