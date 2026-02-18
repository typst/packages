#import "../core/state.typ": metadata-state

#let blurb-block = (blurb: none, title: none) => context {
  let meta = metadata-state.final()
  let blurb-value = if blurb == none { meta.at("blurb", default: none) } else { blurb }
  let title-value = if title == none { meta.at("title", default: none) } else { title }

  [
    #text(size: 32pt)[#title-value]

    #text(size: 20pt)[#blurb-value]
  ]
}
