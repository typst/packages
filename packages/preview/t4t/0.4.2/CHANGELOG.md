# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

- Compatibility with Typst 0.13.0.
- Restructuring of package layout for future development.

### Changed
- Renamed `is-rlength` to `is-relative`.

<!-- 
### Version X.X.X

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security
-->

## Version 0.4.1

### Fixed
- Fixed some bugs after renaming modules.

## Version 0.4.0

### Changed
- :warning: Removed `alias` module in favor of the Typst 0.12 `std` module.
- :warning: Changed argument order in `def` module functions.
	- Old behaviour is still available in the `def.compat` module for now.
- :warning: Renamed `is` module to `test` and moved some tests to the top-level module.
	- `is` will become a reserved word in future Typst versions (see [typst/typst#5229](https://github.com/typst/typst/pull/5229))
- Refactored `get.stroke-paint` and `get.stroke-thickness` to use the native `stroke` type.
- Refactored `get.x-align` and `get.y-align` to use the native `align.x` and `align.y` values.

## Version 0.3.3

### Fixed
- Fixed language tag in README for all typst examples.
- Fixed missing whitespace in `get.text` (thanks to @).

### Deprecated
- Deprecated `alias` module in favor of `std` in Typst 0.12.

## Version 0.3.2

### Fixed
- Fixed issue with the new `#type` function in Typst 0.8.0.

## Version 0.3.1

### Fixed
- Some fixes for message evaluation in `assert` module.

## Version 0.3.0

### Added
- Added a manual (build with [tidy](https://github.com/Mc-Zen/tidy) and [Mantys](https://github.com/jneug/typst-mantys)).
- Added simple tests for all functions.
- Added `assert.has-pos`, `assert.no-pos`, `assert.has-named` and `assert.no-named`.
- Added meaningful messages to asserts.
	- Asserts now support functions as message arguments that can dynamically build an error message from the arguments.

### Changed
- Improved spelling. (Thanks to @cherryblossom000 for proofreading.)

### Fixed
- Fixed bug in `is.elem` (see #2).

## Version 0.2.0

### Added
- `is.neg` function to negate a test function.
- `alias.label`.
- `is.label` test.
- `def.as-arr` to create an array of the supplied values. Useful if an argument can be both a single value or an array.
- `assert.that-not` for negated assertions.
- `is.one-not-none` test to check multiple values, if at least one is not none.
- `do` argument to all functions in `def`.
- `is.sequence` test.

### Changed
- Allowed strings in `is.elem` (see #1).

### Deprecated
- Deprecated `get.stroke-paint`, `get.stroke-thickness`, `get.x-align` and `get.y-align` in favor of new Typst 0.7.0 features.

## Version 0.1.0

- Initial release
