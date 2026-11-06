
#let color-data = (
  "Z": rgb("#ef624d"),
  "S": rgb("#66c65c"),
  "L": rgb("#ef9535"),
  "J": rgb("#1983bf"),
  "T": rgb("#9c27b0"),
  "O": rgb("#f7d33e"),
  "I": rgb("#41afde"),
  "X": rgb("#686868")
)

#let shadow-color = (
  "Z": rgb("#ff9484"),
  "S": rgb("#88ee86"),
  "L": rgb("#ffbf60"),
  "J": rgb("#1ba6f9"),
  "T": rgb("#e56add"),
  "O": rgb("#fff952"),
  "I": rgb("#43d3ff"),
  "X": rgb("#949494")
)

#let is-upper(c) = upper(c) == c

#let render-field(field, rows: 20, cell-size: 10pt, bg-color: rgb("#f3f3ed"), stroke: none, radius: auto, shadow: true) = {
  let actual-radius = if radius == auto { cell-size / 4 } else { radius }
  let shadow-height = cell-size / 5
  block(width: 10 * cell-size, height: rows * cell-size, inset: 0pt, stroke: stroke, radius: actual-radius, clip: true, fill: bg-color, breakable: false, {
    for i in range(rows) {
      for j in range(10) {
        if field.at(i).codepoints().at(j) == "_" {
          continue
        }
        let block = field.at(i).codepoints().at(j)
        if is-upper(block) {
          place(top + left, 
            dx: cell-size * j, 
            dy: cell-size * (rows - 1 - i),
            rect(
              width: cell-size,
              height: cell-size,
              fill: color-data.at(upper(block))
            )
          )
          if shadow and block != "_" {
            place(top + left, 
              dx: cell-size * j, 
              dy: cell-size * (rows - i - 1) - shadow-height,
              rect(
                width: cell-size,
                height: shadow-height,
                fill: shadow-color.at(upper(block))
              )
            )
          }
        } else {
          // operation mino is displayed in lower case
          place(top + left, 
            dx: cell-size * j, 
            dy: cell-size * (rows - 1 - i),
            rect(
              width: cell-size,
              height: cell-size,
              fill: bg-color
            )
          )
          place(top + left, 
            dx: cell-size * j + cell-size * 0.1, 
            dy: cell-size * (rows - 1 - i) + cell-size * 0.1,
            rect(
              width: cell-size * 0.8,
              height: cell-size * 0.8,
              stroke: color-data.at(upper(block)) +  cell-size * 0.1,
            )
          )
        }
      }
    }
  })
}
