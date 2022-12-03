const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

fn competeP1(mine: u8, theirs: u8) usize {
    switch (mine) {
        // rock
        'X' => return switch (theirs) {
            // rock
            'A' => 4, // rock + tie
            // paper
            'B' => 1, // rock + loss
            // scissors
            'C' => 7, // rock + win
            else => unreachable,
        },
        // paper
        'Y' => return switch (theirs) {
            // rock
            'A' => 8, // paper + win
            // paper
            'B' => 5, // paper + tie
            // scissors
            'C' => 2, // paper + loss
            else => unreachable,
        },
        // scissors
        'Z' => return switch (theirs) {
            // rock
            'A' => 3, // scissors + loss
            // paper
            'B' => 9, // scissors + win
            // scissors
            'C' => 6, // scissors + tie
            else => unreachable,
        },
        else => unreachable,
    }
}

fn competeP2(outcome: u8, theirs: u8) usize {
    switch (outcome) {
        // lose
        'X' => return switch (theirs) {
            // lose to rock
            'A' => competeP1('Z', theirs),
            // lose to paper
            'B' => competeP1('X', theirs),
            // lose to scissors
            'C' => competeP1('Y', theirs),
            else => unreachable,
        },
        // draw
        'Y' => return switch (theirs) {
            // draw with rock
            'A' => competeP1('X', theirs),
            // draw with paper
            'B' => competeP1('Y', theirs),
            // draw with scissors
            'C' => competeP1('Z', theirs),
            else => unreachable,
        },
        // win
        'Z' => return switch (theirs) {
            // win against rock
            'A' => competeP1('Y', theirs),
            // win against paper
            'B' => competeP1('Z', theirs),
            // win against scissors
            'C' => competeP1('X', theirs),
            else => unreachable,
        },
        else => unreachable,
    }
}
pub fn main() !void {
    var line_it = tokenize(u8, data, "\n");

    var total_p1: usize = 0;
    var total_p2: usize = 0;

    while (line_it.next()) |line| {
        var letter_it = split(u8, line, " ");

        const theirs = letter_it.next().?[0];
        const mine = letter_it.next().?[0];

        total_p1 += competeP1(mine, theirs);
        total_p2 += competeP2(mine, theirs);
    }

    print("part1: {}, part2: {}\n", .{ total_p1, total_p2 });
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
