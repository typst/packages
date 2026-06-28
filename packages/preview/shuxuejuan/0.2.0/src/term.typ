#let COMPOSER = (
  TERMS: "terms",
  GRID: "grid",
  PAR: "par",
)

#let sxj-content-trim(body) = (
  if type(body) == content {
    if body.has("children") {
      let trimmed = body
      if trimmed.children.first() == [ ] {
        trimmed = trimmed.children.slice(1).join()
      }
      if trimmed.children.last() == [ ] {
        trimmed = trimmed.children.slice(0, -1).join()
      }
      trimmed
    } else { body }
  } else { body }
)

#let sxj-get-composer-for(composer: auto, body) = if composer != auto {
  return composer
} else {
  if type(body) == content {
    if body.func() in (std.grid, math.equation) {
      return COMPOSER.GRID
    }
    if body.has("children") and body.children.len() != 0 {
      if body.children.first().func() == grid {
        return COMPOSER.GRID
      }
    }
  }
  return COMPOSER.TERMS
}

#let sxj-term(
  composer: COMPOSER.TERMS,
  hanging-indent: 1.5em,
  tag-align: right,
  tag,
  body,
  ..args,
) = {
  // Note: wrap the `tag` in two `box`es so that `set align(right)`
  //   won't compress `"."` if it is the last char of `tag`.
  let tag = box(
    width: hanging-indent,
    align(tag-align, box(
      width: auto,
      align(left, tag),
    )),
  )
  let tag = {
    let tag-down = args.at("tag-down", default: none)
    if tag-down != none { v(tag-down) }
    tag
  }
  let body = {
    let body-down = args.at("body-down", default: none)
    if body-down != none { v(body-down) }
    body
  }
  if composer == COMPOSER.TERMS {
    terms(
      indent: 0em,
      separator: none,
      tight: false,
      hanging-indent: hanging-indent,
      terms.item(tag, body),
    )
  } else if composer == COMPOSER.GRID {
    grid(
      gutter: 0em,
      columns: (hanging-indent, 1fr),
      tag, body,
    )
  } else if composer == COMPOSER.PAR {
    set par(hanging-indent: hanging-indent)
    [#tag#body]
  }
}
