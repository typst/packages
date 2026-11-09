# Journal themes and inherited defaults

The development package exposes seven palettes: `neutral`, `slate`, `soft-jade`,
`soft-slate`, `warm-editorial`, `plum`, and `soft-rose`. Covers accept `theme:`;
journals and indexes now accept the same names:

The neutral palette is the default for all document templates and uses only
black and white. `slate` preserves the former dark blue-gray base palette.
Choose another palette in `config.typ` to opt into color.

```typst
#import "@local/satz:0.2.0": journal-entry, journal-index
#journal-index(theme: "soft-jade")
#pagebreak()
#journal-entry(title: "First notes", date: "Wednesday, 21/10/26", theme: "soft-jade")[
  == Goal
  Write the question and what you want to learn.
]
```

Keep the theme name in one project settings file and pass it to the cover,
index and entries. `theme: none` skips the theme and uses template defaults.
Explicit nested `config:` values take precedence over the selected palette.

For **any** Satz template or component with a `config:` parameter, use the
public helper rather than copying palette values:

```typst
#import "@local/satz:0.2.0": theme-config
#let config = theme-config("plum", config: (
  typography: (size: 12pt),
))
// Pass config: config to your report, journal or component.
```

The helper supplies document colors and matching link colors. Document pages
stay white; cover themes may use a subtly tinted background. Components with
an explicit config parameter need that same config passed to them. Prescribed
funder forms retain their own defaults unless explicitly overridden.

## Keep configuration small

A config dictionary is a set of **overrides**, not a required complete snapshot.
Satz deep-merges it with current package defaults. For example:

```typst
#let config = (
  page: (paper: "iso-b5"),
  // Add only settings you deliberately want to fix yourself.
)
```

Every copied key masks future changes to that default. Remove copied font,
leading, heading gaps and decoration settings when you want Satz to manage
them. Keep deliberate choices such as paper format or a custom color.

Package versions and config snapshots are separate: pinning a released package
version gives reproducible documents; using a local development checkout gets
its current code. A local import is not enough if a full copied config still
overrides every updated setting. Update the package deliberately, and keep the
project config minimal so its defaults can take effect.

Run `python3 examples/latex-parity/check_journal_themes.py` for palette,
override and API checks, and `check_journal_header.py` for layout regressions.
These APIs are unreleased; published `@preview/satz:0.1.1` does not yet contain
the new journal theme selector.
