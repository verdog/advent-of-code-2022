const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");
// const data = @embedFile("data/day09_sample.txt");

const Move = struct {
    dir: u8,
    repeat: usize,
};

fn getMoves() []Move {
    var elems = std.mem.tokenize(u8, data, " \n");
    var moves = ArrayList(Move).init(gpa);

    while (elems.next()) |dir| {
        const rep = parseInt(usize, elems.next().?, 10) catch unreachable;
        moves.append(.{ .dir = dir[0], .repeat = rep }) catch unreachable;
    }

    return moves.toOwnedSlice() catch unreachable;
}

fn solveTail(head: Point, tail: Point) Point {
    if (head.x == tail.x and head.y == tail.y) return tail;

    const diffx = std.math.absInt(head.y - tail.y) catch unreachable;
    const diffy = std.math.absInt(head.x - tail.x) catch unreachable;

    if (diffx <= 1 and diffy <= 1) return tail;

    var new = tail;

    if (head.y == tail.y) {
        new.x = head.x + std.math.sign(tail.x - head.x);
        return new;
    }

    if (head.x == tail.x) {
        new.y = head.y + std.math.sign(tail.y - head.y);
        return new;
    }

    if (diffy == 1 and diffx == 0) {
        new.y = head.y;
        return new;
    }

    if (diffx == 1 and diffy == 0) {
        new.x = head.x;
        return new;
    }

    const movex = std.math.sign(head.x - tail.x);
    const movey = std.math.sign(head.y - tail.y);

    new.x += movex;
    new.y += movey;

    return new;
}

test "solve tail" {
    const exe = std.testing.expectEqual;

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = 0 }, .{ .x = 0, .y = 0 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = 0 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = 1 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = 1 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = 1 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = 0 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = -1 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = -1 }, .{ .x = 0, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = -1 }, .{ .x = 0, .y = 0 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = 0 }, .{ .x = -1, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = 0 }, .{ .x = 1, .y = 0 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = 1 }, .{ .x = 0, .y = -1 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = -1 }, .{ .x = 0, .y = 1 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = 0 }, .{ .x = -1, .y = -1 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 1, .y = 0 }, .{ .x = -1, .y = 1 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = 1 }, .{ .x = -1, .y = -1 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = 1 }, .{ .x = 1, .y = -1 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = 0 }, .{ .x = 1, .y = -1 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = -1, .y = 0 }, .{ .x = 1, .y = 1 }));

    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = -1 }, .{ .x = 1, .y = 1 }));
    try exe(Point{ .x = 0, .y = 0 }, solveTail(.{ .x = 0, .y = -1 }, .{ .x = -1, .y = 1 }));
}

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub fn main() !void {
    const moves = getMoves();

    var knots = [_]Point{Point{}} ** 10;

    var tailPositions = AutoHashMap(Point, void).init(gpa);

    for (moves) |move| {
        var i: usize = 0;
        while (i < move.repeat) : (i += 1) {
            switch (move.dir) {
                'U' => knots[0].y -= 1,
                'D' => knots[0].y += 1,
                'R' => knots[0].x += 1,
                'L' => knots[0].x -= 1,
                else => unreachable,
            }

            for (knots) |*knot, j| {
                if (j == 0) continue;
                knot.* = solveTail(knots[j - 1], knot.*);
                if (j == 9)
                    tailPositions.put(knot.*, {}) catch unreachable;
            }
        }
    }

    print("part1: {}, part2: {}\n", .{ tailPositions.count(), 0 });
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
