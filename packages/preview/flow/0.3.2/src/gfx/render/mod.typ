// Actual implementations of individual rendered icons.

#import "segment.typ"
#import "../util.typ": *
#import "../draw.typ": *

#let empty(
  // argument is simply ignored
  // since it is always just a shallow outline
  invert: true,
  ..args,
) = icon(
  invert: true,
  key: "empty",
  ..args,
  () => {
    rect((-0.125, -0.125), (1.125, 1.125), radius: 0.25)
  },
)

#let urgent = icon.with(
  key: "urgent",
  () => {
    let offset = 0.2

    for (offset, y-scale) in (
      ((x: -offset, y: 0), 1),
      ((x: offset, y: 1), -1),
    ) {
      line(
        (0.5 + offset.x, 1 * y-scale + offset.y),
        (0.5 + offset.x, 0.375 * y-scale + offset.y),
      )
      circle(
        (0.5 + offset.x, 0.05 * y-scale + offset.y),
        radius: 0.05,
      )
    }
  },
)

#let progress = icon.with(
  key: "progress",
  () => {
    let bendness = (x: 0.25, y: 0.5)
    let offset = 0.25

    for shift in (-offset, offset) {
      line(
        (0.5 - bendness.x + shift, 0.5 + bendness.y),
        (0.5 + bendness.x + shift, 0.5),
        (0.5 - bendness.x + shift, 0.5 - bendness.y),
        fill: none,
      )
    }
  },
)

#let pause = icon.with(
  key: "pause",
  () => {
    circle((0.5, 0.8), radius: 0.1)
    circle((0.5, 0.2), radius: 0.1)
  },
)

#let block = icon.with(
  key: "block",
  () => {
    line((0, 0.5), (1, 0.5))
  },
)

#let complete = icon.with(
  key: "complete",
  () => {
    set-origin((0.5, 0.5))
    let bend = 0.075
    for _ in range(4) {
      line(
        (0, 0),
        (0, bend),
        (0.5, 0.5),
        (bend, 0),
        close: true,
      )
      rotate(90deg)
    }
  },
)

#let cancel = icon.with(
  key: "cancel",
  () => {
    let slantedness = 0.25

    line(
      (0.5 - slantedness, 0),
      (0.5 + slantedness, 1),
    )
  },
)

#let unknown = icon.with(
  key: "unknown",
  () => {
    arc(
      (0.5, 0.5),
      start: 165deg,
      stop: -90deg,
      fill: none,
      radius: 0.25,
      anchor: "arc-end",
    )
    line(
      (0.5, 0.5),
      (0.5, 0.375),
    )
    circle(
      (0.5, 0.05),
      radius: 0.05,
    )
  },
)

#let remark = icon.with(
  key: "remark",
  () => {
    circle((0.5, 0.95), radius: 0.125, stroke: none)
    line((0.5, 0.6), (0.5, 0))
  },
)

#let hint = icon.with(
  key: "hint",
  () => {
    circle((0.5, 0.5), radius: 0.5, fill: none)
  },
)

#let axiom = icon.with(
  key: "axiom",
  () => {
    let left = (0, 0)
    let top = (0.5, 1)
    let right = (1, 0)
    let slide = 35%

    line(left, top, right, fill: none)
    line((left, slide, top), (right, slide, top))
  },
)

#let define = icon.with(
  key: "define",
  () => {
    line((0.15, 0), (rel: (0, 1)), (rel: (0.2, 0)), fill: none)
    arc((), start: 90deg, stop: -90deg, radius: 0.5, fill: none)
    line((0.15, 0), (0.35, 0))
  },
)

#let theorem = icon.with(
  key: "theorem",
  () => {
    line((0.15, 1), (0.85, 1))
    line((0.5, 1), (rel: (0, -1)))
  },
)

#let propose = icon.with(
  key: "propose",
  () => {
    line(
      (0.25, 0),
      (rel: (0, 1)),
      (rel: (0.25, 0)),
      fill: none,
    )
    arc((), start: 90deg, stop: -90deg, radius: 0.25, fill: none)
    line((0.25, 0.5), (rel: (0.25, 0)))
  },
)

#let lemma = icon.with(
  key: "lemma",
  () => {
    line((0.3, 1), (rel: (0, -0.8)))
    arc((), start: -180deg, stop: 0deg, radius: 0.2, fill: none)
  },
)

#let corollary = icon.with(
  key: "corollary",
  () => {
    for height in (0, 1) {
      line((0.8, height), (rel: (-0.2, 0)))
    }
    arc((), start: 90deg, stop: 270deg, radius: 0.5, fill: none)
  },
)

