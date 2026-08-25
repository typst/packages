#import "../tokens.typ": *

// SAPIANS Dark Callout Card (DeepMind High Contrast)
/// A high-contrast card on the SAPIANS dark fill, with an optional
/// terracotta kicker above the body. Use it to call out a key insight or
/// result that should visually "pop" against a light slide or page.
///
/// ```example
/// #dark-card(width: 60mm, kicker-title: "Insight")[
///   Local surrogates approximate $f$ only near $x$.
/// ]
/// ```
/// -> content
#let dark-card(
  /// Card content. -> content
  body,

  /// Uppercase terracotta kicker shown above the body. Omitted entirely
  /// when `none`. -> none | str
  kicker-title: none,

  /// Card width, forwarded to the underlying `block`. -> auto | relative
  width: 100%,

  /// Card height, forwarded to the underlying `block`. -> auto | relative
  height: auto,

  /// Inner padding, forwarded to the underlying `block`.
  /// -> relative | dictionary
  inset: 3.2mm,
) = {
  block(
    width: width,
    height: height,
    fill: sapians-dark,
    radius: radius-sm,
    inset: inset,
  )[
    #if kicker-title != none [
      #text(
        fill: sapians-terracotta,
        size: font-size-kicker,
        weight: "bold",
        tracking: 0.14em,
      )[#upper(kicker-title)]
      #v(1.6mm)
    ]
    #set text(fill: sapians-text-light, size: font-size-body)
    #body
  ]
}

// SAPIANS Light Card with subtle elevation & hairline border
/// A subtly elevated card on the light card background, with a hairline
/// border and an optional terracotta kicker. This is the light-canvas
/// counterpart of @dark-card — use it for supporting content that should
/// stay visually quiet on a light slide or page.
///
/// ```example
/// #light-card(width: 60mm, kicker-title: "Insight")[
///   Local surrogates approximate $f$ only near $x$.
/// ]
/// ```
/// -> content
#let light-card(
  /// Card content. -> content
  body,

  /// Uppercase terracotta kicker shown above the body. Omitted entirely
  /// when `none`. -> none | str
  kicker-title: none,

  /// Card width, forwarded to the underlying `block`. -> auto | relative
  width: 100%,

  /// Card height, forwarded to the underlying `block`. -> auto | relative
  height: auto,

  /// Inner padding, forwarded to the underlying `block`.
  /// -> relative | dictionary
  inset: 3.2mm,

  /// Card background fill. -> color
  fill: sapians-card-bg,

  /// Card border stroke. -> stroke
  stroke: stroke-light,
) = {
  block(
    width: width,
    height: height,
    fill: fill,
    radius: radius-sm,
    stroke: stroke,
    inset: inset,
  )[
    #if kicker-title != none [
      #text(
        fill: sapians-terracotta,
        size: font-size-kicker,
        weight: "bold",
        tracking: 0.14em,
      )[#upper(kicker-title)]
      #v(1.6mm)
    ]
    #set text(fill: sapians-text-dark, size: font-size-body)
    #body
  ]
}

// Terracotta Accent Card / Callout
/// A flush-left card with a terracotta accent rule down its left edge and
/// an optional bold title. Lighter-weight than @dark-card and @light-card
/// — use it for an inline note, caveat, or hypothesis statement that
/// should stand out without a full card treatment.
///
/// ```example
/// #accent-card(width: 60mm, title: "Hypothesis")[
///   Local surrogates approximate $f$ only near $x$.
/// ]
/// ```
/// -> content
#let accent-card(
  /// Card content. -> content
  body,

  /// Bold title shown above the body, in terracotta. Omitted entirely
  /// when `none`. -> none | str
  title: none,

  /// Card width, forwarded to the underlying `block`. -> auto | relative
  width: 100%,
) = {
  block(
    width: width,
    fill: sapians-card-bg,
    stroke: (left: 1.8pt + sapians-terracotta, rest: stroke-light),
    radius: (right: radius-sm),
    inset: (x: 2.8mm, y: 2.2mm),
  )[
    #if title != none [
      #text(fill: sapians-terracotta, size: 6.2pt, weight: "bold")[#title]
      #v(0.8mm)
    ]
    #set text(size: font-size-body)
    #body
  ]
}
