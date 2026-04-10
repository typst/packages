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

## [0.3.0] - 2025-03-13

<details>
<summary>Migration guide from v0.2.x</summary>

To get a feeling what you need to change, compare [`template/main.typ`](https://github.com/TGM-HIT/typst-diploma-thesis/blob/v0.3.0/template/main.typ) with what you have. In particular, you will probably need to

- add a parameter `read: path => read(path),` to the initial `thesis()` template call
- remove `strict-chapter-end: true,` if you were using it
- remove all instances of `#chapter-end()`

Additionally, you should have a look at [`template/bibliography.bib`](https://github.com/TGM-HIT/typst-diploma-thesis/blob/v0.3.0/template/bibliography.bib#L42-L46) which demonstrates how to cite a prompt.
A (German) prose explanation of the usage of prompts can be found in the [Example document](https://github.com/TGM-HIT/typst-diploma-thesis/blob/v0.3.0/example.pdf), section 1.2 _Promptverzeichnis_.

</details>

### Added
- BREAKING: `thesis()` has an extra `read` parameter for initializing Alexandria
- There is now a separate List of Prompts

### Changed
- BREAKING: in `glossary-entry()`, the `desc` parameter is now named `description`
- for glossary entries, having only a `long` form is not permitted
- bibliography is now handled by Alexandria
- inline quotes with attribution now display that attribution

### Removed
- BREAKING: `chapter-end()` and `strict-chapter-end` have been removed

### Fixed
- setup of the `i-figured` package works again
- the template is now compatible with Typst 0.13
- descriptions of glossary items are no longer ignored
- an empty glossary is now automatically hidden

### Security

## [0.2.0] - 2024-10-23

### Changed
- long chapter titles now look nicer in the header
- **breaking:** glossary entries are now defined differently, see [the diff of the template](https://github.com/TGM-HIT/typst-diploma-thesis/commit/8c4d03a14ac3ddab6718cc7e11341924c66703bd#diff-7c3fcb5c97b51160af4b4a26981b152d6995f8ec0077281456d3f51f4b0e9d84) for an example
- **regression:** if there are no glossary references, an empty glossary section will be shown (glossarium 0.5 hides a couple private functions, see [glossarium#70](https://github.com/typst-community/glossarium/issues/70))

### Fixed
- fix deprecation warnings and incompatibilities introduced in 0.12, in part by updating codly, glossarium and outrageous

## [0.1.3] - 2024-09-14

### Changed
- get rid of more custom outline styling thanks to outrageous:0.2.0

## [0.1.2] - 2024-09-14

(this version was released in a broken state)

## [0.1.1] - 2024-09-09

### Added
- adds support for highlighting authors of individual pages of the thesis, which is a requirement for the thesis' grading

### Changed
- replaces some custom outline styling with [outrageous](https://typst.app/universe/package/outrageous)

## [0.1.0] - 2024-07-13

Initial Release


[Unreleased]: https://github.com/TGM-HIT/typst-diploma-thesis/compare/v0.2.0...HEAD
[0.3.0]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.3.0
[0.2.0]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.2.0
[0.1.3]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.3
[0.1.2]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.2
[0.1.1]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.1
[0.1.0]: https://github.com/TGM-HIT/typst-diploma-thesis/releases/tag/v0.1.0
