# Changelog

## v0.8.0 (latest)
    - feat: allow clues without an icon.
    - feat: add goal clue
    - fix: transparent background for body
    - feat: set body-color
    - feat: use typst quote function inside quote.
    - refactor: update to linguify 0.4.0
    - refactor: split into multiple files for better maintainability


## v0.7.1
    - fix: bug with linguify.
    
## v0.7.0 

- Use linguify:0.3.0 package to manage different languages.
    - lang will be detected from `context text.lang` now.
    - Removed `#gc_header-title-lang.update("de")`.

- Removed `#gc_enable-task-counter.update(false)` use `#show: gentle-clues.with(show-task-counter: false)` now.
- **Breaking:** Changed `_color` to `accent-color`. Only type color and gradient are supported.
- Added `border-color` and `header-color` to overwrite default color calculation from the accent-color.
- Added `origin` parameter to `quote`.

## v0.6.0 

- Added possibility to define default settings via `#show: gentle-clues.with()`  - *lang*, *width*, *stroke-width*, *border-width*, *border-radius*, *breakable* - (See all options in [docs.pdf](docs.pdf))
    - **Deprecated:** `#gc_header-title-lang.update("de")` use `#show: gentle-clues.with(lang: "de")` now.
    - **Deprecated:** `#gc_enable-task-counter.update(false)` use `#show: gentle-clues.with(show-task-counter: false)` now.
- Added option to show all clues without headers. `#show: gentle-clues.with(headless: true)`


## v0.5.0

- Added option `breakable: true` to make clues breakable .
- Added spanish header titles. Use with `#gc_header-title-lang.update("es")`
- Removed aliases (breaking)

## v0.4.0 

- Added french header titles. Use with `#gc_header-title-lang.update("fr")`
- Fixed minor border issues
- Added an task-counter (disable with `gc_enable-task-counter.update(false)`)

*Colors:*

- Changed default color to `navy`
- Fixed bug that the border was sometimes no longer visible after `typst 0.9.0` update.
- Changed default border-color to the same color as `bg-color`
- Added support for gradients: `#clue(_color: gradient.linear(..color.map.crest))`
- **Breaking:** Removed string color_profiles. 
- Changed some predefined colors.

## v0.3.0

- Renamed entry files and base template
- Changed default `header-inset`. It's `0.5em` now.
- Added `gc_header-title-lang` state, which defines the language of the title. Accepts `"de"` or `"en"` at the moment.
- Changed `type` checks which requires typst version `0.8.0`
- Renamed parameter `color` to `_color` due to naming conflicts with the color type.

## v0.2.0

- Added option to set the header inset. `#admonish(header-inset: 0.5em)`
- Added custom color: `#admonish(color: (stroke: luma(150), bg: teal))`
- Added predefined example clue: `#example[Testing]`

## v0.1.0

- Initial release
