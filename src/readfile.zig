const std = @import("std");

pub fn main() !void {
   // Initiate allocator
   var gpa = std.heap.GeneralPurposeAllocator(.{}){};
   defer _ = gpa.deinit();
   const alloc = gpa.allocator();

   // Read contents from file "./filename"
   const cwd = std.fs.cwd();
   const fileContents = try cwd.readFileAlloc(alloc, "src/lexicon/hebrew/H1.md", 4096);
   defer alloc.free(fileContents);

   // Print file contents
   std.debug.print("{s}", .{fileContents});
}
