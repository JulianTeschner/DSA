// //! By convention, root.zig is the root source file when making a library. If
// //! you are making an executable, the convention is to delete this file and
// //! start with main.zig instead.
const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const QueueError = error{
    NoElementsLeft,
};
const TestError = error{
    TestFailed,
};

fn NodeType(comptime T: type) type {
    return struct {
        const Node = @This();

        value: T,
        next: ?*Node,

        fn init(value: T) Node {
            return Node{ .value = value, .next = null };
        }
    };
}

fn QueueType(comptime T: type) type {
    return struct {
        const Queue = @This();
        head: ?*NodeType(T),
        tail: ?*NodeType(T),
        allocator: *Allocator,
        len: u8,

        fn init(allocator: *Allocator, value: T) !Queue {
            const node = try allocator.create(NodeType(T));
            node.* = NodeType(T).init(value);
            return Queue{ .head = node, .tail = node, .allocator = allocator, .len = 1 };
        }

        fn enqueue(self: *Queue, value: T) !void {
            const node = try self.allocator.create(NodeType(T));
            node.* = NodeType(T).init(value);
            if (self.len == 0) {
                self.head = node;
                self.tail = node;
            } else {
                self.tail.?.next = node;
                self.tail = node;
            }
            self.len += 1;
        }

        fn deque(self: *Queue) QueueError!*NodeType(T) {
            const result = self.head orelse return QueueError.NoElementsLeft;
            self.len -= 1;
            self.head = self.head.?.next orelse null;
            result.next = null;
            return result;
        }

        fn deinit(self: *Queue) !void {
            while (self.head != null) {
                const tmp = try self.deque();
                self.allocator.destroy(tmp);
            }
        }

        fn peek(self: *Queue) QueueError!T {
            if (self.len > 0) {
                return self.head.?.value;
            } else {
                return QueueError.NoElementsLeft;
            }
        }
    };
}

test "queue" {
    var allocator = std.testing.allocator;
    const qt = QueueType(u32);
    var list = try qt.init(&allocator, 5);
    std.debug.print("Head: {}\n", .{list.head.?.value});
    std.debug.print("Tail: {}\n", .{list.tail.?.value});

    try list.enqueue(7);
    std.debug.print("Head: {}\n", .{list.head.?.value});
    std.debug.print("Tail: {}\n", .{list.tail.?.value});
    try list.enqueue(9);
    std.debug.print("Head: {}\n", .{list.head.?.value});
    std.debug.print("Tail: {}\n", .{list.tail.?.value});

    var tmp = list.deque() catch {
        return error.TestFailed;
    };

    try std.testing.expectEqual(5, tmp.value);
    list.allocator.destroy(tmp);
    try std.testing.expectEqual(2, list.len);

    try list.enqueue(11);

    tmp = list.deque() catch |err| {
        return err;
    };

    try std.testing.expectEqual(7, tmp.value);
    list.allocator.destroy(tmp);

    tmp = list.deque() catch |err| {
        return err;
    };

    try std.testing.expectEqual(9, tmp.value);
    list.allocator.destroy(tmp);

    var peek = list.peek() catch |err| {
        return err;
    };
    try std.testing.expectEqual(11, peek);

    tmp = list.deque() catch |err| {
        return err;
    };

    try std.testing.expectEqual(11, tmp.value);
    list.allocator.destroy(tmp);

    try std.testing.expectError(error.NoElementsLeft, list.deque());
    try std.testing.expectEqual(0, list.len);

    try list.enqueue(69);
    peek = list.peek() catch |err| {
        return err;
    };
    try std.testing.expectEqual(69, peek);
    try std.testing.expectEqual(1, list.len);

    try list.deinit();
}
