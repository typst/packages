#import "core/draw/sequence.typ"

#let _seq(
  p1,
  p2,
  comment: none,
  comment-align: "left",
  dashed: false,
  start-tip: "",
  end-tip: ">",
  color: black,
  flip: false,
  enable-dst: false,
  create-dst: false,
  disable-dst: false,
  destroy-dst: false,
  disable-src: false,
  destroy-src: false,
  lifeline-style: auto,
  slant: none,
  outer-lifeline-connect: false
) = {
  return ((
    type: "seq",
    draw: sequence.render,
    p1: p1,
    p2: p2,
    comment: comment,
    comment-align: comment-align,
    dashed: dashed,
    start-tip: start-tip,
    end-tip: end-tip,
    color: color,
    flip: flip,
    enable-dst: enable-dst,
    create-dst: create-dst,
    disable-dst: disable-dst,
    destroy-dst: destroy-dst,
    disable-src: disable-src,
    destroy-src: destroy-src,
    lifeline-style: lifeline-style,
    slant: slant,
    outer-lifeline-connect: outer-lifeline-connect,
    linked-notes: ()
  ),)
}

#let _ret(comment: none) = {
  return ((
    type: "ret",
    comment: comment
  ),)
}
