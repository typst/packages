#import "_pkg.typ"

#let apply-for-all(
  values,
  rule,
) = outer => {
  show: inner => {
    values.map(rule).fold(inner, (acc, f) => f(acc))
  }

  outer
}

#let gather-kinds(body) = {
  if _pkg.t4t.is.elem(figure, body) {
    if body.at("kind", default: auto) != auto {
      return (figure.kind,)
    }
  } else if body.has("children") {
    return body.children.map(gather-kinds).flatten().dedup()
  }

  (image, raw, table)
}

#let i18n-kind(kind) = {
  let map = toml("/assets/i18n.toml")

  if kind not in map.en {
    panic("Unknown kind: `" + kind + "`")
  }

  let lang-map = map.at(text.lang, default: (:))
  let region-map = if text.region != none { lang-map.at(text.region, default: (:)) } else { (:) }
  let term = region-map.at(kind, default: none)

  if term == none {
    term = lang-map.at(kind, default: none)
  }

  if term == none {
    term = map.en.at(kind)
  }

  term
}
