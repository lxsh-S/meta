const std = @import("std");
const file = @import("file.zig");
const media = @import("mediaType.zig");

const print = std.debug.print;
const Sha256 = std.crypto.hash.sha2.Sha256;

// ANSI Escape code consts
const reset = "\x1b[0m";
const bold = "\x1b[1m";

const black = "\x1b[30m";
const red = "\x1b[31m";
const green = "\x1b[32m";
const yellow = "\x1b[33m";
const blue = "\x1b[34m";
const magenta = "\x1b[35m";
const cyan = "\x1b[36m";
const white = "\x1b[37m";
const grey = "\x1b[90m";

// more colors
const orange = "\x1b[38;2;255;165;0m";
const pink = "\x1b[38;2;255;105;180m";
const mint_green = "\x1b[38;2;152;251;152m";
const purple = "\x1b[38;2;128;0;128m";
const gold = "\x1b[38;2;255;215;0m";
const dark_grey = "\x1b[28;2;64;64;64m";
const light_grey = "\x1b[38;2;211;211;211m";

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

    print("{s}|--{s}: {s}{s}{d:04}-{d:02}-{d:02}-{d:02}-{d:02}-{d:02} UTC\n", .{
        grey,
        label,
        bold,
        orange,
        year_day.year,
        @backingInt(month_day.month),
        month_day.day_index + 1,
        day_secs.getHoursIntoDay(),
        day_secs.getMinutesIntoHour(),
        day_secs.getSecondsIntoMinute(),
    });
}

fn inspectContent(io: anytype, target_file: anytype) !struct {
    media: media.MediaType,
    sha256: [Sha256.digest_length * 2]u8,
} {
    var hasher = Sha256.init(.{});
    var buf: [64 * 1024]u8 = undefined;
    var header_buf: [16]u8 = undefined;
    var header_len: usize = 0;

    while (true) {
        const bytes_read = target_file.readStreaming(io, &.{&buf}) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };

        // we'll capture the first 16 bytes for magc-byte detection
        if (header_len < header_buf.len) {
            const copy_len = @min(bytes_read, header_buf.len - header_len);
            @memcpy(header_buf[header_len .. header_len + copy_len], buf[0..copy_len]);
            header_len += copy_len;
        }

        hasher.update(buf[0..bytes_read]);
    }

    return .{
        .media = media.detectMediaType(header_buf[0..header_len]),
        .sha256 = std.fmt.bytesToHex(hasher.finalResult(), .lower),
    };
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

    // version
    const version = 0.1;

    // empty space
    print("\n", .{});

    // Name
    print("{s}{s}*META* - {s}v{d}{s}", .{ bold, blue, pink, version, reset });

    // seperator
    print("\n{s}{s}-------------------------------------------------\n{s}", .{ bold, magenta, reset });

    // basic output(non-verbose)
    print("{s}File: {s}{s}{s}{s}\n", .{ grey, bold, cyan, filename, reset });
    print("{s}Size: {s}{s}{d} bytes{s}\n", .{ grey, bold, red, stat.size, reset });

    // file tyope
    const kind_str = switch (stat.kind) {
        .file => "Regular File",
        .directory => "Directory",
        .sym_link => "Symbolic Link",
        .block_device => "Block Device",
        .character_device => "Character device",
        .named_pipe => "Named Pipe (FIFO)",
        .unix_domain_socket => "Unix Domain Socket",
        .whiteout => "Whiteout",
        .door => "Door",
        .event_port => "Event_port",
        .unknown => "Unknown",
    };

    print("{s}Type: {s}{s}{s}{s}\n", .{ grey, bold, gold, kind_str, reset });

    // only inspect if its a regular file
    const is_regular_file = (stat.kind == .file);
    var media_label: ?[]const u8 = null;
    var sha256_hex_val: ?[Sha256.digest_length * 2]u8 = null;

    if (is_regular_file) {
        const content = try inspectContent(io, target_file);
        media_label = switch (content.media) {
            .image => "Image",
            .video => "Video",
            .other => "Other / Binary / Text",
        };
        sha256_hex_val = content.sha256;
    }

    // media content
    if (media_label) |ml| {
        print("{s}Category: {s}{s}{s}{s}\n", .{ grey, bold, cyan, ml, reset });
    }
    // verbose output
    if (verbose) {
        const mode = stat.permissions.toMode();
        print("\n{s}Permissions(octal): {s}{s}0o{o}{s}\n", .{ grey, bold, yellow, mode, reset });

        // formatted like 'ls'
        var buf: [10]u8 = undefined;
        const perm: file.UnixPermissions = @bitCast(@as(u9, @truncate(mode)));
        const formatted = perm.formatLs(&buf);
        print("{s}Permissions(string): {s}{s}{s}{s}\n", .{ grey, bold, yellow, formatted, reset });
        //
        // checksum
        if (is_regular_file) {
            if (sha256_hex_val) |s256| {
                print("\n{s}SHA-256: {s}{s}{s}{s}\n", .{ grey, bold, light_grey, s256, reset });
            }
        }

        // timestamps
        print("\n{s}Timestamps:\n", .{grey});

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
