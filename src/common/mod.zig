const std = @import("std");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn read_2d_i64_array(T: type, allocator: Allocator, path: []const u8, delimeter: []const u8) ![][]T {
    return read_2d_array(T, allocator, path, delimeter, parse_i64);
}

pub fn read_2d_str_array(T: type, allocator: Allocator, path: []const u8, delimeter: []const u8) ![][]T {
    return read_2d_array(T, allocator, path, delimeter, parse_str);
}

pub fn read_str(allocator: Allocator, path: []const u8) ![]u8 {
    const fs = std.fs.cwd();
    const file = try fs.openFile(path, .{ .mode = .read_only });
    defer file.close();

    return try file.readToEndAlloc(allocator, std.math.maxInt(usize));
}

pub fn input_iter(allocator: Allocator) !std.mem.SplitIterator(u8, .sequence) {
    var args = std.process.args();
    defer args.deinit();

    _ = args.skip();

    const input_file = args.next() orelse "";

    const path = try std.fmt.allocPrint(allocator, "src/{s}.txt", .{input_file});
    defer allocator.free(path);

    // Open the file
    const fs = std.fs.cwd();
    const file = try fs.openFile(path, .{ .mode = .read_only });
    defer file.close();

    // Read the entire file content into a buffer
    var content = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    // Convert content to a slice of u8
    const content_str = content[0 .. content.len - 1];

    // Split the content into lines
    const lines_iter = std.mem.splitSequence(
        u8,
        content_str,
        "\n",
    );

    return lines_iter;
}

pub fn read_2d_array(T: type, allocator: Allocator, path: []const u8, delimeter: []const u8, parser: fn (in: []const u8) T) ![][]T {
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

    var list = ArrayList(ArrayList(T)).init(allocator);
    defer list.deinit();
    defer for (list.items) |inner_list| inner_list.deinit();

    while (lines_iter.next()) |line| {
        // Trim the line to remove any extra whitespace
        const trimmed_line = std.mem.trim(u8, line, " \t\r");

        // Split the line by space
        var parts_iter = std.mem.split(u8, trimmed_line, delimeter);

        var inner_list = ArrayList(T).init(allocator);

        while (parts_iter.next()) |part| {
            const value = parser(part);
            try inner_list.append(value);
        }

        try list.append(inner_list);
    }

    const return_list = try allocator.alloc([]T, list.items.len);

    for (0..list.items.len) |i| {
        const inner_list = list.items[i];
        var return_inner_list = try allocator.alloc(T, inner_list.items.len);
        @memcpy(return_inner_list[0..], inner_list.items[0..]);
        return_list[i] = return_inner_list;
    }

    return return_list;
}

pub fn read_1d_array(T: type, allocator: Allocator, path: []const u8, parser: fn (in: []const u8) T) ![]T {
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

    var list = ArrayList(T).init(allocator);
    defer list.deinit();

    while (lines_iter.next()) |line| {
        try list.append(parser(line));
    }

    return try list.toOwnedSlice();
}

pub fn parse_i64(in: []const u8) i64 {
    return std.fmt.parseInt(i64, in, 10) catch -1;
}

pub fn parse_str(in: []const u8) []const u8 {
    return in;
}

pub fn cleanup_array(T: type, allocator: Allocator, array: []T) void {
    for (array) |item| {
        allocator.free(item);
    }
    allocator.free(array);
}
