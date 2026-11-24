# Changelog

The Typst package has its own version axis; its bundled Merman version is recorded separately.

## [0.5.0] - 2026-10-13

Bundles Merman 0.9.0. Existing rendering functions, figures, profiles, and raw-block handlers remain compatible with 0.4.0; plugin ABI 2, options schema 2, and minimum Typst 0.15.0 are unchanged. Update your import to `@preview/merman:0.5.0`. [PR #194](https://github.com/Latias94/merman/pull/194)

### Changed

- SVG backgrounds are transparent. Use `background: "white"` when opaque artwork is needed; otherwise the Typst page shows through. [PR #180](https://github.com/Latias94/merman/pull/180)

### Fixed

- Unicode line breaking keeps long HTML labels within their nodes, with consistent wrapping in layout and embedded SVG. Inherited whitespace rules, preserved newlines, non-breaking spaces, and selected soft hyphens are respected; decoded angle brackets remain literal text during measurement. Thanks [@kossoy](https://github.com/kossoy) for the report. [PR #192](https://github.com/Latias94/merman/pull/192), [PR #193](https://github.com/Latias94/merman/pull/193), [issue #190](https://github.com/Latias94/merman/issues/190)
- Markdown code spans and escaped markup follow each diagram’s label rules: XHTML labels keep literal angle brackets, while Flowchart HTML labels follow Mermaid’s raw-token behavior. Review affected document snapshots. [PR #193](https://github.com/Latias94/merman/pull/193)
- Deeply nested diagrams are safer to parse and clean up after malformed input, cancellation, or a resource-limit error. Mermaid JSON and plugin ABI remain compatible. [PR #191](https://github.com/Latias94/merman/pull/191)
- Hollow Class and ER relationship markers stay hollow in Typst documents. Embedded SVG adapts Mermaid's marker ID-suffix CSS selectors to exact matches supported by Typst's SVG parser, preserving their styling and user overrides. Thanks [@glowcouch](https://github.com/glowcouch) for the report. [PR #182](https://github.com/Latias94/merman/pull/182), [issue #181](https://github.com/Latias94/merman/issues/181)
- Block children reflect later style, class, and type updates; repeated composite declarations retain their first child list and columns. [PR #191](https://github.com/Latias94/merman/pull/191)

## [0.4.0] - 2026-10-09

Published on Typst Universe, bundling Merman 0.8.0 with Mermaid 12.1 behavior, plugin ABI 2, and minimum Typst 0.15.0. See the [dated publication record](https://github.com/Latias94/merman/blob/main/docs/release/PUBLISH_ORDER.md#typst-040-publication). The immutable 0.4.0 package is not rewritten by later source preparation.
