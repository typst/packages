#import "@preview/codly:1.3.0": *

#let _gibz_black_code_box(
  body, // Inhalt: i. d. R. ein fenced code block
  codly-opts: (:), // optionale Codly-Overrides lokal für diesen Block
  box-opts: (:), // optionale Box-Optionen (inset, radius, ...)
) = {
  // Codly-Defaults innerhalb der schwarzen Box
  let codly-defaults = (
    zebra-fill: none,
    number-format: none,
    display-name: false,
    stroke: none,
    fill: black,
  )
  let codly-final = codly-defaults + codly-opts

  box(
    width: 100%,
    fill: black,
    inset: 5pt,
    radius: 5pt,
    stroke: none,
    ..box-opts,
    [
      #set text(fill: white)
      #context {
        codly(..codly-final)
        body
      }
    ],
  )
}

// Öffentlicher Alias wie bisher
#let black-code-box = _gibz_black_code_box
