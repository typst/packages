#import "@preview/cetz:0.3.3": canvas, draw

#let camera_model(size) = {
  set text(1em * size)
  import draw: *
  canvas(
    length: 5em,
    {
      set-style(stroke: 0.1em)
      ortho(
        x: 180deg + 35.26deg,
        y: 225deg,
        z: 0deg,
        sorted: false,
        {
          on-xy({
            rect((-2, 1), (2, -1), stroke: blue)
            let o = (0, 0)
            circle(o, radius: 0.2, stroke: blue)
            line(o, (2.5, 0), mark: (end: "stealth"))
            content((), $x$, anchor: "east")
            line(o, (0, 1.5), mark: (end: "stealth"))
            content((), $y$, anchor: "west")

            content((-0.6, 0), [光心$O$], angle: 30deg)
            content((0, -1.2), [相机], angle: 30deg)
          })

          on-xy(
            {
              rect((-2.1, 1.1), (2.1, -1.1), stroke: blue)
              rect((0.6, 0.6), (-0.6, -0.6), stroke: 0em, fill: gray)
              for i in range(13) {
                line((-1.5, 0.6 - 0.1 * i), (1.5, 0.6 - 0.1 * i), stroke: blue + 0.03em)
                line((0.6 - 0.1 * i, 0.8), (0.6 - 0.1 * i, -0.8), stroke: blue + 0.03em)
              }
              let o = (0, 0)
              line(o, (3, 0), mark: (end: "stealth"))
              content((), $x'$, anchor: "east")
              line(o, (0, 1.5), mark: (end: "stealth"))
              content((), $y'$, anchor: "west")

              content((-0.2, 0), $O'$, angle: 30deg)
              content((0, -1.3), [物理成像平面], angle: 30deg)
              content((0, -0.8), [像素平面], angle: 30deg)
            },
            z: -3,
          )
          line((0, 0, 0), (0, 0, 4), mark: (end: "stealth"))
          content((), $z$, anchor: "west")
          line((0, 0, 0), (0, 0, -3), stroke: (dash: "dashed"))
          content(((0, 0, 0), 50%, (0, 0, -3)), [焦距$f$], angle: -30deg, anchor: "north-west")

          line((-0.6, 0.1, 3), (0, 0, 0), (0.6, 0.1, -3), stroke: red)
          circle((0.6, 0.1, -3), radius: 0.05, stroke: red, fill: red)
          content((0.6, 0.3, -3), $P'$)
          circle((-0.6, 0.1, 3), radius: 0.05, stroke: red, fill: red)
          content((-0.6, 0.3, 3), $P$)
        },
      )
    },
  )
}
