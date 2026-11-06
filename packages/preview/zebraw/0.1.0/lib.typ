/// Block of code with highlighted lines.
///
/// - highlight-lines (array): List of line numbers to highlight. 
/// - body (content): The code block.
/// - highlight-color (color): The color to highlight the lines.
/// - inset (dictionary): The padding around each line. Default is 3pt on all sides.
/// -> content
#let zebraw(highlight-lines: (), body, highlight-color: rgb("#fffd11a1").lighten(70%), inset: (:)) = {
  inset = (top: 3pt, bottom: 3pt, left: 3pt, right: 3pt) + inset
  show raw.where(block: true): it => {
    set par(justify: false, leading: inset.top + inset.bottom)
    block(
      fill: luma(245),
      inset: (top: 4pt, bottom: 4pt),
      radius: 4pt,
      width: 100%,
      stack(
        ..it.lines.map(raw_line => block(
          inset: inset,
          width: 100%,
          fill: if highlight-lines.contains(raw_line.number) {
            highlight-color
          } else {
            none
          },
          grid(
            columns: (1em + 4pt, 1fr),
            align: (right + horizon, left),
            column-gutter: 0.7em,
            row-gutter: 0.6em,
            if highlight-lines.contains(raw_line.number) {
              align(top, text(highlight-color.darken(89%), [#raw_line.number]))
            } else {
              align(top, text(gray, [#raw_line.number]))
            },
            raw_line,
          ),
        )),
      ),
    )
  }
  body
}
