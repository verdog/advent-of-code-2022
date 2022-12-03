const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

fn itemToIdx(item: u8) usize {
    if (item <= 'Z') {
        return item - 'A' + 26 + 1;
    } else {
        return item - 'a' + 1;
    }
}

test "itemToIdx" {
    try std.testing.expectEqual(itemToIdx('a'), 1);
    try std.testing.expectEqual(itemToIdx('z'), 26);
    try std.testing.expectEqual(itemToIdx('A'), 27);
    try std.testing.expectEqual(itemToIdx('Z'), 52);
}

pub fn main() !void {
    var line_i = std.mem.tokenize(u8, data, "\n");

    var sum: usize = 0;
    var sum2: usize = 0;

    var mod: usize = 0;

    const f: u8 = 0;
    var items_buf: [3]@Vector(52, u8) = .{
        @splat(52, f),
        @splat(52, f),
        @splat(52, f),
    };

    while (line_i.next()) |line| : (mod +%= 1) {
        const first = line[0 .. line.len / 2];
        const second = line[line.len / 2 ..];

        // order a-z, A-Z
        var items = &items_buf[mod % 3];
        items.* = @splat(52, f);

        print("{} {} {s} | {s} -> ", .{ mod, mod % 3, first, second });

        // populate first
        for (first) |item| {
            items.*[itemToIdx(item) - 1] = 255;
        }

        // check second
        for (second) |item| {
            const priority = itemToIdx(item);
            if (items.*[priority - 1] == 255) {
                sum += priority;
                print("{c} ({})\n", .{ item, priority });
                break;
            }
        }

        // populate second
        for (second) |item| {
            items.*[itemToIdx(item) - 1] = 255;
        }

        if (mod % 3 == 2) {
            // crunch part two
            const common = items_buf[0] & items_buf[1] & items_buf[2];
            const letters: @Vector(52, u8) = .{
                @intCast(u8, itemToIdx('a')),
                @intCast(u8, itemToIdx('b')),
                @intCast(u8, itemToIdx('c')),
                @intCast(u8, itemToIdx('d')),
                @intCast(u8, itemToIdx('e')),
                @intCast(u8, itemToIdx('f')),
                @intCast(u8, itemToIdx('g')),
                @intCast(u8, itemToIdx('h')),
                @intCast(u8, itemToIdx('i')),
                @intCast(u8, itemToIdx('j')),
                @intCast(u8, itemToIdx('k')),
                @intCast(u8, itemToIdx('l')),
                @intCast(u8, itemToIdx('m')),
                @intCast(u8, itemToIdx('n')),
                @intCast(u8, itemToIdx('o')),
                @intCast(u8, itemToIdx('p')),
                @intCast(u8, itemToIdx('q')),
                @intCast(u8, itemToIdx('r')),
                @intCast(u8, itemToIdx('s')),
                @intCast(u8, itemToIdx('t')),
                @intCast(u8, itemToIdx('u')),
                @intCast(u8, itemToIdx('v')),
                @intCast(u8, itemToIdx('w')),
                @intCast(u8, itemToIdx('x')),
                @intCast(u8, itemToIdx('y')),
                @intCast(u8, itemToIdx('z')),
                @intCast(u8, itemToIdx('A')),
                @intCast(u8, itemToIdx('B')),
                @intCast(u8, itemToIdx('C')),
                @intCast(u8, itemToIdx('D')),
                @intCast(u8, itemToIdx('E')),
                @intCast(u8, itemToIdx('F')),
                @intCast(u8, itemToIdx('G')),
                @intCast(u8, itemToIdx('H')),
                @intCast(u8, itemToIdx('I')),
                @intCast(u8, itemToIdx('J')),
                @intCast(u8, itemToIdx('K')),
                @intCast(u8, itemToIdx('L')),
                @intCast(u8, itemToIdx('M')),
                @intCast(u8, itemToIdx('N')),
                @intCast(u8, itemToIdx('O')),
                @intCast(u8, itemToIdx('P')),
                @intCast(u8, itemToIdx('Q')),
                @intCast(u8, itemToIdx('R')),
                @intCast(u8, itemToIdx('S')),
                @intCast(u8, itemToIdx('T')),
                @intCast(u8, itemToIdx('U')),
                @intCast(u8, itemToIdx('V')),
                @intCast(u8, itemToIdx('W')),
                @intCast(u8, itemToIdx('X')),
                @intCast(u8, itemToIdx('Y')),
                @intCast(u8, itemToIdx('Z')),
            };
            const common_item = @reduce(.Max, common & letters);
            sum2 += common_item;
            print("-> {}\n", .{common_item});
        }
    }

    print("part1: {}, part2: {}\n", .{ sum, sum2 });
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOfScalar = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfPosLinear = std.mem.indexOfPosLinear;
const lastIndexOfScalar = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfLinear = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
