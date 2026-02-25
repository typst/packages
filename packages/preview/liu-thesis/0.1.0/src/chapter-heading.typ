// VZ43 chapter heading style.

#let line-count = 7
#let line-thickness = 1pt
#let line-height = 5cm
#let line-gap = 1mm
#let line-below-baseline = 2cm
#let line-above-baseline = line-height - line-below-baseline
#let lines-total-width = line-count * line-thickness + line-count * line-gap

#let box-width = 0.8cm
#let box-inset = 3pt

#let chapter-font-size = 20.2pt
#let space-before = 75pt
#let lines-overlap = -20pt
#let space-after = 44pt

#let draw-vertical-lines() = {
  box(
    width: lines-total-width,
    height: line-height,
    {
      for i in range(line-count) {
        box(
          width: line-thickness,
          height: line-height,
          fill: black,
        )
        h(line-gap)
      }
    },
  )
}

#let render-chapter-heading(type-block-width, it) = {
  pagebreak(weak: true)

  let has-number = it.numbering != none

  v(if has-number { space-before } else { space-before - 14pt })

  let number-element = if has-number {
    box(
      fill: black,
      width: box-width + 2 * box-inset,
      height: 32pt,
      inset: box-inset,
      {
        set align(center + horizon)
        set text(
          fill: white,
          size: chapter-font-size,
          weight: "bold",
        )
        counter(heading).display("1")
      },
    )
  }

  let title-element = {
    set text(size: chapter-font-size, weight: "bold")
    set align(left + horizon)
    it.body
  }

  let grid-dx = lines-total-width + lines-overlap
  let row-height = 32pt

  block(above: 0pt, below: space-after, {
    box(width: 100%, height: line-height, {
      place(top + left, draw-vertical-lines())

      let content-y = line-above-baseline - row-height / 2

      place(
        top + left,
        dx: grid-dx,
        dy: content-y,
        grid(
          columns: (1cm, type-block-width - 3cm),
          column-gutter: 12pt,
          align: (center + horizon, left + horizon),
          if has-number { number-element },
          title-element,
        ),
      )
    })
  })
}

#let make-chapter-heading(type-block-width) = {
  (it) => render-chapter-heading(type-block-width, it)
}
