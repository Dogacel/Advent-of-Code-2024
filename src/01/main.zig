const std = @import("std");
const testing = std.testing;
const math = std.math;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    // Open the file
    const fs = std.fs.cwd();
    const file = try fs.openFile("src/01/input.txt", .{ .mode = .read_only });
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

    var list = ArrayList(struct { first: i64, second: i64 }).init(allocator);
    defer list.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r");

        // Split the line by space
        var parts_iter = std.mem.split(u8, trimmed_line, "   ");

        const first_str = parts_iter.next().?;
        const second_str = parts_iter.next().?;

        // Convert strings to integers
        const first = try std.fmt.parseInt(i64, first_str, 10);
        const second = try std.fmt.parseInt(i64, second_str, 10);

        try list.append(.{ .first = first, .second = second });
    }

    var list_1 = try ArrayList(i64).initCapacity(allocator, list.items.len);
    defer list_1.deinit();

    var list_2 = try ArrayList(i64).initCapacity(allocator, list.items.len);
    defer list_2.deinit();

    for (list.items) |it| {
        try list_1.append(it.first);
        try list_2.append(it.second);
    }

    const result_part_1 = solve_part_1(list_1.items, list_2.items);

    std.debug.print("Part 1 result: {}\n", .{result_part_1});

    const result_part_2 = solve_part_2(list_1.items, list_2.items);

    std.debug.print("Part 2 result: {}\n", .{result_part_2});
}

pub fn solve_part_1(list_1: []i64, list_2: []i64) i64 {
    std.mem.sort(i64, list_1, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, list_2, {}, comptime std.sort.asc(i64));

    var result: i64 = 0;
    for (0..list_1.len) |i| {
        result += @intCast(@abs(list_1[i] - list_2[i]));
    }

    return result;
}

pub fn solve_part_2(list_1: []i64, list_2: []i64) i64 {
    std.mem.sort(i64, list_1, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, list_2, {}, comptime std.sort.asc(i64));

    var result: i64 = 0;
    var l_iter: usize = 0;
    var r_iter: usize = 0;

    while (l_iter < list_1.len) {
        var r_count: i64 = 0;
        while (r_iter < list_2.len and list_2[r_iter] <= list_1[l_iter]) {
            if (list_2[r_iter] == list_1[l_iter]) {
                r_count += 1;
            }
            r_iter += 1;
        }

        const curr = list_1[l_iter];
        while (l_iter < list_1.len and list_1[l_iter] == curr) {
            result += list_1[l_iter] * r_count;
            l_iter += 1;
        }
    }

    return result;
}

test "solve" {
    var list_1 = [_]i64{ 3, 4, 2, 1, 3, 3 };
    var list_2 = [_]i64{ 4, 3, 5, 3, 9, 3 };

    const result_part_1 = solve_part_1(list_1[0..], list_2[0..]);

    try testing.expectEqual(11, result_part_1);

    const result_part_2 = solve_part_2(list_1[0..], list_2[0..]);

    try testing.expectEqual(31, result_part_2);
}
