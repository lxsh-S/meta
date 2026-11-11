const std = @import("std");
const print = std.debug.print;

pub fn printHelp() !void {
    print("meta - A simple file metadata reader!\n", .{});
    print("\nUsage:\n", .{});
    print("    meta <FILE> [Options]\n", .{});
    print("\nOptions:", .{});
    print("    -v, --verbose        Display additional information\n", .{});
    print("    -h, --help           Display this help msg\n", .{});
    print("\nExamples:\n", .{});
    print("    meta main.zig\n", .{});
    print("    meta downloads/idk.rust -v  --prints additional information\n", .{});
    print("    meta -h\n", .{});
}
