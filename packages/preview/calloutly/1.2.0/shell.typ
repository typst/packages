// Shared layout primitives for text callouts and code callouts.
//
// Both `callout.typ` and `code-callout.typ` draw the same frames, so the frames
// live here once and each caller supplies its own colours, icon and title.

/// Renders an inline SVG string as a 1em icon tinted with `color`.
///
/// The baseline offset centres the icon on the cap height of the surrounding
/// text: a 1em box sits on the baseline, so shifting it down by 0.15em puts its
/// midpoint at 0.35em above the baseline -- the optical centre of capitals.
/// Wrapping the result in another baseline-shifted box compounds the offset and
/// drops the icon below the text, so callers pass this straight into `text`.
/// Pass `baseline: 0pt` when the icon is centred in a box of its own instead of
/// sitting on a line of text, and `size` to scale it against that box.
#let svg-icon(svg, color, baseline: 0.15em, size: 1em) = box(
  image(bytes(svg.replace("currentColor", color.to-hex())), height: size),
  baseline: baseline,
)

// Icon and title as a single run, for the styles that put them on one line.
#let _header(icon, title, title-style) = text(..title-style)[#icon#h(0.45em)#title]

/// Draws the outer frame shared by every callout variant.
///
/// - style (string): "quarto", "github", "edstem", or anything else for "simple".
/// - accent (color): the accent bar, or the icon tile in "edstem".
/// - icon (content): the already-tinted icon.
/// - title (content, none): the resolved title; `none` omits it ("edstem" only).
/// - body (content): the callout contents.
/// - title-style (dictionary): named arguments forwarded to `text` for the title.
/// - header-fill (color, none): background of the quarto header strip.
/// - header-stroke (stroke, none): divider under the quarto header strip.
/// - body-fill (color, none): background behind the contents; in "edstem" this
///   is the tint of the whole block.
/// - border (color): colour of the non-accent borders.
/// - border-width (length): thickness of the non-accent borders.
#let shell(
  style,
  accent,
  icon,
  title,
  body,
  title-style: (:),
  header-fill: none,
  header-stroke: none,
  body-fill: none,
  border: rgb("#dee2e6"),
  border-width: 1pt,
) = {
  if style == "quarto" {
    block(
      width: 100%,
      stroke: (left: 4pt + accent, rest: border-width + border),
      inset: 0pt,
      radius: 4pt,
      clip: true,
      {
        set align(start)
        block(
          width: 100%,
          inset: (x: 1em, y: 0.5em),
          fill: header-fill,
          stroke: header-stroke,
          _header(icon, title, title-style),
        )
        block(
          width: 100%,
          fill: body-fill,
          inset: (x: 1em, top: 0.6em, bottom: 1em),
          above: 0pt, // remove native paragraph/block spacing
          body,
        )
      },
    )
  } else if style == "edstem" {
    // A ribbon: the icon tile hangs off the left edge of a flat tinted panel,
    // with a folded-back corner beneath the overhanging part. Square corners,
    // no border. Proportions are taken from the reference design:
    // a 1.75em tile sitting 0.35em below the panel top, overhanging it by
    // 1.05em, with the body text 1.4em in from the panel's own left edge.
    let tile = 1.75em
    let overhang = 1.05em
    let fold-height = 0.5em
    let drop = 0.35em

    block(width: 100%, {
      set align(start)

      pad(left: overhang, block(
        width: 100%,
        fill: body-fill,
        inset: (left: 1.4em, right: 1em, y: 0.85em),
        {
          if title != none {
            text(..title-style, title)
            v(0.4em, weak: true)
          }
          body
        },
      ))

      // Placed after the panel so the ribbon sits on top of it rather than
      // being painted over, and so it never widens the panel or moves the text.
      place(
        top + left,
        dy: drop + tile,
        polygon(
          fill: accent.transparentize(75%), // the shaded underside of the fold
          (0pt, 0pt),
          (overhang, 0pt),
          (overhang, fold-height),
        ),
      )
      place(
        top + left,
        dy: drop,
        box(width: tile, height: tile, fill: accent, align(center + horizon, icon)),
      )
    })
  } else if style == "github" {
    block(
      width: 100%,
      stroke: (left: 3pt + accent),
      fill: body-fill,
      inset: 1em,
      {
        set align(start)
        _header(icon, title, title-style)
        v(0.5em)
        body
      },
    )
  } else {
    // "simple", and any style we do not recognise
    block(
      width: 100%,
      stroke: (left: 0.25em + accent),
      fill: body-fill,
      inset: (x: 1em, y: 0.8em),
      radius: 4pt,
      {
        set align(start)
        _header(icon, title, title-style)
        v(1.0em, weak: true)
        body
      },
    )
  }
}
