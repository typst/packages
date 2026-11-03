# Typst correspondence facade

Copy this complete directory into a project and import `letter.typ`. It contains
its generated locale tables and vendored family sources, so no package registry
lookup or sibling checkout is needed while compiling.

```typst
#import "letter.typ": salutation, closing, long-date, orthography-issues
#salutation("de-li", "Frau Dr. Müller")
#closing("de-li")
#long-date("de-li", 2026, 9, 9)
#assert.eq(orthography-issues("de-li", "Grüße"), (("ß", "ss"),))
```

The facade reexports cgreet's salutation and recipient-advisory helpers,
cfarewell's closing, cdate's date formats, and cink's `signature-image`.
Opening, subject, locale resolution and orthography remain cletter-owned.
Locale IDs are lowercase; mixed-case inputs resolve compatibly. Explicit
opening/subject/closing overrides and recipient names are preserved verbatim.

`normalize-locale-id(" EN_CH ")` returns `"en-ch"` without inferring a region
or falling back through the correspondence tables. It preserves all explicit
subtags. It trims only ASCII space, tab, LF, CR, VT and FF, replaces underscores
with hyphens and lowercases ASCII letters. Other characters, including U+FEFF
and U+0085, remain for caller validation. Callers validate syntax and their
supported locale shape separately.
`normalize-language` and `resolve-locale` retain their supported-table behavior.

`apply-ortho` performs literal substitutions only on caller-selected prose.
`orthography-issues` reports applicable pairs without changing text. The caller
excludes names, quotations, URLs and exact source material; neither helper
infers protected boundaries or evaluates a letter's evidence, tone or argument.

`vendor/manifest.json` records repositories, candidate package versions and exact
SHA-256 identities of copied sources. Source hashes are authoritative for an
unreleased snapshot. Never hand-edit vendored sources: change their owning
library, regenerate its tables, then run from the cletter checkout:

```sh
python3 scripts/sync-typst-family.py /path/to/family-checkouts
python3 scripts/typst-conformance.py /path/to/family-checkouts
```

The conformance driver uses an existing `typst` or `tinymist` compiler and runs
all canonical JSON vectors for cgreet, cfarewell, cdate and cletter. The cink
Typst helper renders a sized image; decoding and sizing vectors belong to its
Rust, TypeScript and Python ports.
