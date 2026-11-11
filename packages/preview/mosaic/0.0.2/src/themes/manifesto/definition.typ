// Passive Manifesto design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary. Manifesto is the poster voice of the bundled set: one red on
// warm white, serif type set large, uppercase tracked headings, a bordered
// title plate, and rule sections carried by a heavy bar.
#import "../../component/api.typ" as components
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens
#import "../polarity.typ": is-dark-canvas, dark-code-theme

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  set text(
    font: options.font,
    size: base-size,
    fill: colors.text,
    fallback: true,
  )
  // Tight lists become wide. A list nested in an item is then a block that
  // would take the paragraph spacing above it, a gap wider than the item
  // rhythm, so each item body pins nested lists to the item spacing. The
  // rule lives in the body, not on the list, so the space above a top-level
  // list is left alone.
  let widen(item) = {
    let fields = item.fields()
    let body = fields.remove("body")
    (item.func())(..fields, {
      show selector(list).or(enum): set block(above: 0.9em)
      body
    })
  }
  show list.where(tight: true): it => list(tight: false, ..it.children.map(widen))
  show enum.where(tight: true): it => enum(tight: false, ..it.children.map(widen))
  set list(spacing: 0.9em, marker: text(fill: colors.accent, size: 0.62em)[■])
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  show heading.where(level: 1): set text(size: base-size * 2.2, weight: "bold")
  show heading.where(level: 2): set text(
    size: base-size * 1.6, weight: "bold", tracking: 0.06em,
  )
  // Poster headings shout: every slide heading is set in uppercase, and the
  // tracking above keeps the capitals from crowding.
  show heading.where(level: 2): it => upper(it)
  show heading: set block(below: 1em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show label("mosaic-title-display"): set text(
    size: 2.4em, weight: "bold", tracking: -0.015em,
  )
  // The poster display line breathes: extra air between the title and the
  // subtitle beneath it.
  show label("mosaic-title-display"): it => pad(bottom: 0.35em, it)
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set text(size: 2em)
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Manifesto",
  colors: tokens.colors,
  defaults: (
    spacing: (inset: 45pt),
    // The progress ring in the corner of every numbered slide, drawn in the
    // poster's red. It resolves its colors from the deck record, so a palette
    // swap recolors it too, and the component quiets itself on unnumbered
    // pages such as titles.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom + right, block(
      inset: (right: 18pt, bottom: 14pt),
      components.progress(variant: "circle"),
    ))),
  ),
  options: (
    // Designed face first, then the display serif each platform ships by
    // default, ending in Libertinus Serif, which Typst embeds and so always
    // resolves. Typst warns once per unknown family even when a later one
    // resolves, which is the price of the poster reading as designed on a
    // machine with nothing installed.
    font: (
      "Source Serif 4",
      "Charter",
      "Constantia",
      "Libertinus Serif",
    ),
    base-size: 16pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
