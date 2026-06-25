# Development Workflow: Z-Graphics RHI

## 1. Branching & Change Process
- **Task Isolation:** Always create a dedicated branch (e.g. `feat/feature-name` or `fix/bug-desc`) for every new feature, bug fix, or chore.
- **Pull Request Creation:** Open a Pull Request (PR) to merge changes into the `master` branch.
- **CI/CD Requirement:** The GitHub Actions CI/CD pipeline must pass cleanly (green light) before any merge.
- **Merge & Clean Up:** Once CI/CD passes successfully, merge the PR (prefer fast-forward/squash) and automatically delete both remote and local branches.

## 2. Code Quality & Formatting
- **Formatting Enforcement:** Code formatting must be checked with `zig fmt` and must be clean before staging changes. CI will enforce formatting checks.
- **Style Alignment:** Follow the engineering rules documented in `conductor/code_styleguides/zig.md` and `conductor/code_styleguides/general.md`.

## 3. Testing Requirements
- **Local Smoke Test Run:** Developers must verify changes locally by building and running the test suite (`zig build test` or `zig-out/bin/smoke-test --all`) before pushing.
- **GitHub Actions Verification:** The test executable will be built and verified automatically in the CI pipeline for Windows, macOS, and Linux targets.

## 4. Phase Completion Protocol
- Each development phase must end with a validation step verifying that all tests pass on both local and CI environments.
- Verify FFI interface compatibility during changes to prevent downstream breakage.
