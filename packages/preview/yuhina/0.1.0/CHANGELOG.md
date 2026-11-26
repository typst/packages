# Changelog

All notable changes to yuhina are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Versioning

yuhina follows [Semantic Versioning](https://semver.org/). The public API consists of the names exported by `lib.typ` and their parameters, as listed in the README; everything under `src/` that `lib.typ` does not export is internal and may change at any time.

Before 1.0.0:

- Breaking changes (removing or renaming a public name, changing a parameter or a default output) bump the minor version, e.g. 0.1.0 → 0.2.0.
- New features that keep existing documents working also bump the minor version.
- Bug fixes bump the patch version, e.g. 0.1.0 → 0.1.1.

From 1.0.0 on, breaking changes bump the major version, new features the minor version, and bug fixes the patch version.

Changes in how a document looks, such as a different fallback font or heading number, are listed under "Changed" even when no name or parameter changes.

## [0.1.0] - 2026-11-23

Initial release.

### Added

- Font lists `font-song`, `font-hei`, `font-kai`, `font-yuan` and `font-fsong`, preferring the Windows/Office fonts common in Taiwan and falling back to Libertinus and Noto CJK TC.
- `--input USE_WIN=1` and `--input USE_LINUX=1` to keep only the fonts of one platform and avoid `unknown font family` warnings.
- Real bold for CJK fonts that ship a bold face and fake bold (via cuti) for those that do not.
- Inline styles `keyword` and `inquote`; `title-block` and `normalize-authors` for title and author blocks.
- Typesetting rules that can be applied one by one: `document-style`, `page-style`, `text-style`, `par-style`, `quote-style`, `list-style`, `figure-style`, `footnote-style`, `heading-style` and `ref-style`; `common-style` applies all of them.
- Six heading levels numbered 壹、一、(一)、1.、(1)、①, with an optional chapter level "Ch. 1" (`large: true`).
- Centered level-1 headings, numbered or not, and a space below every heading equal to the paragraph spacing, so that a heading followed directly by another heading is spaced like one followed by body text.
- Cross-references to headings that print the full heading path, e.g. 見壹、二、(三).
- `plain-links` to drop link styling from the rest of the document.

[0.1.0]: https://github.com/zhenhuang-tw/yuhina/releases/tag/v0.1.0
