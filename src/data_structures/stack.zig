const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const StackError = error{
    EmptyStack,
};

fn NodeType(comptime T: type) type {
    return struct {
        const Node = @This();

        value: T,
        prev: ?*Node,

        fn init(value: T) Node {
            return Node{
                .value = value,
                .prev = null,
            };
        }
    };
}

fn StackType(comptime T: type) type {
    return struct {
        const Stack = @This();

        allocator: *const Allocator,
        len: u8,
        head: ?*NodeType(T),

        fn init(allocator: *const Allocator) Stack {
            return Stack{
                .allocator = allocator,
                .len = 0,
                .head = null,
            };
        }

        fn deinit(self: *Stack) !void {
            while (self.head) |_| {
                const head = try self.pop();
                self.allocator.destroy(head);
            }
        }

        fn push(self: *Stack, value: T) !void {
            const node = try self.allocator.create(NodeType(T));
            node.* = NodeType(T).init(value);
            if (self.head) |head| {
                node.prev = head;
            }
            self.head = node;
            self.len += 1;
        }

        fn pop(self: *Stack) StackError!*NodeType(T) {
            var result = self.head orelse return StackError.EmptyStack;
            self.head = self.head.?.prev;
            self.len -= 1;
            result.prev = null;
            return result;
        }
        fn peek(self: *Stack) StackError!T {
            if (self.len > 0) {
                return self.head.?.value;
            }
            return StackError.EmptyStack;
        }
    };
}

test "stack" {
    const allocator = std.testing.allocator;
    var stack = StackType(u32).init(&allocator);
    try stack.push(5);
    try stack.push(7);
    try stack.push(9);

    var tmp = try stack.pop();
    try std.testing.expectEqual(9, tmp.value);
    allocator.destroy(tmp);
    try std.testing.expectEqual(2, stack.len);

    try stack.push(11);

    tmp = try stack.pop();
    try std.testing.expectEqual(11, tmp.value);
    allocator.destroy(tmp);

    tmp = try stack.pop();
    try std.testing.expectEqual(7, tmp.value);
    allocator.destroy(tmp);

    try std.testing.expectEqual(5, stack.peek());

    tmp = try stack.pop();
    try std.testing.expectEqual(5, tmp.value);
    allocator.destroy(tmp);

    try std.testing.expectError(StackError.EmptyStack, stack.pop());

    try stack.push(69);
    try std.testing.expectEqual(69, stack.peek());
    try std.testing.expectEqual(1, stack.len);

    try stack.deinit();
    // // just wanted to make sure that I could not blow up myself when i remove
    // // everything
    // list.push(69);
    // expect(list.peek()).toEqual(69);
    // expect(list.length).toEqual(1);
    //
    // //yayaya
}
