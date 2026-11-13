// Retain Satz paragraph/heading rhythm. Only form-specific values belong here.
#let defaults = (
  toc: (depth: 0), lof: (depth: 0), lot: (depth: 0),
  page: (paper: "a4", margin: (top: 25mm, bottom: 25mm, left: 25mm, right: 25mm)),
  // Official forms permit Calibri or a close match. Arial is widely available.
  // Single-spaced Arial uses about 1.22 × type size between baselines here;
  // Typst's added leading is not a LaTeX/Word line-spacing multiplier.
  typography: (font: "Arial", leading: 0.5em),
  colors: (bg-paper: white, text-main: black, brand-primary: black),
  links: (color: black, url-color: black),
  captions: (alignment: left),
)
