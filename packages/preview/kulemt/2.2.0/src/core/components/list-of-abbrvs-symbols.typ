// List of Abbreviations and Symbols.
//
// CHANGED: the reference PDF lays these out as a two-column list -- term on
// the left, description on the right, with the description block hanging and
// wrapping cleanly. 0.1.0 just dumped whatever content you passed, which is
// what its author's "TODO: idk, is kinda wonky to use" was about.
//
// Pass an array of (term, description) pairs:
//
//   abbreviations: (
//     ("LoG",  "Laplacian-of-Gaussian"),
//     ("MSE",  "Mean Square error"),
//     ("PSNR", "Peak Signal-to-Noise ratio"),
//   )
//
// Raw content still works and is passed through untouched.

#let term-list(items, term-width: 5em) = {
  if type(items) != array {
    return items
  }
  let cells = ()
  for pair in items {
    cells.push(pair.at(0))
    cells.push(pair.at(1))
  }
  grid(
    columns: (term-width, 1fr),
    column-gutter: 1em,
    row-gutter: 0.45em,
    ..cells
  )
}

/// -> content
#let insert-list-of-abbrv-symbol(
  lang: "en",
  abbreviations: none,
  symbols: none,
) = {
  let title = if lang == "en" {
    "List of Abbreviations and Symbols"
  } else {
    "Lijst van afkortingen en symbolen"
  }

  set par(first-line-indent: 0em)
  heading(numbering: none, bookmarked: true, level: 1, outlined: true, title)

  let sub(name) = block(
    above: 1.4em,
    below: 0.8em,
    text(size: 1.1em, weight: "bold", name),
  )

  if abbreviations != none {
    sub(if lang == "en" { "Abbreviations" } else { "Afkortingen" })
    term-list(abbreviations)
  }
  if symbols != none {
    sub(if lang == "en" { "Symbols" } else { "Symbolen" })
    term-list(symbols)
  }
}
