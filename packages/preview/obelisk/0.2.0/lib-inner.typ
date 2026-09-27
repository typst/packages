#import "layout.typ": *
#import "headers.typ": *
#import "default.typ": (
  def-deco, def-fonts, def-headers, def-margin, def-paper,
  def-side, def-texts, default-settings,
  or-default-settings,
)
#import "theorem.typ": *

#import "@preview/hydra:0.6.3": anchor, hydra

#let hydra = hydra.with(use-last: true)

#let init(
  it,
  paper: def-paper,
  margin: def-margin,
  side: def-side,
  texts: def-texts,
  fonts: def-fonts,
  deco: def-deco,
  headers: def-headers,
) = {
  let default = or-default-settings(
    paper,
    margin,
    side,
    texts,
    fonts,
    deco,
    headers,
  )
  default-settings.update(_ => default)
  let (
    paper,
    margin,
    side,
    body,
    fonts,
    texts,
    deco,
    headers,
  ) = default
  let paper-margin = if paper.two-sided {
    (
      top: margin.t + texts.step,
      outside: margin.e,
      inside: margin.s,
      bottom: margin.f,
    )
  } else {
    (
      top: margin.t + texts.step,
      left: margin.e,
      right: margin.s,
      bottom: margin.f,
    )
  }
  set page(
    margin: paper-margin,
    background: context {
      let page-num = here().page()
      let dx = if (
        calc.even(page-num) or not paper.two-sided
      ) {
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
      //   dy: margin.t,
      //   grid(
      //     columns: (body.width,),
      //     stroke: (bottom: 0.5pt + gray),
      //     ..(block(width: 100%, height:texts.step),) * 42
      //   ),
      // )
      if deco.line-number {
        let dx = if (
          calc.even(page-num) or not paper.two-sided
        ) {
          paper.width - margin.s + side.half-gutter
        } else {
          margin.s - side.half-gutter - 3pt
        }
        let rot = if (
          calc.even(page-num) or not paper.two-sided
        ) {
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
      }
      init-sblock()
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
        if calc.odd(page-num) and paper.two-sided {
          context hydra(2) + " "
        } else {
          "" + context hydra(1)
        },
      )

      let dx = -body.width / 2 - side.half-gutter
      place(
        top + center,
        dx: if calc.even(page-num) or not paper.two-sided {
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
      let flush = if (
        calc.odd(page-num) and paper.two-sided
      ) {
        right
      } else {
        left
      }
      place(
        top + flush,
        dx: if calc.even(page-num) or not paper.two-sided {
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
    let (
      height: h,
      ascender: ht,
      descender: hb,
    ) = true-metrics(it)
    let gt = (
      calc.max(calc.ceil((ht - texts.step + texts.descender) / texts.step), 0)
        * texts.step
    )
    let gb = (
      calc.max(
        calc.ceil(
          (hb - texts.step + texts.ascender) / texts.step,
        ),
        0,
      )
        * texts.step
    )

    // FIXME: if we wrap the equation in a box, it becomes unbreakable. The box may also break some diagram packages like fletcher.
    // This is a temporary fix that should work most of the time: when there is no adjustment needed, don't wrap the equation.
    if gt + gb == 0pt {
      it
    } else {
      box(
        // height: gt + gb,
        inset: (top: gt - ht, bottom: gb - hb),
        // stroke: blue,
        text(top-edge: "bounds", bottom-edge: "bounds", it),
        // outset: (top: texts.step),
      )
    }
  }

  show: show-headers

  show: init-theorem

  it
}
