const std = @import("std");
const testing = std.testing;
const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const list = try read_file(allocator, "src/02/input.txt");

    defer cleanup_array([]i64, allocator, list);

    const result_part_1 = try solve_part_1(list);
    std.debug.print("Part 1: {}\n", .{result_part_1});

    const result_part_2 = try solve_part_2(list);
    std.debug.print("Part 2: {}\n", .{result_part_2});
}

pub fn read_file(allocator: Allocator, path: []const u8) ![][]i64 {
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

    var list = ArrayList(ArrayList(i64)).init(allocator);
    defer list.deinit();
    defer for (list.items) |inner_list| inner_list.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r");

        // Split the line by space
        var parts_iter = std.mem.split(u8, trimmed_line, " ");

        var inner_list = ArrayList(i64).init(allocator);

        while (parts_iter.next()) |part| {
            const value = std.fmt.parseInt(i64, part, 10) catch continue;
            try inner_list.append(value);
        }

        try list.append(inner_list);
    }

    const return_list = try allocator.alloc([]i64, list.items.len);

    for (0..list.items.len) |i| {
        const inner_list = list.items[i];
        var return_inner_list = try allocator.alloc(i64, inner_list.items.len);
        @memcpy(return_inner_list[0..], inner_list.items[0..]);
        return_list[i] = return_inner_list;
    }

    return return_list;
}

pub fn solve_part_1(list: [][]i64) !i64 {
    var result: i64 = 0;

    for (0..list.len) |i| {
        const arr = list[i];
        const should_increase = arr[1] > arr[0];
        var is_valid = true;

        for (0..arr.len - 1) |j| {
            var diff = arr[j + 1] - arr[j];
            if (!should_increase) {
                diff *= -1;
            }

            if (diff <= 0 or diff >= 4) {
                is_valid = false;
                break;
            }
        }

        if (is_valid) {
            result += 1;
        }
    }

    return result;
}

pub fn solve_part_2(list: [][]i64) !i64 {
    var result: i64 = 0;
    const allocator = std.heap.page_allocator;

    for (0..list.len) |i| {
        const arr = list[i];

        // Brute force all possible combinations
        for (0..arr.len) |j| {
            var new_arr = try allocator.alloc(i64, arr.len - 1);
            defer allocator.free(new_arr);
            var rindex: usize = 0;
            for (0..arr.len) |k| {
                if (k == j) {
                    continue;
                }

                new_arr[rindex] = arr[k];
                rindex += 1;
            }

            var in_list = [1][]i64{new_arr};
            const is_valid_part_1 = try solve_part_1(&in_list);
            if (is_valid_part_1 > 0) {
                result += 1;
                break;
            }
        }
    }

    return result;
}

test "solve" {
    const allocator = testing.allocator;
    const list = try read_file(allocator, "src/02/test_input.txt");

    defer cleanup_array([]i64, allocator, list);

    const result_part_1 = solve_part_1(list);

    try testing.expectEqual(2, result_part_1);

    const result_part_2 = solve_part_2(list);

    try testing.expectEqual(4, result_part_2);
}

fn cleanup_array(T: type, allocator: Allocator, array: []T) void {
    for (array) |item| {
        allocator.free(item);
    }
    allocator.free(array);
}
