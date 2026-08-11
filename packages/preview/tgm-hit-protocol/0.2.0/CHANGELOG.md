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

## [0.2.0] - 2025-11-25

### Changed
- BREAKING: the minimum supported Typst version is now 0.13.1
- Several packages were updated to their most recent versions, among them glossarium:
  - for glossary entries, having only a `long` form is now permitted
  - BREAKING: glossarium no longer supports keys containing `:` colons
  - BREAKING: in `glossary-entry()`, the `desc` parameter is now named `description`
  - BREAKING: glossary entries are now defined differently, see [the diff of the template](https://github.com/TGM-HIT/typst-protocol/commit/a9ce50817370262b33c583c7e84ab450e5516b93#diff-7c3fcb5c97b51160af4b4a26981b152d6995f8ec0077281456d3f51f4b0e9d84) for an example

### Fixed
- The template is now Typst 0.14 compatible

## [0.1.0] - 2024-10-09

- Initial version


[Unreleased]: https://github.com/TGM-HIT/typst-protocol/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/TGM-HIT/typst-protocol/releases/tag/v0.2.0
[0.1.0]: https://github.com/TGM-HIT/typst-protocol/releases/tag/v0.1.0
