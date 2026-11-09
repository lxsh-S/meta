const std = @import("std");
const file = @import("file.zig");

const print = std.debug.print;

// our file struct
pub const File = struct { size: u8, permission: file.UnixPermissions };

pub fn main() !void {
    const my_file = File{
        .size = 128,
        .permission = .{
            .owner_read = true,
            .owner_write = true,
            .owner_execute = false,
            .group_read = true,
            .group_write = false,
            .group_execute = false,
            .other_read = true,
            .other_write = false,
            .other_execute = false,
        },
    };

    // convert permission feild to POSIX
    const raw_mode: u9 = @bitCast(my_file.permission);

    // we'll format the permissions string block
    var string_buffer: [10]u8 = undefined;
    const ls_format = my_file.permission.formatLs(&string_buffer);

    print("filesize: {} bytes\n", .{my_file.size});
    print("permissions in octal: 0o{0}\n", .{raw_mode});
    print("permissions string: {s}\n", .{ls_format});
}

fn printHelp() !void {
    print("HELP!", .{});
}
