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
  show heading: set block(below: 1em)
  show figure.caption: set text(size: 0.72em, fill: colors.muted)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.8em)
  // Both halves are show-set rules on purpose: a user rule on the same label,
  // written after setup or scoped to one slide, overrides either half instead
  // of fighting a wrapping transform or a constructor-strength ink.
  show label("mosaic-cell-header"): set block(fill: colors.text)
  show label("mosaic-cell-header"): set text(fill: colors.canvas, weight: "medium")
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
    // record, so a palette swap recolors it too, and the component quiets
    // itself on unnumbered pages: the title keeps its clean edge and section
    // slides already carry the big section bar.
    // Chrome, not content: the artifact wrapper keeps it out of the tagged
    // PDF's structure tree, so a screen reader never announces it.
    foreground: pdf.artifact(place(bottom, components.progress(
      variant: "line", count: "slides", width: 100%, thickness: 3pt,
    ))),
  ),
  options: (
    // Designed face first, then the best slide sans each platform ships by
    // default, then the Linux workhorse, ending in Libertinus Serif. Typst
    // embeds no sans at all, so the terminal is a serif and some name here
    // is always unknown: it warns once per unknown family even when a later
    // one resolves, which is the price of rendering as designed anywhere.
    // The beamer original sets Fira; a deck that wants it passes
    // `setup(font: "Fira Sans")`. Code needs no option of its own: Typst
    // pins `raw` to its embedded DejaVu Sans Mono and a document-wide text
    // font never reaches it, so a deck with a favorite mono writes the one
    // rule `show raw: set text(font: ..)`, as it would under any theme.
    font: (
      "Source Sans 3",
      "Avenir Next",
      "Segoe UI",
      "DejaVu Sans",
      "Libertinus Serif",
    ),
    base-size: 21.5pt,
  ),
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
