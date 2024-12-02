const std = @import("std");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn read_file_array_of_array(T: type, allocator: Allocator, path: []const u8, delimeter: []const u8) ![][]T {
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
            const value = std.fmt.parseInt(T, part, 10) catch continue;
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
