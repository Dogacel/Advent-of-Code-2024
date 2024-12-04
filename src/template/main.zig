const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var args = std.process.args();
    _ = args.skip();

    const x = args.next() orelse "";
    const curr = "00";

    const path = if (std.mem.eql(u8, x, "test"))
        "src/" ++ curr ++ "/test_input.txt"
    else
        "src/" ++ curr ++ "/input.txt";

    // Open the file
    const fs = std.fs.cwd();
    const file = try fs.openFile(path, .{ .mode = .read_only });
    defer file.close();

    // Read the entire file content into a buffer
    var content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    // Convert content to a slice of u8
    const content_str = content[0 .. content.len - 1];

    // Split the content into lines
    var lines_iter = std.mem.split(
        u8,
        content_str,
        "\n",
    );

    var raw_list = ArrayList([]const u8).init(allocator);
    defer raw_list.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r");

        try raw_list.append(trimmed_line);
    }

    var result: i64 = 0;
    result = result;

    const list = raw_list.items;
    _ = list;

    std.debug.print("Result: {}\n", .{result});
}
