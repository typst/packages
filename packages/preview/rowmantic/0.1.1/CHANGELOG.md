# Changelog

All notable changes to this project will be documented in this file.

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
[0.1.1]: https://github.com/typst-community/rowmantic/releases/tag/v0.1.1
[0.1.0]: https://github.com/typst-community/rowmantic/releases/tag/v0.1.0
