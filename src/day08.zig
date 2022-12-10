const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
// const data = @embedFile("data/day08_sample.txt");
const dataT = transpose(data);

fn transpose(comptime in: []const u8) [in.len]u8 {
    @setEvalBranchQuota(100000);
    var result: [in.len]u8 = undefined;
    const line_len = std.mem.sliceTo(in, '\n').len;

    for (in) |c, i| {
        if (c == '\n') {
            result[i] = c;
        } else {
            const row = @divTrunc(i, line_len + 1);
            const col = i % (line_len + 1);
            result[col * (line_len + 1) + row] = c;
        }
    }

    return result;
}

fn reverse(comptime in: []const u8) [in.len]u8 {
    @setEvalBranchQuota(100000);
    var result: [in.len]u8 = undefined;

    var i: usize = 0;
    while (i < in.len) : (i += 1) {
        result[0] = in[in.len - 1 - i];
    }

    return result;
}

test "transpose" {
    const in =
        \\30373
        \\25512
        \\65332
        \\33549
        \\35390
        \\
    ;

    const inT = transpose(in);
    const a =
        \\32633
        \\05535
        \\35353
        \\71349
        \\32290
        \\
    ;

    try std.testing.expectEqualStrings(a, &inT);
}

fn getBitsetSize() usize {
    @setEvalBranchQuota(100000);
    const num_lines = std.mem.count(u8, data, "\n");
    const line_len = std.mem.sliceTo(data, '\n').len;

    return num_lines * line_len;
}

const Dir = enum {
    forward,
    backward,
};

const size = getBitsetSize();
fn getVisibleSet(in: []const u8, dir: Dir, tpose: bool) std.StaticBitSet(size) {
    var result = std.StaticBitSet(size).initEmpty();
    var lines = std.mem.tokenize(u8, in, "\n");

    var line_num: usize = 0;
    while (lines.next()) |line| : (line_num += 1) {
        var i: i32 = if (dir == .forward) 0 else @intCast(i32, line.len) - 1;
        var inc: i32 = if (dir == .forward) 1 else -1;
        var tallest: i32 = -1;

        // print("{s} ->", .{line});
        while (i >= 0 and i < line.len) : (i += inc) {
            const ui = @intCast(usize, i);
            const c = line[ui];
            const height = parseInt(i32, &.{c}, 10) catch unreachable;
            if (height > tallest) {
                if (!tpose)
                    result.set(line_num * line.len + ui)
                else
                    result.set(ui * line.len + line_num);

                tallest = height;
                // print("{c}, ", .{c});
            }
        }
        // print("\n", .{});
    }

    return result;
}

fn score(in: []const u8, inT: []const u8, row: usize, col: usize) usize {
    const len = std.mem.sliceTo(in, '\n').len;
    const t = row * (len + 1) + col;
    const tT = col * (len + 1) + row;

    if (row == 0 or row == len - 1) return 0;
    if (col == 0 or col == len - 1) return 0;

    print("row {} {}\n", .{ row, col });

    const east = std.mem.sliceTo(in[t..], '\n')[1..];
    const west = in[(std.mem.lastIndexOf(u8, in[0..t], "\n") orelse std.math.maxInt(usize)) +% 1 .. t];

    const south = std.mem.sliceTo(inT[tT..], '\n')[1..];
    const north = inT[(std.mem.lastIndexOf(u8, inT[0..tT], "\n") orelse std.math.maxInt(usize)) +% 1 .. tT];

    var scr: usize = 1;

    const this_height = parseInt(usize, &.{in[t]}, 10) catch unreachable;

    inline for (.{ east, west, south, north }) |line, i| {
        print("line {s}\n", .{line});
        var line_count: usize = 0;
        var j: i32 = if (i % 2 == 0) 1 else -1;
        var k: i32 = if (i % 2 == 0) 0 else @intCast(i32, line.len) - 1;

        while (k >= 0 and k < line.len) : (k += j) {
            const c = line[@intCast(usize, k)];
            const height = parseInt(usize, &.{c}, 10) catch unreachable;
            print("{} ", .{height});
            line_count += 1;
            if (height >= this_height) {
                break;
            }
        }
        print("\n", .{});

        scr *= line_count;
    }

    return scr;
}

pub fn main() !void {
    // bit is true if the tree can be seen
    var looking_north = getVisibleSet(&dataT, .backward, true);
    var looking_south = getVisibleSet(&dataT, .forward, true);
    var looking_east = getVisibleSet(data, .forward, false);
    var looking_west = getVisibleSet(data, .backward, false);

    looking_east.setUnion(looking_west);
    looking_east.setUnion(looking_north);
    looking_east.setUnion(looking_south);

    var prettiest: usize = 0;
    const line_len = std.mem.sliceTo(data, '\n').len;

    for (data) |c, i| {
        if (c == '\n') continue;
        const row = @divTrunc(i, line_len + 1);
        const col = i % (line_len + 1);

        const pretty = score(data, &dataT, row, col);
        if (pretty > prettiest)
            prettiest = pretty;
    }

    print("part1: {}, part2: {}\n", .{ looking_east.count(), prettiest });
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
