<!-- Reference: https://github.com/typst-community/typst-package-template/blob/main/CHANGELOG.md -->

# Changelog

## [Unreleased]

## [0.1.2] - 2025-07-17

### Added
- Added ability to hide table of contents (toc) (#5) - Set `depth-toc` to `none`
- Added logic for bibliography usage to the template (#8)
- Added additional styling in template (#9)
- Added centralized package management for imports

### Changed
- Updated [glossarium] to version 0.5.8
- Updated [hydra] to version 0.6.1 
- Replaced `"Roboto"` font with `default-font` (#7)

### Removed
- Removed unnecessary paragraph settings from `card` and `author-box` definitions (#6)

### Fixed
- Fixed typo in example thesis (DE)

## [0.1.1] - 2025-03-30

### Changed

- Updated used packages, thanks [@fritz-m-h]
- BREAKING: in `abbreviations()`, the `desc` parameter is now named `description`, thanks [@fritz-m-h]
- For glossary entries / abbreviations, having only a long form is not permitted

### Fixed

- Fixed broken todo functionality (caused by deprecated locate function), thanks [@fritz-m-h]
- Fixed broken footer when `thesis-compliant` was set to `true`, thanks [@fritz-m-h]

> The template is now compatible with Typst 0.13

## [0.1.0] - 2024-07-30

Initial Release, thanks [@SillyFreak]

<!--
Below are the target URLs for each version
You can link version numbers (in level-2 headings)
to the corresponding tag on GitHub, or the diff
in comparison to the previous release
-->

[Unreleased]: https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/releases/tag/v0.1.2
[0.1.1]: https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/releases/tag/v0.1.1
[0.1.0]: https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/releases/tag/v0.1.0

<!--
Below are the GitHub profile links of contributors
-->

[@SillyFreak]: https://github.com/SillyFreak
[@fritz-m-h]: https://github.com/fritz-m-h

<!--
Below are used Typst package links
-->
[citegeist]: https://typst.app/universe/package/citegeist
[codly]: https://typst.app/universe/package/codly
[glossarium]: https://typst.app/universe/package/glossarium
[hydra]: https://typst.app/universe/package/hydra
[linguify]: https://typst.app/universe/package/linguify
