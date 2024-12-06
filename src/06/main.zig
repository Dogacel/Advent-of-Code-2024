const std = @import("std");
const common = @import("common");

const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Direction = enum { Up, Right, Down, Left };
const Coordinate = struct { x: usize, y: usize };
const Position = struct { x: usize, y: usize, direction: Direction };

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var lines_iter = try common.input_iter(allocator);
    defer allocator.free(lines_iter.buffer);

    var map = ArrayList([]u8).init(allocator);

    while (lines_iter.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t\r\n");

        const mutable_line = try allocator.alloc(u8, line.len);
        @memcpy(mutable_line, line);
        try map.append(mutable_line);
    }

    var curr_pos = Position{ .x = 0, .y = 0, .direction = Direction.Right };

    for (0..map.items.len) |y| {
        const line = map.items[y];
        for (0..line.len) |x| {
            if (line[x] == '^') {
                curr_pos = Position{ .x = x, .y = y, .direction = Direction.Up };
                break;
            }
        }
    }

    const start_pos = curr_pos;
    var visited = std.AutoHashMap(Position, void).init(allocator);
    var looper_positions = std.AutoHashMap(Position, void).init(allocator);

    while (!visited.contains(curr_pos)) {
        // std.debug.print("[main] Curr: {}\n", .{curr_pos});

        try visited.put(curr_pos, void{});

        if (curr_pos.direction == Direction.Up) {
            if (curr_pos.y == 0) {
                break;
            }

            if (map.items[curr_pos.y - 1][curr_pos.x] == '#') {
                curr_pos.direction = Direction.Right;
            } else {
                curr_pos.y -= 1;
                map.items[curr_pos.y][curr_pos.x] = '#';
                if (has_loop(allocator, start_pos, &map)) {
                    try looper_positions.put(curr_pos, {});
                }
                map.items[curr_pos.y][curr_pos.x] = '.';
            }
        } else if (curr_pos.direction == Direction.Right) {
            if (curr_pos.x == map.items[curr_pos.y].len - 1) {
                break;
            }

            if (map.items[curr_pos.y][curr_pos.x + 1] == '#') {
                curr_pos.direction = Direction.Down;
            } else {
                curr_pos.x += 1;

                map.items[curr_pos.y][curr_pos.x] = '#';
                if (has_loop(allocator, start_pos, &map)) {
                    try looper_positions.put(curr_pos, {});
                }
                map.items[curr_pos.y][curr_pos.x] = '.';
            }
        } else if (curr_pos.direction == Direction.Down) {
            if (curr_pos.y == map.items.len - 1) {
                break;
            }

            if (map.items[curr_pos.y + 1][curr_pos.x] == '#') {
                curr_pos.direction = Direction.Left;
            } else {
                curr_pos.y += 1;

                map.items[curr_pos.y][curr_pos.x] = '#';
                if (has_loop(allocator, start_pos, &map)) {
                    try looper_positions.put(curr_pos, {});
                }
                map.items[curr_pos.y][curr_pos.x] = '.';
            }
        } else if (curr_pos.direction == Direction.Left) {
            if (curr_pos.x == 0) {
                break;
            }

            if (map.items[curr_pos.y][curr_pos.x - 1] == '#') {
                curr_pos.direction = Direction.Up;
            } else {
                curr_pos.x -= 1;

                map.items[curr_pos.y][curr_pos.x] = '#';
                if (has_loop(allocator, start_pos, &map)) {
                    try looper_positions.put(curr_pos, {});
                }
                map.items[curr_pos.y][curr_pos.x] = '.';
            }
        }
    }

    var no_direction_visited = std.AutoHashMap(Position, void).init(allocator);
    var key_iter = visited.keyIterator();
    while (key_iter.next()) |item| {
        // std.debug.print("Visiting: {}\n", .{item});
        try no_direction_visited.put(Position{ .x = item.x, .y = item.y, .direction = .Up }, {});
    }

    std.debug.print("Result 1: {d}\n", .{no_direction_visited.count()});

    var no_looper_pos = std.AutoHashMap(Position, void).init(allocator);
    var no_looper_key_iter = looper_positions.keyIterator();
    while (no_looper_key_iter.next()) |item| {
        // std.debug.print("Looper pos: {}\n", .{item});
        if (item.*.x != start_pos.x or item.*.y != start_pos.y) {
            try no_looper_pos.put(Position{ .x = item.x, .y = item.y, .direction = .Up }, {});
        }
    }

    std.debug.print("Result 2: {d}\n", .{no_looper_pos.count()});
}

fn has_loop(allocator: Allocator, _curr_pos: Position, map: *ArrayList([]u8)) bool {
    var visited = std.AutoHashMap(Position, void).init(allocator);
    var curr_pos = _curr_pos;

    while (!visited.contains(curr_pos)) {
        // std.debug.print("[has_loop] Curr: {}\n", .{curr_pos});

        visited.put(curr_pos, void{}) catch return false;

        if (curr_pos.direction == Direction.Up) {
            if (curr_pos.y == 0) {
                return false;
            }

            if (map.items[curr_pos.y - 1][curr_pos.x] == '#') {
                curr_pos.direction = Direction.Right;
            } else {
                curr_pos.y -= 1;
            }
        } else if (curr_pos.direction == Direction.Right) {
            if (curr_pos.x == map.items[curr_pos.y].len - 1) {
                return false;
            }

            if (map.items[curr_pos.y][curr_pos.x + 1] == '#') {
                curr_pos.direction = Direction.Down;
            } else {
                curr_pos.x += 1;
            }
        } else if (curr_pos.direction == Direction.Down) {
            if (curr_pos.y == map.items.len - 1) {
                return false;
            }

            if (map.items[curr_pos.y + 1][curr_pos.x] == '#') {
                curr_pos.direction = Direction.Left;
            } else {
                curr_pos.y += 1;
            }
        } else if (curr_pos.direction == Direction.Left) {
            if (curr_pos.x == 0) {
                return false;
            }

            if (map.items[curr_pos.y][curr_pos.x - 1] == '#') {
                curr_pos.direction = Direction.Up;
            } else {
                curr_pos.x -= 1;
            }
        }
    }

    return true;
}
