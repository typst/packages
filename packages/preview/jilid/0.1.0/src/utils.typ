#import "state.typ": sections

#let filled(x) = x not in (none, "")

// turn a string or simple content into plain text.
// so that [TEXT] and "text" can be compared.
#let plain(it) = if type(it) == str { it } else if it.has("text") {
  it.text
} else if it.has("children") {
  it.children.map(plain).sum(default: "")
} else if it.has("body") { plain(it.body) } else { "" }

// put the label before the value.
// skip the label when the value already starts with it.
#let prefixed(label, value) = {
  let l = upper(plain(label))
  let v = upper(plain(value))
  if v == l or v.starts-with(l + " ") { value } else [#label #value]
}

// write a level-1 title in capitals when `headings.h1.uppercase` is true.
// numbered appendix titles follow `headings.appendix.uppercase`.
#let h1-title(cfg, body, appendix: false) = {
  let up = if appendix { cfg.headings.appendix.uppercase } else {
    cfg.headings.h1.uppercase
  }
  if up { upper(body) } else { body }
}

// "BAB II" for a chapter, "Lampiran 1" for an appendix.
// `n` is the heading's number within part `sec`.
#let h1-number(cfg, sec, n) = {
  let (word, style) = if sec == sections.main {
    (cfg.t.chapter, cfg.numbering.chapter)
  } else if sec == sections.back {
    (cfg.t.appendix, cfg.numbering.appendix)
  } else { return none }
  [#word #numbering(style, n)]
}

// write `body` in a text style.
// the style takes any `text` argument, `upper` and `underline`.
#let styled(style, body) = {
  if body == none { return none }
  let args = style
  let up = args.remove("upper", default: false)
  let line = args.remove("underline", default: false)
  if up { body = upper(body) }
  if line { body = underline(body) }
  text(..args, body)
}
