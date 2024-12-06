const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var lines_iter = try common.input_iter(allocator);
    defer allocator.free(lines_iter.buffer);

    while (lines_iter.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t\r\n");

        // Split the content into lines
        var items_iter = std.mem.tokenizeAny(
            u8,
            line,
            " ,;|",
        );

        items_iter = items_iter;
    }
}
