#import "../core/state.typ": meta-value, val-or-meta

#let blurb-block = (blurb: none, title: none) => context {
  let blurb-value = val-or-meta(blurb, "blurb")
  let title-value = val-or-meta(title, "title")

  [
    #text(size: 32pt)[#title-value]

    #text(size: 20pt)[#blurb-value]
  ]
}
