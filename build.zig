const std = @import("std");

pub fn build(b: *std.Build) !void {
    const allocator = b.allocator;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var common_iter = (try std.fs.cwd().openDir(
        "./src/common",
        .{ .iterate = true },
    )).iterate();

    var common_modules = std.ArrayList(struct { mod: *std.Build.Module, name: []const u8 }).init(allocator);
    defer common_modules.deinit();

    while (try common_iter.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".zig")) {
            const file_path = try std.fs.path.join(allocator, &.{ "src/common", entry.name });
            const mod = b.createModule(.{ .root_source_file = b.path(file_path) });
            try common_modules.append(.{ .mod = mod, .name = entry.name[0 .. entry.name.len - 4] });
        }
    }

    var it = (try std.fs.cwd().openDir(
        "./src",
        .{ .iterate = true },
    )).iterate();

    const all_tests = b.step("all_tests", "Run all tests");

    while (try it.next()) |entry| {
        if (entry.kind == .directory and entry.name[0] != '.') {
            // Assuming each subfolder contains a `main.zig` file to be built
            const subfolder_path = try std.fs.path.join(allocator, &.{ "src", entry.name });

            // Construct the path to the `main.zig` file in the subfolder
            const source_file = try std.fs.path.join(allocator, &.{ subfolder_path, "main.zig" });

            // If main.zig doesn't exist, skip
            _ = std.fs.cwd().openFile(source_file, .{}) catch continue;

            const exe = b.addExecutable(.{
                .name = entry.name,
                .root_source_file = b.path(source_file),
                .target = target,
                .optimize = optimize,
            });

            for (common_modules.items) |common_mod| {
                exe.root_module.addImport(common_mod.name, common_mod.mod);
            }

            b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);

            run_cmd.step.dependOn(b.getInstallStep());

            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_name = try std.fmt.allocPrint(allocator, "run_{s}", .{entry.name});
            const run_description = try std.fmt.allocPrint(allocator, "Run the app for day {s}", .{entry.name});
            const run_step = b.step(run_name, run_description);
            run_step.dependOn(&run_cmd.step);

            const exe_unit_tests = b.addTest(.{
                .root_source_file = b.path(source_file),
                .target = target,
                .optimize = optimize,
            });

            const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

            const test_name = try std.fmt.allocPrint(allocator, "test_{s}", .{entry.name});
            const test_description = try std.fmt.allocPrint(allocator, "Run unit tests for day {s}", .{entry.name});
            const test_step = b.step(test_name, test_description);
            test_step.dependOn(&run_exe_unit_tests.step);

            all_tests.dependOn(test_step);
        }
    }
}
