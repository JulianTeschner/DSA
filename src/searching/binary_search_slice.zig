//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

fn binary_search(haystack: []const u32, needle: u32) bool {
    var hi: usize = haystack.len;
    var lo: usize = 0;
    while (true) {
        const mid = lo + (hi - lo) / 2;
        const v = haystack[mid];
        std.debug.print("hi {} \t lo {} \t mid {}\n", .{ hi, lo, mid });
        if (v == needle) {
            return true;
        }
        if (v > needle) {
            hi = mid;
        } else {
            lo = mid + 1;
        }
        std.debug.print("hi {} \t lo {} \t mid {}\n", .{ hi, lo, mid });
        if (!(lo < hi)) {
            break;
        }
    }
    return false;
}

test "binary search array" {
    const foo = [_]u32{ 1, 3, 4, 69, 71, 81, 90, 99, 420, 1337, 69420 };
    try testing.expect(binary_search(&foo, 69) == true);
    std.debug.print("\n", .{});
    try testing.expect(binary_search(&foo, 1336) == false);
    std.debug.print("\n", .{});
    try testing.expect(binary_search(&foo, 69420) == true);
    std.debug.print("\n", .{});
    try testing.expect(binary_search(&foo, 69421) == false);
    std.debug.print("\n", .{});
    try testing.expect(binary_search(&foo, 1) == true);
    std.debug.print("\n", .{});
    try testing.expect(binary_search(&foo, 0) == false);
}
