const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var lines_iter = try common.input_iter(allocator);

    const Pair = struct { x: i64, y: i64 };

    var rules = std.AutoHashMap(Pair, void).init(allocator);
    defer rules.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r\n");

        // Split the content into lines
        var inner_iter = std.mem.tokenizeAny(
            u8,
            trimmed_line,
            " ,;|",
        );

        if (trimmed_line.len == 0) {
            break;
        }

        const xx = inner_iter.next() orelse "";
        const yy = inner_iter.next() orelse "";

        _ = try rules.getOrPut(Pair{ .x = common.parse_i64(xx), .y = common.parse_i64(yy) });
    }

    var result_1: i64 = 0;
    var result_2: i64 = 0;

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r\n");

        // Split the content into lines
        var inner_iter = std.mem.tokenizeAny(
            u8,
            trimmed_line,
            " ,;|",
        );

        var raw_list = ArrayList(i64).init(allocator);
        defer raw_list.deinit();

        while (inner_iter.next()) |item| {
            try raw_list.append(common.parse_i64(item));
        }

        // std.debug.print("Line: {s}\n", .{trimmed_line});

        var items = raw_list.items;
        var swaps: u32 = 0;

        for (0..items.len) |_| {
            for (0..items.len - 1) |i| {
                // Swap if the rule is present
                if (rules.contains(Pair{ .x = items[i + 1], .y = items[i] })) {
                    swaps += 1;
                    const temp = items[i];
                    items[i] = items[i + 1];
                    items[i + 1] = temp;
                }
            }
        }

        if (swaps == 0) {
            result_1 += items[items.len / 2];
        } else {
            result_2 += items[items.len / 2];
        }
    }

    std.debug.print("Result part 1: {}\n", .{result_1});
    std.debug.print("Result part 2: {}\n", .{result_2});
}
