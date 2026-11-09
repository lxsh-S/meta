const std = @import("std");

const print = std.debug.print;

// defining the layout of permission bits
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

    // Return the fromatted 10byte buffer
    pub fn formatLs(self: UnixPermissions, buf: *[10]u8) []const u8 {
        buf[0] = '.'; //default file flag (use 'd' for dir)
        buf[1] = if (self.owner_read) 'r' else '-';
        buf[2] = if (self.owner_write) 'w' else '-';
        buf[3] = if (self.owner_execute) 'x' else '-';
        buf[4] = if (self.group_read) 'r' else '-';
        buf[5] = if (self.group_write) 'w' else '-';
        buf[6] = if (self.group_execute) 'x' else '-';
        buf[7] = if (self.other_read) 'r' else '-';
        buf[8] = if (self.other_write) 'w' else '-';
        buf[9] = if (self.owner_execute) 'x' else '-';

        return buf;
    }
};
