# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

- Added support for aligning a signature left, center or right when only one signature is given.

- Added two new optional fields `title` and `affiliation` for signatures.

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

[Unreleased]: https://github.com/nandac/letterloom/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/nandac/letterloom/releases/tag/v0.1.0
[1.0.0]: https://github.com/nandac/letterloom/releases/tag/v1.0.0
