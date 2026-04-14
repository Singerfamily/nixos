{
  dev.rust = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          rustup

          # Testing & watching
          cargo-nextest # Next-generation test runner
          cargo-watch # Watch over Cargo project's source

          # Cross-compilation
          cargo-cross # Zero setup cross-compilation
          cargo-zigbuild # Compile with zig as the linker

          # Project scaffolding & generation
          cargo-generate # New project from git template
          cargo-c # Build and install C-compatible libraries

          # Web / WASM
          cargo-tauri # Build Tauri desktop apps
          cargo-leptos # Build tool for the Leptos web framework
          leptosfmt # Formatter for the leptos view! macro
          trunk # Build, bundle & ship Rust WASM to the web
          dioxus-cli # Develop, test, and publish Dioxus apps

          # Debugging & profiling
          cargo-binutils # Invoke LLVM tools from Rust toolchain
          cargo-valgrind # Runs valgrind and collects output
          cargo-flamegraph # Easy flamegraphs for Rust projects

          # Code quality & auditing
          cargo-semver-checks # Scan for semver violations
          cargo-audit # Audit for security vulnerabilities
          cargo-outdated # Display when dependencies are out of date
          cargo-license # Lists licenses of all dependencies
          cargo-expand # Show results of macro expansion
          cargo-modules # Show tree-like overview of crate modules
          cargo-machete # Detect unused dependencies
          cargo-unfmt # Unformat code into perfect rectangles (meme)

          # Maintenance
          cargo-sweep # Clean up unused build files
          cargo-wizard # Configure Cargo profiles for best performance

          # Installation & binary management
          cargo-binstall # Install rust binaries as alternative to building

          # Database & backend
          diesel-cli # Database tool for projects using Diesel
          sqlx-cli # SQLx command-line utility

          # Build tooling
          bacon # Background rust code checker
          sccache # Ccache with Cloud Storage

          # Linker
          mold # Fast linker
        ];

        # Configure cargo to use mold linker
        home.file.".cargo/config.toml".text = ''
          [target.x86_64-unknown-linux-gnu]
          rustflags = ["-C", "link-arg=-fuse-ld=mold"]
        '';
      };
  };
}
