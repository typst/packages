// typst
#let typstmark() = {
  set text(font: "Buenard", weight: "bold")
  let pSHFT = 0.025em
  let sSHFT = 0.010em
  box()[ty#h(+pSHFT)p#h(sSHFT - pSHFT)s#h(-sSHFT)t]
}

// TeX - from "plain.tex"
// \def\TeX{T\kern-.1667em\lower.5ex\hbox{E}\kern-.125emX}
// Conversion factor 1ex=0.43056em from https://tex.stackexchange.com/a/8337
#let texmark() = {
  set text(font: "New Computer Modern")
  box()[T#h(-.1667em)#text(baseline:.43056*.5em,"E")#h(-.125em)X]
}

// LaTeX
#let latexmark() = {
  set text(font: "New Computer Modern")
  box()[L#h(-.33em)#box(
      baseline: -.205em,
      scale(
        70%,
        origin: bottom + left,
        "A"
      )
    )#h(-.345em)#texmark()]
}

