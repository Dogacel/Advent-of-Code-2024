const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var lines_iter = try common.input_iter(allocator);
    defer allocator.free(lines_iter.buffer);

    var map = ArrayList([]const u8).init(allocator);
    defer map.deinit();

    var antinode_map = ArrayList([]u8).init(allocator);
    defer antinode_map.deinit();

    const point = struct { x: i32, y: i32 };
    var locations = std.AutoHashMap(u8, ArrayList(point)).init(allocator);
    defer locations.deinit();

    var out_y: usize = 0;

    while (lines_iter.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t\r\n");

        const new_line = try allocator.dupe(u8, line);
        try map.append(line);
        try antinode_map.append(new_line);

        for (line, 0..) |c, x| {
            if (c != '.') {
                const p = point{ .x = @intCast(x), .y = @intCast(out_y) };

                var array = locations.get(c) orelse ArrayList(point).init(allocator);

                try array.append(p);

                try locations.put(c, array);
            }
        }

        out_y += 1;
    }

    for (map.items, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == '.' or c == '#') {
                continue;
            }

            const antinodes = locations.get(c).?;

            for (antinodes.items) |antinode| {
                const xi64: i64 = @intCast(x);
                const yi64: i64 = @intCast(y);

                const x_dist: i64 = antinode.x - xi64;
                const y_dist: i64 = antinode.y - yi64;

                if (x_dist == 0 and y_dist == 0) {
                    continue;
                }

                // Part 1
                // const projection_1_x = xi64 - x_dist;
                // const projection_1_y = yi64 - y_dist;
                //
                // const max_x: i64 = @intCast(line.len);
                // const max_y: i64 = @intCast(map.items.len);
                //
                // if (projection_1_x >= 0 and projection_1_y >= 0 and projection_1_x < max_x and projection_1_y < max_y) {
                //     const xu: usize = @intCast(projection_1_x);
                //     const yu: usize = @intCast(projection_1_y);
                //
                //     antinode_map.items[yu][xu] = '#';
                // }

                // Part 2
                var projection_1_x = xi64;
                var projection_1_y = yi64;

                const max_x: i64 = @intCast(line.len);
                const max_y: i64 = @intCast(map.items.len);

                while (projection_1_x >= 0 and projection_1_y >= 0 and projection_1_x < max_x and projection_1_y < max_y) {
                    const xu: usize = @intCast(projection_1_x);
                    const yu: usize = @intCast(projection_1_y);

                    antinode_map.items[yu][xu] = '#';

                    projection_1_x -= x_dist;
                    projection_1_y -= y_dist;
                }
            }
        }
    }

    var count: u64 = 0;
    for (antinode_map.items) |line| {
        std.debug.print("{s}\n", .{line});
        for (line) |c| {
            if (c == '#') {
                count += 1;
            }
        }
    }

    std.debug.print("Count: {d}\n", .{count});
}
