#let pagebreak-from-odd(twoside: false) = {
  set page(footer: { text(size: 0pt, ".") })
  context {
    if twoside and calc.rem(here().position().page, 2) == 0 {
      counter(page).update(prev => if prev > 1 { prev - 1} else { prev })
    }
  }
  pagebreak(weak: true, to: if twoside { "odd" })
}