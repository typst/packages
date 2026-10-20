// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The logo of Animo, alone or as a badge that says the deck was made with Animo.
//
// The logo is an SVG image that typst builds from the path below,
// so a deck can show the logo in any color without an image file.
// The SVG files under `logo/` hold the same path, which a test keeps in step.

// The path of the logo, in a square of 32 by 32 units.
// The path has holes for the face, so it needs the even-odd fill rule.
// Its ink spans the units 2 to 30 in both directions, so the logo is centered in its square.
#let logo-path = (
  "M20.07 18.53a1 1 0 0 0-.6.47 3.97 3.97 0 0 1-6.93 0 1 1 0 0 0-1.37-.37A1 1 0 0 0 10.8 20"
    + "a6.03 6.03 0 0 0 10.4 0 1 1 0 0 0-.37-1.37 1 1 0 0 0-.76-.1m-.76-9.46a.6.6 0 0 0-.31.53"
    + "v4.8a.6.6 0 0 0 .92.5l3.8-2.4a.6.6 0 0 0 0-1l-3.8-2.4a.6.6 0 0 0-.6-.03M12.6 9h.8"
    + "c.33 0 .6.27.6.6v4.8a.6.6 0 0 1-.6.6h-.8a.6.6 0 0 1-.6-.6V9.6c0-.33.27-.6.6-.6m-4 0h.8"
    + "c.33 0 .6.27.6.6v4.8a.6.6 0 0 1-.6.6h-.8a.6.6 0 0 1-.6-.6V9.6c0-.33.27-.6.6-.6"
    + "m14.07 18c0 4-6 4-6 0m-1.34 0c0 4-6 4-6 0M8 27c0 4-6 4-6 0V16a14 14 0 1 1 28 0v11"
    + "c0 4-6 4-6 0"
)

// The fill a logo is drawn in, which is the text color when the caller passes `auto`.
// An SVG fill attribute holds a single color, so a gradient or a tiling is refused.
#let logo-fill(fill) = {
  let fill = if fill == auto { text.fill } else { fill }
  assert(
    type(fill) == color,
    message: "the fill of the Animo logo must be a color, not " + repr(fill),
  )
  fill
}

/// The logo of Animo, as an image in any color.
///
/// - fill (auto, color): The color of the logo.
///   With `auto`, the logo takes the color of the surrounding text.
/// - ..arguments (arguments): Passed on to `image`, such as `height`, `width` or `alt`.
/// -> content
#let animo-logo(fill: auto, ..arguments) = context image(
  bytes(
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>"
      + "<path fill-rule='evenodd' fill='"
      + logo-fill(fill).to-hex()
      + "' d='"
      + logo-path
      + "'/></svg>",
  ),
  format: "svg",
  alt: "The logo of Animo",
  ..arguments,
)

/// A badge with the logo of Animo beside the words "made with Animo" on two lines.
/// The word "Animo" is set larger, so that it is as wide as "made with" above it.
///
/// - fill (auto, color): The color of the logo and the words.
///   With `auto`, the badge takes the color of the surrounding text.
/// - height (length): The height of the logo, which is also the height of the badge.
/// -> content
#let made-with-animo(fill: auto, height: 2em) = context {
  let fill = logo-fill(fill)
  let height = height.to-absolute()
  set text(fill: fill)
  let first = [made with]
  let name = text(weight: "bold")[Animo]
  let widen = measure(first).width / measure(name).width
  let lines = stack(spacing: 0.2em, first, text(size: widen * 1em, name))
  // The two lines take four fifths of the height of the logo, measured from the top of
  // "made" to the baseline of "Animo".
  // Their height grows in proportion to the text size, so one measurement gives the size.
  let shrink = 0.8 * height / measure(lines).height
  box(grid(
    columns: 2,
    column-gutter: 0.12 * height,
    align: horizon,
    // The words say what the logo means, so the logo carries no alternative text.
    animo-logo(fill: fill, height: height, alt: none),
    text(size: shrink * 1em, lines),
  ))
}
