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
        .pic = true,
    });
    lib_mod.link_libc = true;

    if (target.result.os.tag == .linux and !target.result.abi.isAndroid()) {
        lib_mod.addIncludePath(b.path("src/platform"));
        lib_mod.addCSourceFile(.{
            .file = b.path("src/platform/xdg-shell-protocol.c"),
            .flags = &.{},
        });
        lib_mod.linkSystemLibrary("wayland-client", .{});
        lib_mod.linkSystemLibrary("X11", .{});
    }

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

    // Shader compilation step (Vulkan/SPIR-V from GLSL)
    const shaders_dir = b.path("shaders");
    const basic_vert_glsl = shaders_dir.path(b, "basic.vert");
    const basic_frag_glsl = shaders_dir.path(b, "basic.frag");
    const instanced_vert_glsl = shaders_dir.path(b, "instanced.vert");
    const compute_comp_glsl = shaders_dir.path(b, "compute.comp");

    const shader_test_frag_glsl = shaders_dir.path(b, "shader_test.frag");

    const compile_vert = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const vert_spirv = compile_vert.addOutputFileArg("basic.vert.spv");
    compile_vert.addFileArg(basic_vert_glsl);

    const compile_frag = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const frag_spirv = compile_frag.addOutputFileArg("basic.frag.spv");
    compile_frag.addFileArg(basic_frag_glsl);

    const compile_shader_test = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const shader_test_spirv = compile_shader_test.addOutputFileArg("shader_test.frag.spv");
    compile_shader_test.addFileArg(shader_test_frag_glsl);

    const compile_instanced_vert = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const instanced_vert_spirv = compile_instanced_vert.addOutputFileArg("instanced.vert.spv");
    compile_instanced_vert.addFileArg(instanced_vert_glsl);

    const compile_compute = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const compute_spirv = compile_compute.addOutputFileArg("compute.comp.spv");
    compile_compute.addFileArg(compute_comp_glsl);

    const ui_sdf_vert_glsl = shaders_dir.path(b, "ui_sdf.vert");
    const ui_sdf_frag_glsl = shaders_dir.path(b, "ui_sdf.frag");

    const compile_ui_sdf_vert = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const ui_sdf_vert_spirv = compile_ui_sdf_vert.addOutputFileArg("ui_sdf.vert.spv");
    compile_ui_sdf_vert.addFileArg(ui_sdf_vert_glsl);

    const compile_ui_sdf_frag = b.addSystemCommand(&.{ "glslangValidator", "-V", "--target-env", "vulkan1.0", "-o" });
    const ui_sdf_frag_spirv = compile_ui_sdf_frag.addOutputFileArg("ui_sdf.frag.spv");
    compile_ui_sdf_frag.addFileArg(ui_sdf_frag_glsl);

    const shader_gen = b.addWriteFiles();
    _ = shader_gen.addCopyFile(vert_spirv, "basic.vert.spv");
    _ = shader_gen.addCopyFile(frag_spirv, "basic.frag.spv");
    _ = shader_gen.addCopyFile(shader_test_spirv, "shader_test.frag.spv");
    _ = shader_gen.addCopyFile(instanced_vert_spirv, "instanced.vert.spv");
    _ = shader_gen.addCopyFile(compute_spirv, "compute.comp.spv");
    _ = shader_gen.addCopyFile(ui_sdf_vert_spirv, "ui_sdf.vert.spv");
    _ = shader_gen.addCopyFile(ui_sdf_frag_spirv, "ui_sdf.frag.spv");
    const shader_zig = shader_gen.add("shaders.zig",
        \\pub const vert = @embedFile("basic.vert.spv");
        \\pub const frag = @embedFile("basic.frag.spv");
        \\pub const shader_test = @embedFile("shader_test.frag.spv");
        \\pub const instanced_vert = @embedFile("instanced.vert.spv");
        \\pub const compute = @embedFile("compute.comp.spv");
        \\pub const ui_sdf_vert = @embedFile("ui_sdf.vert.spv");
        \\pub const ui_sdf_frag = @embedFile("ui_sdf.frag.spv");
    );

    const shaders_mod = b.createModule(.{
        .root_source_file = shader_zig,
    });

    lib_mod.addImport("shaders", shaders_mod);
    static_lib.root_module.addImport("shaders", shaders_mod);
    smoke_test.root_module.addImport("shaders", shaders_mod);

    smoke_test.root_module.link_libc = true;
    smoke_test.root_module.addIncludePath(b.path("src/platform"));

    // Zawra Native Zig Browser Shell Executable
    const zawra_shell = b.addExecutable(.{
        .name = "zawra-shell",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ui/shell.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    zawra_shell.root_module.addImport("shaders", shaders_mod);
    zawra_shell.root_module.link_libc = true;
    zawra_shell.root_module.addIncludePath(b.path("src/platform"));

    if (target.result.os.tag == .linux) {
        smoke_test.root_module.linkSystemLibrary("vulkan", .{});
        zawra_shell.root_module.linkSystemLibrary("vulkan", .{});
        if (!target.result.abi.isAndroid()) {
            smoke_test.root_module.linkSystemLibrary("X11", .{});
            smoke_test.root_module.linkSystemLibrary("wayland-client", .{});
            zawra_shell.root_module.linkSystemLibrary("X11", .{});
            zawra_shell.root_module.linkSystemLibrary("wayland-client", .{});
        }
    } else if (target.result.os.tag == .macos) {
        // macOS Metal uses pure dynamic dispatch via dlopen/dlsym/libobjc at runtime.
        // No compile-time framework stubs required, enabling clean cross-compilation from Linux/Windows hosts.
    } else if (target.result.os.tag == .windows) {
        smoke_test.root_module.linkSystemLibrary("d3d12", .{});
        smoke_test.root_module.linkSystemLibrary("dxgi", .{});
        smoke_test.root_module.linkSystemLibrary("user32", .{});
        smoke_test.root_module.linkSystemLibrary("kernel32", .{});
        zawra_shell.root_module.linkSystemLibrary("d3d12", .{});
        zawra_shell.root_module.linkSystemLibrary("dxgi", .{});
        zawra_shell.root_module.linkSystemLibrary("user32", .{});
        zawra_shell.root_module.linkSystemLibrary("kernel32", .{});
    }

    smoke_test.root_module.addImport("lib", lib_mod);
    zawra_shell.root_module.addImport("lib", lib_mod);

    if (!target.result.abi.isAndroid()) {
        b.installArtifact(smoke_test);
        b.installArtifact(zawra_shell);

        const run_cmd = b.addRunArtifact(smoke_test);
        const test_step = b.step("test", "Run smoke test");
        test_step.dependOn(&run_cmd.step);
    }
}
