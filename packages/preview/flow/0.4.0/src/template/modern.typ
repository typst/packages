#import "common.typ": *
#import "generic.typ": generic

/// Compromise between generic and note.
/// Does not display any content but uses nice, legible fonts.
#let modern(body, ..args) = {
  set text(font: "Atkinson Hyperlegible Next", size: 14pt)
  show raw: set text(font: "Intel One Mono")
  show title: set text(1.75em)

  set par(linebreaks: "optimized")
  show: generic.with(..args)

  body
}
