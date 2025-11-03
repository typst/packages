# Changelog

## [0.8.0] - 2024-1229

### Added

* Added `rose-pine` theme.

## [0.7.0] - 2024-12-12

### Changed

* Changed default entry point to `lib.typ`
* Added package details

## [0.6.1] - 2023-12-26

### Changed

* Changed default foreground color name to `default-fg`
* Slightly reduce pdf size by removing default box fill

## [0.6.0] - 2023-12-06

### Fixed

* Removed workaround for a bug in `raw` that fixed in Typst 0.10.0

## [0.5.1] - 2023-10-21

### Fixed

* Fixed height with empty newline

## [0.5.0] - 2023-09-29

### Added

* Added `bold-is-bright` option #2

### Changed

* Allow setting font to none #3
* Changed default font size to `1em`
* Use `raw` to render content now

### Fixed

* Fixed 8-bit colors 8-15 use the wrong colors #4

## [0.4.2] - 2023-09-24

### Added

* Added gruvbox themes #1

## [0.4.1] - 2023-09-22

### Changed

* Changed default font size to `9pt`
* Prevent `set` affects box layout from outside of the function

## [0.4.0] - 2023-09-13

### Added

* Added most options from [`block`]([https://](https://typst.app/docs/reference/layout/block/)) function with the same names and default values
* Added `vscode-light` theme

### Changed

* Changed outmost layout from `rect` to `block`
* Changed default theme to `vscode-light`

## [0.3.0] - 2023-09-09

### Added

* Added `radius` option, default is `3pt`

### Changed

* Changed default font size to `10pt`
* Changed default font to `Cascadia Code`
* Changed default theme to `solarized-light`

## [0.2.0] 2023-08-05

### Changed

* Changed coding style to kebab-case and two spaces

## [0.1.0] 2023-07-02

first release
