#let _notions = state(
  "notions",
  ((:), ()),
)

#let _notion-wrapper-arg-name = "notion-wrapper-fun"

#let _new-notion(repr, url, style) = (
  repr: repr,
  url: url,
  style: style,
  introduced: false,
  anchored: false,
)

#let _is-existing-notion(repr) = repr in _notions.get().at(0)
#let _get-meta(notion) = _notions.get().at(1).at(
  _notions.get().at(0).at(notion),
)