# tables — canonical valediction data

One concern only: which valediction a locale uses. `tests/vectors/` is the
executable form of this contract.

## Schema (`closing.json`)

| Key | Meaning |
|-----|---------|
| `locales` | BCP 47 code → valediction string, verbatim. Keys are lowercase locale IDs (`de-ch`, `en-us`). |
| `fallback` | Locale used when neither the exact code nor its base language is present. Always `en`. |

## Resolution (all languages)

1. Exact code (`fr-ch`) wins.
2. Otherwise the base language (`fr-ch` → `fr`).
3. Otherwise `fallback` (`en`).
4. An explicit override always wins over all three.

Locale IDs are lowercase in tables, returned locale lists, examples and paths.
Lookups accept mixed-case input and resolve the lowercase exact code, then base
language, then fallback. `de-li` has an explicit Liechtenstein entry.
