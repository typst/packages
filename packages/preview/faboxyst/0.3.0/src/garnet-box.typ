// Independent rounded garnet banner with the standard postit's native shadow.
#import "fabox.typ": fabox, is-rtl
#import "theme.typ": theme-state, grayscale-paint

/// A standalone rounded garnet title box with the standard postit's native
/// lifted shadow, mirrored downward so its tips meet the lower edge.
/// Width defaults to a content fit; `inset` accepts one length or `(x, y)`,
/// with `inset-x` and `inset-y` available as separate overrides.
/// LTR defaults to centered text; RTL defaults to right-aligned text.
#let garnet-box(
  body,
  direction: auto,
  width: auto,
  fill: rgb("#A60650"),
  text-color: white,
  radius: 0.34cm,
  inset: auto,
  inset-x: auto,
  inset-y: auto,
  size: 12pt,
  weight: "bold",
  alignment: auto,
  shadow: "large",
  shadow-color: auto,
  shadow-length: 50%,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let source-fill = fill
  let fill = if print-mode { white } else { fill }
  let text-color = if print-mode { black } else { text-color }
  // Preserve the configured shadow, but translate its paint to gray below.
  let rtl-mode = if direction == auto { is-rtl() } else { direction == rtl }
  if print-mode { set text(fill: black) }
  let text-alignment = if alignment == auto {
    if rtl-mode { right } else { center }
  } else { alignment }
  let default-inset = if inset == auto { (0.50cm, 0.22cm) }
    else if type(inset) == array { inset }
    else { (inset, inset) }
  let inset-x = if inset-x == auto { default-inset.at(0) } else { inset-x }
  let inset-y = if inset-y == auto { default-inset.at(1) } else { inset-y }
  let resolved-shadow-color = if shadow-color == auto {
    source-fill.darken(40%)
  } else { shadow-color }
  // Combine a vertical pale-to-deep wash with a horizontal dark-edge glaze.
  // Both passes paint the same native lifted contour; neither reshapes it.
  let shadow-base-fill = if print-mode { source-fill } else { fill }
  let shadow-paint = (
    mode: "two-axis",
    center-top: shadow-base-fill.lighten(55%),
    center-bottom: resolved-shadow-color,
    edge: resolved-shadow-color.darken(25%),
  )
  set text(dir: if rtl-mode { rtl } else { ltr })

  layout(avail => {
    let label = text(size: size, weight: weight, fill: text-color)[#body]
    let natural-width = measure(label).width + 2 * inset-x
    let card-width = if width == auto { calc.min(avail.width, natural-width) }
      else if type(width) == ratio { avail.width * width }
      else { width }
    let inner-width = calc.max(0pt, card-width - 2 * inset-x)
    let label-box = box(width: inner-width, align(text-alignment, label))
    let card-height = measure(label-box).height + 2 * inset-y

    // Match the ordinary postit's lower-edge shadow carrier. The shadow is
    // native fabox `large`, but the colored banner itself remains a simple pill.
    let shadow-width = if type(shadow-length) == ratio {
      card-width * shadow-length
    } else { shadow-length }
    let shadow-width = calc.min(card-width, shadow-width)
    // The native inset and the front banner's mask leave only part of the
    // carrier visible below the edge. Calibrate the carrier so `shadow-length`
    // describes the visible bowl span; it may overhang internally, while the
    // outer box still clips everything to the banner width.
    let carrier-width = shadow-width / 0.46 + 0.50cm
    let carrier-x = (card-width - carrier-width) / 2
    let carrier-height = 0.70cm
    // Keep the carrier anchored behind the banner so its broad top edge stays
    // masked; only the bowl itself drops below the lower edge.
    let carrier-y = card-height - 0.70cm
    let reserved-shadow = 0.55cm

    box(width: card-width, height: card-height + reserved-shadow, clip: true, {
      // Place first so the front pill masks the upper part of the native carrier.
      place(top + left, dx: carrier-x, dy: carrier-y,
        fabox([], width: carrier-width, height: carrier-height,
          inset: 0pt, colour: fill, frame: fill,
          back: fill.transparentize(100%),
          frame-hidden: true, radius: 0.02, weight: 0.1pt,
          shadow: shadow, shadow-colour: shadow-paint,
          shadow-flip-y: true))
      // Rounded garnet face.
      place(top + left, box(width: card-width, height: card-height,
        fill: fill, radius: radius,
        stroke: if print-mode { 0.9pt + black } else { none }))
      // Use faboxyst 0.3.0's native sunken relief over the face fill.
      // Its back is transparent so only the clipped inner rim is added.
      place(top + left, fabox([], width: card-width, height: card-height,
        inset: 0pt, colour: fill, back: fill.transparentize(100%),
        frame-hidden: true, radius: radius / 1cm, weight: 0pt,
        shadow: "creuse"))
      // Set the words last so the inset shadow does not tint their edges.
      place(top + left, dx: title-offset-x, dy: title-offset-y, box(width: card-width, height: card-height,
          inset: (left: inset-x, right: inset-x,
            top: inset-y, bottom: inset-y),
          label-box))
    })
  })
}
