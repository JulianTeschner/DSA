const std = @import("std");
const testing = std.testing;

const Point = struct {
    x: i32,
    y: i32,
};

const x = 0x78;
const s = 0x20;
const a = 0x2a;

const dir: [4]Point = .{
    .{ .x = -1, .y = 0 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = -1 },
    .{ .x = 0, .y = 1 },
};

fn walk(comptime X: usize, comptime Y: usize, maze: *[Y][X]u8, wall: u8, curr: Point, end: Point, seen: *[Y][X]bool, path: *std.ArrayList(Point)) !bool {
    // 1. Base Case
    // off the map
    if (curr.y < 0 or curr.y >= Y or curr.x < 0 or curr.x >= X) {
        return false;
    }
    // 2. Base Case
    // on a wall
    const cx: usize = @intCast(curr.x);
    const cy: usize = @intCast(curr.y);
    if (maze[cy][cx] == wall) {
        return false;
    }
    // 3. Base case
    // at the end
    if (curr.x == end.x and curr.y == end.y) {
        try path.append(end);
        return true;
    }
    // 4. Base case
    // seen
    if (seen[cy][cx]) {
        return false;
    }
    // 3 recurse steps
    // pre
    seen[cy][cx] = true;
    try path.append(curr);

    // recurse
    for (dir) |d| {
        if (try walk(X, Y, maze, wall, .{ .x = curr.x + d.x, .y = curr.y + d.y }, end, seen, path)) {
            return true;
        }
    }
    // post
    _ = path.pop();
    return false;
}

fn maze_solver(allocator: std.mem.Allocator, comptime X: usize, comptime Y: usize, maze: *[Y][X]u8, wall: u8, start: Point, end: Point) !std.ArrayList(Point) {
    var seen: [Y][X]bool = undefined;
    for (0..Y) |y| {
        for (0..X) |sx| {
            seen[y][sx] = false;
        }
    }
    var path = std.ArrayList(Point).init(allocator);
    _ = try walk(X, Y, maze, wall, start, end, &seen, &path);
    return path;
}

fn draw_path(comptime X: usize, comptime Y: usize, data: *[Y][X]u8, path: []const Point) [Y][X]u8 {
    var ret: [Y][X]u8 = data.*;

    for (path) |p| {
        if (p.y < Y and p.x < X) {
            ret[@intCast(p.y)][@intCast(p.x)] = a;
        }
    }
    return ret;
}

test "maze solver" {
    const allocator = std.testing.allocator;
    var maze: [6][12]u8 = .{
        .{ x, x, x, x, x, x, x, x, x, x, s, x },
        .{ x, s, s, s, s, s, s, s, s, x, s, x },
        .{ x, s, s, s, s, s, s, s, s, x, s, x },
        .{ x, s, x, x, x, x, x, x, x, x, s, x },
        .{ x, s, s, s, s, s, s, s, s, s, s, x },
        .{ x, s, x, x, x, x, x, x, x, x, x, x },
    };

    const mazeResult = [_]Point{
        Point{ .x = 10, .y = 0 },
        Point{ .x = 10, .y = 1 },
        Point{ .x = 10, .y = 2 },
        Point{ .x = 10, .y = 3 },
        Point{ .x = 10, .y = 4 },
        Point{ .x = 9, .y = 4 },
        Point{ .x = 8, .y = 4 },
        Point{ .x = 7, .y = 4 },
        Point{ .x = 6, .y = 4 },
        Point{ .x = 5, .y = 4 },
        Point{ .x = 4, .y = 4 },
        Point{ .x = 3, .y = 4 },
        Point{ .x = 2, .y = 4 },
        Point{ .x = 1, .y = 4 },
        Point{ .x = 1, .y = 5 },
    };
    const expectedRet = draw_path(12, 6, &maze, &mazeResult);

    const actualResultList = try maze_solver(allocator, 12, 6, &maze, x, .{ .x = 10, .y = 0 }, .{ .x = 1, .y = 5 });
    defer actualResultList.deinit();

    for (actualResultList.items, 0..) |v, i| {
        try std.testing.expectEqual(mazeResult[i], v);
    }
    const actualRet = draw_path(12, 6, &maze, actualResultList.items);
    for (actualRet) |py| {
        for (py) |px| {
            std.debug.print("{c}", .{px});
        }
        std.debug.print("\n", .{});
    }
    try std.testing.expectEqual(expectedRet, actualRet);
}
