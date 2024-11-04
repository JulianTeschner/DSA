const std = @import("std");
const testing = std.testing;

const MyNumberError = error{
    NoResult,
};

fn two_crystal_balls(breaks: []bool) !u32 {
    const inc = std.math.sqrt(breaks.len);
    var idx: u32 = inc;
    while (true and idx < breaks.len) : (idx += inc) {
        if (breaks[idx] == false) {
            idx -= inc;
            break;
        }
    }
    std.debug.print("{}\n", .{idx});
    while (idx < breaks.len) : (idx += 1) {
        if (breaks[idx] == false) {
            return idx;
        }
    }
    return MyNumberError.NoResult;
}

test "two crystal balls" {
    const size = 100;
    const idx = std.crypto.random.intRangeAtMost(u32, 0, size);
    var data: [size]bool = undefined;
    @memset(&data, false);
    for (0..idx) |i| {
        data[i] = true;
    }
    try testing.expectEqual(two_crystal_balls(&data), idx);
}
