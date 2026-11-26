// Links in both directions. Every reference and `goto` leaves a marker
// naming its target, and the name of the target ("Theorem 1", "Table 2")
// is itself the link back when exactly one other slide points at it.

#import "@preview/touying:0.8.0": utils
#import "design.typ": *

// A marker for a labelled target.
#let backref-marker(target) = [#metadata(str(target))<monash-backref>]

// The place to go back to: the one other slide among `sources`. With no
// other slide, or with several, there is no single way back, so `none`.
#let _only-elsewhere(sources) = {
  let own = utils.slide-counter.get()
  let elsewhere = sources.filter(source => utils.slide-counter.at(source) != own)
  let slides = elsewhere.map(source => utils.slide-counter.at(source)).dedup()
  // The last one: on a slide with `#pause` it is the complete subslide.
  if slides.len() == 1 { elsewhere.last() }
}

// How a link inside the deck looks: blue text, or an underline where the
// text sits on a coloured bar or has a colour of its own.
#let link-style(body) = text(fill: monash-blue, body)
#let _underlined(body) = underline(offset: .18em, stroke: .6pt, body)

// `body` as a link to `source`. The label lets the theme style the link,
// or turn it off again.
#let _back(source, body, underlined: false) = if source == none { body } else if underlined {
  [#link(source, body)<monash-backlink-underlined>]
} else {
  [#link(source, body)<monash-backlink>]
}

/// `body`, which names the target labelled `target`, as a link back to the
/// one other slide that points at that target. When no other slide does,
/// or several do, or with `monash-theme(backlinks: false)`, it is `body`
/// unchanged.
#let back-link(target, body, underlined: false) = context {
  if target == none { return body }
  let markers = query(<monash-backref>).filter(it => it.value == str(target))
  _back(_only-elsewhere(markers.map(it => it.location())), body, underlined: underlined)
}

// Label of the figure being drawn, for content that cannot be handed it.
#let current-target = state("monash-backlink-target", none)

#let back-link-here(body) = context back-link(current-target.get(), body, underlined: true)

#let _label-of(it) = it.at("label", default: none)

// The "Table 1" of a caption links back.
#let _figure-rules(body) = {
  show figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw)): it => {
    let target = _label-of(it)
    if target == none { return it }
    show figure.caption: caption => {
      if caption.supplement == none or caption.numbering == none { return caption }
      let name = [#caption.supplement~#context caption.counter.display(caption.numbering)]
      block[#back-link(target, name)#caption.separator#caption.body]
    }
    it
  }
  body
}

// The number of a labelled display equation links back. The equation is
// set again without its number so that the number can be a link.
#let _equation-rules(body) = {
  show math.equation.where(block: true): it => {
    let target = _label-of(it)
    if target == none or it.numbering == none { return it }
    context {
      let markers = query(<monash-backref>).filter(marker => marker.value == str(target))
      let source = _only-elsewhere(markers.map(marker => marker.location()))
      if source == none { return it }
      let number = numbering(it.numbering, ..counter(math.equation).at(it.location()))
      block(width: 100%, {
        place(right + horizon, _back(source, number))
        align(center, math.equation(block: true, numbering: none, it.body))
      })
    }
  }
  body
}

// Typst itself links the number of a bibliography entry to the first
// citation of that entry, in styles that number the entries. The theme only
// marks that number as a link.
#let _citation-rules(body) = {
  show cite: set text(fill: monash-blue)
  show bibliography: it => {
    show grid.cell.where(x: 0): set text(fill: monash-blue)
    it
  }
  body
}

/// Rules that record references and make their targets link back, for
/// every slide body.
#let backlink-rules(enabled, body) = {
  show <monash-backlink>: it => if enabled { link-style(it) } else { it.body }
  show <monash-backlink-underlined>: it => if enabled { _underlined(it) } else { it.body }
  // Every link inside the deck is blue, whichever way it points.
  show ref: it => if it.form == "normal" and it.element != none {
    link-style(it) + backref-marker(it.target)
  } else { it }
  show: _figure-rules
  show: _equation-rules
  show: _citation-rules
  body
}

/// Marks a piece of text as a place to go to. `goto` with the same label
/// links to it, and the text links back to the slide that does.
///
/// ```typst
/// #anchor(<assumption>)[The key assumption] is that the data are i.i.d.
/// ```
#let anchor(
  /// A label such as `<assumption>`.
  target,
  /// The text at the place.
  body,
) = {
  assert(
    type(target) == label,
    message: "unofficial-monash-touying: use #anchor(<name>)[Text].",
  )
  [#metadata("monash-anchor")#target#back-link(target, body)]
}

/// A link to a place marked with `anchor`, or to any labelled element.
///
/// ```typst
/// #goto(<assumption>)[Recall the key assumption.]
/// ```
#let goto(
  /// The label to go to.
  target,
  /// The link text.
  body,
) = {
  assert(
    type(target) == label,
    message: "unofficial-monash-touying: use #goto(<name>)[Text].",
  )
  link(target, link-style(body))
  backref-marker(target)
}
