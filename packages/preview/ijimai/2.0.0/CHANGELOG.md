# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Types of changes: -->
<!-- `Added` for new features. -->
<!-- `Changed` for changes in existing functionality. -->
<!-- `Deprecated` for soon-to-be removed features. -->
<!-- `Removed` for now removed features. -->
<!-- `Fixed` for any bug fixes. -->
<!-- `Security` in case of vulnerabilities. -->
<!-- **Breaking Change:** -->

## [Unreleased]

## [2.0.0]

### Added

- **Breaking Change:** Added ORCID logo and `orcid` key to each author in TOML
  config.
- **Breaking Change:** Add `UnitOT-Light.otf` font.
- Made template PDF/UA-1 compliant.
- Added preprint styling with `paper.preprint` key in TOML config.
- Added PDF metadata based on TOML config.
- The `paper.abstract`'s value in the config can now contain markup mode
  content.
- Added `CHANGELOG.md`.
- Added Development section in `README.md`.
- Documented `blue-unir` and `blue-unir-soft` colors in `README.md`.

### Changed

- **Breaking Change:** Updated and improved a lot of styling:
  - Replaced `N` + superscript `o` with `№` and added space after it in the
    page header.
  - Use title case for keywords.
  - Enforced proper DOI link and display in bibliography.
  - Use `blue-unir` color for bibliography references (in text).
  - Disallowed math mode in table caption.
  - Use title case for table caption.
  - Enforced use of parentheses around institution country.
  - Improved text formatting of `cite-string` content.
  - Text now wraps around the logo (on the left and top sides).
  - Bottom of the logo now aligns perfectly with bottom of underline of
    received/accepted/published line.
  - Make received/accepted/published and DOI centered between colored lines.
  - Simplified gutter values for abstract/keywords grid.
  - Use DOI line's width for keywords column.
  - Replaced `underline` + `overline` usage in DOI line with `block`.
  - Simplified space between "DOI:" and DOI value: only 1 space is copied.
  - Unified space for underline between abstract/keywords and 1st level headings.
  - Unified stroke thickness for underline between:
    - received/accepted/published line,
    - DOI line,
    - 1st level headings.
  - Improved spacing and simplify code for author bio.
- **Breaking Change:** Bumped minimal required Typst version to 0.14.2.
- Use `title()` for paper title.
- Now compiled PDF files are reproducible.
- Reorganized keys in TOML config.
- Updated Testing section in `README.md`.
- Updated mentioned fonts and use permanent links in `README.md`.
- Use title case for headings in `README.md`.
- Check for CRediT roles directly in template (short call stack on error).
- Refactored the rest of the template codebase.

### Removed

- Removed `paper.journal` key from TOML config.
- Removed `paper.publication-year` key from TOML config.

### Fixed

- **Breaking Change:** Fixed and improved a lot of styling:
  - Fixed first word in Introduction: upper semibold -> smallcaps regular.
  - Fixed footnote indentation and space after number.
  - Fixed and improved heading styling:
    - Fixed numbering: `I.A.a)` -> `I.A.1.a)`.
    - Fixed `heading`'s spacing, font, and other settings.
    - Use title case for headings in PDF's Document Outline (i.e., Bookmarks).
    - Added heading numbering in Document Outline.
    - Use consistent spacing between numbering and name: 0.5 em.
  - Fixed abstract/keywords font size: 8.8 → 9 pt.
  - Fixed abstract/keywords (headings): use smallcaps with correct font size
    (14 pt).
  - Fixed "regular issue" header: capitalize "issue."
  - Fixed multiline title leading and splitting: 11 pt + optimized line breaks.
  - Fixed font size of authors line: 13 → 11 pt.
  - Fixed font size of corresponding author: 10 → 8 pt.
  - Fixed received/accepted/published line:
    - Use light font weight.
    - Color the vertical bars in `blue-unir`.
  - Fixed leading below abstract: 5.5 → 5 pt.
  - Fixed leading below keywords: 4 → 5 pt.
  - Fixed DOI line: use light font weight with correct font size (7 pt).
  - Fixed and improved bibliography:
    - Removed link `blue-unir` color and underline.
    - Fixed font size: 7.5 → 8 pt.
    - Use better spacing.
- Fixed page-number-based header styling when `paper.starting-page` is even.

## [1.0.0] - 2025-10-13

### Added

