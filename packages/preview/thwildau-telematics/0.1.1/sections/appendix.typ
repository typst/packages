#import "../utils/translation.typ": translation

#let make-appendix(appendix) = {
  pagebreak(weak: true)

  set heading(numbering: "A")

  heading(level: 1, translation("Appendix"))
  
  set heading(offset: 1)

  appendix
}
