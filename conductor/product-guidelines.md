# Product Guidelines: Z-Graphics RHI

## 1. API Surface & Architecture
- **Minimalist C FFI:** Keep the API surface flat and minimal. Do not expose internal structs directly.
- **Predictable C Naming:** All public exported functions, entry points, and flat C-compatible structs must be prefixed with `ZG_` or `ZG` where possible.
- **Dual FFI Surface:** Support clean FFI exports for easy bridging to external platforms.

## 2. Memory Management Guidelines
- **Zero Allocations on Hot-Path:** Avoid dynamically allocating heap memory per frame. Persistent resources (command pools, descriptor pools, staging buffers) must be allocated once and reused.
- **Explicit Destruction:** Every created resource must have a matching `ZG_Destroy*` or equivalent destruction method. All allocated memory must be freed completely upon destruction.

## 3. Error Handling & Debugging
- **Defensive Design:** Fail fast with assertions and clear logs using `std.debug.print` in Debug builds.
- **Safe Release Fallbacks:** In Release configurations (e.g. ReleaseFast/ReleaseSmall), strip debug prints and ensure the API returns predictable safe error codes or stubs (no crashes).
- **Conditional Debugging:** Restrict debug diagnostics to non-production code paths.
