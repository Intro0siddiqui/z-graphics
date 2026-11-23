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
    lib_mod.addImport("lib", lib_mod);

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

    // Precompiled SPIR-V shaders (self-contained, no external glslangValidator required at build time)
    const shaders_dir = b.path("shaders");
    const shader_gen = b.addWriteFiles();
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "basic.vert.spv"), "basic.vert.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "basic.frag.spv"), "basic.frag.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "shader_test.frag.spv"), "shader_test.frag.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "instanced.vert.spv"), "instanced.vert.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "compute.comp.spv"), "compute.comp.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "ui_sdf.vert.spv"), "ui_sdf.vert.spv");
    _ = shader_gen.addCopyFile(shaders_dir.path(b, "ui_sdf.frag.spv"), "ui_sdf.frag.spv");
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

    // Zawra UI static library (for embedding in zawra browser binary without main)
    const ui_mod = b.createModule(.{
        .root_source_file = b.path("src/ui/shell.zig"),
        .target = target,
        .optimize = optimize,
    });
    ui_mod.addImport("shaders", shaders_mod);
    ui_mod.link_libc = true;
    ui_mod.addIncludePath(b.path("src/platform"));
    ui_mod.addImport("lib", lib_mod);

    const ui_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zawra-ui",
        .root_module = ui_mod,
    });
    b.installArtifact(ui_lib);

    // Zawra Native Zig Browser Shell Executable (standalone test runner)
    const zawra_shell = b.addExecutable(.{
        .name = "zawra-shell",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/ui/main.zig"),
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
