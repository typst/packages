# Datify
![Test Datify](https://github.com/Jeomhps/datify/actions/workflows/test.yml/badge.svg?branch=main)
> **⚠️ Major Breaking Changes in v1.0.0+**
>
> - The user-facing API of Datify has been completely rewritten.
> - Functions like `day-name`, `month-name`, etc. are **no longer available directly in Datify**.
>   They have been moved to [datify-core](https://github.com/Jeomhps/datify-core), which Datify uses as its backend.
>   Example migration:
>   ```typst
>   #import "@preview/datify-core:1.0.0": *
>   #get-day-name(datetime.today(), lang: "en") // Now available in datify-core
>   ```
> - The new backend is based on the [Unicode CLDR project](https://cldr.unicode.org/), providing robust internationalization.
> - If you need to resolve a single day or month name, it is recommended to use `datify-core` directly.
>   You can also use `custom-date-format` for this, but it is less practical for single values.
> - The core logic for string transformation now uses a formal language and automata approach, similar to many modern date libraries.
>   This introduces a new quoting system for escaping text in patterns.
> - **If you are migrating from a previous version, your code will need to be updated.**
>   The old usage is not compatible with this version.

---

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Usage](#usage)
   - [Formatting Dates](#formatting-dates)
   - [Format Tokens](#format-tokens)
   - [Named Patterns](#named-patterns)
   - [Literal Text in Patterns](#literal-text-in-patterns)
4. [Supported Languages](#supported-languages)
5. [Contributing](#contributing)
6. [License](#license)
7. [Development & Testing](#development--testing)
8. [Planned Features](#planned-features)
9. [Glossary](#glossary)

---

## Overview
Datify is a Typst package for flexible, locale-aware date formatting.
It leverages [datify-core](https://github.com/Jeomhps/datify-core) for internationalization and supports CLDR-style date patterns.

---

## Installation
Add Datify to your Typst project (specify the version you want):
```typst
#import "@preview/datify:1.0.0": *
```

---

## Usage

### Function Reference
| Argument | Type      | Required | Default | Description                                      |
|----------|-----------|----------|---------|--------------------------------------------------|
| date     | datetime  | Yes      | –       | The date to format                               |
| pattern  | str       | No       | "full"  | Pattern string or CLDR named pattern             |
| lang     | str       | No       | "en"    | ISO 639-1 language code (e.g., "en", "fr", "es") |

**If you only provide `lang`, the pattern defaults to `"full"` for that locale.**
**All arguments must be named except for the first (`date`).**

#### Example usage
```typst
#let mydate = datetime(year: 2025, month: 1, day: 5)
#custom-date-format(mydate) // Output: Sunday, January 5, 2025 (in English, full format)
#custom-date-format(mydate, lang: "es") // Output: domingo, 5 de enero de 2025
#custom-date-format(mydate, pattern: "yyyy-MM-dd") // Output: 2025-01-05
#custom-date-format(mydate, pattern: "full", lang: "fr") // Output: dimanche 5 janvier 2025
```

---

### Pattern Syntax
The `pattern` argument can be either:
- A **CLDR named pattern** (`"full"`, `"long"`, `"medium"`, `"short"`) for locale-appropriate formatting.
- A **custom string pattern** using the tokens below.

#### CLDR Pattern Example
```typst
#custom-date-format(mydate, pattern: "full", lang: "fr") // Output: dimanche 5 janvier 2025
```

#### Custom Pattern Example
```typst
#custom-date-format(mydate, pattern: "EEEE, MMMM dd, yyyy") // Output: Sunday, January 05, 2025
#custom-date-format(mydate, pattern: "EEE, MMM d, yyyy") // Output: Sun, Jan 5, 2025
```

---

### Format Tokens
| Token   | Description                        | Example Output      |
|---------|------------------------------------|---------------------|
| `EEEE`  | Full weekday name                  | Sunday              |
| `EEE`   | Abbreviated weekday name           | Sun                 |
| `MMMM`  | Full month name                    | January             |
| `MMM`   | Abbreviated month name             | Jan                 |
| `MM`    | Month number, 2 digits             | 01                  |
| `M`     | Month number, 1-2 digits           | 1                   |
| `dd`    | Day of month, 2 digits             | 05                  |
| `d`     | Day of month, 1-2 digits           | 5                   |
| `yyyy`  | 4-digit year                       | 2025                |
| `y`     | Year (same as `yyyy`)              | 2025                |

- **Tokens are case-sensitive.**
- Only the tokens above are supported.

---

### Named Patterns
You can use CLDR-style named patterns: `"full"`, `"long"`, `"medium"`, `"short"`.
These will be resolved to locale-appropriate patterns for the given language.

| Pattern | English (en)               | French (fr)               |
|---------|----------------------------|---------------------------|
| full    | Sunday, January 5, 2025    | dimanche 5 janvier 2025   |
| long    | January 5, 2025            | 5 janvier 2025            |
| medium  | Jan 5, 2025                | 5 janv. 2025              |
| short   | 1/5/25                     | 05/01/2025                |

---

### Literal Text in Patterns
To include **literal text** in patterns, wrap it in single quotes (`'`).
To include a single quote, use `''` (two single quotes).

| Example Pattern               | Output                     |
|-------------------------------|----------------------------|
| `'Today is' EEEE`             | Today is Sunday            |
| `yyyy'/'MM'/'dd`               | 2025/01/05                 |
| `'''Quoted text'''`           | 'Quoted text'              |
| `EEE 'the' dd`                | Sun the 05                 |

⚠️ **Important**: Always quote literal text to avoid misinterpretation as tokens.
While unquoted text may work now, it could cause errors in future versions.

---

## Supported Languages
Datify supports all languages provided by [datify-core](https://github.com/Jeomhps/datify-core?tab=readme-ov-file#supported-locales).
If you pass an unsupported language code, an error will be thrown.

---

## Contributing
- **Native speakers wanted!**
  If you notice missing or incorrect translations for a language, please contribute directly to [datify-core](https://github.com/Jeomhps/datify-core), which manages all locale data for Datify.
- Pull requests for bug fixes, improvements, ideas, or feedback are welcome here.
- For upstream locale data and structure, see [cldr-json](https://github.com/unicode-org/cldr-json).

---

## License
MIT © 2025 Jeomhps
CLDR data © Unicode, Inc., used under the [Unicode License](https://unicode.org/copyright.html).

---

## Development & Testing
To run the full test suite locally, you have two options:
1. **Using [tt (tytanic)](https://github.com/taiki-e/tytanic)**
   ```sh
   tt run
   ```
2. **Using [act](https://github.com/nektos/act)**
   ```sh
   act --artifact-server-path /tmp/artifact
   ```

---

## Glossary
- **CLDR**: Unicode Common Locale Data Repository, a project for locale-specific data (e.g., date formats, language rules).
- **ISO 639-1**: Two-letter codes for representing languages (e.g., `en` for English, `fr` for French).
- **Typst**: A markup-based typesetting system.
