const std = @import("std");
const help = @import("help.zig");
const print = std.debug.print;

// cli struct
pub const Cli = struct {
    filename: ?[]const u8 = null,
    verbose: bool = false,
};

pub const cliError = error{
    Help,
    UnknownFileName,
    MissingFileName,
    UnknownFlag,
    TooManyArgs,
};

pub fn parseArgs(args: []const [:0]const u8) !Cli {
    var config = Cli{};

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "-h")) {
            help.printHelp();
            return cliError.Help;
        } else if (std.mem.eql(u8, arg, "-v")) {
            config.verbose = true;
        } else if (arg[0] == '-') {
            print("error: unknown flag", .{});
            help.printHelp();
            return cliError.UnknownFlag;
        } else {
            if (config.filename != null) {
                print("error: unexpected arguments '{s}'\n", .{arg});
                return cliError.TooManyArgs;
            }
            config.filename = arg;
        }
    }

    // ensuring that a filename was provided
    if (config.filename == null) {
        help.printHelp();
        return cliError.MissingFileName;
    }
    return config;
}
