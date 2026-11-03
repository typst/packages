#import "default.typ": default-settings
#import "layout.typ": blank-page, place-node

#let show-headers(it) = context {
  let (
    paper,
    margin,
    fonts,
    texts,
    headers,
  ) = default-settings.get()

  show heading: it => {
    let step = texts.step
    set block(
      above: step * 3,
      below: step * 2,
      breakable: false,
    )
    set par(leading: step * 2, justify: false)
    set text(font: fonts.sans)
    block(it)
  }

  show heading.where(level: 1): it => context {
    let step = texts.step
    let two-sided = paper.two-sided
    if two-sided {
      blank-page(to: "odd", weak: true)
    } else {
      blank-page(weak: true)
    }
    let h1 = counter(heading).at(here()).at(0)
    let boxed = box(
      stroke: 0.75pt + luma(180),
      fill: white,
      width: 7cm,
      height: 7cm,
      align(
        center + horizon,
        text(
          font: fonts.sans,
          size: 120pt,
          fill: white,
          top-edge: "bounds",
          bottom-edge: "bounds",
          stroke: 1.5pt + luma(180),
          [#h1],
        ),
      ),
    )
    if two-sided {
      place(
        top + right,
        dx: margin.e + 10pt,
        dy: -margin.t - step - 10pt,
        boxed,
      )
    } else {
      place(
        top + left,
        dx: -margin.e - 10pt,
        dy: -margin.t - step - 10pt,
        boxed
      )
    }

    v(step * 12)
    text(
      size: texts.size * 3.5,
      font: fonts.sans,
      align(right)[
        #text(weight: "light")[Section #h1]\ #text(
          weight: "extrabold",
          it,
        )
      ],
    )
    v(step * 3)
  }

  show heading.where(level: 2): it => {
    let step = texts.step
    set text(size: texts.size * headers.h2.size)
    set block(
      above: step * 3,
      below: step * 2,
      breakable: false,
    )
    block(breakable: false)[#place-node(
        $#headers.h2.sym$,
        dy: headers.h2.dy,
      ) #h(2pt)#box(it)]
  }

  show heading.where(level: 3): it => {
    let step = texts.step
    set text(texts.size * headers.h3.size)
    set block(
      above: step * 3,
      below: step * 2,
      breakable: false,
    )
    block(breakable: false)[#place-node(
        $#headers.h3.sym$,
        dy: headers.h3.dy,
      ) #it]
  }

  it
}
