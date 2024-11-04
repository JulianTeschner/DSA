//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

fn linear_search(haystack: []const u32, needle: u32) bool {
    for (haystack) |hay| {
        if (hay == needle) {
            return true;
        }
    }
    return false;
}

test "linear search array" {
    const foo = [_]u32{ 1, 3, 4, 69, 71, 81, 90, 99, 420, 1337, 69420 };
    try testing.expect(linear_search(&foo, 69) == true);
    try testing.expect(linear_search(&foo, 1336) == false);
    try testing.expect(linear_search(&foo, 69420) == true);
    try testing.expect(linear_search(&foo, 69421) == false);
    try testing.expect(linear_search(&foo, 1) == true);
    try testing.expect(linear_search(&foo, 0) == false);
}

//
// test("linear search array", function() {
//
//     const foo = [1, 3, 4, 69, 71, 81, 90, 99, 420, 1337, 69420];
//     expect(linear_fn(foo, 69)).toEqual(true);
//     expect(linear_fn(foo, 1336)).toEqual(false);
//     expect(linear_fn(foo, 69420)).toEqual(true);
//     expect(linear_fn(foo, 69421)).toEqual(false);
//     expect(linear_fn(foo, 1)).toEqual(true);
//     expect(linear_fn(foo, 0)).toEqual(false);
// });
//
//
