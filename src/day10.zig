const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");
// const data = @embedFile("data/day10_sample.txt");

const Instruction = struct {
    const Opcode = enum {
        noop,
        addx,
    };

    op: Opcode,
    rval: ?i64,
    cycles: usize,
};

const CPU = struct {
    x: i64 = 1,
    clock: i64 = 0,
};

fn getInstructions() []Instruction {
    var insts = ArrayList(Instruction).init(gpa);

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        var tokens = std.mem.tokenize(u8, line, " ");

        const opcode = blk: {
            const t = tokens.next().?;

            if (std.mem.eql(u8, t, "noop"))
                break :blk Instruction.Opcode.noop;
            if (std.mem.eql(u8, t, "addx"))
                break :blk Instruction.Opcode.addx;
            unreachable;
        };

        const cycles: usize = if (opcode == .noop) 1 else 2;

        const rval: ?i64 = blk: {
            if (opcode == .addx) {
                break :blk parseInt(i64, tokens.next().?, 10) catch unreachable;
            }
            break :blk null;
        };

        insts.append(.{ .op = opcode, .rval = rval, .cycles = cycles }) catch unreachable;
    }

    return insts.toOwnedSlice() catch unreachable;
}

pub fn main() !void {
    var cpu = CPU{};
    var sum: i64 = 0;
    const insts = getInstructions();

    var screen = [_]u8{' '} ** 240;

    for (insts) |rominst| {
        var inst = rominst;
        // burn cpu
        while (inst.cycles > 0) : (inst.cycles -= 1) {
            if (cpu.clock >= 19 and @mod(((cpu.clock + 1) -| 20), 40) == 0) {
                const plus = @intCast(i64, cpu.clock + 1) * cpu.x;
                print("{} * {} = {}\n", .{ cpu.clock + 1, cpu.x, plus });
                sum += plus;
            }

            const pixdiff = std.math.absInt(@mod(cpu.clock, 40) - cpu.x) catch unreachable;

            if (pixdiff <= 1) {
                screen[@intCast(usize, cpu.clock)] = '#';
            }

            cpu.clock += 1;
        }

        // affect state
        switch (inst.op) {
            .noop => {},
            .addx => {
                // print("  +{}\n", .{inst.rval.?});
                cpu.x += inst.rval.?;
            },
        }
    }

    print("ended at cycle {}\n", .{cpu.clock});

    print("part1: {}\n", .{sum});

    print("part2:\n", .{});
    print("{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n", .{
        screen[0..40],
        screen[40..80],
        screen[80..120],
        screen[120..160],
        screen[160..200],
        screen[200..240],
    });
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
