// ================================================================
// SANG-MATH — Layout in hai mặt có vùng nháp
// ================================================================

#let _print-a4-width = 21cm
#let _print-a4-height = 29.7cm

// 70% nội dung + 30% nháp khi nháp-pct: 30%.
// Trang lẻ: nháp ngoài bên phải. Trang chẵn: nháp ngoài bên trái.
#let layout-draft(
  body,
  nháp-pct: 30%,
  nháp-fill: rgb("#f7faf8"),
  nháp-line: rgb("#cbd8d2"),
  nháp-label: "NHÁP",
  accent: rgb("#117a65"),
  content-margin: 1.5cm,
  top-margin: 2cm,
  bottom-margin: 2cm,
  line-count: 27,
) = {
  let draft-width = _print-a4-width * nháp-pct

  set page(
    paper: "a4",
    binding: left,
    margin: (
      top: top-margin,
      bottom: bottom-margin,
      inside: content-margin,
      outside: content-margin + draft-width,
    ),
    background: context {
      let page-number = counter(page).get().first()
      let odd = calc.odd(page-number)
      let draft-x = if odd { _print-a4-width - draft-width } else { 0pt }

      place(
        top + left,
        dx: draft-x,
        rect(
          width: draft-width,
          height: _print-a4-height,
          fill: nháp-fill,
          stroke: if odd {
            (left: 0.8pt + accent.lighten(55%), rest: none)
          } else {
            (right: 0.8pt + accent.lighten(55%), rest: none)
          },
        ),
      )

      let label-x = draft-x + draft-width * 0.5 - 8pt
      place(
        top + left,
        dx: label-x,
        dy: top-margin,
        rotate(90deg, text(
          size: 7.5pt,
          fill: accent.lighten(58%),
          weight: "bold",
          tracking: 5pt,
        )[#upper(nháp-label)]),
      )

      let content-height = _print-a4-height - top-margin - bottom-margin
      let line-gap = content-height / line-count
      for index in range(line-count) {
        place(
          top + left,
          dx: draft-x + 6pt,
          dy: top-margin + index * line-gap,
          line(
            length: draft-width - 12pt,
            stroke: (paint: nháp-line, thickness: 0.4pt),
          ),
        )
      }
    },
  )
  body
}

// Biến thể phần nội dung chia hai cột, vẫn đảo vùng nháp theo trang chẵn/lẻ.
#let layout-2col-draft(body, nháp-pct: 24%, column-gutter: 12pt, ..args) = {
  show: layout-draft.with(nháp-pct: nháp-pct, ..args.named())
  columns(2, gutter: column-gutter, body)
}
