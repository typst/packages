#import "./core.typ": *

// Draw one classical column clue cell.
// = Arguments:
// == `value` and `count`
// The clue entry to display.
// == `row` and `col`
// The coordinates of this clue cell within the clue area.
// == `additional-info`
// A dictionary containing the puzzle `width`, `height`, and `marked` status.
// == `cell-size`
// The width and height of the clue cell.
// == `text-processor`
// A callback applied to the displayed `count` before it is placed in the cell.
// == `marker`
// A callback that adds a marker to the clue cell when `additional-info.marked` is true.
// It receives the cell content, the resolved foreground color, and the resolved background
// color, and should return the modified, marked-up content.
// == `content-drawer`
// An optional callback that receives `(value, count, row, col, additional-info)`
// and returns the clue content directly instead of using text-processor.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `coloring`, `omit-default-background`, `default-background`, and `color-lightness-threshold`
// Control whether resolved colors affect the cell background, when the default
// background should be preserved, what that background is, and when foreground
// text should switch to white for contrast.
// == `font`
// The font used to render clue text.
// == `weak-stroke`, `strong-stroke`, `close-opposite-strokes`, `draw-parallel-weak-strokes`, `draw-parallel-strong-strokes`, and `draw-perpendicular-strokes`
// Control the clue cell borders, including 5-cell separators and whether the
// edge opposite the puzzle should be closed with a strong stroke.
#let classical-column-cell-drawer(
  value,
  count,
  row,
  col,
  additional-info: (:),
  cell-size: 1em,
  text-processor: value => [#value],
  marker: (contents, foreground-color, background-color) => [#contents#place(center + horizon, rotate(-45deg, line(
      length: 100%,
      stroke: (paint: foreground-color, cap: "round"),
    )))],
  content-drawer: none,
  color-map: (:),
  coloring: "background",
  omit-default-background: true,
  default-background: white,
  color-lightness-threshold: 50%,
  font: "Libertinus Serif",
  weak-stroke: 0.5pt + black,
  strong-stroke: 1.5pt + black,
  close-opposite-strokes: true,
  draw-parallel-weak-strokes: false,
  draw-parallel-strong-strokes: true,
  draw-perpendicular-strokes: false,
) = {
  let stroke = (left: weak-stroke, right: weak-stroke, top: weak-stroke, bottom: weak-stroke)
  // Top stroke is none or strong if close-opposite is true and it's the first row
  stroke.top = if close-opposite-strokes and (row == 0) {
    strong-stroke
  } else {
    none
  }
  // Left stroke is strong for the first column or multiple of 5 column (for better readability)
  stroke.left = if ((col == 0) or (draw-parallel-strong-strokes and calc.rem(col, 5) == 0)) {
    strong-stroke
  } else if (draw-parallel-weak-strokes) {
    weak-stroke
  } else {
    none
  }
  //right stroke is strong for the last column
  stroke.right = if (col == additional-info.width - 1) {
    strong-stroke
  } else {
    none
  }
  // Bottom stroke is strong for the last row, else weak if draw-perpendicular-weak-strokes is true, else none
  stroke.bottom = if (row == additional-info.height - 1) {
    strong-stroke
  } else if (draw-perpendicular-strokes) {
    weak-stroke
  } else {
    none
  }
  let foreground-color = get-value(value, color-map, default: black)
  if type(foreground-color) == function {
    foreground-color = foreground-color(value, count)
  }
  let background-color = default-background
  if type(background-color) == function {
    background-color = background-color(value, count)
  }
  if (
    coloring == "background"
      and value not in (none, 0)
      and (not omit-default-background or foreground-color != get-value("default", color-map, default: black))
  ) {
    background-color = foreground-color
    if color.luma(background-color).components().at(0) < color-lightness-threshold {
      foreground-color = white
    } else {
      foreground-color = black
    }
  }
  let cell-content = if content-drawer == none {
    text(fill: foreground-color, font: font, if value == none { "" } else {
      [#text-processor(str(count))]
    })
  } else {
    content-drawer(value, count, row, col, additional-info)
  }
  if additional-info.marked {
    cell-content = marker(cell-content, foreground-color, background-color)
  }
  grid.cell(stroke: stroke, fill: background-color, align(center + horizon, block(width: cell-size, height: cell-size, {
    cell-content
  })))
}

// Draw one classical row clue cell.
// = Arguments:
// == `value` and `count`
// The clue entry to display.
// == `row` and `col`
// The coordinates of this clue cell within the clue area.
// == `additional-info`
// A dictionary containing the puzzle `width`, `height`, and `marked` status.
// == `cell-size`
// The width and height of the clue cell.
// == `text-processor`
// A callback applied to the displayed `count` before it is placed in the cell.
// == `marker`
// A callback that adds a marker to the clue cell when `additional-info.marked` is true.
// It receives the cell content, the resolved foreground color, and the resolved background
// color, and should return the modified, marked-up content.
// == `content-drawer`
// An optional callback that receives `(value, count, row, col, additional-info)`
// and returns the clue content directly instead of using `text-processor`.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `coloring`, `omit-default-background`, `default-background`, and `color-lightness-threshold`
// Control whether resolved colors affect the cell background, when the default
// background should be preserved, what that background is, and when foreground
// text should switch to white for contrast.
// == `font`
// The font used to render clue text.
// == `weak-stroke`, `strong-stroke`, `close-opposite-strokes`, `draw-parallel-weak-strokes`, `draw-parallel-strong-strokes`, and `draw-perpendicular-strokes`
// Control the clue cell borders, including 5-cell separators and whether the
// edge opposite the puzzle should be closed with a strong stroke.
#let classical-row-cell-drawer(
  value,
  count,
  row,
  col,
  additional-info: (:),
  cell-size: 1em,
  text-processor: value => [#value],
  marker: (contents, foreground-color, background-color) => [#contents#place(center + horizon, rotate(-45deg, line(
      length: 100%,
      stroke: (paint: foreground-color, cap: "round"),
    )))],
  content-drawer: none,
  color-map: (:),
  coloring: "background",
  omit-default-background: true,
  default-background: white,
  color-lightness-threshold: 50%,
  font: "Libertinus Serif",
  weak-stroke: 0.5pt + black,
  strong-stroke: 1.5pt + black,
  close-opposite-strokes: true,
  draw-parallel-weak-strokes: true,
  draw-parallel-strong-strokes: true,
  draw-perpendicular-strokes: false,
) = {
  let stroke = (left: weak-stroke, right: weak-stroke, top: weak-stroke, bottom: weak-stroke)
  // Left stroke is none or strong if close-opposite is true and it's the first column
  stroke.left = if close-opposite-strokes and (col == 0) {
    strong-stroke
  } else {
    none
  }
  // Top stroke is strong for the first row or multiple of 5 row (for better readability)
  stroke.top = if ((row == 0) or (draw-parallel-strong-strokes and calc.rem(row, 5) == 0)) {
    strong-stroke
  } else if (draw-parallel-weak-strokes) {
    weak-stroke
  } else {
    none
  }
  // Right stroke is strong for the last column, else weak if draw-perpendicular-stroke is true, else none
  stroke.right = if (col == additional-info.width - 1) {
    strong-stroke
  } else if (draw-perpendicular-strokes) {
    weak-stroke
  } else {
    none
  }
  // Bottom stroke is strong for the last row
  stroke.bottom = if (row == additional-info.height - 1) {
    strong-stroke
  } else {
    none
  }
  let foreground-color = get-value(value, color-map, default: black)
  if type(foreground-color) == function {
    foreground-color = foreground-color(value, count)
  }
  let background-color = default-background
  if type(background-color) == function {
    background-color = background-color(value, count)
  }
  if (
    coloring == "background"
      and value != none
      and (not omit-default-background or foreground-color != get-value("default", color-map, default: black))
  ) {
    background-color = foreground-color
    if color.luma(background-color).components().at(0) < color-lightness-threshold {
      foreground-color = white
    } else {
      foreground-color = black
    }
  }
  let cell-content = if content-drawer == none {
    text(fill: foreground-color, font: font, if value == none { "" } else {
      [#text-processor(str(count))]
    })
  } else {
    content-drawer(value, count, row, col, additional-info)
  }
  if additional-info.marked {
    cell-content = marker(cell-content, foreground-color, background-color)
  }
  grid.cell(stroke: stroke, fill: background-color, align(center + horizon, block(width: cell-size, height: cell-size, {
    cell-content
  })))
}

// Draw one classical puzzle cell.
// = Arguments:
// == `value`
// The board entry being drawn.
// == `row` and `col`
// The cell coordinates within the puzzle grid.
// == `additional-info`
// A dictionary containing the puzzle `width` and `height`.
// == `cell-size`
// The width and height of the rendered cell.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `content-map`
// A map or callback map from board values to displayed content. The special
// string `"fill"` fills the whole cell with the resolved color.
// == `content-drawer`
// An optional callback that receives `(value, row, col, additional-info)` and
// returns the cell content directly instead of using `content-map`.
// == `colorizer`
// A callback that post-processes non-filled content. It receives `(content,
// color, value)`.
// == `default-background`
// The background used for non-filled cells.
// == `weak-stroke` and `strong-stroke`
// Control the regular grid lines and the emphasized 5-cell separators.
// == `show-solution`
// If `false`, cell contents are hidden even though the grid is still rendered.
#let classical-cell-drawer(
  value,
  row,
  col,
  additional-info,
  cell-size: 1em,
  color-map: ("default": black),
  content-map: (
    "0": scale(200%, text(baseline: -0.07em, sym.times)),
    "1": "fill",
    "default": none,
  ),
  content-drawer: none,
  colorizer: (content, color, value) => {
    set text(fill: color)
    content
  },
  default-background: white,
  weak-stroke: 0.5pt + black,
  strong-stroke: 1.5pt + black,
  show-solution: false,
) = {
  let stroke = (left: weak-stroke, right: weak-stroke, top: weak-stroke, bottom: weak-stroke)
  stroke.left = if ((col == 0) or (calc.rem(col, 5) == 0)) {
    strong-stroke
  } else {
    weak-stroke
  }
  stroke.top = if ((row == 0) or (calc.rem(row, 5) == 0)) {
    strong-stroke
  } else {
    weak-stroke
  }
  stroke.right = if (col == additional-info.width - 1) {
    strong-stroke
  } else {
    weak-stroke
  }
  stroke.bottom = if (row == additional-info.height - 1) {
    strong-stroke
  } else {
    weak-stroke
  }
  let content = if content-drawer == none {
    get-value(value, content-map, default: none)
  } else {
    content-drawer(value, row, col, additional-info)
  }
  let color = get-value(value, color-map, default: black)
  if type(color) == function {
    color = color(value, none)
  }
  if colorizer != none and content != "fill" {
    content = colorizer(content, color, value)
  }
  if not show-solution or value == none {
    content = none
  }
  if content == "fill" {
    grid.cell(block(height: cell-size, width: cell-size), fill: color, stroke: stroke)
  } else {
    grid.cell(
      block(height: cell-size, width: cell-size, inset: 0pt, above: 0pt, below: 0pt, align(center + horizon, content)),
      fill: default-background,
      stroke: stroke,
    )
  }
}

