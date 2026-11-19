// Render-time context: the values `alta()` provides, from the merged
// preferences, to everything that renders. Typst `state` cells, read
// inside `context { }`, because the public helpers (`tag`, `term`,
// `divider`, `rating`, `icon`) can sit anywhere in a user's document
// and can't be passed the preferences. The theme's tokens and roles
// live in `design/theme.typ`.

#import "design/theme.typ": _default-theme
#import "data/options.typ": _resolve-labels
#import "data/defaults.typ": _default-preferences

// The built themes (`_theme-for`) of the templates the content sits
// in, innermost last: `_document` pushes its theme and, for `altacv`,
// pops it after its body, so content after a nested template reads the
// outer one. Standalone `alta()`'s stays pushed.
#let _theme-state = state("alta-theme", (_default-theme,))
// The theme in effect where it's read (in `context`).
#let _theme() = _theme-state.get().last()
// The label overrides in effect, outermost first: each `altacv`'s
// `labels:` (`_template-labels`), pushed for its body, and inside it
// each `alta()`'s, pushed for its CV, so the blocks that CV draws read
// them. Kept as layers rather than resolved labels, as the bundled
// translation they go over is the language where they're read.
#let _labels-state = state("alta-labels", ())
// The labels where they're read (in `context`): the defaults, the
// translation for `text.lang`, then the layers in effect.
#let _labels() = _resolve-labels(text.lang, .._labels-state.get())
// Read only by the public `rating()` helper's default `max`; the
// languages section passes `prefs.max-rating` explicitly.
#let _max-rating-state = state(
  "alta-max-rating",
  _default-preferences.max-rating,
)

