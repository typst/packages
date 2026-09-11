# cletter

Compose locale-aware letter components: salutations, openings, subjects,
closings, Gregorian dates, spelling conventions, and signature images.

```typst
#import "@preview/cletter:0.2.1" as letter
#let locale = "de-ch"
#assert.eq(letter.salutation(locale, "Frau Dr. Müller"), "Sehr geehrte Frau Dr. Müller")
#assert.eq(letter.long-date(locale, 2026, 10, 7), "7. Oktober 2026")
#assert.eq(letter.closing(locale), "Freundliche Grüsse")
#assert.eq(letter.apply-ortho(locale, "Grüße"), "Grüsse")
#letter.salutation(locale, "Frau Dr. Müller")

#letter.long-date(locale, 2026, 10, 7)

#letter.closing(locale)
```

| Helpers | Purpose |
| --- | --- |
| `resolve-locale(language: none, location: none)` | Select a document locale |
| `salutation(locale, name)` | Address a recipient |
| `opening(locale, name: none, override: none)` | Choose an opening |
| `subject(locale, title: none, prefix-override: none)` | Format an application subject |
| `closing(locale, override: none)` | Choose a conventional closing |
| `long-date`, `medium-date`, `short-date` | Format `(locale, year, month, day)` |
| `month-year(locale, year, month)` | Format a month-only dateline |
| `is-valid-date(year, month, day)` | Validate a Gregorian date |
| `apply-ortho(locale, text)` | Apply explicit spelling replacements |
| `orthography-issues(locale, text)` | Report matched replacement pairs |
| `signature-image(path, height-pt, width-pt: none)` | Size an image in points |

Openings and closings have 40 locale entries. Lookup is case-insensitive and
tries the exact locale, its base language, then English. Date formatting covers
German and English variants, with an English fallback; invalid dates return
`none`. Explicit overrides are preserved. Subject defaults suit job applications;
provide a prefix override for other correspondence. The package supplies
components; your document owns the body, layout and PDF rendering.

Spelling replacements require caller-selected prose. Preserve names, quotations,
URLs and exact source material; use diagnostics when those boundaries are unknown.

The bundle includes its runtime dependencies, so importing this package requires
no separate component imports. `typst/vendor/manifest.json` records the bundled
versions and file hashes.

## License

Copyright 2026 Julian Y. Richard Corbet. [Apache-2.0](LICENSE).
The files under `typst/vendor/cgreet/` retain their MIT OR Apache-2.0
license; both texts are included there. The other bundled components
are Apache-2.0 and retain their own notices.
