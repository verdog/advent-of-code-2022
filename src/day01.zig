// const data = @embedFile("data/day01_sample.txt");
const data = @embedFile("data/day01.txt");

pub noinline fn main() void {
    @setEvalBranchQuota(100000);

    const mosts = comptime blk: {
        var mosts_buf = [_]usize{ 0, 0, 0, 0 };

        var line_itr = split(u8, data, "\n");
        var running_total: usize = 0;

        while (line_itr.next()) |line| {
            if (line.len > 0) {
                const line_amount = parseInt(usize, line, 10) catch return;
                running_total += line_amount;
            } else {
                mosts_buf[3] = running_total;

                sort(usize, &mosts_buf, {}, desc(usize));

                running_total = 0;
            }
        }

        break :blk mosts_buf;
    };

    const out = std.fmt.comptimePrint("part1: {}, part2: {}\n", .{ mosts[0], mosts[0] + mosts[1] + mosts[2] });
    _ = std.os.system.write(0, out, out.len);
}

// Useful stdlib functions
const std = @import("std");
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const parseInt = std.fmt.parseInt;

const print = std.debug.print;

const sort = std.sort.sort;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
