# Changelog

Note:
This document
only covers significant **user-facing** changes.

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
