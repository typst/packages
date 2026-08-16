// Passive Metropolis design definition; the Mosaic engine owns setup.
//
// The engine emits no typography, so this states the complete look: base type,
// headings, captions, list rhythm, and the canonical <mosaic-cell-*>
// vocabulary, plus Metropolis's inverted header bar and progress-ruled
// section. The section is the theme's signature: a display-size title over a
// full-width progress bar prominent enough to read from the back row.
#import "../../component/api.typ" as components
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens
#import "../polarity.typ": is-dark-canvas, dark-code-theme
#import "../../deck-state.typ": slide-numbered

#let apply(body, colors: (:), options: (:)) = {
  let base-size = options.base-size
  set text(
    font: options.font,
    size: base-size,
    fill: colors.text,
    fallback: true,
  )
  show list.where(tight: true): it => list(tight: false, ..it.children)
  show enum.where(tight: true): it => enum(tight: false, ..it.children)
  set list(spacing: 0.9em)
  set enum(spacing: 0.9em)
  set terms(spacing: 0.9em)
  set table(stroke: 0.8pt + colors.line)
  set raw(theme: dark-code-theme) if is-dark-canvas(colors)
  // The section display size, stated once and used absolutely in both rules
  // below. Absolute on purpose: Typst's native level-1 heading scale and the
  // section cell's own scale are both em multipliers, so an em size here
  // would compound with them and a `= Heading` section would render larger
  // than a `cells: (section: ..)` one. An absolute size replaces the whole
  // chain, so the two spellings render identically.
  let section-size = base-size * 1.5
  show heading.where(depth: 1): set text(size: section-size, weight: "semibold")
  show heading.where(depth: 2): set text(size: 1.15em, weight: "regular")
  show heading: set block(below: 0.75em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show raw: set text(font: options.font-mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.8em)
  show label("mosaic-cell-header"): it => block(
    width: 100%, fill: colors.text,
    text(fill: colors.canvas, weight: "medium", it),
  )
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-title-display"): set text(
    size: 2em, weight: "semibold", tracking: -0.015em,
  )
  show label("mosaic-cell-title"): set par(leading: 0.42em)
  show label("mosaic-cell-section"): set align(left + bottom)
  show label("mosaic-cell-section"): set text(size: section-size, weight: "semibold")
  show label("mosaic-cell-section-progress"): set block(above: 0pt, below: 0pt)
  show label("mosaic-cell-footer"): set text(size: 0.55em, fill: colors.muted)
  show label("mosaic-cell-authors"): set text(size: 0.8em, weight: "medium")
  show label("mosaic-cell-details"): set text(size: 0.62em, fill: colors.muted)
  body
}
#let definition = (
  name: "Metropolis",
  colors: tokens.colors,
  defaults: (
    // The signature progress line at the bottom edge of every numbered slide,
    // filling as the deck advances. It resolves its colors from the deck
    // record, so a palette swap recolors it too, and it quiets itself on
    // unnumbered pages: the title keeps its clean edge and section slides
    // already carry the big section bar.
    foreground: context if slide-numbered.get() {
      place(bottom, components.progress(
        variant: "line", count: "slides", width: 100%, thickness: 3pt,
      ))
    },
  ),
  options: (
    // See the note in the mono theme: only families that are present
    // everywhere are named, because Typst warns once per unknown family even
    // when a later one resolves. The beamer original sets Fira; a deck that
    // wants it passes `setup(font: "Fira Sans", font-mono: "Fira Mono")`.
    font: ("Source Sans 3", "Liberation Sans", "DejaVu Sans"),
    font-mono: ("DejaVu Sans Mono", "Liberation Mono"),
    base-size: 21.5pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
