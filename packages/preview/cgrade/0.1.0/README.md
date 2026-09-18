# cgrade

**Reproducible school grades across scales.**

[![crates.io](https://img.shields.io/crates/v/cgrade.svg)](https://crates.io/crates/cgrade) [![npm](https://img.shields.io/npm/v/@corbet-labs/cgrade.svg)](https://www.npmjs.com/package/@corbet-labs/cgrade) [![PyPI](https://img.shields.io/pypi/v/cgrade.svg)](https://pypi.org/project/cgrade/) [![Rust API](https://docs.rs/cgrade/badge.svg)](https://docs.rs/cgrade)

Convert school and university grades between national scales without a network dependency, operating-system locale, or model. The same inputs produce the same numbers in Rust, JavaScript, Python, and Typst.

```js
import { toDe } from '@corbet-labs/cgrade';

toDe('ch', 5.5);
// 1.7
```

## Scales

| ID | System | Best | Worst | Pass (lowest passing) | Orientation |
| --- | --- | --- | --- | --- | --- |
| `ch` | Switzerland (6er-Skala) | 6 | 1 | 4 | higher is better |
| `de` | Germany (1–6) | 1.0 | 6.0 | 4.0 | lower is better |
| `at` | Austria (1–5) | 1 | 5 | 4 | lower is better |
| `fr` | France (0–20) | 20 | 0 | 10 | higher is better |
| `it` | Italy, università (0–30) | 30 | 0 | 18 | higher is better |
| `es` | Spain (0–10) | 10 | 0 | 5 | higher is better |
| `us` | USA, GPA (0.0–4.0) | 4.0 | 0.0 | 1.0 (D) | higher is better |

**Oriented values warning:** a bare number is meaningless without its system. `1.0` is the best possible grade in Germany and Austria but a failing grade in Switzerland, Spain, and the USA. Always carry the scale ID with the value; `is_pass` and every conversion take the system first.

The `step` field on each scale (`0.5` for `ch`, Zwischennoten for `de`) is an advisory display hint only and never enters computation.

## Formula

Foreign grades convert to the German scale with the official **modified Bavarian formula** (KMK Beschluss on the Gesamtnote, Anlage):

```
x = 1 + 3 * (Nmax - Nd) / (Nmax - Nmin)
```

`Nmax` is the best achievable foreign grade, `Nmin` the lowest passing foreign grade, `Nd` the achieved grade. Per KMK ("es wird nicht gerundet") the result is **truncated, never rounded**, to 1 decimal: an exact 1.75 becomes 1.7, an exact 1.29 becomes 1.2. The inverse direction truncates to 2 decimals:

```
Nd = Nmax - (x - 1) / 3 * (Nmax - Nmin)
```

Reference points (HSG conversion table, Göttingen/notenberechner.ch table):

| Foreign | German |
| --- | --- |
| CH 6 / FR 20 / IT 30 / ES 10 / US 4.0 / AT 1 | 1.0 |
| CH 5.5 | 1.7 |
| CH 5.0 | 2.5 |
| CH 4.5 | 3.2 |
| CH 4.0 / FR 10 / IT 18 / ES 5 / US 1.0 / AT 4 | 4.0 |

Only passing grades convert: `Nd` outside `[pass .. best]` (in that system's orientation) yields no output (`None`/`null`/`none`), never an extrapolation. Failing grades have no Bavarian equivalent by construction. `convert` chains both directions through the German scale and is therefore a documented approximation — the intermediate 1-decimal truncation loses information, so `convert('ch', 'ch', 5.5)` is `5.53`, not the identity.

## Install

| Environment | Command |
| --- | --- |
| Rust / Cargo | `cargo add cgrade` |
| Python / pip | `python -m pip install cgrade` |
| Python / uv | `uv add cgrade` |
| Node.js / npm | `npm install @corbet-labs/cgrade` |
| pnpm | `pnpm add @corbet-labs/cgrade` |
| Yarn | `yarn add @corbet-labs/cgrade` |
| Bun | `bun add @corbet-labs/cgrade` |
| Deno | `deno add npm:@corbet-labs/cgrade` |

The 0.1.0 JavaScript distribution includes compiled ESM, CommonJS,
TypeScript declarations, and a standalone browser module. Node.js 20+ is
supported; no TypeScript loader is required.

```js
// CommonJS
const { toDe } = require('@corbet-labs/cgrade');
```

```html
<script type="module">
  import { toDe } from 'https://cdn.jsdelivr.net/npm/@corbet-labs/cgrade@0.1.0/dist/browser.js';
  console.log(toDe('ch', 5.5));
</script>
```

```typst
#import "@preview/cgrade:0.1.0": to-de, format-grade, parse-grade

#to-de("ch", 5.5)
// 1.7
#format-grade(parse-grade("6,0"), 1)
// 6.0
```

Python 3.10+ packages are available on [PyPI](https://pypi.org/project/cgrade/).
See the [installation guide](https://github.com/corbet-labs/cgrade/blob/main/docs/installation.md)
for CLI commands and other distribution options.
JSR publication and Typst availability are listed there explicitly.

## Rust

```rust
use cgrade::{format_grade, from_de, parse_grade, to_de};

assert_eq!(to_de("ch", 5.5), Some(1.7));
assert_eq!(from_de("fr", 2.5), Some(15.0));
assert_eq!(parse_grade("6,0"), Some(6.0));
assert_eq!(format_grade(6.0, 1).as_deref(), Some("6.0"));
```

## Python

```python
from cgrade import format_grade, parse_grade, to_de

assert to_de("ch", 5.5) == 1.7
assert parse_grade("6,0") == 6.0
assert format_grade(6.0, 1) == "6.0"
```

## API

| JavaScript / Python or Rust | Meaning |
| --- | --- |
| `availableScales` / `available_scales` | Lowercase scale IDs, sorted |
| `scale` | Scale entry (`best`, `worst`, `pass`, `step`, `higher_is_better`) or `null` |
| `isPass` / `is_pass` | Whether a grade passes in its system |
| `toDe` / `to_de` | Foreign grade → German scale (1 decimal, truncated) |
| `fromDe` / `from_de` | German grade → foreign scale (2 decimals, truncated) |
| `convert` | Grade from one system to another via the German pivot |
| `parseGrade` / `parse_grade` | Numeral with dot OR comma separator → float (`"6,0"` and `"6.0"` both yield `6.0`); strict, `null` on garbage |
| `formatGrade` / `format_grade` | Grade → string with explicit decimals, dot separator always (`6.0`, never `6,0`) |
| `bavarianToDe` / `bavarian_to_de` | Raw formula core over explicit `(Nmax, Nmin, Nd)` |
| `bavarianFromDe` / `bavarian_from_de` | Raw inverse core over explicit `(Nmax, Nmin, x)` |

Typst uses kebab-case (`to-de`, `from-de`, `available-scales`, …) from the `grade.typ` entrypoint.

Scale IDs are lowercase; lookups accept mixed-case input. Unknown systems, out-of-range grades, and degenerate scales return `null`/`None`/`none`. Scale bounds come from the KMK Beschluss, anabin, the HSG conversion table, and notenberechner.ch; see [the tables](https://github.com/corbet-labs/cgrade/tree/main/tables).

## Scope: data only

This library computes numbers, never words. There are no grade labels ("gut", "pass", "excellent") — tone belongs to applications.

## Correspondence family

| Library | Responsibility |
| --- | --- |
| [cletter](https://github.com/corbet-labs/cletter) | Compose the correspondence helpers |
| [cgreet](https://github.com/corbet-labs/cgreet) | German salutations and titles |
| [cfarewell](https://github.com/corbet-labs/cfarewell) | Locale-specific closings |
| [cdate](https://github.com/corbet-labs/cdate) | Calendar-date formatting |
| [cink](https://github.com/corbet-labs/cink) | Handwritten signature images |
| [cgrade](https://github.com/corbet-labs/cgrade) | School grades and the Bavarian formula |

## Development

Behavior is defined by [the grade tables](https://github.com/corbet-labs/cgrade/tree/main/tables)
and [shared conformance vectors](https://github.com/corbet-labs/cgrade/tree/main/tests/vectors).
Rust, JavaScript, and Python run the same vectors. Selected CI checks exercise
installed JavaScript tarballs, Python wheels and command-line entrypoints, and
Typst packages. Release validation records the actual runtime and platform;
Linux results do not establish native Windows or macOS coverage.
All five Rust crates forbid unsafe code in their own source.

See [the release guide](https://github.com/corbet-labs/cgrade/blob/main/docs/releasing.md)
for generation, verification, and publication commands.

## License

Copyright 2026 Julian Y. Richard Corbet. The 0.1.0 release line is licensed
under [LGPL-3.0-only](https://github.com/corbet-labs/cgrade/blob/main/LICENSES/LGPL-3.0-only.txt)
[WITH LGPL-3.0-linking-exception](https://github.com/corbet-labs/cgrade/blob/main/LICENSES/LGPL-3.0-only%20WITH%20LGPL-3.0-only%20WITH%20LGPL-3.0-linking-exception.txt),
with the incorporated [GPL version 3](https://github.com/corbet-labs/cgrade/blob/main/LICENSES/GPL-3.0-only.txt).
Combined works may link statically or dynamically without relinking duties;
library modifications stay LGPL. Applications can use a different license
subject to the LGPL's conditions.
This is the first release line; 0.1.0 is published to registries.

See the [licensing notes](https://github.com/corbet-labs/cgrade/blob/main/LICENSE.md) for distribution conditions and retained notices.
