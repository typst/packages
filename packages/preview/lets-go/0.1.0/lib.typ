#let input-position-to-coords(position) = {
  if type(position) == array {
    return (
      row: position.at(0),
      col: position.at(1),
    )
  }

  let m = position.match(regex("([ABCDEFGHIJKLMNOPQRSTabcdefghijklmnopqrst])(\d{1,2})"))
  if m != none {
    let A_UNICODE = 65
    let ZERO_UNICODE = 50
    return (
      row: m.captures.at(0).codepoints().at(0).to-unicode() - A_UNICODE,
      col: int(m.captures.at(1)) - 1,
    )
  }

  let m = position.match(regex("([abcdefghijklmnopqrst])([abcdefghijklmnopqrst])"))
  if m != none {
    let a_unicode = 97
    return (
      row: m.captures.at(0).to-unicode() - a_unicode,
      col: m.captures.at(1).to-unicode() - a_unicode,
    )
  }

  return none
}

#let draw-stone(highlight-color: none, shadow-color: none) = {
  move(
    dx: -50%,
    dy: -50%,
    circle(
      width: 100%,
      fill: gradient.radial(center: (40%, 40%), highlight-color, shadow-color),
    ),
  )
}
#let black-stone = draw-stone(highlight-color: luma(130), shadow-color: luma(40))
#let white-stone = draw-stone(highlight-color: luma(100%), shadow-color: luma(70%))


/// This is the main function that draws a go board
///
/// - stones (): List of stones to place
/// - size (int): Board size
/// - marks (): Reference marks to draw
/// - padding (): Border padding
/// - board-fill (): Background fill
/// - mark-radius (): Reference marks radius
/// - stone-diameter-ratio (): Ratio of stone diameter to grid size
/// - black-stone (): Black stone to use
/// - white-stone (): White stone to use
/// - open-edges (): Which edges to extend a bit to mark that the board extends there
/// - open-edges-added-length (): Proportion to extend the edges
/// - add-played-number (): Add numbers showing the play order
/// -> content
#let go-board(
  stones: (),
  size: 13,
  marks: (),
  padding: 0mm,
  board-fill: orange.lighten(70%),
  mark-radius: 2%,
  stone-diameter-ratio: 0.75,
  black-stone: black-stone,
  white-stone: white-stone,
  open-edges: (),
  open-edges-added-length: 4%,
  add-played-number: false,
) = {
  let ratio-line-board-len = (100% - 2 * padding) * (size - 1) / size
  let edge-padding = padding + 0.5 / (size - 1) * ratio-line-board-len
  let stone-diameter = stone-diameter-ratio / size * 100%

  black-stone = scale(stone-diameter-ratio / size * 100%, origin: top + left, black-stone)
  white-stone = scale(stone-diameter-ratio / size * 100%, origin: top + left, white-stone)

  let open-edges-paddings = (
    top: 0%,
    right: 0%,
    bottom: 0%,
    left: 0%,
  )

  for dir in open-edges-paddings.keys() {
    if open-edges.contains(dir) {
      open-edges-paddings.insert(dir, open-edges-added-length)
    }
  }

  square(
    fill: board-fill,
    stroke: none,
    inset: 0%,
    outset: 0%,
    width: 100%,
    {
      for p in range(size) {
        place(
          dy: edge-padding + p / (size - 1) * ratio-line-board-len,
          dx: edge-padding - open-edges-paddings.at("left"),
          line(length: ratio-line-board-len + open-edges-paddings.at("left") + open-edges-paddings.at("right")),
        )
      }

      for p in range(size) {
        place(
          dx: edge-padding + p / (size - 1) * ratio-line-board-len,
          dy: edge-padding - open-edges-paddings.at("top"),
          line(
            angle: 90deg,
            length: ratio-line-board-len + open-edges-paddings.at("top") + open-edges-paddings.at("bottom"),
          ),
        )
      }

      for mark in marks {
        let coords = input-position-to-coords(mark)
        place(
          dx: edge-padding + (coords.col) * ratio-line-board-len / (size - 1) - mark-radius / 2,
          dy: edge-padding + (coords.row) * ratio-line-board-len / (size - 1) - mark-radius / 2,
          circle(
            width: mark-radius,
            fill: black,
            stroke: none,
          ),
        )
      }

      let next-color = "black"
      let next-number = 1
      for stone in stones {
        let is-dict = type(stone) == dictionary
        let is-black = next-color == "black"
        let skip-numbering = false

        let coords = input-position-to-coords(if is-dict and "position" in stone { stone.at("position") } else {
          stone
        })

        if is-dict and "skip-numbering" in stone { skip-numbering = true }
        if is-dict and "color" in stone {
          is-black = stone.at("color") == "black"
        }

        let dx = edge-padding + (coords.col) * ratio-line-board-len / (size - 1)
        let dy = edge-padding + (coords.row) * ratio-line-board-len / (size - 1)
        place(
          dx: dx,
          dy: dy,
          if is-black {
            black-stone
          } else { white-stone },
        )
        if add-played-number and not skip-numbering {
          place(
            dx: dx,
            dy: dy,
            // Hacky, I don't know how to center it better
            move(dx: -5%, dy: -5%, box(width: 10%, height: 10%, align(horizon + center, text(
              fill: if is-black {
                white
              } else { black },
            )[#next-number]))),
          )
        }
        if not skip-numbering {
          next-number = next-number + 1
        }
        next-color = if is-black { "white" } else { "black" }
      }
    },
  )
}


#let go-board-19 = go-board.with(
  marks: ((3, 3), (3, 9), (3, 15), (9, 3), (9, 9), (9, 15), (15, 3), (15, 9), (15, 15)),
  size: 19,
)

#let go-board-13 = go-board.with(
  size: 13,
  marks: ((3, 3), (9, 3), (3, 9), (9, 9), (6, 6)),
)

#let go-board-9 = go-board.with(
  size: 9,
  marks: ((2, 2), (6, 2), (2, 6), (6, 6), (4, 4)),
)

