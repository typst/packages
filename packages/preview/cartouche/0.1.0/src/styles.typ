#import "frames.typ": frame-bar, frame-marked, frame-plain, frame-rules

// The full set of style options. Every preset is a complete dictionary with
// exactly these keys, which also makes the key list the authoritative
// validation table for user-supplied overrides.
#let base = (
  // The quote.
  text: (size: 0.95em),
  par: (leading: 0.62em, justify: false),
  quotes: false,

  // The attribution line. `attribution-format` is a `(by, from) => content`
  // function replacing the default "— Author, Work".
  attribution-format: auto,
  attribution-prefix: [#sym.dash.em#h(0.35em)],
  attribution-text: (size: 0.85em, style: "normal"),
  attribution-align: auto, // `auto` follows `text-align`

  // Layout.
  width: 100%,
  align: auto, // `auto` keeps the surrounding alignment
  text-align: start,
  gap: 0.65em,
  divider: false, // rule between quote and attribution: `true` draws it with
                  // `thickness` and `accent`, or pass a stroke of your own
  above: 1.2em,
  below: 1.6em,

  // Decoration, interpreted by `frame`.
  frame: frame-plain,
  accent: luma(55%), // `auto` follows the text colour
  inset: 0.8em,
  thickness: 0.6pt,
)

/// The styles shipped with this package, by name.
///
/// Each value is a plain dictionary, so a custom style is just a preset plus
/// the keys you want to change:
/// `epigraph-presets.bar + (accent: blue, width: 80%)`.
#let epigraph-presets = (
  // Nothing but a smaller, indented block of text.
  plain: base,

  // The familiar chapter-opening epigraph: an italic block set towards the
  // outer edge, attribution flush right underneath.
  classic: base + (
    text: (size: 0.92em, style: "italic"),
    width: 40%,
    align: end,
    attribution-align: end,
  ),

  // The look of LaTeX's epigraph package: a narrow ragged-right block at the
  // outer margin, a hairline, then the work over the author.
  latex-epigraph: base + (
    text: (size: 0.9em),
    width: 40%,
    align: end,
    attribution-align: end,
    attribution-format: (by, from) => {
      if from != none { emph(from) }
      if by != none and from != none { linebreak() }
      if by != none { smallcaps(by) }
    },
    divider: true,
    accent: auto,
    thickness: 0.4pt,
    gap: 0.5em,
    above: 0.6em,
    below: 0.6em,
  ),

  // Centred between two hairlines; works well under a chapter heading.
  ruled: base + (
    text: (size: 0.92em, style: "italic"),
    width: 72%,
    align: center,
    text-align: center,
    attribution-align: center,
    frame: frame-rules,
    above: 1.4em,
    below: 1.8em,
  ),

  // Modern pull-quote with an accent rule along the inner edge.
  bar: base + (
    width: 78%,
    frame: frame-bar,
    inset: 1em,
    thickness: 2pt,
    accent: luma(70%),
    attribution-align: start,
  ),

  // Oversized opening quotation mark hanging into the margin.
  marked: base + (
    text: (size: 0.95em, style: "italic"),
    width: 72%,
    frame: frame-marked,
    inset: 1.4em,
    accent: luma(78%),
    attribution-align: end,
  ),

  // Front-matter dedication: centred, airy, no hanging indent.
  dedication: base + (
    text: (size: 1.05em, style: "italic"),
    par: (leading: 0.75em, justify: false),
    width: 70%,
    align: center,
    text-align: center,
    attribution-align: center,
    gap: 1.2em,
    above: 2em,
    below: 2em,
  ),
)
