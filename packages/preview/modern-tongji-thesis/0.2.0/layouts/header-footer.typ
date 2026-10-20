// Page headers, footers, and binding line
#import "../utils/fonts.typ": TJFONT_BODY

#let draw-binding(twoside: false) = {
  context {
    let pipe-dx = -1.6cm
    let label-dx = -1.8cm
    if twoside and calc.rem(counter(page).get().first(), 2) == 0 {
      pipe-dx = 17.5cm
      label-dx = 17.3cm
    }
    place("|", dx: pipe-dx, dy: 2.3cm)
    place("|", dx: pipe-dx, dy: 2.9cm)
    place("|", dx: pipe-dx, dy: 3.5cm)
    place("|", dx: pipe-dx, dy: 4.1cm)
    place("|", dx: pipe-dx, dy: 4.7cm)
    place("|", dx: pipe-dx, dy: 5.3cm)
    place("|", dx: pipe-dx, dy: 5.9cm)
    place("|", dx: pipe-dx, dy: 6.5cm)
    place("|", dx: pipe-dx, dy: 7.1cm)
    place("|", dx: pipe-dx, dy: 7.7cm)
    place("装", dx: label-dx, dy: 8.3cm)
    place("|", dx: pipe-dx, dy: 8.9cm)
    place("|", dx: pipe-dx, dy: 9.5cm)
    place("|", dx: pipe-dx, dy: 10.1cm)
    place("|", dx: pipe-dx, dy: 10.7cm)
    place("|", dx: pipe-dx, dy: 11.3cm)
    place("订", dx: label-dx, dy: 11.9cm)
    place("|", dx: pipe-dx, dy: 12.5cm)
    place("|", dx: pipe-dx, dy: 13.1cm)
    place("|", dx: pipe-dx, dy: 13.7cm)
    place("|", dx: pipe-dx, dy: 14.3cm)
    place("|", dx: pipe-dx, dy: 14.9cm)
    place("线", dx: label-dx, dy: 15.5cm)
    place("|", dx: pipe-dx, dy: 16.1cm)
    place("|", dx: pipe-dx, dy: 16.7cm)
    place("|", dx: pipe-dx, dy: 17.3cm)
    place("|", dx: pipe-dx, dy: 17.9cm)
    place("|", dx: pipe-dx, dy: 18.5cm)
    place("|", dx: pipe-dx, dy: 19.1cm)
    place("|", dx: pipe-dx, dy: 19.7cm)
    place("|", dx: pipe-dx, dy: 20.3cm)
    place("|", dx: pipe-dx, dy: 20.9cm)
    place("|", dx: pipe-dx, dy: 21.5cm)
  }
}

#let empty-par() = {
  v(-1.2em)
  box()
}

// Make page header (shared between preface and mainmatter)
#let make-page-header(ff, twoside, header-text) = context {
  let is-odd = calc.rem(counter(page).get().first(), 2) != 0
  let flip = twoside and not is-odd
  set text(font: ff.song, size: TJFONT_BODY)
  let a = image("../figures/tongji-header.svg", height: 1.14cm)
  let b = align(horizon, block(height: 1.14cm, align(center + horizon, text(font: ff.song, size: TJFONT_BODY, header-text))))
  let (logo, label) = if flip { (b, a) } else { (a, b) }
  let (cl, cr) = if flip { (0.5em, 1cm) } else { (1cm, 0.5em) }
  grid(
    columns: (cl, 1fr, auto, cr), [],
    logo,
    label,
    [],
  )
  v(-0.5em)
  block(width: 100%, height: 1.5pt, stroke: (top: 0.5pt, bottom: 0.5pt))
  draw-binding(twoside: twoside)
}
