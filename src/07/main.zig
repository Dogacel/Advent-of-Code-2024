const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines_iter = try common.input_iter(allocator);
    defer allocator.free(lines_iter.buffer);

    var result_1: u64 = 0;
    var result_2: u64 = 0;

    while (lines_iter.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t\r\n");

        // Split the content into lines
        var items_iter = std.mem.tokenizeAny(
            u8,
            line,
            " ,;|:",
        );

        var items = ArrayList(u64).init(allocator);
        const expected = common.parse_i64(items_iter.next() orelse unreachable);

        while (items_iter.next()) |item| {
            const value = common.parse_i64(item);
            try items.append(@intCast(value));
        }

        const posses = std.math.pow(u64, 2, items.items.len);

        for (0..posses) |i| {
            var sum: u64 = 0;
            for (0..items.items.len) |j| {
                if (i & std.math.pow(u64, 2, j) != 0) {
                    sum += items.items[j];
                } else {
                    sum *= items.items[j];
                }
            }

            // std.debug.print("{b} Sum: {d}\n", .{ i, sum });

            if (sum == expected) {
                // std.debug.print("Found: {d}\n", .{sum});
                result_1 += sum;
                break;
            }
        }

        std.debug.print("Expected: {d}\n", .{expected});

        const posses3 = std.math.pow(u64, 3, items.items.len);

        for (0..posses3) |i| {
            var sum: u64 = 0;
            for (0..items.items.len) |j| {
                const id = i / std.math.pow(u64, 3, j) % 3;

                if (id == 0) {
                    sum += items.items[j];
                } else if (id == 1) {
                    sum *= items.items[j];
                } else {
                    const padding = digits(items.items[j]);
                    defer allocator.free(padding);
                    // std.debug.print("{d} Padding: {d}\n", .{ items.items[j], padding.len });

                    sum *= std.math.pow(u64, 10, padding.len);
                    sum += items.items[j];
                }

                if (sum > expected) {
                    break;
                }
            }

            // std.debug.print("{s} Sum: {d} \n", .{ toBase3(i), sum });

            if (sum == expected) {
                // std.debug.print("Found: {d}\n", .{sum});
                result_2 += @intCast(expected);
                break;
            }
        }
    }

    std.debug.print("Result 1 = {d}\n", .{result_1});
    std.debug.print("Result 2 = {d}\n", .{result_2});
}

pub fn toBase3(value: u64) []u8 {
    var buffer: [64]u8 = undefined; // Enough space for large base 3 numbers
    var index: usize = buffer.len;

    var num = value;
    while (num != 0) {
        index -= 1;
        buffer[index] = @intCast('0' + (num % 3));
        num /= 3;
    }

    return buffer[index..];
}

pub fn digits(value: u64) u64 {
    inline for (0..64) |i| {
        if (value < std.math.pow(u64, 10, i)) {
            return i;
        }
    }

    return -1;
}
