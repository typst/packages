#import "../store.typ"
#import "../presentate.typ" as p
#import "@preview/navigator:0.1.0" as nav

// Re-export navigator config
#let structure-config = nav.navigator-config

/// A slide with no margins, header, footer, or background decorations. 
#let empty-slide(fill: none, text-size: 20pt, text-font: "Lato", body) = {
  // We force background: none to ensure sidebars or logos from themes don't show up.
  set page(margin: 0pt, header: none, footer: none, fill: fill, background: none)
  p.slide(logical-slide: false, {
    set align(top + left)
    set text(size: text-size, font: text-font)
    body
  })
}
