# Technology Stack: z-graphics RHI

## Core Language
- **Language:** [Zig](https://ziglang.org/) (0.16.0)
- **Build System:** Zig Build (`build.zig`)

## Graphics Abstraction (RHI)
- **Linux/Android:** [Vulkan](https://www.khronos.org/vulkan/) (via `VK_KHR_surface`)
- **Windows:** [DirectX 12 (D3D12)](https://learn.microsoft.com/en-us/windows/win32/direct3d12/direct3d-12-graphics)
- **macOS/iOS:** [Metal](https://developer.apple.com/metal/)

## Shader Pipeline
- **Shader Language:** [HLSL](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl)
- **Compilation Toolchain:** [DirectXShaderCompiler (DXC)](https://github.com/microsoft/DirectXShaderCompiler)
- **Cross-Compilation:** [SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross) (for Metal support)

## CI/CD and Tooling
- **CI/CD:** [GitHub Actions](https://github.com/features/actions)
- **Code Style/Lint:** Standard `zig fmt`
