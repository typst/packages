#import "_pkg.typ"

#let _numbering = numbering

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

#let stitch-pairs(args) = {
  if args.len() == 0 {
    return ()
  }

  assert.ne(type(args.first()), label, message: "First item must not be a label")

  let pairs = ()
  while args.len() != 0 {
    let item = args.remove(0)
    if type(item) == label {
      let last = pairs.pop()

      assert.ne(type(last), label, message: "Cannot have two consecutive labels")

      last.at(1) = item
      pairs.push(last)
    } else {
      pairs.push((item, none))
    }
  }

  pairs
}

#let sparse-numbering(numbering) = if type(numbering) == str {
  let symbols = ("1", "a", "A", "i", "I", "い", "イ", "א", "가", "ㄱ", "\\*")
  let c =  numbering.matches(regex(symbols.join("|"))).len()

  if c == 1 {
    // if we have only one symbol we drop the super number
    (_, num) => _numbering(numbering, num)
  } else {
    (..nums) => _numbering(numbering, ..nums)
  }
} else {
  numbering
}
