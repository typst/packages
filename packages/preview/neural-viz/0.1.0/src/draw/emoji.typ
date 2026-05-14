#import "@preview/cetz:0.4.2": draw
#import "../internal/geometry.typ": node-edge

#let draw-node-emoji(
  node,
  kind: "lock-closed",
  emoji: none,
  place: "top",
  gap: 0.55,
  shift: (0.0, 0.0),
  size: 0.95em,
  color: none,
  use-outer: true,
  key-state: none,
  state-text: none,
  state-size: 0.42em,
  state-gap: 0.32,
  state-position: "below",
) = {
  let p = if place == "over" { "top" } else if place == "under" { "bottom" } else { place }
  let symbol = if emoji != none {
    emoji
  } else if kind == "lock-open" {
    [UNLOCK]
  } else if kind == "key" {
    [KEY]
  } else {
    [LOCK]
  }

  let status = if state-text != none {
    state-text
  } else if key-state == "encrypted" {
    [LOCK]
  } else if key-state == "decrypted" {
    [UNLOCK]
  } else {
    none
  }

  let x = if p == "left" {
    node-edge(node, side: "left", outer: use-outer) - gap
  } else if p == "right" {
    node-edge(node, side: "right", outer: use-outer) + gap
  } else {
    node.cx
  }

  let y = if p == "top" {
    node-edge(node, side: "top", outer: use-outer) + gap
  } else if p == "bottom" {
    node-edge(node, side: "bottom", outer: use-outer) - gap
  } else {
    node.cy
  }

  let px = x + shift.at(0)
  let py = y + shift.at(1)
  draw.content(
    (px, py),
    text(size: size, fill: if color == none { black } else { color })[#symbol],
  )

  if status != none {
    let sy = if state-position == "above" { py + state-gap } else { py - state-gap }
    draw.content(
      (px, sy),
      text(size: state-size, fill: rgb("#555555"))[#status],
    )
  }
}
