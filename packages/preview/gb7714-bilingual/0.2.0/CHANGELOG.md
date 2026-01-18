# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-21

### Changed

- **Breaking**: `init-gb7714` now accepts file content (bytes) instead of file path
  - Old: `init-gb7714.with("ref.bib", ...)`
  - New: `init-gb7714.with(read("ref.bib"), ...)`
  - Reason: Published packages cannot access user project files
- Hidden `bibliography()` is now automatically included; no manual `#hide(bibliography(...))` needed

## [0.1.0] - 2026-01-12

### Added

- Initial release
- Support for GB/T 7714—2015 and GB/T 7714—2025
- Numeric (顺序编码制) and author-date (著者-出版年制) citation styles
- Automatic Chinese/English language detection
- Author formatting with proper handling of prefixes, suffixes, and hyphenated names
- Same-author-same-year disambiguation (a, b, c suffixes)
- Multi-citation merging with `multicite` function
  - Dictionary arguments with `supplement` for page numbers
- Citation form control (`form` parameter): `prose`, `author`, `year`
- Citation supplement (`supplement` parameter) for page numbers
- Click-to-jump from citations to bibliography
- Complete entry type support (article, book, thesis, conference, report, patent, standard, webpage, etc.)
- Multiple BibTeX file support
