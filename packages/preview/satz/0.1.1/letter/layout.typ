/// Fold and punch marks for page 1.
///
/// Three small ticks on the left edge — at 105, 148.5, and 210 mm.
/// Only page 1 gets them.
/// -> content (use as `background` in `set page`)
#let falz_und_locher_marken() = context {
  if counter(page).get().first() == 1 [
    #place(top + left, dx: 0mm, dy: 0mm)[
      #place(top + left, dx: 4mm, dy: 105mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 148.5mm)[#line(length: 7mm, stroke: 0.35pt + luma(120))]
      #place(top + left, dx: 4mm, dy: 210mm)[#line(length: 5mm, stroke: 0.35pt + luma(120))]
    ]
  ]
}

/// Page numbers at the bottom — "Page X of Y".
///
/// Starts on page 2. Page 1 stays clean (it's the letterhead).
///
/// - strings (dictionary): translated "Page" / "of"
/// -> content (use as `footer` in `set page`)
#let seiten_footer(strings) = context {
  let p = counter(page).get().first()
  let last = counter(page).final().first()
  if p > 1 {
    align(center)[
      #text(size: 8.5pt, fill: black)[#strings.page #p #strings.of #last]
    ]
  }
}
