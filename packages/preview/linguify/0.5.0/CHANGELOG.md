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

## [0.5.0] - 2025-12-15

<details>
<summary>Migration guide from v0.4.x</summary>

The following identifiers have been renamed and need to be changed in your source code:

- `load_ftl_data` --> `load-ftl-data`
- `data_type` key in database `toml` files --> `data-type`
- `lflib.get_text` --> `lflib.get-text`
- `lflib.fluent.get_message` --> `lflib.fluent.get-message`

(there should be no need to use `lflib` directly, so the first two should be enough)

<!-- Write migration guide here -->

</details>

### Added

- Add `database-at()` that allows one to use a database that is active in another part of the document.
  This is mainly for outlines, where you may want to use the database used for the heading, instead of the one active at the outline.
- Add `linguify-raw()` which requires external `context` and thus returns non-opaque results.
  This can _also_ be used for outlines, but also enables a bunch of other use cases that require inspecting translated text.

### Changed

- **BREAKING:** identifiers now use kebab-case consistently; see the migration guide for a list

### Fixed

- discrepancies between manual and implementation have been fixed


[Unreleased]: https://github.com/SillyFreak/typst-alexandria/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.5.0
