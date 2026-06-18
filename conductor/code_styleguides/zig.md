# Zig Engineering Rules (Hajr & Z-Net Style)

This guide defines the engineering standards, architectural patterns, and Zig `0.16.0` constraints for high-performance, cross-platform graphics programming.

## 1. Core Language Standards
- **Memory Management**: Use `std.ArrayListUnmanaged(T)` for all performance-critical paths. This enforces passing an `Allocator` to every mutating operation.
- **Allocator Pattern**: Always pass an explicit `std.mem.Allocator` to any function that performs allocation or deallocation.
- **Error Handling**: Use `try` for all syscalls. Map `errno` to domain-specific `Error` types.
- **Atomic Ordering**: Project policy forbids explicit `@fence` calls. Use operation-level memory ordering (`.acquire`, `.release`, `.acq_rel`).
- **Pointers & Casting**: 
    - `@ptrCast` requires explicit target types.
    - Raw Syscalls: Use `@bitCast` to convert packed structs to `u32`.
- **Platform Page Sizing**: Never hardcode `4096` alignments. Use `std.heap.page_size_min`.

## 2. Platform Portability (The "Zig Method")
When implementing OS-specific logic, use compile-time dispatch to provide the fastest native implementation while maintaining a single public API.

**Rule:** **1 API, 3 Fast Code Paths.**

```zig
pub fn getRxBytes(allocator: std.mem.Allocator, ifname: []const u8) !u64 {
    return switch (builtin.os.tag) {
       .linux => try getRxBytesLinux(ifname),
       .macos, .freebsd, .openbsd, .netbsd => try getRxBytesBsd(allocator, ifname),
       .windows => try getRxBytesWindows(ifname),
        else => error.UnsupportedOs,
    };
}
```

## 3. Hardware Abstraction Layer (HAL)
The HAL is the boundary between hardware primitives (Vulkan, Metal, D3D12) and the browser core.

- **No Bypassing**: Never call raw OS-level memory mapping (mmap, mprotect) outside of the `hw` module.
- **Architecture**: 
    1. **Facade (`src/hw/mod.zig`)**: Public API.
    2. **OS Abstraction (`src/hw/os_abstraction.zig`)**: OS boundary.
    3. **Hardware Implementation (`src/hw/arch/`)**: Pure implementation.

## 4. Unified I/O
Use `std.Io` for networking, files, and timers.

**Rule:** All structs or functions performing I/O must accept an `io_ctx: *std.Io` parameter.

## 5. Migration & Best Practices
- **Timing**: Use `hw.os.monotonicTimestamp()` (nanoseconds) for portable timing.
- **Atomics**: Use `std.atomic.Value(T)` with explicit memory ordering.
- **Memory Protection**: All guard page probing and memory protection changes must go through `hw.os.memProtect`.
- **Testing**: Use `zig build test` after every major change. Use `std.mem.doNotOptimizeAway()` to prevent compiler optimization in benchmarks.
