// The `altacv` template's body, applied by `altacv` and standalone
// `alta()` (`render.typ`) and by the component gallery
// (`tests/components.typ`), which adds the CV's own styles, so it
// shows components exactly as a CV does.

#import "design/styles.typ": _base-styles, _label-headings, _part
#import "design/theme.typ": _theme-for, _token-prefs
#import "context.typ": _labels-state, _theme-state

// The theme state, the default text and margins, and the paragraph
// and list rules, from the built theme and the body size and
// margins `data/` resolves: what a user's rules after `altacv`
// override. Pushes the template's `theme` and its `labels` layer
// (`altacv.with(labels: ..)`, `none` for none) for its body; a
// `scoped` template's end with it, so content after a nested template
// reads the outer one's. Standalone `alta()`'s theme stays set for
// the content after it, as the public helpers (`tag`, `rating`, …)
// there read it.
#let _document(theme, size, margin, body, labels: none, scoped: true) = {
  let layers = if labels == none { () } else { (labels,) }
  _theme-state.update(themes => themes + (theme,))
  _labels-state.update(stack => stack + layers)
  set text(
    size,
    font: theme.font,
    weight: theme.type.body.weight,
    fill: theme.colours.body,
  )
  set page(margin: margin)
  show: _base-styles.with(theme)
  body
  if scoped {
    _theme-state.update(themes => themes.slice(0, -1))
    _labels-state.update(stack => stack.slice(0, stack.len() - layers.len()))
  }
}

// For `show: _standalone.with(prefs, labels, footer)`, with the merged,
// validated preferences and labels and `footer` a function of the
// built theme: the template's body and its heading rules, then the
// preferences that stand in for a user's set rules after it.
#let _standalone(prefs, labels, footer, body) = {
  // The default theme, under `font` and the deprecated `accent`.
  let theme = _theme-for((:), _token-prefs(prefs))
  show: _document.with(theme, prefs.body-size, prefs.margin, scoped: false)
  show: _label-headings.with(theme)
  // `text.lang` unless the deprecated `labels.lang` is set; drop with
  // it (#239). Before `set page`, so the footer inherits it.
  set text(lang: labels.lang)
  set page(paper: prefs.paper, footer: _part("footer", footer(theme)))
  body
}
