# cgreet

Compose formal German salutations for Switzerland, Liechtenstein, Germany,
and Austria from explicitly supplied recipient details.

```typst
#import "@preview/cgreet:0.2.1": de-salutation, salutation-titles

#de-salutation("Frau Dr. Müller", region: "ch")
// Sehr geehrte Frau Dr. Müller

#de-salutation("Herr Professor Dr. Schmidt", region: "de")
// Sehr geehrter Herr Professor Schmidt,

#assert.eq(salutation-titles("Herr Dipl.-Ing. Müller"), ("Dipl.-Ing.",))
```

`de-salutation(name, region: "ch")` returns a string. German (`de`) and Austrian
(`at`) salutations end with a comma; Swiss (`ch`) and Liechtenstein (`li`)
salutations do not. Region codes must be lowercase. An unsupported region raises
an assertion; `parse-region` lets callers check one first.

Missing honorifics or surnames produce the generic salutation
`Sehr geehrte Damen und Herren` with the region's punctuation. The helper reads
supplied `Herr`/`Herrn` or `Frau`; it does not infer gender from a person's name.
Professor takes precedence over other recognized titles. Surname extraction
selects the last significant token, so callers should review compound names.

## Helpers

Import any of these functions with an explicit `@preview/cgreet:0.2.1` import.
All `name`, `token`, `code`, `region`, and `location` arguments are strings.

| Function | Result |
| --- | --- |
| `de-salutation(name, region: "ch")` | Complete salutation string. |
| `parse-region(code)` | `ch`, `li`, `de`, or `at`; `none` for unsupported input. |
| `region-uses-comma(region)` | Whether a supported region requires a comma. |
| `salutation-last-name(name)` | Last whitespace-separated token, or an empty string. |
| `salutation-honorific(name)` | `herr`, `frau`, or an empty string. |
| `salutation-title-kind(token)` | Normalized recognized title, or an empty string. |
| `salutation-titles(name)` | Array of distinct recognized titles, with precedence applied. |
| `salutation-surname(name)` | Last token after ignoring honorifics, titles, and post-nominal grades. |
| `recipient-salutation-warning(location, name)` | Advisory string for a missing name, otherwise `none`. |
| `de-honorific-warning(location, name)` | Advisory string for incomplete German address details, otherwise `none`. |

Token lookup strips leading and trailing periods and lowercases ASCII A–Z.
Names retain their spelling. The bundled [German correspondence table](tables/de.json)
is shared with cgreet's Rust, JavaScript, and Python implementations. Diagnostic
strings retain the `job.cl_recipient.name` field label used by the originating
application; callers can present their own wording around these advisories.

## License

Copyright © 2026 Julian Y. Richard Corbet. Use this release under either
[MIT](LICENSES/MIT.txt) or [Apache-2.0](LICENSES/Apache-2.0.txt), at your option.
Both license texts are included in the package.
