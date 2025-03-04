# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.10.2] - 2025-02-05

### Changed

- Updated code to work nicely with Typst v0.12.0. Will not compile with older
  versions. (**breaking change**).
- Made `example.typ` reproducible for the same compiler version.

## [0.10.1] - 2023-12-01

### Changed

- Hid the default recipe (from `just -l`) in the `.justfile`.
- Removed `tag` argument wherever it's not needed in the `.justfile`.

### Added

- Added `Development` and `Publishing a Typst package` sections in the `README.md`.
- Added keywords in the `typst.toml`: `ルビ`, `振り仮名`, `ふりがな`.

## [0.10.0] - 2023-11-24

### Changed

- Values are now compared with "first-class values" types instead of strings
  (see [Typst 0.8.0 release notes](https://github.com/typst/typst/releases/tag/v0.8.0))
  (**breaking change**).

### Added

- Added minimal Typst version to `0.8.0` (see the reason above).

## [0.9.2] - 2023-09-14

### Fixed

- Fixed import in example.typ.

## [0.9.1] - 2023-09-14

### Fixed

- Fixed example.typ.

## [0.9.0] - 2023-09-14

### Changed

Now kebab case is used instead of snake case.

- Renamed function `get_ruby` to `get-ruby` (**breaking change**).
- Renamed `get-ruby`'s argument `auto_spacing` to `auto-spacing` (**breaking
  change**).

## [0.8.0] - 2023-07-03

Initial release.

[0.10.1]: https://github.com/Andrew15-5/rubby/releases/tag/v0.10.1

[0.10.0]: https://github.com/Andrew15-5/rubby/releases/tag/v0.10.0

[0.9.2]: https://github.com/Andrew15-5/rubby/releases/tag/v0.9.2

[0.9.1]: https://github.com/Andrew15-5/rubby/releases/tag/v0.9.1

[0.9.0]: https://github.com/Andrew15-5/rubby/releases/tag/v0.9.0

[0.8.0]: https://github.com/Andrew15-5/rubby/releases/tag/v0.8.0
