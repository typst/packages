#import "simple-arrow.typ": simple-arrow, double-arrow
#import "pinit-fletcher.typ": pinit-fletcher-edge
#import "pinit-core.typ": *

// -----------------------------------------------
// Libs
// -----------------------------------------------

/// Draw a rectangular shape on the page **containing all pins** with optional extended width and height.
///
/// - `dx`: [`length`] &mdash; Offset X relative to the min-left of pins.
/// - `dy`: [`length`] &mdash; Offset Y relative to the min-top of pins.
/// - `extended-width`: [`length`] &mdash; Optional extended width of the rectangular shape.
/// - `extended-height`: [`length`] &mdash; Optional extended height of the rectangular shape.
/// - `pin1`: [`pin`] &mdash; One of these pins.
/// - `pin2`: [`pin`] &mdash; One of these pins.
/// - `pin3`: [`pin`] &mdash; One of these pins, optionally.
/// - `...args`: Additional named arguments or settings for [`rect`](https://typst.app/docs/reference/visualize/rect/), like `fill`, `stroke` and `radius`.
#let pinit-rect(
  dx: 0em,
  dy: -1em,
  extended-width: 0em,
  extended-height: 1.4em,
  ..args,
) = {
  pinit(
    ..args.pos(),
    callback: (..positions) => {
      positions = positions.pos()
      let min-x = calc.min(..positions.map(loc => loc.x))
      let max-x = calc.max(..positions.map(loc => loc.x))
      let min-y = calc.min(..positions.map(loc => loc.y))
      let max-y = calc.max(..positions.map(loc => loc.y))
      absolute-place(
        dx: min-x + dx,
        dy: min-y + dy,
        rect(
          width: max-x - min-x + extended-width,
          height: max-y - min-y + extended-height,
          ..args.named(),
        ),
      )
    },
  )
}

/// Highlight a specific area on the page with a filled color and optional radius and stroke. It is just a simply styled `pinit-rect`.
///
// - `fill`: [`color`] &mdash; The fill color for the highlighted area.
// - `radius`: [`length`] &mdash; Optional radius for the highlight.
// - `stroke`: [`stroke`] &mdash; Optional stroke width for the highlight.
// - `dx`: [`length`] &mdash; Offset X relative to the min-left of pins.
// - `dy`: [`length`] &mdash; Offset Y relative to the min-top of pins.
// - `extended-width`: [`length`] &mdash; Optional extended width of the rectangular shape.
// - `extended-height`: [`length`] &mdash; Optional extended height of the rectangular shape.
// - `pin1`: [`pin`] &mdash; One of these pins.
// - `pin2`: [`pin`] &mdash; One of these pins.
// - `pin3`: [`pin`] &mdash; One of these pins, optionally.
// - `...args`: Additional arguments or settings for [`pinit-rect`](#pinit-rect).
#let pinit-highlight(
  fill: rgb(255, 0, 0, 20),
  radius: 5pt,
  stroke: 0pt,
  dx: 0em,
  dy: -1em,
  extended-width: 0em,
  extended-height: 1.4em,
  ..args,
) = {
  pinit-rect(
    fill: fill,
    radius: radius,
    stroke: stroke,
    dx: dx,
    dy: dy,
    extended-width: extended-width,
    extended-height: extended-height,
    ..args,
  )
}

/// Draw a line on the page between two specified pins with an optional stroke.
///
/// - `stroke`: [`stroke`] &mdash; The stroke for the line.
/// - `start-dx`: [`length`] &mdash; Offset X relative to the start pin.
/// - `start-dy`: [`length`] &mdash; Offset Y relative to the start pin.
/// - `end-dx`: [`length`] &mdash; Offset X relative to the end pin.
/// - `end-dy`: [`length`] &mdash; Offset Y relative to the end pin.
/// - `start`: [`pin`] &mdash; The start pin.
/// - `end`: [`pin`] &mdash; The end pin.
#let pinit-line(
  stroke: 1pt,
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  start,
  end,
) = {
  pinit(
    start,
    end,
    callback: (start-pos, end-pos) => {
      absolute-place(
        line(
          stroke: stroke,
          start: (
            start-pos.x + start-dx,
            start-pos.y + start-dy,
          ),
          end: (
            end-pos.x + end-dx,
            end-pos.y + end-dy,
          ),
        ),
      )
    },
  )
}

/// Draw an line from a specified pin to a point on the page with optional settings.
///
/// - `stroke`: [`stroke`] &mdash; The stroke for the line.
/// - `pin-dx`: [`length`] &mdash; Offset X of arrow start relative to the pin.
/// - `pin-dy`: [`length`] &mdash; Offset Y of arrow start relative to the pin.
/// - `body-dx`: [`length`] &mdash; Offset X of arrow end relative to the body.
/// - `body-dy`: [`length`] &mdash; Offset Y of arrow end relative to the body.
/// - `offset-dx`: [`length`] &mdash; Offset X relative to the pin.
/// - `offset-dy`: [`length`] &mdash; Offset Y relative to the pin.
/// - `pin-name`: [`pin`] &mdash; The name of the pin to start from.
/// - `body`: [`content`] &mdash; The content to draw the arrow to.
#let pinit-line-to(
  pin-dx: 5pt,
  pin-dy: 5pt,
  body-dx: 5pt,
  body-dy: 5pt,
  offset-dx: 35pt,
  offset-dy: 35pt,
  pin-name,
  body,
  ..args,
) = {
  pinit-line(pin-name, pin-name, start-dx: pin-dx, start-dy: pin-dy, end-dx: offset-dx, end-dy: offset-dy, ..args)
  pinit-place(pin-name, body, dx: offset-dx + body-dx, dy: offset-dy + body-dy)
}

