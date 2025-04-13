# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [v0.5.0](https://github.com/ljgago/typst-chords/compare/v0.4.0...v0.5.0) - 2024-10-31

### Changed

- Repaced the default font `Linux Libertine` deprecated in typst v0.12.0 with the new default font `Libertinus Serif`.
- Replaced `locate` callback function deprecated in typst v0.12.0 with location context in documentation template and examples.

## [v0.4.0](https://github.com/ljgago/typst-chords/compare/v0.3.0...v0.4.0) - 2024-07-09

### Added

- New `background` parameter, now in `chart-chord`, `piano-chord` and `single-chord`. Add a background color on the chord name.
- New `position` parameter in `chart-chord`, `piano-chord`. Now the chart can be below or above of the chord name.
- New `..text-params` in `chart-chord`, `piano-chord` and `single-chord`. It embeds the native text parameters from the standard library of typst.

### Changed

- Renamed `new-chart-chords`, `new-piano-chords` and `new-single-chords` functions by `chart-chord`, `piano-chord` and `single-chord` removing the closure functions. Use the [with](https://typst.app/docs/reference/foundations/function/#definitions-with) property for preset the parameters.
- Renamed `style` parameter by `design` to avoid name collision with the native text parameters. The possible values of `design` are `"sharp"` and `"round"`
- Renamed `fill` parameter by `fill-key` to avoid name collision with the native text parameters.
- Replaced the `styles-measure` syntax by the new [context-measure](https://typst.app/docs/reference/context/) added in Typst v0.11.0.
- Refactored the render and the graphic objects, now each object calculates its own relative position.

### Removed

- Removed `size` as a specific parameter. `size` is included in the native *text* parameters in `..text-params`.

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
