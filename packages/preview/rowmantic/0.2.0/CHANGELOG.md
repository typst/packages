# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-06-09

### Added

- `rowtable` now splits equations as rows, using the default separator `&` (the alignment marker) as cell separator. New examples added for this. #6
- `rowtable` parameter `separator-eq` to control the separator used for equations #6
- `rowtable` now supports table cells with `rowspan` #7
- `rowtable` parameter `column-width` allows configuring column widths without restricting column count #7

## [0.1.1] - 2025-06-03

### Added

- `table` parameter for `rowtable`, to configure which table function to use;
  this allows using rowtable with other table wrappers like `zero.ztable`. #3
- `table.header` and `table.footer` can take a single `expandcell` as their
  content. #5


## [0.1.0] - 2025-05-30

Initial release

### Added

- `rowtable` function
- `row-split` function
- `expandcell` function
- Support for `table.footer` and `table.header` in rowtable.
  They are handled just like other rows, splitting on separator. #2


<!-- versions are final when published on typst universe -->
[Unreleased]: https://github.com/typst-community/rowmantic/compare/v0.1.0...HEAD
[0.2.0]: https://github.com/typst-community/rowmantic/releases/tag/v0.2.0
[0.1.1]: https://github.com/typst-community/rowmantic/releases/tag/v0.1.1
[0.1.0]: https://github.com/typst-community/rowmantic/releases/tag/v0.1.0
