# Changelog
<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2026-04-30

### Added

- Added `required-fields` parameter to control which core fields are rendered. Fields excluded from the list are suppressed entirely — no blank space is left — even if values are provided. Defaults to all nine core fields, preserving backward compatibility. ([#3](https://github.com/nandac/letterloom/issues/3))
- Added `date-alignment` parameter to position the date independently from the sender block. When `date-alignment` matches `from-alignment` and the sender block is present, the date's left edge is automatically aligned with the sender block using `measure`. Defaults to `right`.
- Added `letterhead` parameter for placing a branded image flush with the physical page edges on the first page only. Subsequent pages are unaffected. Accepts a dictionary with the following keys:
  - `file` (required): bytes loaded via `read("path", encoding: none)`
  - `width` (optional): length, ratio (e.g. `60%`), or relative (e.g. `60% + 5mm`) — defaults to the full available width
  - `height` (optional): length — when omitted, height scales proportionally from the width
  - `margin` (optional): length or per-side dictionary with keys `top`, `bottom`, `left`, `right`, `x`, `y`, or `rest` — defaults to `0mm` on all sides
  - `alignment` (optional): `left`, `center`, or `right` — defaults to `center`

  ([#4](https://github.com/nandac/letterloom/pull/4))

## [2.0.0] - 2026-04-28

<!-- markdownlint-disable MD033 -->
<details>
<summary>Migration guide from v1.0.0</summary>
<!-- markdownlint-enable MD033 -->

Each enclosure entry must now be a dictionary with a required `description` field, replacing the previous plain-string format. Optional fields `file`, `pages`, and `margin` allow attaching and rendering external files directly in the letter.

### Enclosures

Before

```typ
enclosures: (
  "Provenance of the Oak Trees on the Dimbleby Estate",
  "Map of the Dimbleby Estate",
),
```

After

```typ
enclosures: (
  (description: "Provenance of the Oak Trees on the Dimbleby Estate"),
  (description: "Map of the Dimbleby Estate"),
),
```

To attach a file that is rendered on a separate page after the letter body:

```typ
enclosures: (
  (
    description: "Provenance of the Oak Trees on the Dimbleby Estate",
    file: read("provenance.pdf", encoding: none),
    pages: 3,
    margin: 10mm,
  ),
),
```

</details>

### Fixed

- Fixed signature block spacing: no gap is added between name, title, and affiliation when optional fields are absent.
- Fixed `footer-font-size` default in `construct-custom-footer` to match the public API default of `9pt`.
- Fixed `cc-label` and `enclosures-label` defaults in `construct-outputs.typ` to match the public API defaults of `"cc:"` and `"encl:"`.
- Fixed example letter in the manual missing required `to-name` and `to-address` parameters.
- Fixed enclosure `margin` dictionary not defaulting unspecified sides to `0mm`, causing them to inherit the outer letter page margins instead.

### Added

- Added Typst minimum version requirement (0.14.0 or higher) to the README and manual.
- Added `test-attn-position-below` and `test-footer` rendered test cases.
- Added Typst standard documentation comments to all functions in `construct-outputs.typ`.

### Changed

- Enclosures are now specified as dictionaries with a required `description` field (string or content). An optional `file` field (bytes loaded via `read("path", encoding: none)`) renders the attachment on a separate page, with `pages` (integer, default `1`) controlling how many pages to render and `margin` (length or per-side dictionary) controlling page margins for the attachment.

## [1.0.0] - 2025-08-30

<!-- markdownlint-disable MD033 -->
<details>
<summary>Migration guide from v0.1.0</summary>
<!-- markdownlint-enable MD033 -->

The field structure has been refactored. Previously nested dictionaries are now represented as separate top-level fields.

### Sender and Recipient

Before

```typ
from: (
  name: "Sender's name",
  address: [Sender's address],
),
```

After

```typ
from-name: "Sender's name",
from-address: [Sender's address],
```

Before

```typ
to: (
  name: "Recipient's name",
  address: [Recipient's address],
),
```

After

```typ
to-name: "Recipient's name",
to-address: [Recipient's address],
```

### Attention Line

Before

```typ
attn-line: (
  name: "Attention name",
  label: "Attn:",
  position: "above",
),
```

After

```typ
attn-name: "Attention name",
attn-label: "Attn:",
attn-position: "above",
```

### Enclosures

Before

```typ
enclosures: (
  encl-list: (
    "enclosure 1",
    "enclosure 2",
    "enclosure 3",
  ),
  label: "encl:",
),
```

After

```typ
enclosures: (
  "enclosure 1",
  "enclosure 2",
  "enclosure 3",
),
enclosures-label: "encl:",
```

### CC Recipients

Before

```typ
cc: (
  cc-list: (
    "recipient 1",
    "recipient 2",
    "recipient 3",
  ),
  label: "cc:",
),
```

After

```typ
cc: (
  "recipient 1",
  "recipient 2",
  "recipient 3",
),
cc-label: "cc:",
```

</details>

### Added

- Added support for aligning a signature left, center or right when only one signature is given. ([#1](https://github.com/nandac/letterloom/issues/1))

- Added two new optional fields `title` and `affiliation` for signatures. ([#2](https://github.com/nandac/letterloom/issues/2))

### Changed

- Sender (from) and recipient (to) fields split into `from-name` / `from-address` and `to-name` / `to-address`.

- Attention line (attn-line) refactored into `attn-name`, `attn-label`, and `attn-position`.

- Enclosures (encl-list) simplified into `enclosures`, with label now specified separately via `enclosures-label`.

- CC recipients (cc-list) simplified into `cc`, with label now specified separately via `cc-label`.

## [0.1.0] - 2025-07-01
<!-- Describe the feature set of the initial release here -->
- Initial release of this package.

<!--
Below are the target URLs for each version
You can link version numbers (in level-2 headings)
to the corresponding tag on GitHub, or the diff
in comparison to the previous release
-->

[Unreleased]: https://github.com/nandac/letterloom/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/nandac/letterloom/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/nandac/letterloom/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/nandac/letterloom/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/nandac/letterloom/releases/tag/v0.1.0
