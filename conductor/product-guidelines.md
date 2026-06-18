# Product Guidelines: z-graphics RHI

## Documentation Tone
- **Approachable:** Documentation should be direct and accessible, prioritizing tutorial-style examples that help developers integrate quickly.

## API Design Principles
- **Minimalist API:** Expose only the strictly necessary surface area to reduce cognitive load and maintenance overhead.
- **Defensive Design:** API calls should fail fast with clear, actionable error messages during development.
- **Performance First:** Every API design decision must prioritize the zero-copy, low-latency requirements of the browser compositor.

## Engineering Policy: Conditional Debugging
- **Development vs. Production:** Debug printing (`std.debug.print` etc.) must be strictly minimized in production builds to avoid performance overhead.
- **Error Handling Strategy:** Utilize a conditional compilation approach (e.g., using Zig's `comptime` or `builtin.mode`) to include verbose error reporting and debug logs only in `Debug` builds. Ensure these are completely stripped or become no-ops in `ReleaseFast` / `ReleaseSmall` builds.

## Engineering Policy: CI/CD
- **Automated Validation:** Every push to `master` or `main` MUST be followed by an automatic check of the CI pipeline status.
- **Cross-OS Verification:** The pipeline MUST verify build/test success across all target platforms (Linux, macOS, Windows) before any track is considered "complete".
