# cdate

Format Gregorian calendar dates in German and English without a clock or timezone.

```typst
#import "@preview/cdate:0.2.1" as date
#assert.eq(date.long-date("de", 2026, 10, 7), "7. Oktober 2026")
#assert.eq(date.long-date("en", 2026, 10, 7), "October 7, 2026")
#assert.eq(date.month-year("de", 2026, 10), "Oktober 2026")
#assert.eq(date.long-date("de", 2026, 2, 30), none)
#date.long-date("de", 2026, 10, 7)
```

| Function | Result |
| --- | --- |
| `long-date(locale, year, month, day)` | Written month and full year |
| `medium-date(locale, year, month, day)` | Compact locale format |
| `short-date(locale, year, month, day)` | Locale-specific short format |
| `month-year(locale, year, month)` | Month and year without inventing a day |
| `is-valid-date(year, month, day)` | Gregorian date validation |
| `is-supported(locale)` | Whether the locale or its base language is supported |
| `available-locales()` | Sorted locale identifiers |

Date fields must be integers. Invalid dates return `none`; validation returns a
boolean. Locale lookup is case-insensitive and tries the exact locale, its base
language, then English. German and English variants are supported; the fallback
does not translate arbitrary languages. This package formats supplied dates and
does not parse localized prose or select today's date.

## License

Copyright 2026 Julian Y. Richard Corbet. [Apache-2.0](LICENSE).
