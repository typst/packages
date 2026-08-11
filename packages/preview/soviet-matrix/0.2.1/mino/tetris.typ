
#let default-color = (
  "Z": rgb("#ef624d"),
  "S": rgb("#66c65c"),
  "L": rgb("#ef9535"),
  "J": rgb("#1983bf"),
  "T": rgb("#9c27b0"),
  "O": rgb("#f7d33e"),
  "I": rgb("#41afde"),
  "X": rgb("#686868"),
)

#let default-highlight-color = (
  "Z": rgb("#ff9484"),
  "S": rgb("#88ee86"),
  "L": rgb("#ffbf60"),
  "J": rgb("#1ba6f9"),
  "T": rgb("#e56add"),
  "O": rgb("#fff952"),
  "I": rgb("#43d3ff"),
  "X": rgb("#949494"),
)

#let is-upper(c) = upper(c) == c

#let process-text(string-field) = {
  string-field.trim().split("\n").rev()
}

#let get-field(field) = {
  if type(field) == array {
    field
  } else if type(field) == str {
    process-text(field)
  } else if type(field) == content {
    process-text(field.text)
  } else {
    panic("unknown type of field")
  }
}

#let render-field(
  field,
  rows: 20,
  cols: 10,
  cell-size: 10pt,
  bg-color: rgb("#f3f3ed"),
  stroke: none,
  radius: auto,
  shadow: true,
  highlight: true,
  color-data: default-color,
  highlight-color-data: default-highlight-color,
  shadow-color: rgb("#6f6f6f17"),
  overdraw: 5
) = {
  let field = get-field(field)
  let actual-radius = if radius == auto {
    cell-size / 4
  } else {
    radius
  }
  let highlight-height = cell-size / 5
  let shadow-offset-vertical = cell-size * 0.4
  let shadow-offset-horizontal = cell-size / 4

  block(
    width: cols * cell-size + highlight-height,
    height: rows * cell-size + highlight-height,
    inset: 0pt,
    stroke: stroke,
    radius: actual-radius,
    clip: true,
    fill: bg-color,
    breakable: false,
    {
      let max-row = calc.min(rows, field.len())
      if shadow {
        for i in range(max-row) {
          let cells = field.at(i).len()
          let loop-max = calc.min(cols, cells)
          for j in range(loop-max) {
            if field.at(i).codepoints().at(j) == "_" {
              continue
            }
            let block = field.at(i).codepoints().at(j)
            if is-upper(block) {
              place(
                top + left,
                dx: cell-size * j + shadow-offset-horizontal,
                dy: cell-size * (rows - 1 - i) + shadow-offset-vertical,
                rect(
                  width: cell-size,
                  height: cell-size,
                  fill: shadow-color,
                ),
              )
            }
          }
        }
      }
      for i in range(max-row) {
        let cells = field.at(i).len()
        let loop-max = calc.min(cols, cells)
        for j in range(loop-max) {
          if field.at(i).codepoints().at(j) == "_" {
            continue
          }
          let block = field.at(i).codepoints().at(j)
          for _ in range(overdraw) {
            if is-upper(block) {
              place(
                top + left,
                dx: cell-size * j,
                dy: cell-size * (rows - 1 - i) + highlight-height,
                rect(
                  width: cell-size,
                  height: cell-size,
                  fill: color-data.at(upper(block)),
                ),
              )
              if highlight and block != "_" {
                let (sx, sy) = (0pt, 0pt)
                place(
                  top + left,
                  dx: cell-size * j,
                  dy: cell-size * (rows - i - 1),
                  polygon(
                    fill: highlight-color-data.at(upper(block)),
                    (highlight-height, 0pt),
                    (0pt, highlight-height),
                    (cell-size, highlight-height),
                    (cell-size + highlight-height, 0pt),
                  ),
                )

                place(
                  top + left,
                  dx: cell-size * j + cell-size,
                  dy: cell-size * (rows - i - 1),
                  polygon(
                    fill: highlight-color-data.at(upper(block)).lighten(-10%),
                    (highlight-height, 0pt),
                    (0pt, highlight-height),
                    (0pt, highlight-height + cell-size),
                    (highlight-height, cell-size),
                  ),
                )
              }
            } else {
              // operation mino is displayed in lower case
              place(
                top + left,
                dx: cell-size * j,
                dy: cell-size * (rows - 1 - i) + highlight-height,
                rect(
                  width: cell-size,
                  height: cell-size,
                  fill: bg-color,
                ),
              )
              place(
                top + left,
                dx: cell-size * j + highlight-height,
                dy: cell-size * (rows - 1 - i),
                rect(
                  width: cell-size,
                  height: cell-size,
                  inset: 0pt,
                  stroke: 0pt,
                  align(center + horizon)[
                    #rect(
                      width: cell-size * 0.8,
                      height: cell-size * 0.8,
                      fill: color-data.at(upper(block)).lighten(70%),
                      stroke: color-data.at(upper(block)) + cell-size * 0.05,
                    )
                  ]
                ),
              )
            }
          }
        }
      }
    },
  )
}