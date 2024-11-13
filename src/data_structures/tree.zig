// //! By convention, root.zig is the root source file when making a library. If
// //! you are making an executable, the convention is to delete this file and
// //! start with main.zig instead.
const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

fn Tree(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            left: ?*Node,
            right: ?*Node,
        };

        head: ?*Node,
        size: usize,

        fn init(head: *Node) Tree(T) {
            return Tree(T){
                .head = head,
                .size = 1,
            };
        }
        ////////////////////////////////
        // IS THIS PRETTIER OR NOT??? //
        ////////////////////////////////
        //
        // fn preOrder(node: *Node, comptime func: *const fn (type, *Tree(T).Node) void) void {
        //     func(T, node);
        //     if (node.left) |left| {
        //         preOrder(left, func);
        //     }
        //     if (node.right) |right| {
        //         preOrder(right, func);
        //     }
        // }
        //
        // fn inOrder(node: *Node, comptime func: *const fn (type, *Tree(T).Node) void) void {
        //     if (node.left) |left| {
        //         inOrder(left, func);
        //     }
        //     func(T, node);
        //     if (node.right) |right| {
        //         inOrder(right, func);
        //     }
        // }
        //
        // fn postOrder(node: *Node, comptime func: *const fn (type, *Tree(T).Node) void) void {
        //     if (node.left) |left| {
        //         postOrder(left, func);
        //     }
        //     if (node.right) |right| {
        //         postOrder(right, func);
        //     }
        //     func(T, node);
        // }

        fn walkPreOrder(curr: ?*Node, path: *std.ArrayList(T)) !void {
            if (curr) |c| {
                // pre
                try path.append(c.value);
                // recurse
                try walkPreOrder(c.left, path);
                try walkPreOrder(c.right, path);
                // post
            } else {
                return;
            }
        }
        fn preOrderSearch(node: ?*Node, path: *std.ArrayList(T)) !void {
            try walkPreOrder(node, path);
        }

        fn walkInOrder(curr: ?*Node, path: *std.ArrayList(T)) !void {
            if (curr) |c| {
                // pre
                try walkInOrder(c.left, path);
                // recurse
                try path.append(c.value);
                try walkInOrder(c.right, path);
                // post
            } else {
                return;
            }
        }
        fn inOrderSearch(node: ?*Node, path: *std.ArrayList(T)) !void {
            try walkInOrder(node, path);
        }

        fn walkPostOrder(curr: ?*Node, path: *std.ArrayList(T)) !void {
            if (curr) |c| {
                // pre
                try walkPostOrder(c.left, path);
                // recurse
                try walkPostOrder(c.right, path);
                try path.append(c.value);
                // post
            } else {
                return;
            }
        }
        fn postOrderSearch(node: ?*Node, path: *std.ArrayList(T)) !void {
            try walkPostOrder(node, path);
        }
    };
}

fn printNode(comptime T: type, node: *Tree(T).Node) void {
    std.debug.print("{}\n", .{node.value});
}

test "tree" {
    const T = Tree(u32);
    const allocator = std.testing.allocator;
    var path1 = std.ArrayList(u32).init(allocator);
    var path2 = std.ArrayList(u32).init(allocator);
    var path3 = std.ArrayList(u32).init(allocator);

    var node0 = T.Node{ .value = 0, .left = null, .right = null };
    var node1 = T.Node{ .value = 1, .left = null, .right = null };
    var node2 = T.Node{ .value = 2, .left = null, .right = null };
    var node3 = T.Node{ .value = 3, .left = null, .right = null };
    var node4 = T.Node{ .value = 4, .left = null, .right = null };
    var node5 = T.Node{ .value = 5, .left = null, .right = null };
    var node6 = T.Node{ .value = 6, .left = null, .right = null };
    var node7 = T.Node{ .value = 7, .left = null, .right = null };
    var node8 = T.Node{ .value = 8, .left = null, .right = null };
    var tree = T.init(&node0);
    tree.head.?.left = &node1;
    tree.head.?.right = &node2;
    tree.head.?.left.?.left = &node3;
    tree.head.?.left.?.right = &node4;

    tree.head.?.right.?.left = &node5;
    tree.head.?.right.?.right = &node6;

    tree.head.?.right.?.right.?.left = &node7;
    tree.head.?.right.?.right.?.right = &node8;
    // T.preOrder(tree.head.?, printNode);
    // std.debug.print("\n", .{});
    // T.inOrder(tree.head.?, printNode);
    // std.debug.print("\n", .{});
    // T.postOrder(tree.head.?, printNode);
    // std.debug.print("\n", .{});

    try T.preOrderSearch(tree.head, &path1);
    for (path1.items) |p| {
        std.debug.print("{}\n", .{p});
    }
    std.debug.print("\n", .{});

    try T.inOrderSearch(tree.head, &path2);
    for (path2.items) |p| {
        std.debug.print("{}\n", .{p});
    }
    std.debug.print("\n", .{});

    try T.postOrderSearch(tree.head, &path3);
    for (path3.items) |p| {
        std.debug.print("{}\n", .{p});
    }
    std.debug.print("\n", .{});
    path1.deinit();
    path2.deinit();
    path3.deinit();
}
