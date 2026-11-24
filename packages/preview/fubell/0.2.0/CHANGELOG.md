# Changelog

## Unreleased

## 0.2.0 - 2026-08-11

### Added

- Added font profile support in `thesis.with(...)` with `font-profile: "submission" | "web" | "portable"`.
- Added optional `font-en` and `font-zh` overrides for custom fallback stacks.
- Added a CLI diagnostics guide in `README.md` for checking effective font config and fallback issues.
- Added `certification-pdf`, `certification-pdf-page`, and `certification-pdf-fit` options to replace the auto-generated certification page with a scanned PDF.
- Added an appendix helper (`#show: appendix`) that switches heading numbering to `附錄A` / `Appendix A`.
- Added `watermark` and `doi` options.
- Added `scripts/stage-release.sh`, which builds the Typst Universe submission directory from source and rewrites the template import to `@preview/fubell:<version>`.

### Fixed

- Fixed `doi` suppressing page numbers throughout the document. A custom page footer replaces the default one, which is what renders `numbering`, so the footer now draws the page number and the DOI together.
- Fixed the scaffolded template failing to compile: `typst init` copies only `template/`, so its `#import "../lib.typ"` could never resolve. The released copy now imports `@preview/fubell:<version>`.
- Reduced duplicated unknown-font warnings by avoiding repeated font stack application in heading styles.

### Changed

- Raised the minimum compiler to Typst 0.14.0. The template uses `outline.entry` set rules and `first-line-indent: (amount:, all:)` (0.13) and PDF-as-image for `certification-pdf` (0.14); the previously declared `0.12.0` floor could not compile the package.

## 0.1.0 - 2026-02-23

- Set up a Typst Universe-conventional package scaffold.
- Added a modular NTU thesis MVP template with bilingual front matter.
- Added a starter thesis project under `template/`.
- Made acknowledgement pages optional (default `none`, rendered only when provided).

