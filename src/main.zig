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

    // will return in formatted 10byte buffer
    pub fn formatLs(self: UnixPermissions, buf: *[10]u8) []const u8 {
        buf[0] = '.'; // default file flag, we'll use 'd' for directory
        buf[1] = if (self.owner_read) 'r' else '-';
        buf[2] = if (self.owner_write) 'w' else '-';
        buf[3] = if (self.owner_execute) 'x' else '-';
        buf[4] = if (self.group_read) 'r' else '-';
        buf[5] = if (self.group_write) 'w' else '-';
        buf[6] = if (self.group_execute) 'x' else '-';
        buf[7] = if (self.other_read) 'r' else '-';
        buf[8] = if (self.other_write) 'w' else '-';
        buf[9] = if (self.other_execute) 'x' else '-';
        return buf;
    }
};

// our file struct
pub const File = struct { size: u8, permission: UnixPermissions };

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
