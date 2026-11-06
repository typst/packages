#import "@preview/cetz:0.4.2": draw
#import "../internal/text.typ": fit-lines
#import "../internal/geometry.typ": chars-cap, node-size, node-edge

#let draw-node(node) = {
  import draw: *

  let (nw, nh) = node-size(node)
  let max-chars = chars-cap(nw)
  let t = fit-lines(node.title, max-chars: max-chars, max-lines: node.wrap-lines)
  let s = fit-lines(node.subtitle, max-chars: max-chars, max-lines: node.wrap-lines)
  let g = fit-lines(node.legend, max-chars: chars-cap(nw + 0.6), max-lines: node.wrap-lines)

  let draw-inner-text(x, y) = {
    if node.subtitle == none {
      content((x, y), align(center)[#text(size: node.title-size)[#t]])
    } else {
      content((x, y + 0.26), align(center)[#text(size: node.title-size)[#t]])
      content((x, y - 0.36), align(center)[#text(size: node.subtitle-size, fill: rgb("#333333"))[#s]])
    }
  }

  let draw-legend(x, y) = {
    if node.legend != none {
      let y-leg = if node.kind == "stack" {
        if node.legend-position == "top" {
          node-edge(node, side: "top", outer: true) + 0.55
        } else {
          node-edge(node, side: "bottom", outer: true) - 0.55
        }
      } else if node.legend-position == "top" {
        y + nh / 2 + 0.55
      } else {
        y - nh / 2 - 0.55
      }
      content((x, y-leg), align(center)[#text(size: node.legend-size, fill: rgb("#555555"))[#g]])
    }
  }

  let draw-image(x, y) = {
    if "image" in node and node.image != none {
      content((x, y), align(center)[#node.image])
    }
  }

  if node.kind == "stack" {
    for i in range(node.n) {
      let j = node.n - 1 - i
      let off = j * node.shift
      let x = node.cx + off
      let y = node.cy + off
      rect(
        (x - node.w / 2, y - node.h / 2),
        (x + node.w / 2, y + node.h / 2),
        fill: node.color,
        stroke: (paint: black, thickness: 0.5pt),
      )

      // For image datasets, draw the same fitted image on each stack layer.
      draw-image(x, y)
    }

    if node.title-position == "below" {
      content((node.cx, node.cy - node.h / 2 - 0.55), align(center)[#text(size: node.title-size)[#t]])
      if node.subtitle != none {
        content((node.cx, node.cy - node.h / 2 - 0.95), align(center)[#text(size: node.subtitle-size, fill: rgb("#333333"))[#s]])
      }
    } else {
      draw-inner-text(node.cx, node.cy)
    }
    draw-legend(node.cx, node.cy)
  } else if node.kind == "image" {
    rect(
      (node.cx - node.w / 2, node.cy - node.h / 2),
      (node.cx + node.w / 2, node.cy + node.h / 2),
      fill: node.color,
      stroke: (paint: black, thickness: 0.65pt),
    )
    draw-image(node.cx, node.cy)
    if node.title-position == "below" {
      content((node.cx, node.cy - node.h / 2 - 0.55), align(center)[#text(size: node.title-size)[#t]])
      if node.subtitle != none {
        content((node.cx, node.cy - node.h / 2 - 0.95), align(center)[#text(size: node.subtitle-size, fill: rgb("#333333"))[#s]])
      }
    } else {
      draw-inner-text(node.cx, node.cy)
    }
    draw-legend(node.cx, node.cy)
  } else if node.kind == "trapezoid" {
    let lx = node.cx - node.w / 2
    let rx = node.cx + node.w / 2
    line(
      (lx, node.cy - node.h-left), (rx, node.cy - node.h-right),
      (rx, node.cy + node.h-right), (lx, node.cy + node.h-left),
      close: true,
      fill: node.color,
      stroke: (paint: black, thickness: 0.65pt),
    )
    if node.subtitle == none {
      content((node.cx, node.cy), align(center)[#text(size: node.title-size)[*#t*]])
    } else {
      content((node.cx, node.cy + 0.26), align(center)[#text(size: node.title-size)[*#t*]])
      content((node.cx, node.cy - 0.36), align(center)[#text(size: node.subtitle-size, fill: rgb("#333333"))[#s]])
    }
    draw-legend(node.cx, node.cy)
  } else {
    rect(
      (node.cx - node.w / 2, node.cy - node.h / 2),
      (node.cx + node.w / 2, node.cy + node.h / 2),
      fill: node.color,
      stroke: (paint: black, thickness: 0.65pt),
    )
    if node.subtitle == none {
      content((node.cx, node.cy), align(center)[#text(size: node.title-size)[*#t*]])
    } else {
      content((node.cx, node.cy + 0.26), align(center)[#text(size: node.title-size)[*#t*]])
      content((node.cx, node.cy - 0.36), align(center)[#text(size: node.subtitle-size)[#s]])
    }
    draw-legend(node.cx, node.cy)
  }
}
