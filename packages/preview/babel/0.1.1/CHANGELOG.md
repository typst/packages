# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1](https://codeberg.org/afiaith/babel/releases/tag/0.1.1) - 2024-10-02

### Changed

- License changed from [CC0](https://creativecommons.org/publicdomain/zero/1.0/) to [MIT-0](https://spdx.org/licenses/MIT-0.html), since CC0 is not OSI-approved and thus cannot be submitted to [Typst Universe](https://typst.app/universe/).
- The precompiled PDF manual moved to the Git repository itself.

## [0.1.0](https://codeberg.org/afiaith/babel/releases/tag/0.1.0) - 2024-10-02

Initial Release.

### Added

- `baffle()`, `redact()`, and `tippex` commands ([`src/baffle.typ`](./src/baffle.typ))
- 75 alphabets ([`src/alphabets.yaml`](./src/alphabets.yaml))
- Logo ([`assets/logo.typ`](./assets/logo.typ))
- ‘Tower of `Babel`’ poster ([`assets/poster.typ`](./assets/poster.typ))
- Manual ([`docs/manual.typ`](./docs/manual.typ))
- Scripts (used for development; [`scripts/`](./scripts/))
- Fundamental files:
	- [`README.md`](./README.md)
	- [`LICENSE`](./LICENSE)
	- [`Justfile`](./Justfile)
	- [`typst.toml`](./typst.toml)
	- [`CHANGELOG.md`](./CHANGELOG.md) (this file)
