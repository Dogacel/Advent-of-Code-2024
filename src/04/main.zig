const std = @import("std");
const common = @import("common");

const testing = std.testing;
const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var args = std.process.args();
    _ = args.skip();

    const x = args.next() orelse "";

    const path = if (std.mem.eql(u8, x, "test"))
        "src/04/test_input.txt"
    else
        "src/04/input.txt";

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

    var list = ArrayList([]const u8).init(allocator);
    defer list.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r");

        try list.append(trimmed_line);
    }

    var result: i64 = 0;
    result = result;

    var result2: i64 = 0;

    const listx = list.items;
    const h = listx.len;
    const l = listx[0].len;

    for (0..l) |i| {
        for (0..h) |j| {
            // l -> r
            if (i + 4 <= l) {
                if (std.mem.eql(u8, listx[j][i .. i + 4], "XMAS")) {
                    result += 1;
                }

                if (std.mem.eql(u8, listx[j][i .. i + 4], "SAMX")) {
                    result += 1;
                }
            }

            if (j + 4 <= h) {
                if (listx[j][i] == 'X' and listx[j + 1][i] == 'M' and listx[j + 2][i] == 'A' and listx[j + 3][i] == 'S') {
                    result += 1;
                }

                if (listx[j][i] == 'S' and listx[j + 1][i] == 'A' and listx[j + 2][i] == 'M' and listx[j + 3][i] == 'X') {
                    result += 1;
                }
            }

            if (i + 4 <= l and j + 4 <= h) {
                if (listx[j][i] == 'X' and listx[j + 1][i + 1] == 'M' and listx[j + 2][i + 2] == 'A' and listx[j + 3][i + 3] == 'S') {
                    result += 1;
                }

                if (listx[j][i] == 'S' and listx[j + 1][i + 1] == 'A' and listx[j + 2][i + 2] == 'M' and listx[j + 3][i + 3] == 'X') {
                    result += 1;
                }

                if (listx[j][i + 3] == 'X' and listx[j + 1][i + 2] == 'M' and listx[j + 2][i + 1] == 'A' and listx[j + 3][i] == 'S') {
                    result += 1;
                }

                if (listx[j][i + 3] == 'S' and listx[j + 1][i + 2] == 'A' and listx[j + 2][i + 1] == 'M' and listx[j + 3][i] == 'X') {
                    result += 1;
                }
            }

            if (i + 3 <= l and j + 3 <= h) {
                if (listx[j][i] == 'M' and listx[j + 1][i + 1] == 'A' and listx[j + 2][i + 2] == 'S' and listx[j + 2][i] == 'M' and listx[j + 1][i + 1] == 'A' and listx[j][i + 2] == 'S') {
                    result2 += 1;
                }

                if (listx[j][i] == 'S' and listx[j + 1][i + 1] == 'A' and listx[j + 2][i + 2] == 'M' and listx[j + 2][i] == 'M' and listx[j + 1][i + 1] == 'A' and listx[j][i + 2] == 'S') {
                    result2 += 1;
                }

                if (listx[j][i] == 'M' and listx[j + 1][i + 1] == 'A' and listx[j + 2][i + 2] == 'S' and listx[j + 2][i] == 'S' and listx[j + 1][i + 1] == 'A' and listx[j][i + 2] == 'M') {
                    result2 += 1;
                }

                if (listx[j][i] == 'S' and listx[j + 1][i + 1] == 'A' and listx[j + 2][i + 2] == 'M' and listx[j + 2][i] == 'S' and listx[j + 1][i + 1] == 'A' and listx[j][i + 2] == 'M') {
                    result2 += 1;
                }
            }
        }
    }

    std.debug.print("Result: {}\n", .{result});
    std.debug.print("Result2: {}\n", .{result2});
}
