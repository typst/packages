// Quotation treatment with optional attribution.
#import "card.typ": card
#import "style.typ": component-tokens, deck-colors

/// Creates a quotation treatment with optional attribution.
///
/// The quotation sits in a lightly tinted `card`; attribution and source share
/// one right-aligned line beneath it, joined by a comma when both are present.
///
/// ```typ
/// #mosaic.components.quote(
///   attribution: [Ada Lovelace],
///   source: [Notes on the Analytical Engine, 1843],
/// )[
///   The Analytical Engine weaves algebraic patterns.
/// ]
/// ```
///
/// To set a portrait beside the quotation, compose one natively:
///
/// ```typ
/// #grid(
///   columns: (auto, 1fr),
///   gutter: 0.6em,
///   mosaic.components.image(path("ada.webp"), width: 4em, height: 4em),
///   mosaic.components.quote(attribution: [Ada Lovelace])[...],
/// )
/// ```
///
/// See `card` for the list of roles and the full list of overrides.
///
/// -> content
#let quote(
  /// The quoted text.
  /// -> content
  body,
  /// Who is being quoted, set on the fine-print line below the quotation.
  /// -> content | none
  attribution: none,
  /// Where the quotation comes from, appended after the attribution.
  /// -> content | none
  source: none,
  /// Semantic role name: `neutral`, `accent`, `warning`, or `error`.
  /// -> str
  role: "neutral",
  /// Panel fill. `auto` is a faint wash of the deck's text color.
  /// -> auto | color | gradient | tiling | none
  fill: auto,
  /// Rail color. `auto` uses the role's own color.
  /// -> auto | color
  accent: auto,
  /// Border stroke. `auto` draws none.
  /// -> auto | stroke | dictionary | none
  stroke: auto,
  /// Corner radius. `auto` uses the shared component radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Padding inside the panel. `auto` uses the shared component inset.
  /// -> auto | length | relative | dictionary
  inset: auto,
  /// Horizontal alignment of the body. `auto` is `left`.
  /// -> auto | alignment
  align: auto,
  /// Native `text` arguments merged over the role's text color.
  /// -> dictionary
  text: (:),
) = context {
  // The tint is the deck's own text color laid over the canvas, not a fixed
  // black: on a dark deck a black tint is invisible, while a tint of the text
  // color reads as the same faint lift in either direction. Pass `fill` to
  // replace it outright.
  let tint = deck-colors().text
  card(
    role: role,
    fill: if fill == auto {
      tint.transparentize(component-tokens.quote-tint)
    } else {
      fill
    },
    accent: accent,
    stroke: if stroke == auto { none } else { stroke },
    radius: radius,
    inset: inset,
    align: align,
    text: text,
  )[
    #body
    #if attribution != none or source != none {
      // `block(above:)` rather than a `linebreak()` followed by block-level
      // content: that stacked an empty line on top of the paragraph break before
      // the block, leaving the attribution floating far below the quotation.
      block(above: component-tokens.quote-attribution-gap, width: 100%, std.align(right)[
        #std.text(size: component-tokens.quote-attribution-size)[
          #if attribution != none { attribution }
          #if attribution != none and source != none { [, ] }
          #if source != none { source }
        ]
      ])
    }
  ]
}
