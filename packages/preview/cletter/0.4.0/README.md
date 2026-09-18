# cletter

**Locale-correct correspondence, from salutation to closing.**

[![crates.io](https://img.shields.io/crates/v/cletter.svg)](https://crates.io/crates/cletter) [![npm](https://img.shields.io/npm/v/@corbet-labs/cletter.svg)](https://www.npmjs.com/package/@corbet-labs/cletter) [![PyPI](https://img.shields.io/pypi/v/cletter.svg)](https://pypi.org/project/cletter/) [![Rust API](https://docs.rs/cletter/badge.svg)](https://docs.rs/cletter)

Compose a formal letter from deterministic rules: resolve a document locale, address a recipient, write an application subject, format the date, choose a closing, and prepare a handwritten signature image. Rust, JavaScript, and Python share the same conformance vectors.

```js
import { salutation } from '@corbet-labs/cletter';

salutation('de-ch', 'Frau Dr. Müller');
// Sehr geehrte Frau Dr. Müller
```

## Install

| Environment | Command |
| --- | --- |
| Rust / Cargo | `cargo add cletter` |
| Python / pip | `python -m pip install cletter==0.4.0` |
| Python / uv | `uv add cletter==0.4.0` |
| Node.js / npm | `npm install @corbet-labs/cletter` |
| pnpm | `pnpm add @corbet-labs/cletter` |
| Yarn | `yarn add @corbet-labs/cletter` |
| Bun | `bun add @corbet-labs/cletter` |
| Deno | `deno add npm:@corbet-labs/cletter` |

The 0.2.2 JavaScript distribution includes compiled ESM, CommonJS,
TypeScript declarations, and a standalone browser module. Node.js 20+ is
supported; no TypeScript loader is required.

```js
// CommonJS
const { salutation } = require('@corbet-labs/cletter');
```

```html
<script type="module">
  import { salutation } from 'https://cdn.jsdelivr.net/npm/@corbet-labs/cletter@0.4.0/dist/browser.js';
  console.log(salutation('de-ch', 'Frau Dr. Müller'));
</script>
```

```typst
#import "@preview/cletter:0.4.0": salutation, closing

#salutation("de-ch", "Frau Dr. Müller")
// Sehr geehrte Frau Dr. Müller
#closing("de-ch")
// Freundliche Grüsse
```

Python 3.10+ users can install [cletter 0.4.0 from PyPI](https://pypi.org/project/cletter/0.4.0/),
including its component dependencies. This release line is
[LGPL-3.0-only WITH LGPL-3.0-linking-exception](https://github.com/corbet-labs/cletter/blob/main/LICENSES/LGPL-3.0-only%20WITH%20LGPL-3.0-linking-exception.txt);
the retained 0.2.1 line stays
[Apache-2.0](https://github.com/corbet-labs/cletter/blob/v0.2.1/LICENSE).
See the [installation guide](https://github.com/corbet-labs/cletter/blob/main/docs/installation.md)
for CLI commands and other distribution options.
JSR publication and Typst availability are listed there explicitly.

## Rust

```rust
use cletter::{closing, long_date, resolve_locale, salutation};

let locale = resolve_locale(Some("de"), Some("Zürich, Zug"));
assert_eq!(salutation(&locale, "Frau Dr. Müller"), "Sehr geehrte Frau Dr. Müller");
assert_eq!(closing(&locale, None), "Freundliche Grüsse");
assert_eq!(long_date(&locale, 2026, 9, 7).as_deref(), Some("7. September 2026"));
```

## Python

```python
from cletter import salutation

assert salutation("de-ch", "Frau Dr. Müller") == 'Sehr geehrte Frau Dr. Müller'
```

## API

The API below follows current main. Python 0.2.1 on PyPI predates
`normalize_locale_id`; its other listed Python helpers are available.

| JavaScript / Python or Rust | Purpose |
| --- | --- |
| `normalizeLocaleId` / `normalize_locale_id` | Normalize explicit ID spelling; preserve all subtags without inference or fallback |
| `resolveLocale` / `resolve_locale` | Language and location → document locale |
| `salutation`, `opening` | Recipient address or formal opening |
| `subject` | Application subject with optional prefix override |
| `closing` | Locale-specific valediction |
| `longDate` / `long_date` and other date helpers | Gregorian datelines |
| `applyOrtho` / `apply_ortho` | Explicit `ß` → `ss`, `ẞ` → `SS` for caller-selected `de-ch`/`de-li` prose |
| `orthographyIssues` / `orthography_issues` | Non-mutating matched source/replacement pairs |
| `orthographyReplacements` / `orthography_replacements` | Applicable spelling pairs from the shared table |
| `normalize`, `signatureSize` / `signature_size` | Signature-image preparation |
| `warnings` | Advisories for incomplete recipient details |

Openings and closings have 40 locale entries. Date formatting currently covers German and English variants; other dates fall back to English. Locale IDs are lowercase in tables and outputs; lookups accept mixed case and explicit overrides win. Subject defaults are for job applications; supply a prefix override for other correspondence. The library produces letter components; your application owns the body, layout, and PDF rendering. Spelling transformations require caller-selected prose: preserve exact names, quotations, URLs and source material; use diagnostics when those boundaries are unavailable.

The self-contained [Typst facade](https://github.com/corbet-labs/cletter/blob/main/typst/README.md) consumes the same greeting, closing and date helpers as the other ports.

Use `normalize_locale_id` (`normalizeLocaleId` in JavaScript) when the caller
has selected an explicit locale: `" EN_CH "` becomes `"en-ch"` even though that
region has no correspondence-table entry. It trims only ASCII space, tab, LF,
CR, VT and FF, converts underscores to hyphens and lowercases ASCII letters.
Other characters, including U+FEFF and U+0085, remain for caller validation.
It does not validate syntax, discard subtags, choose a region or default an empty
value. Applications validate
their storage shape and declared locales. `normalize_language` and
`resolve_locale` retain their supported-language and location fallback behavior.

## Correspondence family

| Library | Responsibility |
| --- | --- |
| [cletter](https://github.com/corbet-labs/cletter) | Compose the correspondence helpers |
| [cnice](https://github.com/corbet-labs/cnice) | Formulaic phrases: salutations and closings for every covered locale (`greet` + `farewell`) |
| [cdate](https://github.com/corbet-labs/cdate) | Calendar-date formatting (CLDR-pinned tables) |
| [cink](https://github.com/corbet-labs/cink) | Handwritten signature images |
| [cnumber](https://github.com/corbet-labs/cnumber) | Number formatting with Swiss amtlich mode (new) |
| [cgrade](https://github.com/corbet-labs/cgrade) | School grades and Bavarian-formula conversion (new, standalone) |
| [cbcp](https://github.com/corbet-labs/cbcp) | BCP 47 locale IDs and vendor adapters |


## Development

Behavior is defined by [the locale tables](https://github.com/corbet-labs/cletter/tree/main/tables)
and [shared conformance vectors](https://github.com/corbet-labs/cletter/tree/main/tests/vectors).
Rust, JavaScript, and Python run the same vectors. Selected CI checks exercise
installed JavaScript tarballs, Python wheels and command-line entrypoints, and
Typst packages. Release validation records the actual runtime and platform;
Linux results do not establish native Windows or macOS coverage.
All family Rust crates forbid unsafe code in their own source.

See [the release guide](https://github.com/corbet-labs/cletter/blob/main/docs/releasing.md)
for generation, verification, and publication commands.

## License

Copyright 2026 Julian Y. Richard Corbet. The 0.3.0 release line is licensed
under [LGPL-3.0-only](https://github.com/corbet-labs/cletter/blob/main/LICENSES/LGPL-3.0-only.txt)
[WITH LGPL-3.0-linking-exception](https://github.com/corbet-labs/cletter/blob/main/LICENSES/LGPL-3.0-only%20WITH%20LGPL-3.0-linking-exception.txt),
with the incorporated [GPL version 3](https://github.com/corbet-labs/cletter/blob/main/LICENSES/GPL-3.0-only.txt).
Combined works may link statically or dynamically without relinking duties;
library modifications stay LGPL. Applications can use a different license
subject to the LGPL's conditions.
Previously released and already prepared distributions retain their original
grants. The installation examples above refer to those available releases;
0.4.0 is published to registries.

The existing cdate, cfarewell and cink Typst snapshots remain Apache-2.0;
the cgreet snapshot remains MIT OR Apache-2.0. Their files and notices
are preserved unchanged.

See the [licensing notes](https://github.com/corbet-labs/cletter/blob/main/LICENSE.md) for distribution conditions and retained notices.
