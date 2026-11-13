// Passive Mono design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary. Mono is the terminal voice of the bundled set: monospace type
// throughout, panel-backed code blocks, a shell prompt on every heading, and toc
// sections that list the whole deck like a process table. It is dark by
// default, so the polarity branch picks the dark code theme with no palette
// override at all.
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
  set list(spacing: 0.9em, marker: text(fill: colors.accent)[--])
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  show heading.where(level: 1): set text(size: base-size * 1.7, weight: "bold")
  show heading.where(level: 2): set text(size: base-size * 1.25, weight: "bold")
  show heading: set block(below: 1em)
  // The slide-header prompt: a shell marker in the accent color before every
  // level-two heading, which is what opens a content slide.
  show heading.where(level: 2): it => grid(
    columns: (auto, 1fr),
    column-gutter: 0.5em,
    align: (left + top, left + top),
    // Decoration, not part of the heading's text: the artifact wrapper keeps
    // it out of the tagged PDF's structure tree.
    pdf.artifact(text(fill: colors.accent)[\$]),
    it,
  )
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show link: set text(fill: colors.accent)
  show raw.where(block: false): set text(fill: colors.accent)
  show raw.where(block: true): set text(size: 0.78em)
  show raw.where(block: true): it => block(
    width: 100%, fill: colors.surface, stroke: 0.8pt + colors.line,
    radius: 4pt, inset: (x: 14pt, y: 11pt), it,
  )
  show label("mosaic-cell-header"): set text(weight: "bold")
  show label("mosaic-title-display"): set text(size: 1.5em, weight: "bold")
  show label("mosaic-cell-title"): set par(leading: 0.5em)
  show label("mosaic-cell-title"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 2em)
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Mono",
  colors: tokens.colors,
  defaults: (
    // The statusline: a right-aligned slide counter at the bottom of every
    // numbered slide. It resolves its colors from the deck record, so a
    // palette swap recolors it too, and the component quiets itself on
    // unnumbered pages such as titles.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom + right, block(
      inset: (right: 24pt, bottom: 12pt),
      text(
        size: 0.55em,
        components.progress(variant: "1/1"),
      ),
    ))),
  ),
  options: (
    // The one chain that needs no platform names: Typst embeds DejaVu Sans
    // Mono, so the designed face always resolves and no build ever warns.
    // A deck that has a favorite mono passes it through `setup(font: ..)`.
    font: ("DejaVu Sans Mono", "Liberation Mono"),
    base-size: 19pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
