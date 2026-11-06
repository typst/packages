// Shared typography helpers.

#let colon-space() = context {
  if text.lang == "fr" { [#"\u{00a0}"] } else { [] }
}

// Apply the optional heading face without forcing users to configure one.
// Newer styles use this helper so their display typography can be changed
// independently while legacy renderers keep their exact output.
#let heading-face(cfg, body) = {
  if cfg.at("heading-font", default: none) != none {
    set text(font: cfg.heading-font)
  }
  body
}

#let _number-with(pattern, fallback, ..values) = {
  if pattern == auto {
    fallback
  } else {
    numbering(pattern, ..values.pos())
  }
}

#let part-number(num, cfg, fallback: auto) = {
  let fallback = if fallback == auto { numbering("I", num) } else { fallback }
  _number-with(cfg.at("part-numbering", default: auto), fallback, num)
}

#let chapter-number(num, cfg, fallback: auto) = {
  let fallback = if fallback == auto { [#num] } else { fallback }
  _number-with(cfg.at("chapter-numbering", default: auto), fallback, num)
}

#let section-number(ch-num, sec-num, cfg, fallback: auto) = {
  let fallback = if fallback == auto {
    if ch-num > 0 { [#ch-num.#sec-num] } else { [#sec-num] }
  } else { fallback }
  if ch-num > 0 {
    _number-with(cfg.at("section-numbering", default: auto), fallback, ch-num, sec-num)
  } else {
    _number-with(cfg.at("section-numbering", default: auto), fallback, sec-num)
  }
}

#let subsection-number(ch-num, sec-num, subsec-num, cfg, fallback: auto) = {
  let fallback = if fallback == auto {
    if ch-num > 0 { [#ch-num.#sec-num.#subsec-num] } else { [#sec-num.#subsec-num] }
  } else { fallback }
  if ch-num > 0 {
    _number-with(cfg.at("subsection-numbering", default: auto), fallback, ch-num, sec-num, subsec-num)
  } else {
    _number-with(cfg.at("subsection-numbering", default: auto), fallback, sec-num, subsec-num)
  }
}

#let subsubsection-number(ch-num, sec-num, subsec-num, subsubsec-num, cfg, fallback: auto) = {
  let fallback = if fallback == auto {
    if ch-num > 0 { [#ch-num.#sec-num.#subsec-num.#subsubsec-num] } else { [#sec-num.#subsec-num.#subsubsec-num] }
  } else { fallback }
  if ch-num > 0 {
    _number-with(cfg.at("subsubsection-numbering", default: auto), fallback, ch-num, sec-num, subsec-num, subsubsec-num)
  } else {
    _number-with(cfg.at("subsubsection-numbering", default: auto), fallback, sec-num, subsec-num, subsubsec-num)
  }
}
