#import "fills.typ": hatch, crosshatch, dots

#let edge = rgb("#26343a")
#let stroke = .55pt + edge
#let internal-stroke = .3pt + edge
#let edge-accent-stroke = none

/// Default material styles used by layer-stack.
#let default-palette = (
  default: (
    (
      fill: hatch(
        background: rgb("#e7ecee"),
        color: rgb("#aab7bc"),
        spacing: 7pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
  ),
  substrate: (
    (
      fill: rgb("#b9cbd0"),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
      fade-bottom: (
        start: 70%,
        end: 95%,
        color: white,
      ),
    ),
  ),
  dielectric: (
    (
      fill: hatch(
        background: rgb("#ccebf3"),
        color: rgb("#71b8c9"),
        spacing: 6pt,
        thickness: .4pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
    (
      fill: hatch(
        background: rgb("#d9d9f2"),
        color: rgb("#9696c8"),
        spacing: 7pt,
        thickness: .4pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
    (
      fill: hatch(
        background: rgb("#cce7de"),
        color: rgb("#75ad9a"),
        spacing: 8pt,
        thickness: .4pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
  ),
  metal: (
    (
      fill: hatch(
        background: rgb("#e3c66f"),
        color: rgb("#a9852e"),
        spacing: 6pt,
        thickness: .4pt,
        angle: -45deg,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
    (
      fill: hatch(
        background: rgb("#d7a17c"),
        color: rgb("#985f3d"),
        spacing: 7pt,
        thickness: .4pt,
        angle: -45deg,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
    (
      fill: hatch(
        background: rgb("#cbd3d6"),
        color: rgb("#7b8b91"),
        spacing: 8pt,
        thickness: .4pt,
        angle: -45deg,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
  ),
  resist: (
    (
      fill: dots(
        background: rgb("#c9dfa2"),
        color: rgb("#7fa254"),
        spacing: 8pt,
        radius: .6pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
    (
      fill: dots(
        background: rgb("#e9b8c5"),
        color: rgb("#b66d82"),
        spacing: 9pt,
        radius: .6pt,
      ),
      stroke: stroke,
      internal-stroke: internal-stroke,
      edge-accent-stroke: edge-accent-stroke,
    ),
  ),
)
