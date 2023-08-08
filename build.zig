const std = @import("std");
const mem = std.mem;

const exe_cflags = [_][]const u8{ "-fno-rtti", "-Werror=type-limits", "-Wno-missing-braces", "-Wno-comment", "-g" };

const c_source = "src/main.zig";

fn addCrossExecutable(alloc: mem.Allocator, b: *std.build.Builder, arch_os_abi: []const u8, comptime main_binary: bool) !void {
    const binary_name = try std.fmt.allocPrint(alloc, "crash.{s}", .{arch_os_abi});
    defer alloc.free(binary_name);
    const target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = arch_os_abi });

    const exe = b.addExecutable(.{
        .name = binary_name,
        .root_source_file = .{ .path = c_source },
        .target = target,
        .optimize = .Debug,
    });
    exe.linkLibC();

    if (main_binary) {
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    b.installArtifact(exe);
}

const targets = [_][]const u8{ "arm-linux-musleabihf", "x86_64-linux-musl" };

pub fn build(b: *std.build.Builder) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    try addCrossExecutable(alloc, b, "native", true);
    for (targets) |target| {
        try addCrossExecutable(alloc, b, target, false);
    }
}
