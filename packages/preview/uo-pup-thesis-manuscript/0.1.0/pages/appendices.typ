#let appendices-section(body) = {
  pagebreak()
  set par(hanging-indent: 0pt, first-line-indent: 0.5in, spacing: 3em)
  align(center)[ #heading("APPENDICES") ]
  body
}

#let appendix(number, title) = {
  number = str(number)
  align(center)[
    #let customLabel = "appendix" + number
    #heading(
      level: 2,
      supplement: [Appendix #number],
      "Appendix " + str(number) + ": " + title,
    ) #label(customLabel)]
}
