#import "simple-arrow.typ": simple-arrow
#import "pinit-core.typ": *

// -----------------------------------------------
// Libs
// -----------------------------------------------

#let pinit-rect(
  dx: 0em,
  dy: -1em,
  extended-width: 0em,
  extended-height: 1.4em,
  ..args,
) = {
  pinit(args.pos(), (positions) => {
    let min-x = calc.min(..positions.map((loc) => loc.x))
    let max-x = calc.max(..positions.map((loc) => loc.x))
    let min-y = calc.min(..positions.map((loc) => loc.y))
    let max-y = calc.max(..positions.map((loc) => loc.y))
    absolute-place(
      dx: min-x + dx,
      dy: min-y + dy,
      rect(
        width: max-x - min-x + extended-width,
        height: max-y - min-y + extended-height,
        ..args.named()
      )
    )
  })
}

#let pinit-highlight(
  fill: rgb(255, 0, 0, 20),
  radius: 5pt,
  stroke: 0pt,
  ..args,
) = {
  pinit-rect(fill: fill, radius: radius, stroke: stroke, ..args)
}

#let pinit-line(
  stroke: 1pt,
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  start,
  end,
) = {
  pinit((start, end), (positions) => {
    absolute-place(
      line(
        stroke: stroke,
        start: (
          positions.at(0).x + start-dx,
          positions.at(0).y + start-dy,
        ),
        end: (
          positions.at(1).x + end-dx,
          positions.at(1).y + end-dy,
        ),
      )
    )
  })
}

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

#let pinit-arrow(
  start-dx: 0pt,
  start-dy: 0pt,
  end-dx: 0pt,
  end-dy: 0pt,
  start,
  end,
  ..args,
) = {
  pinit((start, end), (locations) => {
    absolute-place(simple-arrow(
      start: (
        locations.at(0).x + start-dx,
        locations.at(0).y + start-dy,
      ),
      end: (
        locations.at(1).x + end-dx,
        locations.at(1).y + end-dy,
      ),
      ..args,
    ))
  })
}

#let pinit-point-to(
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
  pinit-arrow(pin-name, pin-name, start-dx: pin-dx, start-dy: pin-dy, end-dx: offset-dx, end-dy: offset-dy, ..args)
  pinit-place(pin-name, body, dx: offset-dx + body-dx, dy: offset-dy + body-dy)
}

#let pinit-point-from(
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
  pinit-arrow(pin-name, pin-name, start-dx: offset-dx, start-dy: offset-dy, end-dx: pin-dx, end-dy: pin-dy, ..args)
  pinit-place(pin-name, body, dx: offset-dx + body-dx, dy: offset-dy + body-dy)
}