// Draw one modern column clue cell.
// = Arguments:
// == `value` and `count`
// The clue entry to display.
// == `row` and `col`
// The coordinates of this clue cell within the clue area.
// == `additional-info`
// A dictionary containing the puzzle `width`, `height`, and `marked` status.
// == `cell-size`
// The width and height of the clue cell.
// == `text-processor`
// A callback applied to the displayed `count` before it is placed in the cell.
// == `marker`
// A callback that adds a marker to the clue cell when `additional-info.marked` is true.
// It receives the cell content, the resolved foreground color, and the resolved background
// color, and should return the modified, marked-up content.
// == `content-drawer`
// An optional callback that receives `(value, count, row, col, additional-info)`
// and returns the clue content directly instead of using `text-processor`.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `coloring`, `omit-default-background`, and `color-lightness-threshold`
// Control whether resolved colors affect the clue background and when the text
// color should switch for contrast.
// == `zebra-even` and `zebra-odd`
// Alternating background colors used when no value-based background is applied.
// == `font`
// The font used to render clue text.
#let modern-column-cell-drawer(
  value,
  count,
  row,
  col,
  additional-info: (:),
  cell-size: 1em,
  text-processor: value => [#value],
  marker: (contents, foreground-color, background-color) => [#contents#place(center + horizon, rotate(-45deg, line(
      length: 100%,
      stroke: (paint: foreground-color, cap: "round"),
    )))],
  content-drawer: none,
  color-map: (:),
  coloring: "background",
  omit-default-background: true,
  color-lightness-threshold: 50%,
  zebra-even: luma(90%),
  zebra-odd: white,
  font: "Libertinus Serif",
) = {
  let zebra-fill = if (calc.rem(col, 2) == 0) {
    zebra-even
  } else {
    zebra-odd
  }
  let radius = if (row == 0) { (top: 0.2em) } else { (:) }
  let background-color = zebra-fill
  let foreground-color = get-value(value, color-map, default: black)
  if type(foreground-color) == function {
    foreground-color = foreground-color(value, count)
  }
  if type(background-color) == function {
    background-color = background-color(value, count)
  }
  if (
    coloring == "background"
      and value != none
      and (not omit-default-background or foreground-color != get-value("default", color-map, default: black))
  ) {
    background-color = foreground-color
    if color.luma(background-color).components().at(0) < color-lightness-threshold {
      foreground-color = white
    } else {
      foreground-color = black
    }
  }
  let cell-content = if content-drawer == none {
    text(fill: foreground-color, font: font, if value == none { "" } else {
      [#text-processor(str(count))]
    })
  } else {
    content-drawer(value, count, row, col, additional-info)
  }
  if additional-info.marked {
    cell-content = marker(cell-content, foreground-color, background-color)
  }
  grid.cell(align(center + horizon, block(fill: background-color, width: cell-size, height: cell-size, radius: radius, {
    cell-content
  })))
}

// Draw one modern row clue cell.
// = Arguments:
// == `value` and `count`
// The clue entry to display.
// == `row` and `col`
// The coordinates of this clue cell within the clue area.
// == `additional-info`
// A dictionary containing the puzzle `width`, `height`, and `marked` status.
// == `cell-size`
// The width and height of the clue cell.
// == `text-processor`
// A callback applied to the displayed `count` before it is placed in the cell.
// == `marker`
// A callback that adds a marker to the clue cell when `additional-info.marked` is true.
// It receives the cell content, the resolved foreground color, and the resolved background
// color, and should return the modified, marked-up content.
// == `content-drawer`
// An optional callback that receives `(value, count, row, col, additional-info)`
// and returns the clue content directly instead of using `text-processor`.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `coloring`, `omit-default-background`, and `color-lightness-threshold`
// Control whether resolved colors affect the clue background and when the text
// color should switch for contrast.
// == `zebra-even` and `zebra-odd`
// Alternating background colors used when no value-based background is applied.
// == `font`
// The font used to render clue text.
 #let modern-row-cell-drawer(
  value,
  count,
  row,
  col,
  additional-info: (:),
  cell-size: 1em,
  text-processor: value => [#value],
  marker: (contents, foreground-color, background-color) => [#contents#place(center + horizon, rotate(-45deg, line(
      length: 100%,
      stroke: (paint: foreground-color, cap: "round"),
    )))],
  content-drawer: none,
  color-map: (:),
  coloring: "background",
  omit-default-background: true,
  color-lightness-threshold: 50%,
  zebra-even: luma(90%),
  zebra-odd: white,
  font: "Libertinus Serif",
) = {
  let zebra-fill = if (calc.rem(row, 2) == 0) {
    zebra-even
  } else {
    zebra-odd
  }
  let radius = if (col == 0) { (left: 0.2em) } else { (:) }
  let background-color = zebra-fill
  let foreground-color = get-value(value, color-map, default: black)
  if type(foreground-color) == function {
    foreground-color = foreground-color(value, count)
  }
  if type(background-color) == function {
    background-color = background-color(value, count)
  }
  if (
    coloring == "background"
      and value != none
      and (not omit-default-background or foreground-color != get-value("default", color-map, default: black))
  ) {
    background-color = foreground-color
    if color.luma(background-color).components().at(0) < color-lightness-threshold {
      foreground-color = white
    } else {
      foreground-color = black
    }
  }
  let cell-content = if content-drawer == none {
    text(fill: foreground-color, font:font, if value == none { "" } else {
      [#text-processor(str(count))]
    })
  } else {
    content-drawer(value, count, row, col, additional-info)
  }
  if additional-info.marked {
    cell-content = marker(cell-content, foreground-color, background-color)
  }
  grid.cell(align(center + horizon, block(fill: background-color, width: cell-size, height: cell-size, radius: radius, {
    cell-content
  })))
}

// Draw one modern puzzle cell with rounded blocks and emphasized 5-cell guides.
// = Arguments:
// == `value`
// The board entry being drawn.
// == `row` and `col`
// The cell coordinates within the puzzle grid.
// == `additional-info`
// A dictionary containing the puzzle `width` and `height`.
// == `strong-stroke` and `background-color`
// Control the emphasized frame around 5-cell blocks and the base background of
// the outer rounded tile.
// == `color-map`
// A map or callback map used to resolve the color associated with `value`.
// == `content-map`
// A map or callback map from board values to displayed content. The special
// string `"fill"` fills the inner rounded block with the resolved color.
// == `content-drawer`
// An optional callback that receives `(value, row, col, additional-info)` and
// returns the cell content directly instead of using `content-map`.
// == `colorizer`
// A callback that post-processes non-filled content. It receives `(content,
// color, value)`.
// == `default-background`
// The background used for the inner block when content is not `"fill"`.
// == `cell-size`
// The width and height of the rendered cell.
// == `show-solution`
// If `false`, cell contents are hidden even though the grid is still rendered.
#let modern-cell-drawer(
  value,
  row,
  col,
  additional-info,
  strong-stroke: 2pt + green,
  background-color: luma(50%),
  color-map: ("default": black),
  content-map: (
    "0": block(height: 100%, width: 100%, rotate(-45deg, [
      #let cross-stroke = (paint: orange, thickness: 2pt, cap: "round")
      #place(center + horizon, line(length: 0.4em, stroke: cross-stroke))
      #place(center + horizon, line(length: 0.4em, angle: 90deg, stroke: cross-stroke))
    ])),
    "default": "fill",
  ),
  content-drawer: none,
  colorizer: (content, color, value) => {
    set text(fill: color)
    content
  },
  default-background: white,
  cell-size: 1em,
  show-solution: false,
) = {
  let stroke = (left: none, right: none, top: none, bottom: none)
  stroke.left = if (calc.rem(col, 5) == 0) {
    if (col != 0) {
      strong-stroke
    } else {
      2pt + background-color
    }
  } else {
    none
  }
  stroke.top = if (calc.rem(row, 5) == 0) {
    if (row != 0) {
      strong-stroke
    } else {
      2pt + background-color
    }
  } else {
    none
  }
  stroke.right = if (col == additional-info.width - 1) {
    2pt + background-color
  } else {
    none
  }
  stroke.bottom = if (row == additional-info.height - 1) {
    2pt + background-color
  } else {
    none
  }
  let radius = if (row == 0) {
    if (col == 0) {
      (top-left: 0.2em)
    } else if (col == additional-info.width - 1) {
      (top-right: 0.2em)
    } else {
      (:)
    }
  } else if ((col == 0) and (row == additional-info.height - 1)) {
    (bottom-left: 0.2em)
  } else if ((col == additional-info.width - 1) and (row == additional-info.height - 1)) {
    (bottom-right: 0.2em)
  } else {
    (:)
  }
  grid.cell(stroke: none, block(width: cell-size, height: cell-size, [
    #place(center + horizon, block(stroke: stroke, radius: radius, fill: background-color, height: 100%, width: 100%, {
      let content = if content-drawer == none {
        get-value(value, content-map, default: none)
      } else {
        content-drawer(value, row, col, additional-info)
      }
      let color = get-value(value, color-map, default: black)
      if type(color) == function {
        color = color(value, none)
      }
      if colorizer != none and content != "fill" {
        content = colorizer(content, color, value)
      }
      if not show-solution or value == none{
        content = none
      }
      place(center + horizon, if content == "fill" {
        block(radius: 0.15em, width: 88%, height: 88%, fill: color)
      } else {
        block(radius: 0.15em, width: 88%, height: 88%, fill: default-background, clip: true)[#align(
          center + horizon,
          content,
        )]
      })
    }))]))
}

