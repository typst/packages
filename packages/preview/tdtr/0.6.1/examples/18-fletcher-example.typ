#import "@preview/tdtr:0.6.1": *

#set page(height: auto, width: auto, margin: 1em)
#show: scale.with(150%, reflow: true)

#tidy-tree-graph(
  draw-edge: (
    tidy-tree-draws.horizontal-vertical-draw-edge,
    tidy-tree-draws.label-match-draw-edge.with(
      to-matches: (
        except: (marks: "1!-n!"),
      ),
      default: (marks: "1!-n?"),
    ),
  ),
  additional-draw: (
    tidy-tree-draws.metadata-match-additional-draw.with(
      matches: (
        snap: (
          tidy-tree-draws.side-label-draw-edge.with(label-sep: 0.25em),
          (
            stroke: teal,
            label: text(teal)[snap],
            label-side: left,
          ),
        ),
        layout: (
          tidy-tree-draws.side-label-draw-edge.with(label-sep: 0.25em),
          (from-node, to-node, _) => (
            vertices: (
              (rel: (-10pt, 0pt), to: from-node.name),
              to-node.name,
            ),
            bend: 40deg,
            stroke: orange,
            label: text(orange)[layout],
            label-angle: auto,
          ),
        ),
      ),
    )
  ),
  spacing: (4em, 3em),
  node-stroke: luma(80%),
  node-inset: .6em,
  edge-corner-radius: 2.5pt,
)[
  - *Diagram* #metadata("layout.end")
    - *Node* <except> #metadata("snap.end") #metadata("layout.begin")
    - *Edge* #metadata("snap.begin")
      - *Mark*
]
