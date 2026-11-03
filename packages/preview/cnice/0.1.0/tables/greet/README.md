# tables — canonical salutation data

One matcher for every language: `salutation.json` carries all locales;
code only resolves the locale, matches normalized tokens and fills
templates. A new language is a new locale row, never new code.
`tests/vectors/` is the executable form of this contract: a port is done
when every vector passes.

## Normative token normalization

All table lookups use this normalization on each whitespace-separated
token — implementations must match it byte-for-byte:

1. Split the name on whitespace using exactly Rust `split_whitespace`
   semantics (Unicode White_Space: tab, newline, vertical tab, form feed,
   carriage return, space, U+0085, U+00A0, U+1680, U+2000–U+200A, U+2028,
   U+2029, U+202F, U+205F, U+3000). JavaScript `\s` differs on U+0085 and
   U+FEFF, so ports must use an explicit set, not a regex shorthand.
2. Strip leading and trailing `.` characters (`trim_matches('.')`).
3. Lowercase **ASCII A–Z only**. Rust uses `to_ascii_lowercase`; ports must
   NOT use Unicode-aware lowercasing (e.g. JavaScript `toLowerCase()` also
   folds non-ASCII, which would diverge — fold `[A-Z]` explicitly).

All keys in this file are already normalized. The schema test in the
Rust crate (`tables_schema`) asserts this on every row.

## Schema (`salutation.json`)

| Key | Meaning |
|-----|---------|
| `fallback` | Locale used when neither the exact code nor its base language has a row. Always `en`. |
| `locales` | BCP 47 code → row. |
| `locales.<code>.source_norms` | Free text: which correspondence norms the row comes from. |
| `locales.<code>.review` | Optional. `"native-pending"` pins provisional bytes whose correctness still awaits native review (currently `rm` only). Vectors prove determinism, not correctness. |
| `locales.<code>.honorifics` | Normalized first-token → `{group: "m"\|"f", display}`. Anything absent is unparsable and triggers the formal fallback. Display forms are canonicalized (never accusative, never abbreviated beyond the table form). No gender is ever inferred. |
| `locales.<code>.titles` | Normalized token → display form. |
| `locales.<code>.sole_titles` | Display forms that suppress every other title (protocol keeps only the highest). |
| `locales.<code>.filler` | Normalized tokens ignored when finding the surname (honorifics, titles, post-nominal grades). |
| `locales.<code>.named` | `{m, f}` templates with `{honorific}`, `{titles}`, `{surname}` slots. Empty parts collapse to single spaces; the locale comma appends last. |
| `locales.<code>.formal` | Formally safe fallback, stored WITHOUT trailing comma. |
| `locales.<code>.comma` | Whether the rendered salutation carries a trailing comma. |

## Matcher (all languages)

1. Resolve the row: case-insensitive exact code, base language, then `fallback`.
2. **Honorific**: `honorifics` lookup of the normalized FIRST token; display form otherwise.
3. **Titles**: scan ALL tokens, map to display forms, dedupe, sole-suppression.
4. **Surname**: last whitespace-separated token (raw, display-preserved) whose normalized form is not in `filler`; empty when none qualifies.
5. **Render**: without a parsable honorific or surname → `formal` (+ `,` when `comma`). Otherwise fill `named[group]`, collapse whitespace, append the comma.
