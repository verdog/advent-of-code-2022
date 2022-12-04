const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");
// const data = @embedFile("data/day04_sample.txt");

const Pair = struct {
    low: usize,
    high: usize,
    len: usize,
};

fn parseGroup(pair: []const u8) !Pair {
    var nums = tokenize(u8, pair, "-");
    const low = try parseInt(usize, nums.next().?, 10);
    const high = try parseInt(usize, nums.next().?, 10);
    const len = high - low + 1;
    return .{ .high = high, .low = low, .len = len };
}

pub fn main() !void {
    var lines = tokenize(u8, data, "\n");

    var sum1: usize = 0;
    var sum2: usize = 0;

    while (lines.next()) |line| {
        var groups = tokenize(u8, line, ",");

        const left = groups.next().?;
        const right = groups.next().?;

        var left_pair = try parseGroup(left);
        var right_pair = try parseGroup(right);

        { // complete overlap
            var short_pair = &left_pair;
            var long_pair = &right_pair;

            if (long_pair.len < short_pair.len) {
                std.mem.swap(Pair, short_pair, long_pair);
            }

            if (short_pair.low >= long_pair.low and short_pair.high <= long_pair.high) {
                sum1 += 1;
            }
        }

        { // partial overlap
            var low_pair = &left_pair;
            var high_pair = &right_pair;

            if (low_pair.low > high_pair.low) {
                std.mem.swap(Pair, low_pair, high_pair);
            }

            if (low_pair.low + low_pair.len > high_pair.low) {
                sum2 += 1;
            }
        }
    }

    print("part1: {}, part2: {}\n", .{ sum1, sum2 });
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
