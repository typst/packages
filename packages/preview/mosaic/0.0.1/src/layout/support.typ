// Shared content and surface primitives for layout resolvers.
#import "../grid/constructors.typ": styled-cell, track
#import "../component/image.typ": image as mosaic-image
#import "core.typ": validate-image

// Subordinate tiers composed inside a single cell (title subtitle, title
// metadata, section subtitle) pin a muted `fill` so they read as secondary on
// the default surface. That fill must not survive a recolored cell: a
// light-on-dark composition sets one rule on <mosaic-cell-title> and expects
// the whole stack to follow.
#let inherit-fill(styles) = if "fill" in styles {
  let styles = styles
  _ = styles.remove("fill")
  styles
} else {
  styles
}

// Keeps the muted tier muted while the cell still carries the deck's ordinary
// text color, and hands the tier over to the inherited fill as soon as
// anything overrides it. Call inside a `context` block: it reads `text.fill`.
#let adapt-fill(styles, settings) = if text.fill == settings.colors.text {
  styles
} else {
  inherit-fill(styles)
}

// Places one such tier below the cell's primary content, or nothing when the
// field is absent.
#let subordinate-block(body, styles, settings, above: 0pt) = if body == none {
  []
} else {
  block(above: above, context text(..adapt-fill(styles, settings), body))
}

#let as-content(value) = if value == none {
  none
} else if type(value) == content {
  value
} else {
  [#value]
}

#let content-or-empty(value) = if value == none { [] } else { as-content(value) }

// Edge cells — headers, footers, captions — hug their own content vertically
// and take the deck's inset horizontally, exactly like every other cell. The
// vertical padding stays equal above and below, so a recolored header still
// reads as a balanced band, but it is a fraction of the horizontal inset: a
// heading is one line tall, and full inset on both sides makes the band deeper
// than the text it carries. A single asymmetric gap is what would look
// unconsidered, not a shallower symmetric one. The cell also sits close to
// the body it introduces because the gutter between them is zero.
#let edge-inset(settings) = (
  x: settings.spacing.inset,
  y: 0.55 * settings.spacing.inset,
)

#let track-children(nodes, tracks) = if tracks == auto {
  nodes
} else {
  nodes.zip(tracks).map(((node, size)) => track(size, node))
}

#let image-path(value) = if type(value) != str {
  value
} else if value.starts-with("/") {
  value
} else {
  "/" + value
}

#let path-image(
  value,
  name,
  width: auto,
  height: auto,
  fit: "cover",
  allow-size: true,
) = {
  let image = validate-image(value, name, allow-size: allow-size)
  let alt = image.at("alt", default: none)
  let image-fit = image.at("fit", default: fit)
  // The scrim rides the picture rather than the cell, so it hugs an inset
  // figure exactly as it covers a full-bleed background.
  mosaic-image(
    image-path(image.path),
    alt: alt,
    width: if allow-size { image.at("width", default: width) } else { width },
    height: if allow-size { image.at("height", default: height) } else { height },
    fit: image-fit,
    scrim: image.at("scrim", default: none),
  )
}

#let image-content(
  value,
  name,
  width: auto,
  height: auto,
  fit: "cover",
  allow-size: true,
) = {
  if type(value) == content {
    value
  } else {
    path-image(
      value,
      name,
      width: width,
      height: height,
      fit: fit,
      allow-size: allow-size,
    )
  }
}

// Structural fixed-content cell. Typography is not threaded here: the cell's
// <mosaic-cell-ID> label carries it through native show rules.
#let fixed-cell(
  body,
  id,
  settings,
  inset: none,
) = styled-cell(
  content: as-content(body),
  id: id,
  style: (
    content-sized: true,
    inset: if inset == none { settings.spacing.compact-gap } else { inset },
  ),
)

// Structural slide-filled cell: the slide supplies its content, and `auto`
// takes the deck's own inset.
#let inset-cell(
  id,
  settings,
  content-sized: false,
  inset: auto,
) = styled-cell(
  id: id,
  style: (
    content-sized: content-sized,
    inset: if inset == auto { settings.spacing.inset } else { inset },
  ),
)
