# [unreleased](https://github.com/tingerrr/subpar/tags/)
## Added

## Removed

## Changed

## Fixed

---

# [v0.2.2](https://github.com/tingerrr/subpar/tags/v0.2.2)
## Changed
- Improved error message for some label error paths

## Fixed
- Fixed panic because of undefined variable in error path
- Fixed incorrect handling of `grid.cell`
- Removed absolute path to assets in [`util.typ`](./src/util.typ)

---

# [v0.2.1](https://github.com/tingerrr/subpar/tags/v0.2.1)
## Added
- i18n: `bg` Bulgarian
- i18n: `ca` Catalan/Valencian
- i18n: `eu` Basque
- i18n: `gl` Galician
- i18n: `he` Hebrew
- i18n: `is` Icelandic
- i18n: `la` Latin
- i18n: `nl` Dutch

## Fixed
- Removed validation of argument types
- i18n: `gr` -> `el` Greek
- i18n: `ua` -> `uk` Ukrainian

---

# [v0.2.0](https://github.com/tingerrr/subpar/tags/v0.2.0)
## Added
- added scope paramter to `super` and `grid`

## Changed
- updated minimum compiler version to 0.12.0

## Fixed
- Passing `grid` sub-elements to `subpar.grid` now correctly passses them though
  to `grid`

---

# [v0.1.1](https://github.com/tingerrr/subpar/tags/v0.1.1)
## Added
- Default implementations for figure show rules
- Manual examples about changing the figure appearances

## Fixed
- non-image kinds are correctly used in `subpar.grid`
- setting supplements manually no longer causes a panic

---

# [v0.1.0](https://github.com/tingerrr/subpar/releases/tag/v0.1.0)
Initial Release