// Shared default color mapping for both board styles.
#let default-color-map = (
  "r": red,
  "g": green,
  "b": blue,
  "y": yellow,
  "B": black,
  "p": purple,
  "o": orange,
  "gr": gray,
  "a": aqua,
  "t": teal,
  "e": eastern,
  "f": fuchsia,
  "m": maroon,
  "ol": olive,
  "l": lime,
  "w": white,
  "s": silver,
  "default": black,
)

// Render a puzzle using the classical square-grid style.
// = Arguments:
// For `board-matrix`, `cell-size`, `corner-cell-drawer`, `column-clues`, `row-clues`, `marked-column-clues`, `marked-row-clues`, `hide-clues`, `show-guide-numbers`, `guide-number-sides`, `guide-number-step`, and `guide-number-drawer`, see `draw-board`.
//
// For `cell-size`, `show-solution`, `color-map`, `content-map`, `cell-content-drawer`, `cell-colorizer`, `cell-default-background`, `weak-stroke`, and `strong-stroke`, see `classical-cell-drawer`.
//
// For`clue-text-processor`, `clue-content-drawer`, `clue-coloring`, `clue-omit-default-background`, `clue-default-background`, `clue-color-lightness-threshold`, `font`, `weak-stroke`, `strong-stroke`, `clue-close-opposite-strokes`, `clue-draw-parallel-weak-strokes`, `clue-draw-parallel-strong-strokes`, and `clue-draw-perpendicular-strokes`
// see `classical-column-cell-drawer` and `classical-row-cell-drawer`.
// == `text-size`
// Sets the document text size before rendering the board.
#let classical-board = (
  board-matrix,
  corner-cell-drawer: (height, width) => grid.cell(rowspan: height, colspan: width, ""),
  column-clues: none,
  row-clues: none,
  hide-clues: false,
  marked-column-clues: none,
  marked-row-clues: none,
  cell-size: 1em,
  text-size: 1em,
  show-solution: false,
  weak-stroke: (thickness: 0.25pt, paint: black, dash: "solid"),
  strong-stroke: (thickness: 1pt, paint: black, dash: "solid"),
  font: "Libertinus Serif",
  content-map: (
    "0": scale(200%, text(baseline: -0.07em, sym.times)),
    "default": "fill",
  ),
  cell-content-drawer: none,
  cell-colorizer: (content, color, value) => {
    set text(fill: color)
    content
  },
  cell-default-background: white,
  color-map: default-color-map,
  show-guide-numbers: false,
  guide-number-sides: ("right", "bottom"),
  guide-number-step: 5,
  guide-number-drawer: (value, is-row, side) => {
    align(center + horizon, text(0.75em, str(value), fill: gray))
  },
  clue-content-drawer: none,
  clue-text-processor: value => [#value],
  clue-coloring: "background",
  clue-omit-default-background: true,
  clue-default-background: white,
  clue-color-lightness-threshold: 50%,
  clue-close-opposite-strokes: true,
  clue-draw-parallel-weak-strokes: false,
  clue-draw-parallel-strong-strokes: true,
  clue-draw-perpendicular-strokes: false,
  display-mask: none,
) => {
  set text(text-size, font: font)
  draw-board(
    board-matrix,
    classical-cell-drawer.with(
      cell-size: cell-size,
      show-solution: show-solution,
      color-map: color-map,
      content-map: content-map,
      content-drawer: cell-content-drawer,
      weak-stroke: weak-stroke,
      strong-stroke: strong-stroke,
      colorizer: cell-colorizer,
      default-background: cell-default-background,
    ),
    classical-column-cell-drawer.with(
      cell-size: cell-size,
      text-processor: clue-text-processor,
      color-map: color-map,
      coloring: clue-coloring,
      omit-default-background: clue-omit-default-background,
      default-background: clue-default-background,
      color-lightness-threshold: clue-color-lightness-threshold,
      font: font,
      weak-stroke: weak-stroke,
      strong-stroke: strong-stroke,
      close-opposite-strokes: clue-close-opposite-strokes,
      draw-parallel-weak-strokes: clue-draw-parallel-weak-strokes,
      draw-parallel-strong-strokes: clue-draw-parallel-strong-strokes,
      draw-perpendicular-strokes: clue-draw-perpendicular-strokes,
      content-drawer: clue-content-drawer,
    ),
    classical-row-cell-drawer.with(
      cell-size: cell-size,
      text-processor: clue-text-processor,
      color-map: color-map,
      coloring: clue-coloring,
      omit-default-background: clue-omit-default-background,
      default-background: clue-default-background,
      color-lightness-threshold: clue-color-lightness-threshold,
      font: font,
      weak-stroke: weak-stroke,
      strong-stroke: strong-stroke,
      close-opposite-strokes: clue-close-opposite-strokes,
      draw-parallel-weak-strokes: clue-draw-parallel-weak-strokes,
      draw-parallel-strong-strokes: clue-draw-parallel-strong-strokes,
      draw-perpendicular-strokes: clue-draw-perpendicular-strokes,
      content-drawer: clue-content-drawer,
    ),
    column-clues: column-clues,
    row-clues: row-clues,
    marked-column-clues: marked-column-clues,
    marked-row-clues: marked-row-clues,
    hide-clues: hide-clues,
    display-mask: display-mask,
    corner-cell-drawer: corner-cell-drawer,
    cell-size: cell-size,
    show-guide-numbers: show-guide-numbers,
    guide-number-sides: guide-number-sides,
    guide-number-step: guide-number-step,
    guide-number-drawer: guide-number-drawer,
  )
};