- **Breaking Change:** Added 5 required top-level sections:
  - Introduction
  - CRediT Authorship Contribution Statement
  - Data Statement
  - Declaration of Conflicts of Interest
  - Acknowledgment
- **Breaking Change:** Added `photo` key from each author in `paper.toml`.
- Add validation to `photos` and `bibliography` parameters of `ijimai`.
- Added tests (using Tytanic).
- Added test reference images in `README.md`.
- Added sections in `README.md`: Documentation, API reference, Examples.
- Added documentation for all functions (including their parameters).
- Added new functions: `no-indent`, `Eq`, `read-raw`.
- Added necessary font files directly in the repository.
- Added explicit requirement for Typst 0.13.1 or newer in `typst.toml`.
- Added `read` and `auto-first-paragraph` parameters to `ijimai` function.
- The `photos` parameter of the `ijimai` function can now receive a directory
  path string.
- Added TOML `photo` key for each author in the config (optional, depending on
  type of `ijimai.photos`).
- The `institution`/`bio`'s value of each author in the config can now contain
  markup mode content (e.g., for smart quotes).

### Changed

- **Breaking Change:** Updated and improved a lot of styling.
- **Breaking Change:** Renamed `ijimai.bib-data` → `ijimai.bibliography`.
- **Breaking Change:** Renamed `ijimai.conf` → `ijimai.config`.
- **Breaking Change:** Renamed `blueunir` → `blue-unir`.
- **Breaking Change:** Renamed `softblueunir` → `soft-blue-unir`.
- Refactor half of the template codebase.
- Improved existing text/sections in `README.md`.
- Made `first-paragraph` usage optional (usage is discouraged).
- Made `paper.short-author-list` key in `paper.toml` optional (usually
  shouldn't be used).
- Now Typst Universe thumbnail is synced with latest styling (using a test
  reference image).
- Code of the "cite as" section/box at the bottom is moved into the `ijimai`
  function (and still displays).

### Removed

- **Breaking Change:** Removed coloring of "Equation".
- **Breaking Change:** Removed `conf` parameter from `first-paragraph`.
- **Breaking Change:** Removed unnecessary `ijimai.logo`.
- Removed `include` key from each author in `paper.toml`.

### Fixed

- Fixed warnings by updating `datify` (0.1.3 → 0.1.4).
- Fixed typos in `README.md`.

## [0.0.4] - 2025-04-11

### Added

- **Breaking Change:** Added the "cite as" section/box at the bottom of the
  first page.
- **Breaking Change:** Added required named parameter `conf` to
  `first-paragraph`.

### Changed

- **Breaking Change:** Slightly increased vertical space above table caption.
- **Breaking Change:** Changed bibliography/citation style from ACM to IEEE.
- Updated example usage in `README.md`.
- Code of the "cite as" section/box at the bottom is moved into the
  `first-paragraph` function.

## [0.0.3] - 2025-04-11

### Added

- **Breaking Change:** Added more figure-related styling.
- **Breaking Change:** Color "Equation" in blue (`azulunir`).
- **Breaking Change:** Enclose `ref` in parentheses if referenced element is
  `math.equation`.

### Changed

- **Breaking Change:** Add different styling for figure and table captions.
- **Breaking Change:** Header with journal name, volume, and number text is now
  bold instead of italic (at least that's the intent).
- Wrap `table` in `figure` in the default template document.

## 0.0.2 - 2025-04-03

### Added

- **Breaking Change:** Added `(1)` numbering to `math.equation`.
- **Breaking Change:** Added explicit drop cap (drop capital) function
  `first-paragraph` to be used in the first paragraph of the Introduction
  section, instead of a fragile hack of traversing document through a show
  rule.

### Changed

- Use the new `first-paragraph` function in the default template document.

### Fixed

- Fixed extension of mentioned fonts in `README.md` (`ttf` → `otf`).
- Use `@preview` instead of `@local` in the usage example in `README.md`.

### Removed

- Removed `photo` key from each author in `paper.toml`.

## 0.0.1 - 2025-03-27

Initial release.

[unreleased]: https://github.com/pammacdotnet/IJIMAI/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/pammacdotnet/IJIMAI/compare/v1.0.0...2.0.0
[1.0.0]: https://github.com/pammacdotnet/IJIMAI/compare/v0.0.4...v1.0.0
[0.0.4]: https://github.com/pammacdotnet/IJIMAI/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/pammacdotnet/IJIMAI/releases/tag/v0.0.3
