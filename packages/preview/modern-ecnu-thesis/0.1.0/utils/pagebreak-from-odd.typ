#import "@preview/anti-matter:0.1.1": core

#let pagebreak-from-odd(twoside: false) = {
  set page(footer: { text(size: 0pt, ".") })
  pagebreak(weak: true, to: if twoside { "odd" })
  context {
    if twoside and calc.rem(here().page(), 2) == 1 {
      core.outer-counter().update(prev => if prev > 0 { prev - 1} else { prev })
    }
  }
}