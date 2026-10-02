# cnice

**Formulaic correspondence phrases: salutations and valedictions for every covered locale.**

[![crates.io](https://img.shields.io/crates/v/cnice.svg)](https://crates.io/crates/cnice) [![npm](https://img.shields.io/npm/v/@corbet-labs/cnice.svg)](https://www.npmjs.com/package/@corbet-labs/cnice) [![PyPI](https://img.shields.io/pypi/v/cnice.svg)](https://pypi.org/project/cnice/) [![Rust API](https://docs.rs/cnice/badge.svg)](https://docs.rs/cnice)

`cnice` is a facade over two deterministic correspondence libraries:
salutations (`cnice.greet`, previously the German-only `cgreet` repo) and
locale-specific valedictions (`cnice.farewell`, previously `cfarewell`).
One matcher renders every language from table rows — a new language is a
new row, never new code. Same input always yields the same output:
no models, no I/O.

```js
import { farewell, greet } from '@corbet-labs/cnice';

greet.salutation('de-ch', 'Frau Dr. Müller');
// Sehr geehrte Frau Dr. Müller
greet.salutation('fr', 'Madame Dupont');
// Madame Dupont,
farewell.closing('de-ch');
// Freundliche Grüsse
```

## Install

Version 0.1.0 has not yet been published to registries; the commands below
resolve once published. A source manifest alone does not establish publication.

| Environment | Command |
| --- | --- |
| Rust / Cargo | `cargo add cnice` |
| Python / pip | `python -m pip install cnice` |
| Python / uv | `uv add cnice` |
| Node.js / npm | `npm install @corbet-labs/cnice` |
| pnpm | `pnpm add @corbet-labs/cnice` |
| Yarn | `yarn add @corbet-labs/cnice` |
| Bun | `bun add @corbet-labs/cnice` |
| Deno | `deno add npm:@corbet-labs/cnice` |
| Typst | `#import "@preview/cnice:0.1.0": *` |

The JavaScript distribution includes compiled ESM, CommonJS,
TypeScript declarations, and a standalone browser module. Node.js 20+ is
supported; no TypeScript loader is required.

```js
// CommonJS
const { greet, farewell } = require('@corbet-labs/cnice');
```

```html
<script type="module">
  import { greet } from 'https://cdn.jsdelivr.net/npm/@corbet-labs/cnice@0.1.0/dist/browser.js';
  console.log(greet.salutation('de-ch', 'Frau Dr. Müller'));
</script>
```

See the [installation guide](https://github.com/corbet-labs/cnice/blob/main/docs/installation.md)
for CLI commands and other distribution options.
JSR installation is documented there too.

## Rust

```rust
use cnice::{farewell, greet};

assert_eq!(greet::salutation("de-ch", "Frau Dr. Müller"), "Sehr geehrte Frau Dr. Müller");
assert_eq!(greet::salutation("fr", "Madame Dupont"), "Madame Dupont,");
assert_eq!(farewell::closing("de-ch", None), "Freundliche Grüsse");
```

## Python

```python
from cnice import farewell, greet

assert greet.salutation("de-ch", "Frau Dr. Müller") == 'Sehr geehrte Frau Dr. Müller'
assert greet.salutation("fr", "Madame Dupont") == 'Madame Dupont,'
assert farewell.closing("de-ch") == 'Freundliche Grüsse'
```

The Python CLI accepts bare and namespaced function names and writes JSON
to stdout:

```sh
cnice greet.salutation '["de-ch", "Frau Dr. Müller"]'
cnice closing '["de-ch"]'
python -m cnice --help
```

## API

| Function | Purpose |
| --- | --- |
| `greet.salutation` / `greet.salutation` / `greet.salutation` | Complete salutation for any covered locale |
| `greet.salutationHonorific`, `greet.salutationTitles`, `greet.salutationSurname` | Parse explicitly supplied recipient details (locale-keyed) |
| `greet.isSupported` / `greet.is_supported` / `greet.is-supported` | Whether a locale has a salutation row |
| `greet.recipientSalutationWarning`, `greet.honorificWarning` | Report incomplete input |
| `farewell.closing(locale, override?)` | Resolve a valediction; even an empty override wins |
| `farewell.availableLocales()` / `farewell.available_locales()` / `farewell.available-locales()` | List the canonical locale codes |

Covered salutation locales: `de`, `de-ch`, `de-at`, `de-li`, `fr`, `it`,
`rm`, `en`, `en-gb`, `en-us`. Comma behavior, title precedence and formal
fallbacks are row data, identical on every port. A recognized Professor
title takes precedence over Dr. Missing honorifics or surnames produce the
formal fallback. The library does not infer a person’s gender from their
name. Valediction lookups are case-insensitive and resolve the exact
locale, then its base language, then English; an explicit override always
wins.

## Correspondence family

| Library | Responsibility |
| --- | --- |
| [cletter](https://github.com/corbet-labs/cletter) | Compose the correspondence helpers |
| [cnice](https://github.com/corbet-labs/cnice) | Formulaic salutations and valedictions (this repo: `cnice.greet` + `cnice.farewell`) |
| [cdate](https://github.com/corbet-labs/cdate) | Calendar-date formatting |
| [cink](https://github.com/corbet-labs/cink) | Handwritten signature images |
| [cgrade](https://github.com/corbet-labs/cgrade) | Planned correspondence helper |
| [cnumber](https://github.com/corbet-labs/cnumber) | Number formatting with Swiss amtlich mode |
| [cbcp](https://github.com/corbet-labs/cbcp) | Planned correspondence helper |

## Development

Behavior is defined by [the locale tables](https://github.com/corbet-labs/cnice/tree/main/tables)
and [shared conformance vectors](https://github.com/corbet-labs/cnice/tree/main/tests/vectors).
Rust, JavaScript, Python, and Typst run the same vectors (74 greet + 57
farewell = 131). Selected CI checks exercise
installed JavaScript tarballs, Python wheels and command-line entrypoints, and
Typst packages. Release validation records the actual runtime and platform;
Linux results do not establish native Windows or macOS coverage.
All crates forbid unsafe code in their own source.

See [the release guide](https://github.com/corbet-labs/cnice/blob/main/docs/releasing.md)
for generation, verification, and publication commands.

## License

Copyright 2026 Julian Y. Richard Corbet. The 0.1.0 release line is licensed
under [LGPL-3.0-only](https://github.com/corbet-labs/cnice/blob/main/LICENSES/LGPL-3.0-only.txt)
[WITH LGPL-3.0-linking-exception](https://github.com/corbet-labs/cnice/blob/main/LICENSES/LGPL-3.0-only%20WITH%20LGPL-3.0-linking-exception.txt),
with the incorporated [GPL version 3](https://github.com/corbet-labs/cnice/blob/main/LICENSES/GPL-3.0-only.txt).
Combined works may link statically or dynamically without relinking duties;
library modifications stay LGPL. Applications can use a different license
subject to the LGPL's conditions.
The `cgreet` and `cfarewell` repositories keep their own release grants
untouched; this facade does not relicense them.

See the [licensing notes](https://github.com/corbet-labs/cnice/blob/main/LICENSE.md) for distribution conditions and retained notices.
