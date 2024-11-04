//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

fn bubble_sort(numbers: []u32) void {
    var n: usize = numbers.len - 1;
    while (true) {
        for (0..n) |i| {
            if (numbers[i] > numbers[i + 1]) {
                const temp = numbers[i];
                numbers[i] = numbers[i + 1];
                numbers[i + 1] = temp;
            }
        }
        n -= 1;
        if (n == 1) {
            break;
        }
    }
}

test "bubble sort" {
    var foo = [_]u32{ 9, 3, 7, 4, 69, 420, 42 };
    const expected = [_]u32{ 3, 4, 7, 9, 42, 69, 420 };
    bubble_sort(&foo);
    try testing.expectEqual(foo, expected);
}
