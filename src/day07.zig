const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const DynamicBitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");
// const data = @embedFile("data/day07_sample.txt");

fn recordBoundary(data_piece: []const u8) bool {
    if (data_piece.len < 6) return false;
    if (std.mem.eql(u8, data_piece[0..6], "$ cd .")) return false;
    if (std.mem.eql(u8, data_piece[0..5], "$ cd ")) return true;
    return false;
}

test "recordBoundary" {
    try std.testing.expect(recordBoundary("$ cd a") == true);
    try std.testing.expect(recordBoundary("$ cd abcdefg") == true);
    try std.testing.expect(recordBoundary("$ cd .") == false);
    try std.testing.expect(recordBoundary("$ cd ..") == false);
}

fn count(sum: *usize, parent_sum: *usize, data_piece: *[]const u8) void {
    var lines = tokenize(u8, data_piece.*, "\n");

    _ = lines.next().?; // cd
    _ = lines.next(); // ls

    var local_file_size: usize = 0;
    var num_local_dirs: usize = 0;

    // print("\n", .{});

    while (lines.next()) |line| {
        // print("{s}", .{line});

        if (line[0] != '$') {
            if (std.mem.eql(u8, line[0..3], "dir")) {
                // dir
                // print(" -> dir\n", .{});
                num_local_dirs += 1;
            } else {
                // file
                // print(" -> file\n", .{});
                local_file_size += parseInt(usize, std.mem.sliceTo(line, ' '), 10) catch unreachable;
            }
        }

        if (recordBoundary(lines.rest())) {
            // print("{s} -> boundary (not consumed)\n", .{lines.rest()[0..6]});
            data_piece.* = lines.rest();
            break;
        }
    }

    var dirs_done: usize = 0;
    while (dirs_done < num_local_dirs) : (dirs_done += 1) {
        count(sum, &local_file_size, data_piece);
    }

    parent_sum.* += local_file_size;

    // print("size for {s}: {}\n", .{ cdline, local_file_size });
    if (local_file_size <= 100_000) sum.* += local_file_size;
}

fn mini(root: usize, smallest: *usize, parent_sum: *usize, data_piece: *[]const u8) void {
    var lines = tokenize(u8, data_piece.*, "\n");

    _ = lines.next().?; // cd
    _ = lines.next(); // ls

    var local_file_size: usize = 0;
    var num_local_dirs: usize = 0;

    // print("\n", .{});

    while (lines.next()) |line| {
        // print("{s}", .{line});

        if (line[0] != '$') {
            if (std.mem.eql(u8, line[0..3], "dir")) {
                // dir
                // print(" -> dir\n", .{});
                num_local_dirs += 1;
            } else {
                // file
                // print(" -> file\n", .{});
                local_file_size += parseInt(usize, std.mem.sliceTo(line, ' '), 10) catch unreachable;
            }
        }

        if (recordBoundary(lines.rest())) {
            // print("{s} -> boundary (not consumed)\n", .{lines.rest()[0..6]});
            data_piece.* = lines.rest();
            break;
        }
    }

    var dirs_done: usize = 0;
    while (dirs_done < num_local_dirs) : (dirs_done += 1) {
        mini(root, smallest, &local_file_size, data_piece);
    }

    parent_sum.* += local_file_size;

    const free_space = 70_000_000 - root + local_file_size;
    // print("{}\n", .{free_space});
    if (free_space >= 30_000_000 and local_file_size < smallest.*) {
        // print("{} -> {}\n", .{ smallest.*, local_file_size });
        smallest.* = local_file_size;
    }
}

pub fn main() !void {
    var sum1: usize = 0;
    var place: usize = 0;
    var dataslice = @as([]const u8, data);

    count(&sum1, &place, &dataslice);

    var sum2: usize = place;
    var place2: usize = 0;

    dataslice = @as([]const u8, data);
    mini(place, &sum2, &place2, &dataslice);

    print("part1: {} ({}), part2: {}\n", .{ sum1, place, sum2 });
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
