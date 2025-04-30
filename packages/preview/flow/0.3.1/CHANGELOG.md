# Changelog

Note:
This document
only covers significant **user-facing** changes.

## 0.3.0

Compatible with both Typst versions 0.12 and 0.13.

### Breaking

- Utils
  - Linear algebra
    - Expand `linco` to accept any number of arguments
    - Add text operator `size`
    - Tildized changed to `xvt` from `xva`
- Text that is surrounded by `[]` is automatically shown in violet and
  underlined now
  - Aimed to become proper clickable xlinks in future
- `cfg.render` aka `--input render=...` is an enum now
  - Retains aliases from booleans, but with slightly different semantics
  - New: `info` render mode which only returns metainfo at top of file and nothing else

### Additions

- New module: `hacks`
  - Things that are likely to break across Typst versions
  - Useful but also dangerous

#### Graphics

- Add 7-segment display

#### Preset

- New in linear algebra (`preset.linalg`)
  - `mpr` → Mixed product, left/right matrix
  - Conjugate → `xc`
  - Absolute value → `xa`, `xva`
  - Norm → `xn`, `xvn`
  - Set with indexed values → `sn`
  - Text operators `corank`, `size`, `Re`, `Im`, `eig`, `diag`, `rot`
  - Add `i`, `m`, `n`, `o` to vector shortcuts
  - Add geometric objects
    - Straight
      - Point-direction form → `std`
      - 2-point form → `stp`
    - Plane
      - Directonal form → `pld`
      - Normal form → `pln`
      - 3-point form → `plp`
- Added analysis (`preset.ana`)
- Added directional arrows (`preset.arrow`)

#### Template

- Styling: Add slight stroke around codeblocks

#### Metainfo

- Schema: Allow multiple translations for one language

#### Util

- New shortcut: centered dots → `ccc`
- Make `cartesian-product` variadic
- Add `versioned` for
  selecting a value based on the compiler version

#### Docs

- Add flow version to manual
- Expand my personal workflow to much more detail

#### Auxiliary

- Add script `flow-query` for querying many notes at once

#### Keyword

- Add more conjugations

### Refactor

- Clean up assets to be a bit shorter

## 0.2.0

### Breaking

- Shortcut presets have been moved
  to the globally-available `preset` module
  - E.g. if you've used `#import linalg: *` before,
    use `#import preset.linalg: *` instead
- Remove `slides` template and `presentation` module
  - It was
    - never properly documented
    - an utter hack causing more headaches than it saved in writing time
    - dependent on polylux
      - which was never updated to resolve the compiler's warnings
        about the new `context` mechanism
      - and needlessly spamming my logs hence

### Additions

- Use [Halcyon](https://github.com/bchiang7/Halcyon)
  as new default theme for codeblocks
- Fill `preset.linalg` with more utilities
  - (Conjugate) transposition via `trp`/`ctrp`
  - Inner product via `ipr`
  - Overline via `ovl`
  - Shorthands for ... after the pattern ...
    - Transposition → `xT`
    - Conjugate transposition → `xH`
    - Vector boldface → `xvb`
    - Vector tildized → `xva`
    - Vector transposed → `xvT`
    - Vector conjugate transposed → `xvH`
- Add more preset modules
  - They're quite empty for now
  - `preset.quantum`
  - `preset.calculus`
- More keyword conjugates
- The `modern` template (used by e.g. `note`)
  defaults to [optimized linebreaks](https://typst.app/docs/reference/model/par/#parameters-linebreaks)
  now
  - Should result in more visually consistent blocks of text

## 0.1.2

Initial published

