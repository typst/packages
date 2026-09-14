#import "@preview/lets-go:0.1.0": go-board, go-board-9, go-board-19

#set page(margin: 1cm, height: auto)

#align(center, {
  box(stroke: black, width: 40%, go-board-9(stones: ("ab", "ac", "ef")))
  h(1cm)
  box(stroke: black, width: 40%, go-board(
    size: 5,
    // Stones stay positioned from the top left corner
    stones: ((position: "ac", color: "white"), (position: "bb", skip-numbering: true), "cc", "ed", "ec", "dc"),
    marks: ("db",),
    mark-radius: 5%,
    open-edges: ("left", "bottom"),
    open-edges-added-length: 7%,
    padding: 2mm,
    board-fill: luma(90%),
    black-stone: move(dx: -50%, dy: -50%, circle(
      width: 100%,
      fill: black,
      stroke: white + 0.2pt,
    )),
    white-stone: move(dx: -50%, dy: -50%, circle(
      width: 100%,
      fill: white,
      stroke: black + 0.2pt,
    )),
    stone-diameter-ratio: 0.8,
    add-played-number: true,
  ))
})

#figure(
  {
    set text(size: 15pt, weight: "semibold")
    block(width: 70%, go-board(
      size: 10,
      stones: ("cc", "dd", "dc", "ed", "be", "dg", "fb", "hd"),
      add-played-number: true,
      open-edges: ("right", "bottom"),
      marks: ("dd", "jd"),
    ))
  },
  caption: [Example joseki],
  kind: "goban",
  supplement: [Goban],
)
