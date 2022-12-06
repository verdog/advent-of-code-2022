const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");
// const data = @embedFile("data/day05_sample.txt");

fn parseStacks() !struct { stacks: [][]u8, rest: []const u8 } {
    const tallest = blk: {
        var line_i = split(u8, data, "\n");
        var crates: usize = 0;

        while (line_i.next()) |line| {
            if (std.mem.eql(u8, line[0..4], " 1  "[0..4])) {
                break;
            }

            var i: usize = 0;
            var num_i: usize = line.len / 4 + 1;
            while (i < num_i) : (i += 1) {
                const crate = line[i * 4 ..];
                if (crate[1] != ' ') {
                    crates += 1;
                }
            }
        }

        break :blk crates;
    };

    const num_stacks = (std.mem.sliceTo(data, '\n').len + 1) / 4;
    print("{} stacks of which the tallest possible is {}\n", .{ num_stacks, tallest });

    var stacks: [][]u8 = try gpa.alloc([]u8, num_stacks);
    for (stacks) |*stack| {
        stack.* = try gpa.alloc(u8, tallest);
        for (stack.*) |*c| {
            c.* = ' ';
        }
    }

    var line_i = tokenize(u8, data, "\n");
    var stack_i: usize = 0;
    while (line_i.next()) |line| : (stack_i += 1) {
        if (line[1] == '1') {
            break;
        }

        var cursor: usize = 1;
        while (cursor < line.len) : (cursor += 4) {
            const stack = @divTrunc(cursor, 4);
            stacks[stack][stack_i] = line[cursor];
        }
    }

    for (stacks) |stack| {
        while (stack[0] == ' ') {
            var i: usize = 0;
            while (i < stack.len - 1) : (i += 1) {
                stack[i] = stack[i + 1];
            }
        }

        std.mem.reverse(u8, std.mem.sliceTo(stack, ' '));

        for (stack) |c| {
            print("{c}", .{c});
        }

        print("|\n", .{});
    }

    return .{ .stacks = stacks, .rest = line_i.rest() };
}

const Move = struct {
    from: usize,
    to: usize,
    repeat: usize,
};

fn parseMoves(move_data: []const u8) ![]Move {
    var moves = ArrayList(Move).init(gpa);

    var line_i = tokenize(u8, move_data, "\n");

    while (line_i.next()) |line| {
        var word_i = tokenize(u8, line, " ");

        _ = word_i.next(); // move
        const rep = try parseInt(usize, word_i.next().?, 10);
        _ = word_i.next(); // from
        const frm = try parseInt(usize, word_i.next().?, 10);
        _ = word_i.next(); // to
        const to = try parseInt(usize, word_i.next().?, 10);

        try moves.append(.{ .from = frm, .to = to, .repeat = rep });
    }

    return moves.toOwnedSlice();
}

pub fn main() !void {
    {
        var first_parse = try parseStacks();
        var stacks = first_parse.stacks;
        var moves = try parseMoves(first_parse.rest);

        for (moves) |move| {
            var count: usize = 0;
            while (count < move.repeat) : (count += 1) {
                const from_top = (indexOfScalar(u8, stacks[move.from - 1], ' ') orelse stacks[move.from - 1].len) - 1;
                const to_top = indexOfScalar(u8, stacks[move.to - 1], ' ').?;

                stacks[move.to - 1][to_top] = stacks[move.from - 1][from_top];
                stacks[move.from - 1][from_top] = ' ';
            }
        }

        for (stacks) |stack| {
            const top = (indexOfScalar(u8, stack, ' ') orelse stack.len) - 1;
            print("{c}", .{stack[top]});
        }

        print("\n", .{});
    }
    {
        var first_parse = try parseStacks();
        var stacks = first_parse.stacks;
        var moves = try parseMoves(first_parse.rest);

        for (moves) |move| {
            var from_bottom = (indexOfScalar(u8, stacks[move.from - 1], ' ') orelse stacks[move.from - 1].len) - move.repeat;
            var to_top = indexOfScalar(u8, stacks[move.to - 1], ' ').?;

            var count: usize = 0;
            while (count < move.repeat) : ({
                count += 1;
                from_bottom += 1;
                to_top += 1;
            }) {
                stacks[move.to - 1][to_top] = stacks[move.from - 1][from_bottom];
                stacks[move.from - 1][from_bottom] = ' ';
            }
        }

        for (stacks) |stack| {
            const top = (indexOfScalar(u8, stack, ' ') orelse stack.len) - 1;
            print("{c}", .{stack[top]});
        }

        print("\n", .{});
    }
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
