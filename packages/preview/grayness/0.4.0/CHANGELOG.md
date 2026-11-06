# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] 2025-08-21

### Added

- `image-mask()` function

## [0.3.0] 2025-03-01

### Added

- Updated documentation with extensive examples
- All functions now also work with SVG images.
- `image-invert()` function
- `image-huerotate()` function
- `image-brighten()` function
- `image-darken()` function

### Changed

- Changed function-name ordering: now "image" always comes first, e.g. `image-grayscale()` instead of `grayscale-image()`. *breaking change*
- All arguments besides the imagebytes are now named instead of positional. *breakin change*
- Flipping is now done via the `scale()`-function and no longer uses the wasm plugin.
- Updated to work with Typst 0.13 without warnings.

### Fixed

- Various typos
- Wrong version numbers and includes in example

## [0.2.0] 2024-10-09

### Added

- Initial Ability to work with SVG (currently only Grayscale)
- Integrated help function using tidy

## [0.1.0]

Initial Release
