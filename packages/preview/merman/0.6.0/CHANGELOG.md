# Changelog

The Typst package has its own version axis; its bundled Merman version is recorded separately.

## [0.6.0] - 2026-11-12

Bundles Merman `0.10.0` with Mermaid `12.3.0` behavior. Update imports to `@preview/merman:0.6.0` and review the migration actions below. The minimum compiler remains Typst `0.15.0`.

### Breaking changes and upgrade actions

- The plugin advances from ABI `2` to `3` and render options from schema `2` to `3`. Use the wrapper and WASM from the same package. Replace raw options `presentation` with top-level `theme` selecting a preset, recipe, or complete spec; send `version: 3` for explicitly versioned options. [PR #178](https://github.com/Latias94/merman/pull/178)
- Replace `presentation-profile` and `host-theme` with `theme-preset`, `theme-recipe`, or `diagram-theme`; keep `typography` for font intent. Rename the old Mermaid-variable `theme` shorthand to `theme-variables`; `theme-name` still selects Mermaid's own theme. The removed `scoped-css` and `css-override-policy` controls, including their raw options fields, are rejected; use typed themes, Mermaid variables, or `background` for document styling. See [Upgrading from 0.5.0](README.md#upgrading-from-050). [PR #178](https://github.com/Latias94/merman/pull/178)

### Added

- Select reusable compiled themes across rendering, figures, SVG/results, and raw blocks. The catalog contains 11 designs and 14 concrete appearances, including Light-only `paper-cut`, `carbon-copy`, and `pop-art`. Select paired `editor`, `gruvbox`, or `ayu` with `theme-appearance: "light"` or `"dark"`; concrete IDs such as `editor-dark` stay fixed to that appearance. Presets and recipes compose with default typography and document context while retaining authored family and role overrides. [PR #178](https://github.com/Latias94/merman/pull/178), [PR #284](https://github.com/Latias94/merman/pull/284), [PR #301](https://github.com/Latias94/merman/pull/301), [PR #302](https://github.com/Latias94/merman/pull/302)
- Discover installed designs with `theme-catalog()`, export complete editable JSON with `export-theme-preset`, and inspect or materialize shared recipes with `materialize-theme`. `mermaid-theme-definition` renders an authored definition directly, and `describe-theme-support` reports support by family and output. Theme spec, authoring, recipe, materialization, support, and catalog contracts remain at version `1`, as do preset revisions. These APIs and presets remain Alpha; availability does not qualify every effect for Typst output. [PR #178](https://github.com/Latias94/merman/pull/178), [PR #253](https://github.com/Latias94/merman/pull/253), [PR #284](https://github.com/Latias94/merman/pull/284)

### Changed

- Advance from Mermaid `12.1.0` to `12.3.0` and ELK `0.12.1`. Flowchart adds Step groups, numbered badges, and nine BPMN shapes; Step output is static in Typst. Mindmap gains depth coloring, and Agentflow, Usecase, Swimlane, and ELK layouts follow updated upstream behavior. Review layout and SVG snapshots; the existing ELK defaults and Dagre selection remain available. [PR #196](https://github.com/Latias94/merman/pull/196), [PR #277](https://github.com/Latias94/merman/pull/277)
- SVG rendering defaults to **14,100,000 layout work units** while retaining the other `constrained` ceilings, allowing larger Mindmaps to render without a custom limit. Explicit finite `resources.limits.max_layout_work_units` values can lower or raise the allowance through raw options or a reusable profile; an explicit `constrained` profile retains **125,000** unless overridden. Analysis and theme operations retain their constrained defaults. [Issue #300](https://github.com/Latias94/merman/issues/300)

### Fixed

- Labels and export bounds account for supported inline font sizes, inherited weights, code fonts, wrapping, and container padding more consistently across Flowchart, Class, ER, Requirement, and Kanban. Escaped HTML/SVG text, Class notes, and Kanban line breaks retain their intended content. Review affected document snapshots. [PR #247](https://github.com/Latias94/merman/pull/247), [PR #250](https://github.com/Latias94/merman/pull/250), [PR #283](https://github.com/Latias94/merman/pull/283), [PR #286](https://github.com/Latias94/merman/pull/286), [PR #298](https://github.com/Latias94/merman/pull/298), [PR #299](https://github.com/Latias94/merman/pull/299)
- Source parsing preserves quoted and multiline labels, Unicode whitespace, comment boundaries, and accessibility text more consistently. Header-only Class programs now fail validation; add a direction statement for an empty diagram. [PR #294](https://github.com/Latias94/merman/pull/294), [PR #297](https://github.com/Latias94/merman/pull/297)
- Typst errors retain structured parse diagnostics and original source locations, including diagrams with frontmatter or non-ASCII text. `mermaid-result` exposes these diagnostics in `details` for programmatic handling. [PR #277](https://github.com/Latias94/merman/pull/277)

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
