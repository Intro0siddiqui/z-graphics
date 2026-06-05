const std = @import("std");

pub fn build(b: *std.Build) void {
    var target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Fix for Windows CI: Ensure we use the GNU ABI instead of MSVC
    // to avoid lld-link issues with compiler_rt.lib on GitHub runners.
    if (target.result.os.tag == .windows) {
        target.result.abi = .gnu;
    }

    // Main module for the library
    const lib_mod = b.addModule("z-graphics", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_mod.link_libc = true;

    // Build the static library
    const static_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "z-graphics",
        .root_module = lib_mod,
    });
    b.installArtifact(static_lib);

    // Smoke test executable
    const smoke_test = b.addExecutable(.{
        .name = "smoke-test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/smoke_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Shader compilation step (Vulkan/SPIR-V)
    const shaders_dir = b.path("shaders");
    const basic_hlsl = shaders_dir.path(b, "basic.hlsl");
    
    const compile_vert = b.addSystemCommand(&.{ "glslangValidator", "-V", "-D", "-e", "VSMain", "-S", "vert", "--target-env", "vulkan1.0", "-o" });
    const vert_spirv = compile_vert.addOutputFileArg("basic.vert.spv");
    compile_vert.addFileArg(basic_hlsl);

    const compile_frag = b.addSystemCommand(&.{ "glslangValidator", "-V", "-D", "-e", "PSMain", "-S", "frag", "--target-env", "vulkan1.0", "-o" });
    const frag_spirv = compile_frag.addOutputFileArg("basic.frag.spv");
    compile_frag.addFileArg(basic_hlsl);

    const shader_gen = b.addWriteFiles();
    _ = shader_gen.addCopyFile(vert_spirv, "basic.vert.spv");
    _ = shader_gen.addCopyFile(frag_spirv, "basic.frag.spv");
    const shader_zig = shader_gen.add("shaders.zig",
        \\pub const vert = @embedFile("basic.vert.spv");
        \\pub const frag = @embedFile("basic.frag.spv");
    );

    lib_mod.addAnonymousImport("shaders", .{
        .root_source_file = shader_zig,
    });
    static_lib.root_module.addAnonymousImport("shaders", .{
        .root_source_file = shader_zig,
    });

    smoke_test.root_module.addAnonymousImport("shaders", .{
        .root_source_file = shader_zig,
    });

    smoke_test.root_module.link_libc = true;

    if (target.result.os.tag == .linux) {
        smoke_test.root_module.linkSystemLibrary("vulkan", .{});
        smoke_test.root_module.linkSystemLibrary("X11", .{});
    } else if (target.result.os.tag == .macos) {
        smoke_test.root_module.linkFramework("Metal", .{});
        smoke_test.root_module.linkFramework("Foundation", .{});
        smoke_test.root_module.linkFramework("QuartzCore", .{});
        smoke_test.root_module.linkFramework("AppKit", .{});
    } else if (target.result.os.tag == .windows) {
        smoke_test.root_module.linkSystemLibrary("d3d12", .{});
        smoke_test.root_module.linkSystemLibrary("dxgi", .{});
        smoke_test.root_module.linkSystemLibrary("user32", .{});
        smoke_test.root_module.linkSystemLibrary("kernel32", .{});
    }

    smoke_test.root_module.addImport("lib", lib_mod);
    b.installArtifact(smoke_test);

    const run_cmd = b.addRunArtifact(smoke_test);
    const test_step = b.step("test", "Run smoke test");
    test_step.dependOn(&run_cmd.step);
}
