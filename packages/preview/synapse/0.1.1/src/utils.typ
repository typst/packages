#import "config.typ": _style-of, _is-mode


#let _get-styled-text(meta, style) = {
  let styled-text = if meta != none and meta.style != none {
    meta.style
  } else {
    _style-of(style)
  }
  if _is-mode("paper") {
    return styled-text.with(fill: text.fill, stroke: none)
  } else {
    return styled-text
  }
}

#let _get-notion-display(meta, style, notion, body) = {
  let notion-string = if body != none {
    body
  } else if "%" in notion {
    notion.split("%").at(0)
  } else {
    notion
  }
  _get-styled-text(meta, style)(notion-string)
}
