
#let show-heading = (cfg, it) => {
  set par(first-line-indent: 0pt)
  if it.level == 1 {
    set text(..cfg.fonts.heading-1)
    counter(heading).display()
    it.body
  } else if it.level == 2 {
    set text(..cfg.fonts.heading-2)
    counter(heading).display()
    it.body
  } else if it.level == 3 {
    set text(..cfg.fonts.heading-3)
    counter(heading).display()
    it.body
  } else {
    set text(..cfg.fonts.heading-3)
    counter(heading).display()
    it.body
  }
}
