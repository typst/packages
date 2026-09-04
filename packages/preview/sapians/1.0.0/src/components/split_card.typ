#import "../tokens.typ": *

// Numbered Key Item (e.g. 01 Approximate the model...)
/// A numbered key item: a two-digit terracotta index next to a title and
/// an optional description. Use it for ordered lists of steps, findings,
/// or takeaways where the sequence itself carries meaning.
///
/// ```example
/// #step-item(
///   1,
///   "Approximate the model",
///   description: "Fit a local surrogate around the point of interest.",
/// )
/// ```
/// -> content
#let step-item(
  /// Index shown as a zero-padded two-digit number when given as an
  /// `int` (e.g. `1` becomes `"01"`); any other value is shown verbatim.
  /// -> int | str
  number,

  /// Item title, shown bold whenever `description` is set. -> str | content
  title,

  /// Supporting text shown below the title, in the muted tone. Omitted
  /// entirely when `none`. -> none | str | content
  description: none,

  /// Whether the item sits on a dark canvas; swaps title and description
  /// colors for the dark palette. -> bool
  dark: false,
) = {
  let num-str = if type(number) == int {
    if number < 10 { "0" + str(number) } else { str(number) }
  } else {
    str(number)
  }
  let title-fill = if dark { sapians-text-light } else { sapians-text-dark }
  let desc-fill = if dark { sapians-muted-light } else { sapians-muted-dark }

  grid(
    columns: (auto, 1fr),
    gutter: 3.5mm,
    align: (top + left, top + left),
    text(fill: sapians-terracotta, size: 6.8pt, weight: "bold")[#num-str],
    [
      #text(fill: title-fill, size: 6.8pt, weight: if description != none {
        "bold"
      } else { "medium" })[#title]
      #if description != none [
        #v(0.6mm)
        #text(fill: desc-fill, size: 5.8pt)[#description]
      ]
    ],
  )
}

// Definition row (e.g. [BLACK BOX] -> f(x))
/// A single-line definition row: an uppercase terracotta kicker on the
/// left and a bold value on the right, both inside a bordered card. Use it
/// for compact key/value pairs, e.g. labeling a formula or a named
/// quantity.
///
/// ```example
/// #def-row("Black box", "f(x)", width: 60mm)
/// ```
/// -> content
#let def-row(
  /// Uppercase kicker on the left. -> str
  kicker-text,

  /// Bold value on the right. -> str | content
  value-text,

  /// Row width, forwarded to the underlying `block`. -> auto | relative
  width: 100%,
) = {
  block(
    width: width,
    fill: sapians-card-bg,
    radius: radius-sm,
    stroke: stroke-light,
    inset: (x: 3.5mm, y: 2.0mm),
  )[
    #grid(
      columns: (1fr, auto),
      align: (horizon + left, horizon + right),
      text(
        fill: sapians-terracotta,
        size: font-size-kicker,
        weight: "bold",
        tracking: 0.12em,
      )[#upper(kicker-text)],
      text(fill: sapians-text-dark, size: 6.8pt, weight: "bold")[#value-text],
    )
  ]
}

// Contrast Comparison: Not This vs This (Refined Proportions)
/// A fixed-height two-up comparison: a muted "not this" card next to a
/// high-contrast dark "this" card, each with its own uppercase label. Use
/// it to contrast a naive approach against the recommended one.
///
/// ```example
/// #box(width: 90mm)[
///   #contrast-pair([Fits the whole dataset], [Fits near the query point])
/// ]
/// ```
/// -> content
#let contrast-pair(
  /// Content for the muted "not this" card. -> str | content
  not-this-content,

  /// Content for the dark, high-contrast "this" card. -> str | content
  this-content,

  /// Uppercase label on the "not this" card. -> str
  not-this-label: "NOT THIS",

  /// Uppercase label on the "this" card. -> str
  this-label: "THIS",

  /// Uppercase sub-label shown below the "this" content. Omitted entirely
  /// when `none`. -> none | str
  this-sub: "LOCAL ≠ GLOBAL",
) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 5mm,
    // NOT THIS (Subtle card with diagonal cancel or muted style)
    block(
      width: 100%,
      height: 34mm,
      fill: sapians-card-bg,
      radius: radius-sm,
      stroke: stroke-light,
      inset: 3.5mm,
      [
        #text(
          fill: sapians-muted-dark,
          size: font-size-kicker,
          weight: "bold",
          tracking: 0.14em,
        )[#upper(not-this-label)]
        #v(4.5mm)
        #text(
          fill: sapians-muted-dark,
          size: 8.5pt,
          weight: "bold",
        )[#not-this-content]
        #v(3.5mm)
        #line(length: 100%, stroke: 1.0pt + sapians-terracotta)
      ],
    ),
    // THIS (Dark card with high contrast)
    block(
      width: 100%,
      height: 34mm,
      fill: sapians-dark,
      radius: radius-sm,
      inset: 3.5mm,
      [
        #text(
          fill: sapians-terracotta,
          size: font-size-kicker,
          weight: "bold",
          tracking: 0.14em,
        )[#upper(this-label)]
        #v(4.5mm)
        #text(
          fill: sapians-text-light,
          size: 8.5pt,
          weight: "bold",
        )[#this-content]
        #if this-sub != none [
          #v(3.5mm)
          #text(
            fill: sapians-muted-light,
            size: 5.2pt,
            weight: "bold",
            tracking: 0.12em,
          )[#upper(this-sub)]
        ]
      ],
    ),
  )
}
