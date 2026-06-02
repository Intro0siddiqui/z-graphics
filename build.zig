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

    const install_vert = b.addInstallFile(vert_spirv, "shaders/basic.vert.spv");
    const install_frag = b.addInstallFile(frag_spirv, "shaders/basic.frag.spv");

    smoke_test.step.dependOn(&install_vert.step);
    smoke_test.step.dependOn(&install_frag.step);

    smoke_test.root_module.link_libc = true;

    if (target.result.os.tag == .linux) {
        smoke_test.root_module.linkSystemLibrary("vulkan", .{});
    } else if (target.result.os.tag == .macos) {
        smoke_test.root_module.linkFramework("Metal", .{});
        smoke_test.root_module.linkFramework("Foundation", .{});
        smoke_test.root_module.linkFramework("QuartzCore", .{});
    } else if (target.result.os.tag == .windows) {
        smoke_test.root_module.linkSystemLibrary("d3d12", .{});
        smoke_test.root_module.linkSystemLibrary("dxgi", .{});
    }

    smoke_test.root_module.addImport("lib", lib_mod);
    b.installArtifact(smoke_test);

    const run_cmd = b.addRunArtifact(smoke_test);
    const test_step = b.step("test", "Run smoke test");
    test_step.dependOn(&run_cmd.step);
}
