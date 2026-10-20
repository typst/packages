#import "@preview/one-liner:0.3.0": fit-to-width

#let details-sheet(
/* * * HEADER * * */
  name: str,
  age: str,
  height: str,
  weight: str,
  eyes: str,
  skin: str,
  hair: str,
/* * * IMAGES * * */
  appearance: none,
  symbol: none,
  symbol-name: str,
/* * * TEXT FIELDS * * */
  backstory: str,
  allies-organizations: str,
  additional-features-traits: str,
  treasure: str,
/* * * for rendering * * */
  settings: (
    language: "en", // only changes built-in lang features, no changes are made to the sheet text
    printer-mono: false, // true for black outlines, false for colored
    spell-rainbows: false, // changes the paper rules to rainbow gradients
    body-font: "Vollkorn"
  ),
  body: none
) = {
  set text(lang: settings.at("language", default: "en"), size:14pt, font: settings.at("body-font", default: "Vollkorn"))
  set page(
    paper: "us-letter",
    margin: (x: 0%, y: 0%, top: 0%, bottom: 0%)
  )

  body = {
  /* * * HEADER * * */
  set text(size:13pt)
  place(
    top + left,
    dx: 268pt,
    dy: 52pt,
    block(
        height: 2cm,
        width: 3.8cm,
        fit-to-width(age, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 378pt,
    dy: 52pt,
    block(
        height: 2cm,
        width: 3.3cm,
        fit-to-width(height, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 474pt,
    dy: 52pt,
    block(
        height: 2cm,
        width: 3.5cm,
        fit-to-width(weight, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 268pt,
    dy: 80pt,
    block(
        height: 2cm,
        width: 3.8cm,
        fit-to-width(eyes, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 378pt,
    dy: 80pt,
    block(
        height: 2cm,
        width: 3.3cm,
        fit-to-width(skin, max-text-size: 14pt)
    )
  )
  place(
    top + left,
    dx: 474pt,
    dy: 80pt,
    block(
        height: 2cm,
        width: 3.5cm,
        fit-to-width(hair, max-text-size: 14pt)
    )
  )

  /* * * IMAGES * * */
  if appearance != none {
    place(
      top + left,
      dx: 36pt,
      dy: 131.4pt,
      appearance
    )
  }
  if symbol != none {
    place(
      top + left,
      dx: 422pt,
      dy: 163pt,
      symbol
    )
  }
  place(
    center,
    dx: 186.1pt,
    dy: 152.6pt,
    block(
        height: 2cm,
        width: 5cm,
        fit-to-width(symbol-name, max-text-size: 13pt)
    )
  )

  /* * * TEXT FIELDS * * */
  place(
    top + left,
    dx: 36pt,
    dy: 387.2pt,
    block(width: 162pt, par(justify: true, leading:4.5pt, text(backstory, size: 10pt)))
  )
  place(
    top + left,
    dx: 225pt,
    dy: 132pt,
    block(width: 168pt, par(justify: true, leading:4.5pt, text(allies-organizations, size: 10pt)))
  )
  place(
    top + left,
    dx: 225pt,
    dy: 376pt,
    block(width: 350pt, height: 214pt, columns(2, gutter: 12pt)[#par(justify: true, leading:4.8pt, text(additional-features-traits, size: 10pt))])
  )
  place(
    top + left,
    dx: 225pt,
    dy: 604pt,
    block(width: 350pt, height: 164pt, columns(2, gutter: 12pt)[#par(justify: true, leading:4.8pt, text(treasure, size: 10pt))])
  )
  }

  // Place Background and all info added to body above
  if settings.at("printer-mono", default: false) {
    set page(
      background: image("/outlines/page-2-mono.svg", width: 100%)
    )
    place(
      top + left,
      dx: 49pt,
      dy: 70pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(name, max-text-size: 21pt)
      )
    )
    body
  } else {
    set page(
      background: image("/outlines/page-2-col.svg", width: 100%)
    )
    place(
      top + left,
      dx: 49pt,
      dy: 70pt,
      block(
        height: 3cm,
        width: 7.3cm,
        fit-to-width(name, max-text-size: 21pt)
      )
    )
    body
  }
}