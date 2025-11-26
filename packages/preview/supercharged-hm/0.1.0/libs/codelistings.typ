// Copyright 2024 Felix Schladt https://github.com/FelixSchladt

#import "@preview/codelst:2.0.2": *

// Display a colored monospace text
#let rgb_raw(msg, color) = {
  show raw: it => text(fill: color, it) 
  raw(msg)
}

// Wrapper for sourcecode with sane defaults
#let code(body, highlighted: (), numbering: "1", numbers-start: 1) = {
  set par(justify: false)  
  sourcecode(highlighted: highlighted, numbering: numbering, numbers-align: top+right, numbers-start: numbers-start)[
    #body
  ]
}