// Render a puzzle using the modern rounded style.
// = Arguments:
// For `board-matrix`, `cell-size`, `corner-cell-drawer`, `column-clues`, `row-clues`, `marked-column-clues`, `marked-row-clues`, `hide-clues`, `show-guide-numbers`, `guide-number-sides`, `guide-number-step`, and `guide-number-drawer`, see `draw-board`.
//
// For, `show-solution`, `cell-strong-stroke`, `cell-background-color`, `color-map`, `content-map`, `cell-content-drawer`, `cell-colorizer`, and `cell-default-background`, see `modern-cell-drawer`.
//
// For `clue-text-processor`, `clue-content-drawer`, `clue-zebra-even`, `clue-zebra-odd`, `clue-coloring`, `clue-omit-default-background`, `clue-color-lightness-threshold`, and `font`, see `modern-column-cell-drawer` and `modern-row-cell-drawer`.
// == `text-size`
// Sets the document text size before rendering the board.
#let modern-board = (
  board-matrix,
  corner-cell-drawer: (height, width) => grid.cell(rowspan: height, colspan: width, ""),
  column-clues: none,
  row-clues: none,
  hide-clues: false,
  marked-column-clues: none,
  marked-row-clues: none,
  cell-size: 1em,
  text-size: 1em,
  show-solution: false,
  cell-strong-stroke: 0.2em + green,
  cell-background-color: luma(50%),
  font: "DejaVu Sans Mono",
  content-map: (
    "0": block(height: 100%, width: 100%, rotate(-45deg, [
      #let cross-stroke = (paint: orange, thickness: 2pt, cap: "round")
      #place(center + horizon, line(length: 0.4em, stroke: cross-stroke))
      #place(center + horizon, line(length: 0.4em, angle: 90deg, stroke: cross-stroke))
    ])),
    "default": "fill",
  ),
  cell-content-drawer: none,
  cell-colorizer: (content, color, value) => {
    set text(fill: color)
    content
  },
  cell-default-background: white,
  color-map: default-color-map,
  show-guide-numbers: false,
  guide-number-sides: ("right", "bottom"),
  guide-number-step: 5,
  guide-number-drawer: (value, is-row, side) => {
    align(center + horizon, text(0.75em, str(value), fill: gray))
  },
  clue-content-drawer: none,
  clue-text-processor: value => text(0.7em, value),
  clue-zebra-even: luma(90%),
  clue-zebra-odd: white,
  clue-coloring: "background",
  clue-omit-default-background: true,
  clue-color-lightness-threshold: 50%,
  display-mask: none,
) => {
  set text(text-size, font: font)
  draw-board(
    board-matrix,
    modern-cell-drawer.with(
      cell-size: cell-size,
      show-solution: show-solution,
      strong-stroke: cell-strong-stroke,
      background-color: cell-background-color,
      color-map: color-map,
      content-map: content-map,
      content-drawer: cell-content-drawer,
      colorizer: cell-colorizer,
      default-background: cell-default-background,
    ),
    modern-column-cell-drawer.with(
      cell-size: cell-size,
      text-processor: clue-text-processor,
      color-map: color-map,
      coloring: clue-coloring,
      omit-default-background: clue-omit-default-background,
      color-lightness-threshold: clue-color-lightness-threshold,
      zebra-even: clue-zebra-even,
      zebra-odd: clue-zebra-odd,
      content-drawer: clue-content-drawer,
      font: font,
    ),
    modern-row-cell-drawer.with(
      cell-size: cell-size,
      text-processor: clue-text-processor,
      color-map: color-map,
      coloring: clue-coloring,
      omit-default-background: clue-omit-default-background,
      color-lightness-threshold: clue-color-lightness-threshold,
      zebra-even: clue-zebra-even,
      zebra-odd: clue-zebra-odd,
      content-drawer: clue-content-drawer,
      font: font,
    ),
    column-clues: column-clues,
    row-clues: row-clues,
    marked-column-clues: marked-column-clues,
    marked-row-clues: marked-row-clues,
    hide-clues: hide-clues,
    display-mask: display-mask,
    corner-cell-drawer: corner-cell-drawer,
    cell-size: cell-size,
    show-guide-numbers: show-guide-numbers,
    guide-number-sides: guide-number-sides,
    guide-number-step: guide-number-step,
    guide-number-drawer: guide-number-drawer,
  )
};
