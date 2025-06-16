# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [v0.3.0](https://github.com/ljgago/typst-chords/compare/v0.2.0...v0.3.0) - 2024-03-01

### Changed

- Renamed `frets` parameter by `frets-amount`.
- Renamed `fret-number` parameter by `fret`.
- Renamed `color` parameter by `fill`.
- Replaced `scale` parameter by `size`. You can use the same functionality using `em` units.
- Replaced new types released in Typst v0.8.0.

## [v0.2.0](https://github.com/ljgago/typst-chords/compare/v0.1.0...v0.2.0) - 2023-08-25

### Added

- New file structure.
- New piano chords.
- Options to scale the graphs.
- New round style.

### Changed

- Renamed new-graph-chords to new-chart-chords.
- Replaced array inputs by string inputs (thanks to `conchord` for the ideas).

### Removed

- Removed dependency of CeTZ, uses only native functions.

## [v0.1.0](https://github.com/ljgago/typst-chords/compare/v0.1.0...v0.1.0) - 2023-07-16

### Added

- Added graph chords.
- Added single chords.

### Changed

- The single chords show the chord name over a specific character or word.
