const std = @import("std");
const common = @import("common");

const testing = std.testing;
const math = std.math;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var content = try common.read_str(allocator, "src/03/input.txt");
    defer allocator.free(content);

    var result: i64 = 0;
    var enabled = true;

    for (0..content.len) |i| {
        if (i + 4 < content.len) {
            if (std.mem.eql(u8, content[i .. i + 4], "do()")) {
                enabled = true;
            }
        }

        if (i + 7 < content.len) {
            if (std.mem.eql(u8, content[i .. i + 7], "don't()")) {
                enabled = false;
            }
        }

        if (i + 3 < content.len and enabled) {
            // mul(
            if (std.mem.eql(u8, content[i .. i + 4], "mul(")) {
                std.debug.print("Found mul at {}\n", .{i});
                // first number
                var j = i + 4;
                while (j < content.len) {
                    if (content[j] < '0' or content[j] > '9') {
                        break;
                    }
                    j += 1;
                }

                std.debug.print("First number: {s}\n", .{content[i + 4 .. j]});

                if (j == content.len or content[j] != ',') {
                    continue;
                }

                const first = common.parse_i64(content[i + 4 .. j]);

                var k = j + 1;

                while (k < content.len) {
                    if (content[k] < '0' or content[k] > '9') {
                        break;
                    }
                    k += 1;
                }

                std.debug.print("Second number: {s}\n", .{content[j + 1 .. k]});

                if (k == content.len or content[k] != ')') {
                    continue;
                }

                const second = common.parse_i64(content[j + 1 .. k]);

                result += first * second;
            }
        }
    }

    std.debug.print("Result: {}\n", .{result});
}
