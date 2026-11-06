# [unreleased](https://github.com/tingerrr/hydra/releases/tags/)

## Changed

## Fixed

---

# [v0.6.2](https://github.com/tingerrr/hydra/releases/tags/v0.6.2)
## Changed
- Bumped `oxifmt` from `0.2.1` to `1.0.0`
- Bumped `mantys` from `1.0.0` to `1.0.2`

## Fixed

---

# [v0.6.1](https://github.com/tingerrr/hydra/releases/tags/v0.6.1)
## Fixed
- Use the correct page length when calculating the top margin

---

# [v0.6.0](https://github.com/tingerrr/hydra/releases/tags/v0.6.0)

## Breaking Changes
- Removed `hydra.dir`
- Removed `hydra.binding`
- Bumped MSTV to `v0.12.0`

## Changed
- Renamed `context` to `hydra-context`
- Renamed `hydra-selector` to `full-selector`
- Renamed `sanitized-selector` to `hydra-selector`

---

# [v0.5.2](https://github.com/tingerrr/hydra/releases/tags/v0.5.2)
## Fixed
- Fixed a panic on the development version of typst caused by an outdated version of oxifmt

---

# [v0.5.1](https://github.com/tingerrr/hydra/releases/tags/v0.5.1)
## Fixed
- hydra no longer considers candidates on pages after the current page (https://github.com/tingerrr/hydra/pull/21)

---

# [v0.5.0](https://github.com/tingerrr/hydra/releases/tags/v0.5.0)
## Added
- `use-last` parameter on `hydra` for a more LaTeX style heading look up, thanks @freundTech!
  - `hydra` now has a new `use-last` parameter
  - `context` now has a new `use-last` field
  - **BREAKING CHANGE** `candidates` now has a new `last` field containing a suitable match for the last primary candidate on this page

---

# [v0.4.0](https://github.com/tingerrr/hydra/releases/tags/v0.4.0)
Almost all changes in this release are **BREAKING CHANGES**.

## Added
- internal util functions and dictionaries for recreating `auto` fallbacks used within the typst
  compiler
  - `core.get-text-dir` - returns the text direction
  - `core.get-binding` - returns the page binding
  - `core.get-top-margin` - returns the absolute top margin
  - `util.text-direction` - returns the text direction for a given language
  - `util.page-binding` - returns the page binding for a given text direction

## Removed
- various parameters on `hydra` have been removed
  - `paper` has been removed in favor of get rule
  - `page-size` has been removed in favor of get rule
  - `top-margin` has been removed in favor of get rule
  - `loc` has been removed in favor of user provided context
- internal util dictionary for page sizes

## Changed
- hydra now requires a minimum Typst compiler version of `0.11.0`
- `hydra` is now contextual
- most internal functions are now contextual
- the internal context dictionary now holds a `anchor-loc` instead of a `loc`
- `get-anchor-pos` has been renamed to `locate-last-anchor`
- the internal `page-sizes` dictionary was changed to function
- various parameters on `hydra` are now auto by default
  - `prev-filter`
  - `next-filter`
  - `display`
  - `dir`
  - `binding`

---

# [v0.3.0](https://github.com/tingerrr/hydra/releases/tags/v0.3.0)

# [v0.2.0](https://github.com/tingerrr/hydra/releases/tags/v0.2.0)

# [v0.1.0](https://github.com/tingerrr/hydra/releases/tags/v0.1.0)
