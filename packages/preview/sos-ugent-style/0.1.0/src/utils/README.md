## Internal utils
- Used only for consumption by files in `src/`
- Distinct from `utils/`, which should be utility functions for *users*.
  See [the readme](../../utils/README.md).
- **Glossy** is thightly integrated with sos-ugent-style.
  See [the reasoning](../../utils/README.md).
  - The dependency is optional. If no glossary entries are provided and
    `ugent.glossary()` is not used, glossy is not imported.
  - The exact version of glossy is specified and lazily imported in `/utils/lib.typ`
  - The template AND glossy-theme-ugent actually depend on
    [my contributions](https://github.com/swaits/typst-collection/pull/55)
    being merged. ~~This is why for the first official release of sos-ugent-style,
    `ugent.glossary()` will panic with a warning to locally install my fork
    or use `ugent.utils.glossy().glossary()` (original, unthemed version).~~
    The first release (see tag `v0.1.0`) just accomodated these changes in
    the theme.
