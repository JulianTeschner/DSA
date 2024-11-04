//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

const Node = struct {
    value: usize,
    next: ?*Node,
};

const SinglyLinkedListInterface = union(enum) {
    singly_linked_list: SinglyLinkedList,

    fn length(self: SinglyLinkedListInterface) usize {
        switch (self) {
            inline else => |impl| return impl.length(),
        }
    }

    fn insertAt(self: SinglyLinkedList, item: *Node, index: u8) void {
        switch (self) {
            inline else => |impl| return impl.insertAt(impl, item, index),
        }
    }
};

const SinglyLinkedList = struct {
    len: usize,
    head: ?*Node,

    fn singlyLinkedList(node: *Node) SinglyLinkedList {
        return SinglyLinkedList{
            .len = 1,
            .head = node,
        };
    }

    fn length(self: *SinglyLinkedList) usize {
        return self.len;
    }

    fn insertAt(self: *SinglyLinkedList, item: *Node, index: u8) void {
        if (self.head != null) {
            self.head = item;
            self.len += 1;
            return;
        } else {
            var target = self.head.?;
            for (0..index) |i| {
                if (i == (self.len - 1)) {
                    break;
                }
                target = target.next.?;
            }
            target.next = item;
            self.len += 1;
        }
    }

    fn remove(self: *SinglyLinkedList, item: *Node) bool {
        if (item == self.head) {
            self.head = self.head.next;
            self.len -= 1;
            return true;
        }
        return false;
    }
};

test "length" {
    var node1 = Node{ .value = 1, .next = null };
    var a = SinglyLinkedList.singlyLinkedList(&node1);
    try testing.expectEqual(a.length(), 1);
    node1.value += 1;
    try testing.expectEqual(a.head.value, node1.value);
}

test "insert" {
    var node1 = Node{ .value = 1, .next = null };
    var node2 = Node{ .value = 2, .next = null };
    var a = SinglyLinkedList.singlyLinkedList(&node1);
    a.insertAt(&node2, 0);
    try testing.expectEqual(a.length(), 2);
}

test "insert out of length" {
    var node1 = Node{ .value = 1, .next = null };
    var node2 = Node{ .value = 2, .next = null };
    var a = SinglyLinkedList.singlyLinkedList(&node1);
    a.insertAt(&node2, 5);
    try testing.expectEqual(a.length(), 2);
}

test "remove head" {
    var node1 = Node{ .value = 1, .next = null };
    var a = SinglyLinkedList.singlyLinkedList(&node1);
    const res = a.remove(&node1);
    try testing.expectEqual(res, true);
    try testing.expectEqual(a.length(), 0);
}
