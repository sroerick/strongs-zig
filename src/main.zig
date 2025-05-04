const std = @import("std");
const cli = @import("zig-cli");

const Config = struct {
    hebrew: ?i64 = null,
    greek: ?i64 = null,
};

var config = Config{};

pub fn main() !void {
    var runner = try cli.AppRunner.init(std.heap.page_allocator);

    const app = cli.App{
        .command = cli.Command{
            .name = "strongs", // this name is required but won't be typed in the CLI
            .options = try runner.allocOptions(&.{
                .{
                    .long_name = "hebrew",
                    .short_alias = 'i',
                    .help = "Hebrew reference number",
                    .value_ref = runner.mkRef(&config.hebrew),
                },
                .{
                    .long_name = "greek",
                    .short_alias = 'g',
                    .help = "Greek reference number",
                    .value_ref = runner.mkRef(&config.greek),
                },
            }),
            .target = cli.CommandTarget{
                .action = cli.CommandAction{ .exec = run_main },
            },
        },
    };

    return runner.run(&app);
}

fn run_main() !void {
    const is_hebrew = config.hebrew != null;
    const is_greek = config.greek != null;

    if (is_hebrew and is_greek) {
        std.debug.print("Error: Cannot use both -h and -g at the same time.\n", .{});
        return;
    } else if (!is_hebrew and !is_greek) {
        std.debug.print("Usage: strongs -h <ref> | -g <ref>\n", .{});
        return;
    }

    if (is_hebrew) {
        try readFile(1, config.hebrew.?);
    } else {
        try readFile(2, config.greek.?);
    }
}




fn readFileExec() !void {
    try readFile(1, 1);
}


fn readFile(lang: i64, ref: i64) !void {
   // Initiate allocator
   var gpa = std.heap.GeneralPurposeAllocator(.{}){};
   defer _ = gpa.deinit();
   const alloc = gpa.allocator();
   var langprefix: []const u8 = undefined;  
   var path: []const u8 = undefined;  
   if (lang == 1) {
       langprefix = "H";
       path = try std.fmt.allocPrint(alloc, "src/lexicon/hebrew/{s}{d}.md", .{langprefix, ref});
   } else {
       langprefix = "G";
       path = try std.fmt.allocPrint(alloc, "src/lexicon/greek/{s}{d}.md", .{langprefix, ref});
   }


   defer alloc.free(path);

   const cwd = std.fs.cwd();
   // const fileContents = try cwd.readFileAlloc(alloc, path, 4096);
    const fileContents = try cwd.readFileAlloc(alloc, path, 4096); //{
    // const fileContents = cwd.readFileAlloc(alloc, path, 4096) catch |err| {
    //     switch (err) {
    //         error.FileNotFound => {
    //             std.debug.print("File not found: {}\n", .{path});
    //         },
    //         else => {
    //             std.debug.print("An error occurred while reading the file: {}\n", .{err});
    //         },
    //     }
    //     return err; 
    // };
    //

   defer alloc.free(fileContents);

   std.debug.print("{s}", .{fileContents});
   //return(fileContents);
}