/// Draw an arrow between two specified pins with optional settings.
///
/// - `start-dx`: [`length`] &mdash; Offset X relative to the start pin.
/// - `start-dy`: [`length`] &mdash; Offset Y relative to the start pin.
/// - `end-dx`: [`length`] &mdash; Offset X relative to the end pin.
/// - `end-dy`: [`length`] &mdash; Offset Y relative to the end pin.
/// - `start`: [`pin`] &mdash; The start pin.
/// - `end`: [`pin`] &mdash; The end pin.
/// - `...args`: Additional arguments or settings for [`simple-arrow`](#simple-arrow), like `fill`, `stroke` and `thickness`.
#let pinit-arrow(
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  start,
  end,
  ..args,
) = {
  pinit(
    start,
    end,
    callback: (start-pos, end-pos) => {
      absolute-place(
        simple-arrow(
          start: (
            start-pos.x + start-dx,
            start-pos.y + start-dy,
          ),
          end: (
            end-pos.x + end-dx,
            end-pos.y + end-dy,
          ),
          ..args,
        ),
      )
    },
  )
}

/// Draw an double arrow between two specified pins with optional settings.
///
/// - `start-dx`: [`length`] &mdash; Offset X relative to the start pin.
/// - `start-dy`: [`length`] &mdash; Offset Y relative to the start pin.
/// - `end-dx`: [`length`] &mdash; Offset X relative to the end pin.
/// - `end-dy`: [`length`] &mdash; Offset Y relative to the end pin.
/// - `start`: [`pin`] &mdash; The start pin.
/// - `end`: [`pin`] &mdash; The end pin.
/// - `...args`: Additional arguments or settings for [`double-arrow`](#double-arrow), like `fill`, `stroke` and `thickness`.
#let pinit-double-arrow(
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  start,
  end,
  ..args,
) = {
  pinit(
    start,
    end,
    callback: (start-pos, end-pos) => {
      absolute-place(
        double-arrow(
          start: (
            start-pos.x + start-dx,
            start-pos.y + start-dy,
          ),
          end: (
            end-pos.x + end-dx,
            end-pos.y + end-dy,
          ),
          ..args,
        ),
      )
    },
  )
}

/// Draw an arrow from a specified pin to a point on the page with optional settings.
/// - `pin-dx`: [`length`] &mdash; Offset X of arrow start relative to the pin.
/// - `pin-dy`: [`length`] &mdash; Offset Y of arrow start relative to the pin.
/// - `body-dx`: [`length`] &mdash; Offset X of arrow end relative to the body.
/// - `body-dy`: [`length`] &mdash; Offset Y of arrow end relative to the body.
/// - `offset-dx`: [`length`] &mdash; Offset X relative to the pin.
/// - `offset-dy`: [`length`] &mdash; Offset Y relative to the pin.
/// - `double`: [`bool`] &mdash; Draw a double arrow, default is `false`.
/// - `pin-name`: [`pin`] &mdash; The name of the pin to start from.
/// - `body`: [`content`] &mdash; The content to draw the arrow to.
/// - `...args`: Additional arguments or settings for [`simple-arrow`](#simple-arrow), like `fill`, `stroke` and `thickness`.
#let pinit-point-to(
  pin-dx: 5pt,
  pin-dy: 5pt,
  body-dx: 5pt,
  body-dy: 5pt,
  offset-dx: 35pt,
  offset-dy: 35pt,
  double: false,
  pin-name,
  body,
  ..args,
) = {
  let arrow-fn = if double {
    pinit-double-arrow
  } else {
    pinit-arrow
  }
  arrow-fn(pin-name, pin-name, start-dx: pin-dx, start-dy: pin-dy, end-dx: offset-dx, end-dy: offset-dy, ..args)
  pinit-place(pin-name, body, dx: offset-dx + body-dx, dy: offset-dy + body-dy)
}

/// Draw an arrow from a point on the page to a specified pin with optional settings.
///
/// - `pin-dx`: [`length`] &mdash; Offset X relative to the pin.
/// - `pin-dy`: [`length`] &mdash; Offset Y relative to the pin.
/// - `body-dx`: [`length`] &mdash; Offset X relative to the body.
/// - `body-dy`: [`length`] &mdash; Offset Y relative to the body.
/// - `offset-dx`: [`length`] &mdash; Offset X relative to the left edge of the page.
/// - `offset-dy`: [`length`] &mdash; Offset Y relative to the top edge of the page.
/// - `double`: [`bool`] &mdash; Draw a double arrow, default is `false`.
/// - `pin-name`: [`pin`] &mdash; The name of the pin that the arrow to.
/// - `body`: [`content`] &mdash; The content to draw the arrow from.
/// - `...args`: Additional arguments or settings for [`simple-arrow`](#simple-arrow), like `fill`, `stroke` and `thickness`.
#let pinit-point-from(
  pin-dx: 5pt,
  pin-dy: 5pt,
  body-dx: 5pt,
  body-dy: 5pt,
  offset-dx: 35pt,
  offset-dy: 35pt,
  double: false,
  pin-name,
  body,
  ..args,
) = {
  let arrow-fn = if double {
    pinit-double-arrow
  } else {
    pinit-arrow
  }
  arrow-fn(pin-name, pin-name, start-dx: offset-dx, start-dy: offset-dy, end-dx: pin-dx, end-dy: pin-dy, ..args)
  pinit-place(pin-name, body, dx: offset-dx + body-dx, dy: offset-dy + body-dy)
}