const std = @import("std");
const mem = std.mem;

const exe_cflags = [_][]const u8{ "-fno-rtti", "-Werror=type-limits", "-Wno-missing-braces", "-Wno-comment", "-g" };

const c_source = "src/main.c";

fn addCrossExecutable(alloc: mem.Allocator, b: *std.build.Builder, arch_os_abi: []const u8, comptime main_binary: bool) !void {
    const binary_name = try std.fmt.allocPrint(alloc, "crash.{s}", .{arch_os_abi});
    defer alloc.free(binary_name);
    const target = try std.zig.CrossTarget.parse(.{ .arch_os_abi = arch_os_abi });

    const exe = b.addExecutable(binary_name, c_source);
    exe.linkLibC();
    exe.setTarget(target);
    exe.setBuildMode(std.builtin.Mode.Debug);

    if (main_binary) {
        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    exe.install();
}

const targets = [_][]const u8{"arm-linux-musleabihf", "x86_64-linux-musl"};

pub fn build(b: *std.build.Builder) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const alloc = arena.allocator();

    try addCrossExecutable(alloc, b, "native", true);
    for (targets) |target| {
        try addCrossExecutable(alloc, b, target, false);
    }
}
