const std = @import("std");

pub fn build(b: *std.Build) void {
    const target_val = b.standardTargetOptions(.{});
    const optimize_val = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "meta",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target_val,
            .optimize = optimize_val,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
