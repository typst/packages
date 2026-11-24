# Changelog

This changelog is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Mousse uses [Pride Versioning](https://pridever.org/).

## [v2.0.1] - 2026-09-21

In summary, lots of minor style changes and bug fixes.

### Fixed

- Theorem environments can now break across pages
- Theorem counters reset across chapters

### Changed

- Theorems use just smallcaps instead of smallcaps + bold
- Examples are smallcaps + bold instead of just bold for consistency
- Definitions and examples no longer set the body in italics (following [this Stack Exchange answer][definition-italics])
- Numbered lists (`enum`) are less indented

[definition-italics]: https://tex.stackexchange.com/questions/38260/non-italic-text-in-theorems-definitions-examples#:~:text=is%20recommended%20for-,definitions,-%2C%20conditions%2C%20problems%2C%20and

## [v2.0.0] - 2026-08-27

This update is a general overhaul of Mousse.
In summary:
- The code is more modular and clean.
- The API is redesigned to be less intrusive, so you can write natural Typst code.
- The title page has changed, along with minor style differences.

### Removed

- `book` function
- `glue` and `indent` formatting functions
- `id: ` parameter on theorem environments (use normal reference syntax instead)
- Support for configuring fonts

### Changed

- (breaking) Title page has completely new appearance
- (breaking) Epigraphs are at the start of chapters instead of on the title page
- (breaking) `thm-env` default formatting changed
- Default template page size changed to US Letter folded in half
- Code syntax highlighting now matches the black and white aesthetic
- Spacing and sizing of elements has been adjusted
- Sections are no longer bold
- Lists now support non-tight spacing
- Changelog moved from `README.md` to `CHANGELOG.md`

### Added

- Automatic workaround for <https://github.com/typst/typst/issues/3206>
- `title-page` and `style` functions (replacing the original `book` entrypoint)
    - `title-page` takes metadata like title, author from the document's
      metadata instead of as parameters
- Normal reference syntax (`<label_name>`) for theorem environments

### Fixed

- Handle non-numbered headings better

## [v1.1.0] - 2025-12-30

### Added

- `style` option, and sans-serif style

### Changed

- Improve line breaks on math and theorem environments
- Style code blocks
- Other miscellaneous style changes
