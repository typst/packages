#import "@preview/cetz:0.4.2"

#let _icon(
  body,
  /// The radius of the background rect.
  radius: 0.25,
  /// How thick the lines in the icons are, relative to the size.
  thickness: 0.1,
  /// The color to tint the icon itself in.
  foreground: luma(0%),
  /// The color behind the icon. Use `none` if you don't want any background.
  background: luma(100%),
  /// Swap foreground and background.
  invert: false,
  /// If true, returns a `content` that can be directly put into text.
  /// If false, returns an array of draw commands that can be used in a cetz canvas.
  contentize: true,
  name: none,
  /// Arguments to forward to `canvas` if `contentize` is true.
  ..args,
) = {
  import cetz.draw: *

  let (background, foreground) = if invert {
    (foreground, background)
  } else {
    (background, foreground)
  }

  // corners
  let (bl, ur) = ((0, 0), (1, 1))

  let maybe-name = {
    if name != none {
      (name: name)
    }
  }

  let cmds = group(
    {
      if background == none {
        set-viewport(bl, ur)
      } else {
        rect(
          bl,
          ur,
          stroke: none,
          fill: background,
          radius: radius,
          ..maybe-name,
        )
      }

      // intended to be selectively disabled via passing `none` explicitly
      set-style(
        stroke: (
          paint: foreground,
          thickness: thickness,
          cap: "round",
          join: "round",
        ),
        radius: thickness / 2,
        fill: foreground,
      )

      // so the user can just draw from 0 to 1 while the padding is outside
      set-origin((0.2, 0.2))
      scale(0.6)
      body()
    },
    ..maybe-name,
  )

  if contentize {
    box(
      inset: (
        y: -0.175em,
      ),
      cetz.canvas(cmds, length: 1em, ..args),
    )
  } else {
    cmds
  }
}

