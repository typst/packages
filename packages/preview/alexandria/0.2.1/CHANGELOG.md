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

## [0.2.1] - 2025-07-08

### Changed
- update the Hayagriva version used by the plugin from 0.8.0 to 0.8.1, fixing various bugs

## [0.2.0] - 2025-04-23

### Added
- `citegroup` added, which allows creating collapsed citations

### Changed
- the structure in which config data is stored has changed: the state now has `prefixes.at(..).citations` instead of `prefixes.citations.at(..)`. If you use the (internal) functions of the `alexandria.hayagriva` module directly, this is a BREAKING change.
- `get-citation-index()` is now `get-citation-info()` and returns a dictionary with `index` and `group`. If you use the (internal) functions of the `alexandria.hayagriva` module directly, this is a BREAKING change.
- serialization inside the plugin has been simplified
- during serialization, link bodies are no longer wrapped into text elements. If you use the (internal) functions of the `alexandria.hayagriva` module directly, this is a BREAKING change.

### Fixed
- links now don't span whole citations, but only the parts that would be links in vanilla Typst
- `cite(form: none)` is now supported

## [0.1.3] - 2025-03-13

### Added
- Hayagriva's "transparent" content is now supported, enabling citation supplements

### Changed
- `get-bibliography` now accepts `auto` as a parameter if there is only one bibliography

### Fixed
- citations' supplements (such as `[1, p. 42]` instead of `[1]`) are no longer ignored

## [0.1.2] - 2025-03-08

### Added
- support for `bytes` as a bib or csl file parameter, to be up-to-date with Typst 0.13's `bibliography()` API

## [0.1.1] - 2025-02-12

### Added
- `load-bibliography` that stores bib data for later retrieval
- `get-bibliography` that retrieves the data
- `render-bibliography` that renders the bib data
- add details (type, title, author, ...) to data available for bibliography users
- add support for custom CSL styles loaded from files

### Fixed
- fixed a deprecation warning when running Typst 0.13
- split bibliographyx into load, get and render parts

## [0.1.0] - 2025-02-06

### Added

- plugin for rendering references and citations
- Typst wrapper for
  - collecting citations
  - calling the plugin
  - processing its results (rendering structured data into styled content)
- Tests for IEEE and APA references in English and German (APA tests are deactivated to to something that's probably a Typst bug)


[Unreleased]: https://github.com/SillyFreak/typst-alexandria/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.2.1
[0.2.0]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.2.0
[0.1.3]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.1.3
[0.1.2]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.1.2
[0.1.1]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.1.1
[0.1.0]: https://github.com/SillyFreak/typst-alexandria/releases/tag/v0.1.0
