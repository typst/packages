# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

<details>
<summary>Migration guide from v0.1.x</summary>

<!-- Write migration guide here -->

</details>

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.1] - 2025-06-25

### Changed

- replace `debug` with `border` to indicate its broader usefulness; `border` also accepts `"labels"`
  and `"sublabels"` for only drawing some borders. (see #2)

### Deprecated

- the `debug` parameter

### Fixed

- multi-page label sheets now work correctly (see #1)

## [0.1.0] - 2025-02-23

### Added

- `sheet` function for specifying sheet sizes
- `repeat` and `skip` functions for skipping and repeating grid cells
- `labels` function for layouting a grid of labels on a sheet
- typechecking, tests, and documentation


[Unreleased]: https://github.com/SillyFreak/typst-etykett/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/SillyFreak/typst-etykett/releases/tag/v0.1.1
[0.1.0]: https://github.com/SillyFreak/typst-etykett/releases/tag/v0.1.0
