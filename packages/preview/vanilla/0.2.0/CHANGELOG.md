# Changelog

All notable changes to the Vanilla Typst package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-25

### Changed
- Refactored `vanilla()` function arguments to accept styles with smart defaults
- Improved text setting application to ensure proper body font and size handling

### Fixed
- Fixed bug where text settings were not properly applied for body font and size

### Removed
- Removed unused `par-single-spaced` import from library code
- Removed typst-packages subproject reference

### Documentation
- Updated README.md with improved documentation
- Updated GITHUB_ACTION.md with workflow improvements
- Updated examples to reflect new API changes

## [0.1.1] - 2025-05-18

### Changed
- Minor improvements and bug fixes

## [0.1.0] - 2025-05-16

### Added
- Initial release of the Vanilla Typst package
- Basic styling functions similar to MS Word defaults
- Single and double spacing options for paragraphs
- Shadow box element for figures
- Customizable margins, fonts, and font sizes
- Template for creating new documents
