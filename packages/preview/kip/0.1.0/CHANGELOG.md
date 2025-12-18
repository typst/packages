# Changelog

All notable changes to **Kip** - the Pikchr plugin for Typst will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-17

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
- `image.decode` deprecation warning (to be updated for Typst 0.15.0)
- Some complex nested diagrams may have edge cases

## [Unreleased]

### Planned
- Dark mode support
- Additional helper functions for common diagram patterns
- Performance optimizations
- Support for Typst 0.15.0 image API changes
- Additional examples and templates
