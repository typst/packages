#import "layout.typ": *
#import "default.typ": *
#import "theorem.typ": *

#import "@preview/hydra:0.6.2": anchor, hydra

#let hydra = hydra.with(use-last: true)

#let init(
  it,
  paper: (width: width, height: height),
  margin: (
    s: s-margin,
    e: e-margin,
    t: t-margin,
    f: f-margin,
  ),
  side: (half-gutter: half-gutter, margin: e-margin-margin),
  texts: (
    size: text-size,
    ascender: text-height,
    step: step,
  ),
  fonts: (
    body: body-font,
    math: math-font,
    sans: sans-font,
    mono: mono-font,
  ),
) = {
  let default = or-default-settings(
    paper,
    margin,
    side,
    texts,
    fonts,
  )
  default-settings.update(_ => default)
  let (paper, margin, side, body, fonts, texts) = default
  set page(
    margin: (
      top: margin.t + texts.step,
      outside: margin.e,
      inside: margin.s,
      bottom: margin.f,
    ),
    background: context {
      let page-num = here().page()
      let dx = if calc.even(page-num) {
        margin.e - side.half-gutter
      } else {
        paper.width - margin.e + side.half-gutter
      }
      place(
        top + left,
        dx: dx,
        dy: 0pt,
        line(
          start: (0%, 0%),
          end: (0%, 100%),
          stroke: 0.75pt + luma(180),
        ),
      )
      // place(
      //   top + left,
      //   dx: margin.e,
      //   dy: t-margin,
      //   grid(
      //     columns: (t-width,),
      //     stroke: (bottom: 0.5pt + gray),
      //     ..(block(width: 100%, height: step),) * 42
      //   ),
      // )
      let dx = if calc.even(page-num) {
        paper.width - margin.s + side.half-gutter
      } else {
        margin.s - side.half-gutter - 3pt
      }
      let rot = if calc.even(page-num) {
        90deg
      } else {
        -90deg
      }
      set text(
        font: fonts.mono,
        features: ("tnum",),
        size: 0.66em,
        fill: luma(210),
      )
      for i in range(texts.step-num) {
        place(
          dx: dx,
          dy: margin.t
            + texts.step * (i + 1)
            - texts.ascender / 4,
          rotate(rot, [#(
            "0123456789ABCDEF".at(calc.rem-euclid(i, 16))
          )]),
        )
      }
    },
    footer: context {
      let page-num = here().page()
      let pnum-text = text(
        font: fonts.mono,
        fill: luma(180),
      )[[ #text(fill: luma(60))[#page-num] ]]
      let pnum-width = measure(pnum-text).width

      let header-text = text(
        font: fonts.mono,
        fill: luma(210),
        if calc.odd(page-num) {
          context hydra(2) + " "
        } else {
          "" + context hydra(1)
        },
      )

      let dx = -body.width / 2 - side.half-gutter
      place(
        top + center,
        dx: if calc.even(page-num) {
          dx
        } else {
          -dx
        },
        dy: side.half-gutter,
        box(
          fill: white,
          outset: (
            top: side.half-gutter + texts.ascender,
            bottom: side.half-gutter,
          ),
          pnum-text,
        ),
      )

      let dx = -side.half-gutter + pnum-width / 2
      let flush = if calc.odd(page-num) {
        right
      } else {
        left
      }
      place(
        top + flush,
        dx: if calc.even(page-num) {
          dx
        } else {
          -dx
        },
        dy: side.half-gutter,
        header-text,
      )
    },
    header: anchor(),
  )

  set text(
    font: fonts.body,
    size: texts.size,
    top-edge: "baseline",
    bottom-edge: "baseline",
  )

  show math.equation: set text(font: fonts.math)

  set par(
    leading: texts.step,
    spacing: texts.step * 2,
    justify: true,
  )

  show math.equation.where(block: true): it => {
    set block(breakable: true)
    set par(leading: texts.step / 2)
    bblock(it, breakable: true)
  }

  set heading(numbering: (..levels) => {
    let parts = levels.pos()
    if parts.len() > 1 {
      // For Level 2+ headings (e.g., == Subsection)
      parts.map(str).join(".")
    } else {
      none
    }
  })

  show math.equation.where(block: false): it => context {
    let h = measure({
      set text(top-edge: "bounds", bottom-edge: "bounds")
      it
    }).height
    let g = (
      (
        calc.ceil(
          (h - texts.step * 2 + texts.ascender)
            / texts.step,
        )
      )
        * texts.step
    )
    box(
      it,
      height: g,
      outset: (top: texts.step),
      // stroke: 0.5pt,
    )
  }

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
    blank-page(to: "odd", weak: true)
    let h1 = counter(heading).at(here()).at(0)
    place(
      top + right,
      dx: margin.e + 10pt,
      dy: -margin.t - step - 10pt,
      box(
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
      ),
    )
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
    set text(size: texts.size * 2)
    set block(
      above: step * 3,
      below: step * 2,
      breakable: false,
    )
    block(breakable: false)[#place-node(
        $circle.filled$,
        dy: -4pt,
      ) #h(2pt)#box(it)]
  }

  show heading.where(level: 3): it => {
    let step = texts.step
    set text(texts.size * 1.5)
    set block(
      above: step * 3,
      below: step * 2,
      breakable: false,
    )
    block(breakable: false)[#place-node(
        $triangle.filled.small.b$,
        dy: 2pt,
      ) #it]
  }

  show: init-theorem

  it
}
