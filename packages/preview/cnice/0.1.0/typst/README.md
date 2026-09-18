# Typst correspondence phrases

Copy `typst/lib.typ` together with `typst/greet.typ`, `typst/farewell.typ`,
`typst/generated/`, `tables/salutation.json` and `tables/farewell/closing.json`,
preserving their relative paths. The modules read the canonical tables used by
Rust, TypeScript and Python.

```typst
#import "typst/lib.typ" as cnice
#cnice.greet.salutation("de-ch", "Frau Dr. Müller")
#cnice.greet.salutation("fr", "Madame Dupont")
#cnice.farewell.closing("de-ch")
#assert.eq(cnice.greet.salutation-titles("de", "Herr Dipl.-Ing. Müller"), ("Dipl.-Ing.",))
```

`greet` runs one uniform matcher for every covered locale
(`de`, `de-ch`, `de-at`, `de-li`, `fr`, `it`, `rm`, `en`, `en-gb`, `en-us`):
locale-keyed honorific/title/surname extraction, template rendering and
recipient advisories; `is-supported` reports row coverage. `farewell`
exports `closing` (exact code, base language, then English fallback;
explicit overrides always win) and `available-locales`. Names are
preserved; no spelling transformation runs
implicitly. Token normalization strips outer periods and lowercases ASCII A–Z.
