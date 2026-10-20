# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-06-03

### Added
- Added a geometric path pullback calculation for routed links when `link-marks` is enabled, ensuring thick lines stay hidden inside the arrowheads.

### Changed
- Improved the `#deixis-note-outline` rendering engine. It now allows multi-line note bodies to wrap naturally without clipping, and aligns page numbers to the bottom.

### Fixed
- Fixed a panic caused by backlinks on celibate (mark-only) endnotes.
- Fixed an issue where multi-page region marks would calculate incorrect vertical boundaries on non-A4 paper sizes by dynamically resolving Typst's native `auto` margins.

## [0.1.0] - 2026-06-01

### Added
- Initial public release of `deixis` to the Typst Universe.