#let icons = {
  import cetz.draw: *

  (
    " ": () => {
      rect(
        (-0.125, -0.125),
        (1.125, 1.125),
        radius: 0.25,
        stroke: none,
      )
    },
    "!": () => {
      let offset = 0.2

      for (offset, y-scale) in (
        ((x: -offset, y: 0), 1),
        ((x: offset, y: 1), -1),
      ) {
        line(
          (0.5 + offset.x, 1 * y-scale + offset.y),
          (0.5 + offset.x, 0.375 * y-scale + offset.y),
        )
        circle(
          (0.5 + offset.x, 0.05 * y-scale + offset.y),
        )
      }
    },
    ">": () => {
      let bendness = (x: 0.25, y: 0.5)
      let offset = 0.25

      for shift in (-offset, offset) {
        line(
          (0.5 - bendness.x + shift, 0.5 + bendness.y),
          (0.5 + bendness.x + shift, 0.5),
          (0.5 - bendness.x + shift, 0.5 - bendness.y),
          fill: none,
        )
      }
    },
    ":": () => {
      circle((0.5, 0.8), radius: 0.1)
      circle((0.5, 0.2), radius: 0.1)
    },
    "|": () => {
      line((0.5, 0), (rel: (0, 1)))
    },
    "-": () => {
      line((0, 0.5), (1, 0.5))
    },
    "/": () => {
      let slantedness = 0.25

      line(
        (0.5 - slantedness, 0),
        (0.5 + slantedness, 1),
      )
    },
    "?": () => {
      arc(
        (0.5, 0.5),
        start: 165deg,
        stop: -90deg,
        fill: none,
        radius: 0.25,
        anchor: "arc-end",
      )
      line(
        (0.5, 0.5),
        (0.5, 0.375),
      )
      circle(
        (0.5, 0.05),
      )
    },
    "i": () => {
      circle((0.5, 0.95))
      line((0.5, 0.6), (0.5, 0))
    },
    "l": () => {
      line((0.3, 1), (rel: (0, -0.8)))
      arc(
        (),
        start: -180deg,
        stop: 0deg,
        radius: 0.2,
        fill: none,
      )
    },
    "o": () => {
      circle((0.5, 0.5), radius: 0.5, fill: none)
    },
    "x": () => {
      set-origin((0.5, 0.5))
      let bend = 0.075
      for _ in range(4) {
        line(
          (0, 0),
          (0, bend),
          (0.5, 0.5),
          (bend, 0),
          close: true,
        )
        rotate(90deg)
      }
    },
    "A": () => {
      let left = (0, 0)
      let top = (0.5, 1)
      let right = (1, 0)
      let slide = 35%

      line(left, top, right, fill: none)
      line((left, slide, top), (right, slide, top))
    },
    "B": () => {
      set-origin((0.2, 0))
      let radius-top = 0.225
      let radius-bottom = 0.5 - radius-top
      let half-circle(radius) = arc(
        (),
        start: 90deg,
        stop: -90deg,
        fill: none,
        radius: radius,
      )

      line((0, 0), (0, 1), (0.25, 1), fill: none)
      half-circle(radius-top)

      line((0, radius-bottom * 2), (rel: (0.4, 0)))
      half-circle(radius-bottom)
      line((), (0, 0))
    },
    "C": () => {
      for height in (0, 1) {
        line((0.8, height), (rel: (-0.2, 0)))
      }
      arc(
        (),
        start: 90deg,
        stop: 270deg,
        radius: 0.5,
        fill: none,
      )
    },
    "D": () => {
      line(
        (0.15, 0),
        (rel: (0, 1)),
        (rel: (0.2, 0)),
        fill: none,
      )
      arc(
        (),
        start: 90deg,
        stop: -90deg,
        radius: 0.5,
        fill: none,
      )
      line((0.15, 0), (0.35, 0))
    },
    "E": () => {
      line(
        (1, 1),
        (0, 1),
        (0, 0),
        (1, 0),
        fill: none,
      )
      for sign in (-1, 1) {
        bezier(
          (0, 0.5 + 0.25 * sign),
          (0.25, 0.5),
          (0, 0.5),
        )
      }
      line((), (0.75, 0.5))
    },
    "F": () => {
      set-origin((0.25, 0))
      line((0, 0), (0, 0.75))
      for shift in (0.35, 0.75) {
        bezier(
          (0, shift),
          (0.25, shift + 0.25),
          (0, shift + 0.25),
        )
        line((), (0.5, shift + 0.25))
      }
    },
    "G": () => {
      set-origin((0.925, 0.15)) // pivot
      arc(
        (0, 0),
        start: 315deg,
        stop: 45deg,
        radius: 0.5,
        fill: none,
      )
      line(
        (0, 0),
        (0, 0.325),
        (rel: (-0.325, 0)),
        fill: none,
      )
      bezier(
        (0, 0.075),
        (-0.25, 0.325),
        (0, 0.25),
      )
    },
    "H": () => {
      set-origin((0.5, 0.5))
      scale(0.5)
      line((-0.5, 0), (0.5, 0))

      for _ in range(2) {
        line((1, 1), (1, -1))
        for _ in range(2) {
          bezier((1, 0.5), (0.5, 0), (1, 0))
          scale(y: -1)
        }
        rotate(180deg)
      }
    },
    "P": () => {
      line(
        (0.25, 0),
        (rel: (0, 1)),
        (rel: (0.25, 0)),
        fill: none,
      )
      arc(
        (),
        start: 90deg,
        stop: -90deg,
        radius: 0.25,
        fill: none,
      )
      line((0.25, 0.5), (rel: (0.25, 0)))
    },
    "T": () => {
      line((0.15, 1), (0.85, 1))
      line((0.5, 1), (rel: (0, -1)))
    },
  )
    .pairs()
    .map(((name, cmds)) => (name, _icon.with(cmds)))
    .to-dict()
}

