# [unreleased](https://github.com/tingerrr/hydra/releases/tags/)
## Added

## Removed

## Changed

---

# [v0.5.0](https://github.com/tingerrr/hydra/releases/tags/v0.5.0)
## Added
- `use-last` parameter on `hydra` for a more LaTeX style heading look up, thanks @freundTech!
  - `hydra` now has a new `use-last` parameter
  - `context` now has a new `use-last` field
  - **BREAKING CHANGE** `candidates` now has a new `last` field containing a suitable match for the last primary candidate on this page

## Removed

## Changed

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
