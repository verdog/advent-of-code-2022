const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");
// const data = @embedFile("data/day12_sample.txt");

const Cell = struct {
    height: u8,
};

const Grid = struct {
    cells: []Cell,
    width: usize,
    height: usize,
    start: *Cell,
    end: *Cell,

    pub fn fromText(text: []const u8) This {
        const width = std.mem.sliceTo(text, '\n').len;
        const height = std.mem.count(u8, text, "\n");

        var g = This{
            .cells = undefined,
            .width = width,
            .height = height,
            .start = undefined,
            .end = undefined,
        };

        g.cells = gpa.alloc(Cell, width * height) catch unreachable;

        var lines = std.mem.tokenize(u8, text, "\n");
        var i: usize = 0;
        while (lines.next()) |line| {
            for (line) |c| {
                defer i += 1;
                g.cells[i].height = c;

                if (c == 'S') {
                    g.cells[i].height = 'a';
                    g.start = &g.cells[i];
                }

                if (c == 'E') {
                    g.cells[i].height = 'z';
                    g.end = &g.cells[i];
                }
            }
        }

        return g;
    }

    pub fn at(self: This, x: usize, y: usize) ?*Cell {
        if (y >= self.height) return null;
        if (x >= self.width) return null;

        const idx = y * self.width + x;
        return if (idx < self.cells.len) &self.cells[idx] else null;
    }

    pub fn getLinks(self: This, cell: *Cell) [4]?*Cell {
        var links_buf = [_]?*Cell{null} ** 4;
        const idx = blk: {
            for (self.cells) |*cellptr, j| {
                if (cellptr == cell) break :blk j;
            }
            unreachable;
        };

        const x = @mod(idx, self.width);
        const y = @divTrunc(idx, self.width);

        var i: usize = 0;
        if (self.at(x, y -% 1)) |cellptr| {
            if (cell.height + 1 >= cellptr.height) {
                links_buf[i] = cellptr;
                i += 1;
            }
        }
        if (self.at(x, y +% 1)) |cellptr| {
            if (cell.height + 1 >= cellptr.height) {
                links_buf[i] = cellptr;
                i += 1;
            }
        }
        if (self.at(x -% 1, y)) |cellptr| {
            if (cell.height + 1 >= cellptr.height) {
                links_buf[i] = cellptr;
                i += 1;
            }
        }
        if (self.at(x +% 1, y)) |cellptr| {
            if (cell.height + 1 >= cellptr.height) {
                links_buf[i] = cellptr;
                i += 1;
            }
        }
        return links_buf;
    }

    const This = @This();
};

fn shortestLength(grid: Grid, start: *Cell, root: *std.Progress.Node, answer: *usize) void {
    defer root.completeOne();

    var dists = std.AutoHashMap(*Cell, usize).init(gpa);
    defer dists.deinit();

    const comp = struct {
        fn f(distz: *std.AutoHashMap(*Cell, usize), a: *Cell, b: *Cell) std.math.Order {
            const mx = std.math.maxInt(usize);
            const ad = distz.get(a) orelse mx;
            const bd = distz.get(b) orelse mx;

            if (ad < bd) return .lt;
            if (ad == bd) return .eq;
            if (ad > bd) return .gt;
            unreachable;
        }
    }.f;

    var frontier = std.PriorityQueue(*Cell, *std.AutoHashMap(*Cell, usize), comp).init(gpa, &dists);

    dists.put(start, 0) catch unreachable;
    frontier.add(start) catch unreachable;

    while (frontier.count() > 0) {
        var cellptr = frontier.remove();

        for (std.mem.sliceTo(&grid.getLinks(cellptr), null)) |c| {
            const total_weight = dists.get(cellptr).? + 1;

            if (total_weight < dists.get(c.?) orelse std.math.maxInt(usize)) {
                frontier.add(c.?) catch unreachable;
                dists.put(c.?, total_weight) catch unreachable;
            }
        }
    }

    answer.* = dists.get(grid.end) orelse std.math.maxInt(usize);
}

pub fn main() !void {
    const grid = Grid.fromText(data);

    var progress = std.Progress{};
    var root = progress.start("Path", 0);
    defer root.end();

    var part1answer: usize = undefined;
    shortestLength(grid, grid.start, root, &part1answer);

    var mn: usize = std.math.maxInt(usize);

    var threads = [_]?std.Thread{null} ** 16;
    var answers = [_]usize{undefined} ** threads.len;

    for (grid.cells) |*cell, j| {
        if (cell.height == 'a') {
            const tidx = j % threads.len;

            if (threads[tidx] == null) {
                threads[tidx] = try std.Thread.spawn(.{}, shortestLength, .{ grid, cell, root, &answers[tidx] });
            } else {
                threads[tidx].?.join();
                mn = @min(mn, answers[tidx]);
                threads[tidx] = null;
            }
        }
    }

    for (threads) |th, tidx| {
        if (th != null) {
            threads[tidx].?.join();
            mn = @min(mn, answers[tidx]);
            threads[tidx] = null;
        }
    }

    print("part1: {}, part2: {}\n", .{ part1answer, mn });
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
