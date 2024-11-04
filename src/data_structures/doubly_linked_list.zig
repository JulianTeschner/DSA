// //! By convention, root.zig is the root source file when making a library. If
// //! you are making an executable, the convention is to delete this file and
// //! start with main.zig instead.
const std = @import("std");

const DoublyLinkedListError = error{
    IndexOutOfBounds,
    ValueDoesNotExist,
    ListIsEmpty,
};

fn NodeType(comptime T: type) type {
    return struct {
        const Node = @This();
        value: T,
        prev: ?*NodeType(T),
        next: ?*NodeType(T),

        fn init(value: T) Node {
            return Node{
                .value = value,
                .prev = null,
                .next = null,
            };
        }
    };
}

fn DoublyLinkedListType(comptime T: type) type {
    return struct {
        const DoublyLinkedList = @This();
        allocator: *const std.mem.Allocator,
        len: usize,
        head: ?*NodeType(T),
        tail: ?*NodeType(T),

        fn init(allocator: *const std.mem.Allocator) DoublyLinkedList {
            return DoublyLinkedList{
                .len = 0,
                .allocator = allocator,
                .head = null,
                .tail = null,
            };
        }

        fn deinit(self: *DoublyLinkedList) void {
            for (0..self.len) |_| {
                const h = self.head;
                self.head = self.head.?.next;
                self.allocator.destroy(h.?);
            }
        }

        fn append(self: *DoublyLinkedList, value: T) std.mem.Allocator.Error!void {
            var node = try self.allocator.create(NodeType(T));
            node.* = NodeType(T).init(value);
            if (self.len == 0) {
                self.head = node;
                self.tail = node;
            } else {
                self.tail.?.next = node;
                node.prev = self.tail;
                self.tail = node;
            }
            self.len += 1;
        }

        fn prepend(self: *DoublyLinkedList, value: T) std.mem.Allocator.Error!void {
            var node = try self.allocator.create(NodeType(T));
            node.* = NodeType(T).init(value);
            if (self.len == 0) {
                self.head = node;
                self.tail = node;
            } else {
                self.head.?.prev = node;
                node.next = self.head;
                self.head = node;
            }
            self.len += 1;
        }

        fn get(self: *DoublyLinkedList, index: usize) DoublyLinkedListError!T {
            if (index + 1 > self.len) {
                return DoublyLinkedListError.IndexOutOfBounds;
            } else {
                var node = self.head.?;
                for (0..index) |_| {
                    node = node.next.?;
                }
                return node.value;
            }
        }

        fn remove(self: *DoublyLinkedList, value: T) DoublyLinkedListError!T {
            if (self.len <= 0) {
                return DoublyLinkedListError.ListIsEmpty;
            }
            var node = self.head.?;
            for (0..self.len) |i| {
                if (node.value == value) {
                    return self.removeAt(i);
                }
                if (node.next) |next| {
                    node = next;
                }
            }
            return DoublyLinkedListError.ValueDoesNotExist;
        }

        fn removeAt(self: *DoublyLinkedList, index: usize) DoublyLinkedListError!T {
            if (index + 1 > self.len) {
                return DoublyLinkedListError.IndexOutOfBounds;
            } else {
                var node = self.head.?;
                for (0..index) |_| {
                    node = node.next.?;
                }
                var prev = node.prev;
                var next = node.next;
                prev.next = next;
                next.prev = prev;
                const val = node.value;
                self.allocator.destroy(node);
                self.len -= 1;
                return val;
            }
        }
    };
}

test "Node" {
    const node = NodeType(u8).init(5);
    try std.testing.expectEqual(5, node.value);
    try std.testing.expectEqual(null, node.next);
}

test "doubly linked list" {
    const allocator = std.testing.allocator;
    var list = DoublyLinkedListType(u8).init(&allocator);
    try list.append(5);
    try list.append(7);
    try list.append(9);
    try std.testing.expectEqual(5, list.head.?.value);
    try std.testing.expectEqual(7, list.head.?.next.?.value);
    try std.testing.expectEqual(9, list.tail.?.value);
    try std.testing.expectEqual(7, list.tail.?.prev.?.value);
    try std.testing.expectEqual(3, list.len);
    try std.testing.expectEqual(9, try list.get(2));
    try std.testing.expectEqual(7, try list.removeAt(1));
    try std.testing.expectEqual(2, list.len);
    try list.append(11);
    try std.testing.expectEqual(9, try list.removeAt(1));
    try std.testing.expectError(DoublyLinkedListError.ValueDoesNotExist, list.remove(9));
    std.debug.print("{}\n", .{list.head.?.value});
    std.debug.print("{}\n", .{list.tail.?.value});
    // try std.testing.expectEqual(5, try list.removeAt(0));
    // try std.testing.expectEqual(11, try list.removeAt(0));
    // try std.testing.expectEqual(0, list.len);

    list.deinit();
}

//
// expect(list.removeAt(0)).toEqual(5);
// expect(list.removeAt(0)).toEqual(11);
// expect(list.length).toEqual(0);
//
// list.prepend(5);
// list.prepend(7);
// list.prepend(9);
//
// expect(list.get(2)).toEqual(5);
// expect(list.get(0)).toEqual(9);
// expect(list.remove(9)).toEqual(9);
// expect(list.length).toEqual(2);
// expect(list.get(0)).toEqual(7);
