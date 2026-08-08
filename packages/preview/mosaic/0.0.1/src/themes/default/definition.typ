// Canonical passive Default definition.
//
// Mosaic's engine emits no typography at all, so a theme states its complete
// look here: base type, headings, captions, list rhythm, and the canonical
// <mosaic-cell-*> vocabulary that the layouts compose against. Default is the
// plainest complete statement of that set, which makes it the file to copy
// when starting a theme from scratch. Its quietness is deliberate: the other
// bundled themes are voices, and this one is the absence of one.
//
// Default has no dark twin. A deck flips it by passing a dark palette through
// `setup(colors: ..)`; every rule below paints from `colors.*`, and the one
// asset that cannot (the syntax highlighting theme) branches on the canvas.
#import "../../palettes.typ": light
#import "../../component/api.typ" as components
#import "../../deck-state.typ": slide-numbered
#import "../polarity.typ": is-dark-canvas, dark-code-theme
#import "layouts.typ" as layouts

#let apply(body, colors: (:), options: (:)) = {
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text,
    fallback: true,
  )
  show heading.where(depth: 1): set text(size: 2em, weight: "semibold")
  show heading.where(depth: 2): set text(size: 1.4em, weight: "semibold")
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  // The accent stays functional: links, list markers, and the section
  // baseline rule carry it, and nothing decorative does.
  show link: set text(fill: colors.accent)
  set list(spacing: 0.8em, marker: text(fill: colors.accent)[•])
  set enum(spacing: 0.8em)
  set terms(spacing: 0.8em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(size: 2em, weight: "semibold")
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}

#let definition = (
  name: "Default",
  colors: light,
  defaults: (
    // The progress ring in the corner of every numbered slide, the one piece
    // of furniture the quiet theme carries. It resolves its colors from the
    // deck record, so a palette swap recolors it too, and it quiets itself on
    // unnumbered pages such as titles.
    foreground: context if slide-numbered.get() {
      place(bottom + right, block(
        inset: (right: 18pt, bottom: 14pt),
        text(size: 0.55em, components.progress(variant: "circle")),
      ))
    },
  ),
  options: (
    font: (
      "Inter",
      "Source Sans 3",
      "Liberation Sans",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    base-size: 28pt,
  ),
  layouts: (
    content: layouts.content(variant: "header-body"),
    title: layouts.title(),
    section: layouts.section(variant: "baseline"),
  ),
  apply: apply,
)
