const std = @import("std");
const file = @import("file.zig");

const print = std.debug.print;

// for printing readable timestamps
fn printTimestamp(label: []const u8, ts: anytype) void {
    const timestamp: std.Io.Timestamp = switch (@typeInfo(@TypeOf(ts))) {
        .optional => ts orelse return,
        else => ts,
    };
    const ns = timestamp.nanoseconds;
    const secs = @divFloor(ns, 1_000_000_000);

    const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(secs) };
    const epoch_day = epoch_seconds.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_secs = epoch_seconds.getDaySeconds();

    print("||--{s}: {d:04}-{d:02}-{d:02}-{d:02}-{d:02}-{d:02} UTC\n", .{
        label,
        year_day.year,
        @backingInt(month_day.month),
        month_day.day_index + 1,
        day_secs.getHoursIntoDay(),
        day_secs.getMinutesIntoHour(),
        day_secs.getSecondsIntoMinute(),
    });
}

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
            printTimestamp("Accessed", stat.atime);
        }

        if (@hasField(@TypeOf(stat), "mtime")) {
            printTimestamp("Modified", stat.mtime);
        }

        if (@hasField(@TypeOf(stat), "ctime")) {
            printTimestamp("Created", stat.ctime);
        }
    }
}
