# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-04-21

### Fixed

- Appendix heading numbering now correctly renders as "Appendix A.", "Appendix A.1.", etc. instead of bare "A.1." format

### Added

- Automated GitHub Actions release workflow triggered on version tags
- `create-release.sh` helper script for creating and pushing release tags with pre-flight checks
- `RELEASE.md` documenting the release process

## [0.1.0] - 2026-01-16

### Added

- Initial release of the IOP Publishing article template
- Support for IOP journal formatting
- Template includes title, abstract, authors, institutions, and keywords
- Appendix environment support
- Basic document structure and styling
- Example template with sample content

### Features

- Journal-specific formatting
- Author and institution management
- Paper metadata support (year, volume, etc.)
- Keywords support
- Bibliography support via BibTeX

[0.1.1]: https://github.com/munechika-koyo/ioppub/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/munechika-koyo/ioppub/releases/tag/v0.1.0
