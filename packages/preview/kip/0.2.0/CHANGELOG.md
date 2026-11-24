# Changelog

All notable changes to **Kip** - the Pikchr plugin for Typst will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Additional helper functions for common diagram patterns
- Performance optimizations
- Additional examples and templates

## [0.2.0] - 2026-11-16

### Added
- Dark mode: `kip(..., dark: true)` inverts colors for dark backgrounds
  (Pikchr's `PIKCHR_DARK_MODE`). `render-dark()` is now a real shorthand for
  it instead of a placeholder.
- Visual examples gallery in the README

### Changed
- Pikchr syntax errors now fail compilation with Pikchr's own plain-text
  error message instead of a generic "failed to parse SVG" error
- Minimum Typst version is now 0.13.0 (the first version where `image()`
  accepts bytes, which 0.1.0 already relied on)
- WASM module rebuilt from current Pikchr trunk (2026-01-02; no rendering
  changes relative to the Pikchr bundled with 0.1.0)
- `build.sh` now fetches the Pikchr source tree and generates `pikchr.c`
  itself, since upstream no longer ships a pre-generated `pikchr.c`
- Built with Emscripten 5.0.6 and wasi-stub 0.3.2; the build scripts now pass
  `--stub-module wasi_snapshot_preview1` explicitly, which wasi-stub 0.3
  requires when `--stub-function` is also given

### Fixed
- Typst deprecation warning for `image.decode`
- Invalid category in `typst.toml`

## [0.1.0] - 2025-12-17

### Added
- Initial release of Kip (Pikchr plugin for Typst)
- WebAssembly-based SVG diagram rendering
- Support for both string and raw block (```) input
- `kip()` function as primary interface
- `pikchr()` and `render()` aliases for compatibility and convenience
- Optional width, height, and fit parameters
- Comprehensive documentation and examples
- Build scripts for regenerating WASM module
- Example file (`example_simple.typ`) with common diagram patterns

### Technical Details
- Built with Emscripten 4.0.21
- Uses wasm-minimal-protocol for Typst plugin interface
- WASM module size: ~125KB
- Compatible with Typst 0.12.0+

### Naming
- Package name: `kip` (clever reverse of "pik" from Pikchr)
- Main function: `kip()`
- Aliases: `pikchr()`, `render()`

### Known Issues
- Font warning may appear if "Linux Libertine" font is not installed
- Some complex nested diagrams may have edge cases
