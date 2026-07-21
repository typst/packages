# Datify

![Test Datify](https://github.com/Jeomhps/datify/actions/workflows/test.yml/badge.svg?branch=main)

Datify is a Typst package for flexible, locale-aware date formatting. It turns a
`datetime` and a CLDR pattern into a formatted date string, using the locale data
provided by [datify-core](https://github.com/Jeomhps/datify-core).

---

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [API Reference](#api-reference)
   - [`custom-date-format`](#custom-date-format)
   - [`display-date`](#display-date)
4. [Pattern Reference](#pattern-reference)
   - [Named Patterns](#named-patterns)
   - [Format Tokens](#format-tokens)
   - [Literal Text](#literal-text)
   - [How Patterns Are Parsed](#how-patterns-are-parsed)
5. [Supported Languages](#supported-languages)
6. [Contributing](#contributing)
7. [License](#license)
8. [Development & Testing](#development--testing)
9. [Glossary](#glossary)

---

## Overview

Datify has one job: format a date. It owns *pattern parsing and substitution*;
all locale data (day names, month names, locale-specific patterns) comes from
[datify-core](https://github.com/Jeomhps/datify-core). Patterns follow the
[Unicode CLDR](https://cldr.unicode.org/) field-symbol convention.

---

## Installation

Add Datify to your Typst project (pick the version you want):

```typst
#import "@preview/datify:1.3.0": *
```

---

## API Reference

Datify exposes **exactly two functions**. They accept the same `date` and
`pattern`; they differ only in how the locale is chosen and what they return.

| Function                              | Returns   | Use it when                                                        |
| ------------------------------------- | --------- | ------------------------------------------------------------------ |
| [`custom-date-format`](#custom-date-format) | `string`  | you need the formatted date as a string, with an explicit language |
| [`display-date`](#display-date)       | `content` | you want to place a date that follows the **document's** language   |

### `custom-date-format`

Format a date to a **string** with an explicitly chosen language.

**Synopsis**

```typst
custom-date-format(date, pattern: "full", lang: "en") -> str
```

**Parameters**

| Name      | Type       | Required | Default  | Description                                                        |
| --------- | ---------- | -------- | -------- | ------------------------------------------------------------------ |
| `date`    | `datetime` | yes      | –        | The date to format (positional — the only unnamed argument).       |
| `pattern` | `str`      | no       | `"full"` | A [named pattern](#named-patterns) or a custom [CLDR pattern](#format-tokens). |
| `lang`    | `str`      | no       | `"en"`   | ISO 639 language code, optionally with a region (e.g. `fr`, `fr-CA`). |
| `community` | `bool`   | no       | `false`  | Consult datify-core's opt-in [community overlay](https://github.com/Jeomhps/datify-core#community-overlay) first (e.g. Brazilian `pt-BR` conventions). |

**Returns:** the formatted date as a `str`.

**Examples**

```typst
#let d = datetime(year: 2025, month: 1, day: 5)

#custom-date-format(d)                              // Sunday, January 5, 2025
#custom-date-format(d, lang: "es")                  // domingo, 5 de enero de 2025
#custom-date-format(d, pattern: "full", lang: "fr") // dimanche 5 janvier 2025
#custom-date-format(d, pattern: "yyyy-MM-dd")       // 2025-01-05
```

An unknown or region-specific `lang` never errors — it resolves through
datify-core's [fallback chain](#supported-languages).

### `display-date`

Format a date using the **document's current locale** (`text.lang` +
`text.region`), returning **content**. Use this when you just want the date to
match the surrounding document without passing a language every time.

**Synopsis**

```typst
display-date(date, pattern: "full") -> content
```

**Parameters**

| Name      | Type       | Required | Default  | Description                                                        |
| --------- | ---------- | -------- | -------- | ------------------------------------------------------------------ |
| `date`    | `datetime` | yes      | –        | The date to format (positional).                                   |
| `pattern` | `str`      | no       | `"full"` | A [named pattern](#named-patterns) or a custom [CLDR pattern](#format-tokens). |
| `community` | `bool`   | no       | `false`  | Consult datify-core's opt-in [community overlay](https://github.com/Jeomhps/datify-core#community-overlay) first. |

**Returns:** `content`. The active locale is only known inside a `context`, so
`display-date` returns content — **place it in your document**; don't do string
operations on the result. For string output, use
[`custom-date-format`](#custom-date-format) with an explicit `lang`.

**Examples**

```typst
#set text(lang: "fr")
#display-date(datetime(year: 2025, month: 1, day: 5))                  // dimanche 5 janvier 2025

// Region is honored: en vs en-GB differ.
#set text(lang: "en", region: "GB")
#display-date(datetime(year: 2025, month: 1, day: 5), pattern: "short") // 05/01/2025
```

**Notes**

- It combines `text.lang` with `text.region` automatically (e.g. `en` + `GB` →
  `en-GB`). A region with no dedicated CLDR data truncates back to the base
  language via the fallback chain. Script subtags (e.g. `Hant`) aren't exposed by
  `text`, so locales needing one fall back to the base language.
- `text.lang` defaults to `"en"`, so `display-date` with no `#set text` formats
  in English.
- Equivalent without the helper: `#context custom-date-format(date, lang: text.lang)`.

---

## Pattern Reference

The `pattern` argument of both functions is either a **named pattern** or a
**custom pattern string** made of the tokens below.

### Named Patterns

Locale-appropriate presets resolved per language: `"full"`, `"long"`,
`"medium"`, `"short"`.

| Pattern  | English (`en`)          | French (`fr`)           |
| -------- | ----------------------- | ----------------------- |
| `full`   | Sunday, January 5, 2025 | dimanche 5 janvier 2025 |
| `long`   | January 5, 2025         | 5 janvier 2025          |
| `medium` | Jan 5, 2025             | 5 janv. 2025            |
| `short`  | 1/5/25                  | 05/01/2025              |

### Format Tokens

Custom patterns are built from CLDR field symbols. Tokens are **case-sensitive**.

| Token        | Description                            | Example |
| ------------ | -------------------------------------- | ------- |
| `EEEE`       | Weekday name, format, wide             | Sunday  |
| `E`–`EEE`    | Weekday name, format, abbreviated      | Sun     |
| `cccc`       | Weekday name, stand-alone, wide        | Sunday  |
| `c`–`ccc`    | Weekday name, stand-alone, abbreviated | Sun     |
| `MMMM`       | Month name, format, wide               | January |
| `MMM`        | Month name, format, abbreviated        | Jan     |
| `LLLL`       | Month name, stand-alone, wide          | January |
| `LLL`        | Month name, stand-alone, abbreviated   | Jan     |
| `MM` / `LL`  | Month number, 2 digits                 | 01      |
| `M` / `L`    | Month number, 1–2 digits               | 1       |
| `dd`         | Day of month, 2 digits                 | 05      |
| `d`          | Day of month, 1–2 digits               | 5       |
| `yyyy` / `y` | Year                                   | 2025    |
| `yy`         | Year, last two digits                  | 25      |

The 5-letter narrow forms (`MMMMM`, `EEEEE`, `ccccc`, `LLLLL`) map to the
locale's narrow width. **Unhandled field symbols pass through verbatim** — in
particular the era field `G` is not supported (datify-core ships no era data), so
it is emitted literally (affects only the Thai `th` `full`/`long` patterns).

### Literal Text

Wrap literal text in single quotes (`'`). For a literal apostrophe, use `''`.

| Pattern             | Output          |
| ------------------- | --------------- |
| `'Today is' EEEE`   | Today is Sunday |
| `yyyy'/'MM'/'dd`    | 2025/01/05      |
| `EEE 'the' dd`      | Sun the 05      |
| `'''Quoted text'''` | 'Quoted text'   |

> **Always quote literal letters** so they aren't read as field tokens.

### How Patterns Are Parsed

The parser is a small two-state automaton. Outside quotes it reads a **maximal
run of one letter** as a single field and maps `(letter, run-length)` to a value;
inside quotes every character is literal. `''` is an escaped apostrophe in either
state.

| State     | Input           | Action                                                | Next state |
| --------- | --------------- | ----------------------------------------------------- | ---------- |
| `Normal`  | run of a letter | substitute field (`y M L d E c`; unknown → verbatim)  | `Normal`   |
| `Normal`  | `''`            | emit `'`                                              | `Normal`   |
| `Normal`  | `'`             | open quote                                            | `Literal`  |
| `Normal`  | any other char  | emit verbatim                                         | `Normal`   |
| `Literal` | `''`            | emit `'`                                              | `Literal`  |
| `Literal` | `'`             | close quote                                           | `Normal`   |
| `Literal` | any other char  | emit verbatim                                         | `Literal`  |

Parsing starts in `Normal`. Reading a whole run as one field is why every length
is handled uniformly: `M`→`1`, `MM`→`01`, `MMM`→`Jan`, `MMMM`→`January`,
`MMMMM`→`J`.

---

## Supported Languages

Datify supports every locale provided by
[datify-core](https://github.com/Jeomhps/datify-core?tab=readme-ov-file#supported-locales).
Region-specific or unknown codes resolve through its CLDR fallback chain: the
trailing subtags are dropped one at a time (e.g. `fr-CA` → `fr`), and anything
still unresolved falls back to the default locale (`en`). Formatting therefore
never errors on an unrecognized language code.

---

## Contributing

Datify owns only the formatting logic; all locale data lives in
[datify-core](https://github.com/Jeomhps/datify-core), which is opinionated and
CLDR-only (its data is generated from the Unicode CLDR, not hand-edited).

- **Locale data fixes** (wrong or missing day/month names or patterns) should go
  upstream to [CLDR](https://cldr.unicode.org/); they reach Datify through a
  `datify-core` data update.
- Pull requests here for bug fixes, formatter improvements, or new field-symbol
  support are welcome.
- See [cldr-json](https://github.com/unicode-org/cldr-json) for the upstream data and structure.

---

## License

MIT © 2026 Jeomhps. CLDR data © Unicode, Inc., used under the
[Unicode License](https://unicode.org/copyright.html).

---

## Development & Testing

Run the test suite locally with either:

1. [tt (tytanic)](https://github.com/typst-community/tytanic):
   ```sh
   tt run
   ```
2. [act](https://github.com/nektos/act) (runs the CI workflow):
   ```sh
   act --artifact-server-path /tmp/artifact
   ```

### Developing against a local `datify-core`

Datify depends on the published `@preview/datify-core`. To iterate on both
packages before publishing, link your local `datify-core` checkout into Typst's
local package directory (it overrides the downloaded copy of that version):

```sh
# Linux/macOS — match the version to the pin in src/formats.typ
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/preview/datify-core/2.0.0"
mkdir -p "$DEST"
cp -r /path/to/datify-core/typst.toml /path/to/datify-core/src "$DEST"/
```

Re-run the copy after each `datify-core` change, then `tt run` picks up the local
version. (On Windows the package directory is `%APPDATA%\typst\packages`.)

---

## Glossary

- **CLDR** — Unicode Common Locale Data Repository, the source of locale-specific
  data (date formats, names, language rules).
- **Field symbol** — a CLDR pattern letter such as `y`, `M`, `d`, `E` whose run
  length selects a representation (e.g. `M` vs `MMMM`).
- **ISO 639** — standard language codes (e.g. `en`, `fr`), optionally with a
  region subtag (e.g. `fr-CA`).
- **Typst** — a markup-based typesetting system.
