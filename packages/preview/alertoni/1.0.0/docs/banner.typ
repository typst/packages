#import "@preview/alertoni:1.0.0" as at

#let radius = 3pt
#let inset = (top: 8pt, rest: 6pt)

#let callout-style(title, icon, content, paint, height, width) = align(
  center,
  block(
    above: 1.5em,
    below: 1.5em,
    width: width,
    height: height,
    stroke: paint + 1pt,
    inset: inset,
    fill: white,
    radius: radius,
    {
      set align(left)
      // title block

      if icon != none or title != none {
        place(top + left, dy: -inset.top - 0.5em, dx: -1pt, box(
          fill: white,
          inset: if icon == none {
            (x: 2pt)
          } else if title == none {
            (x: 0pt)
          } else {
            (left: 1pt, right: 2pt)
          },
          outset: (y: 1pt),
          grid(
            align: center + horizon,
            ..if icon != none and title != none { (column-gutter: 0.2em) },
            columns: if icon == none or title == none {
              auto
            } else {
              (1em, auto)
            }, rows: 1em,
            ..(
              if icon != none {
                (text(paint, icon),)
              }
                + if title != none {
                  (text(weight: "bold", paint, title),)
                }
            )
          ),
        ))
      }
      content
    },
  ),
)

#let callout = at.callout.with(style: callout-style)

#set page(width: 21cm, height: 6.8cm, margin: 5mm)
#set text(21pt)

#let typst-toml = toml("../typst.toml")

#block(width: 100%, height: 100%, [
  #place(top, {
    callout(pad(1.5em, text(5.5em)[A]), width: 40%)
  })

  #place(
    top,
    {
      callout(type: "tip", pad(1em, text(5.5em)[to]), width: auto)
    },
    dx: 13.5em,
    dy: 0.8em,
  )

  #place(
    top,
    {
      callout(type: "caution", pad(1em, text(5.5em)[ler]), width: auto)
    },
    dx: 6em,
    dy: 1.6em,
  )

  #place(
    top,
    {
      callout(type: "important", pad(1em, text(5.5em)[ni]), width: auto)
    },
    dx: 20em,
    dy: 0.4em,
  )

  #place(right+bottom, text(0.7em)[Version #typst-toml.package.version], dy: -0.3em, dx: 0em)
])


