# Vendored fonts — Open Sans

This directory contains the **complete Open Sans family** required by the
Europass CV template, vendored so that every build is reproducible and the
rendered PDF never falls back to a font installed on the host machine.

## Files

| File                        | Style        | Used for                                   |
| --------------------------- | ------------ | ------------------------------------------ |
| `OpenSans-Regular.ttf`      | Regular 400  | body text, dates, labels                   |
| `OpenSans-Italic.ttf`       | Italic 400   | organisation / location line               |
| `OpenSans-Semibold.ttf`     | Semibold 600 | (reserved for heavier accents)             |
| `OpenSans-SemiboldItalic.ttf` | Semibold Italic | (reserved)                            |
| `OpenSans-Bold.ttf`         | Bold 700     | name, section headings, CEFR level codes   |
| `OpenSans-BoldItalic.ttf`   | Bold Italic  | (reserved)                                 |

## Why Open Sans

Open Sans is the typeface used by the official Europass CV
(europa.eu/europass).  It is the primary family in `lib.typ`:

```typst
#let body-font = ("Open Sans",)
```

Only a single family is listed on purpose: every family in the stack must be
vendored, otherwise `--ignore-system-fonts` would warn about a missing family
and the build would no longer be hermetic.

## Glyph coverage (verified)

Open Sans alone covers **every character** used by the template across all
**24 official EU languages**, including:

- Latin Extended-A/B — Czech, Slovak, Croatian, Slovenian, Polish, Hungarian,
  Lithuanian, Latvian, Maltese, Romanian, Estonian
- Greek — `el`
- Cyrillic — `bg`
- plus Turkish and Vietnamese probes (full coverage)

No fallback family is therefore required.  The only glyphs Open Sans lacks
are box-drawing characters (`─`, `═`) which appear solely in source-code
comments and never reach the PDF.

## License & provenance

Open Sans is licensed under the **Apache License, Version 2.0**.  The full
license text ships alongside the binaries:

- `LICENSE-OpenSans-Apache2.txt`

Redistribution of these binaries is permitted under that license.  They were
copied from the distribution package `open-sans-fonts`; no modification was
made.  If you redistribute this repository you must keep this README and the
license file together with the `.ttf` files.

## Regenerating

If you ever need to refresh the family, copy the same six styles from an
authoritative Open Sans release (Apache-2.0) and re-run `./verify.sh` to
confirm the rendered PDF still embeds and subsets them.
