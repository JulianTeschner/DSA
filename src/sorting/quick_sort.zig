//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

fn qs(arr: []u32, lo: usize, hi: usize) void {
    if (lo >= hi) {
        return;
    }

    const pivotIdx = partition(arr, lo, hi);

    qs(arr, lo, pivotIdx - 1);
    qs(arr, pivotIdx + 1, hi);
}

fn partition(arr: []u32, lo: usize, hi: usize) usize {
    const pivot = arr[hi];

    var idx = lo;

    for (lo..hi) |i| {
        if (arr[i] <= pivot) {
            const tmp = arr[i];
            arr[i] = arr[idx];
            arr[idx] = tmp;
            idx += 1;
        }
    }
    const tmp = arr[hi];
    arr[hi] = arr[idx];
    arr[idx] = tmp;

    return idx;
}

fn quick_sort(arr: []u32) void {
    qs(arr, 0, arr.len - 1);
}

test "quick sort" {
    var foo = [_]u32{ 9, 435, 1, 3, 7, 4, 69, 420, 42 };
    const expected = [_]u32{ 1, 3, 4, 7, 9, 42, 69, 420, 435 };
    quick_sort(&foo);
    try testing.expectEqual(foo, expected);
}
