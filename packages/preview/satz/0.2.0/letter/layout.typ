/// Add the DIN fold and punch position marks to the first page background.
///
/// The three gray ticks sit 105mm, 148.5mm, and 210mm below the page top. The
/// helper checks the page counter and emits nothing after page 1, so it can be
/// installed as a page background for the whole letter.
///
/// - arguments: none
/// -> content: fold and punch marks for `set page(background: ...)`
#let falz_und_locher_marken() = context {
  if counter(page).get().first() == 1 [
    #place(top + left, dx: 0mm, dy: 0mm)[
      #place(top + left, dx: 4mm, dy: 105mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 210mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
    ]
  ]
}

/// Render the centered page footer with current and final page numbers.
///
/// The footer uses the translated `Page` and `of` strings and appears only
/// after the first page, leaving the letterhead page clean. The total comes
/// from Typst's final page counter, so it reflects the compiled letter length.
///
/// - strings (dictionary): translations with `page` and `of` text values
/// -> content: centered `Page X of Y` footer for `set page(footer: ...)`
#let seiten_footer(strings) = context {
  let p = counter(page).get().first()
  let last = counter(page).final().first()
  if p > 1 {
    align(center)[
      #text(size: 8.5pt, fill: black)[#strings.page #p #strings.of #last]
    ]
  }
}
