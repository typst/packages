# cfarewell

Choose a conventional closing for correspondence from 40 locale entries.

```typst
#import "@preview/cfarewell:0.2.1" as farewell
#assert.eq(farewell.closing("de-ch"), "Freundliche Grüsse")
#assert.eq(farewell.closing("DE-LI"), "Freundliche Grüsse")
#assert.eq(farewell.closing("de", override: "Bis bald"), "Bis bald")
#farewell.closing("de-ch")
```

`closing(locale, override: none)` returns a string. An explicit override is
preserved verbatim, including an empty string. Otherwise lookup is
case-insensitive and tries the exact locale, its base language, then English.
`available-locales()` returns the sorted locale identifiers. Layout, punctuation
outside the returned closing, and the letter body remain with the caller.

## License

Copyright 2026 Julian Y. Richard Corbet. [Apache-2.0](LICENSE).
