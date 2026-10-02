# tables — canonical correspondence data

`locales.json` holds everything locale-shaped; `countries.json` resolves a
free-text location to a country code. `tests/vectors/` is the executable
form of this contract.

## Schema (`locales.json`)

| Key | Meaning |
|-----|---------|
| `locales` | BCP 47 code → `{formal, named, subject_prefix, subject_unsolicited, use_ss}`. `named` carries a `{name}` placeholder and fills verbatim for locales outside the uniform salutation renderer; for covered locales (`de`, `de-ch`, `de-at`, `de-li`, `fr`, `it`, `rm`, `en`, `en-gb`, `en-us` per `cnice::greet::is_supported`) the renderer owns named rendering and `named` keeps a formal duplicate for schema shape. `use_ss` is true for `de-ch` and `de-li`. The `rm` formal/subject strings are attested (Lia Rumantscha/BAKOM for the opening) or marked native-pending (subject); see the `rm` review note below. |
| `orthography_replacements` | Ordered literal source/replacement pairs applied where `use_ss` is true: `ß` → `ss`, `ẞ` → `SS`. |
| `supported` | Every BCP 47 code the resolver accepts (convention locales plus region-only variants like `de-de`, resolved through their base). |
| `fallback` | Locale used when neither the exact code nor its base language has an entry. Always `en`. |
| `variants` | Base language → country code → regional variant (`de` + `CH` → `de-ch`). Only languages with meaningful convention differences are listed. |

## Resolution (all languages)

`resolve_locale(language?, location?)`: normalize the language
(trimmed, lowercase, underscores changed to hyphens, must be supported, else `en`);
extract the country from the location (keywords, then Swiss cantons);
map through `variants` (known country → variant, else base; no location →
normalized language).

Lookups (`opening`, `subject`, orthography) then resolve exact code →
base language → `fallback`. An explicit override always wins — tables
supply defaults, never commands.

Two normalizations coexist by design: table tokens (honorifics, locale
codes) match ASCII-only, exactly like `cnice::greet`; free-text location
scanning lowercases Unicode-aware (`Österreich` must match), mirroring
the reference implementation the tables were transcribed from.

Locale IDs are lowercase in tables, returned values, examples and paths.
Lookups accept mixed-case input and resolve the lowercase exact code, then base
language, then fallback. `normalize_language` always returns lowercase or no
value. Country codes from `country_from_location` and `variants` keys remain
uppercase ISO country codes; they are separate from locale IDs.

`orthography_replacements` returns the applicable table pairs;
`orthography_issues` reports pairs present in the text without changing it.
`apply_ortho` performs explicit substitutions on caller-selected prose. Callers
must exclude exact names, quotations, URLs and source material; the library does
not guess those boundaries or rewrite opening/subject/closing overrides.
