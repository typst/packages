#import "consts.typ": *
#import "core/draw/note.typ"

#let SIDES = (
  "left",
  "right",
  "over",
  "across"
)

#let SHAPES = (
  "default",
  "rect",
  "hex"
)

#let _note(
  side,
  content,
  pos: none,
  color: COL-NOTE,
  shape: "default",
  aligned: false,
  allow-overlap: true
) = {
  if side == "over" {
    if pos == none {
      panic("Pos cannot be none with side 'over'")
    }
  }
  if aligned {
    if side != "over" {
      panic("Aligned notes can only be over a participant (got side '" + side + "')")
    }
  }
  if color == auto {
    color = COL-NOTE
  }
  return ((
    type: "note",
    draw: note.render,
    side: side,
    content: content,
    pos: pos,
    color: color,
    shape: shape,
    aligned: aligned,
    aligned-with: none,
    allow-overlap: allow-overlap
  ),)
}
