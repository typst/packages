#import "/src/cetz.typ": styles

#let default = (
  fill: none,
  stroke: black + .5pt,
  padding: none,
  sequence: (
    color: black,
    thickness: .5pt,
    start-tip: none,
    end-tip: ">"
  ),
  participant: (
    color: rgb("#E2E2F0"),
    shape: "participant"
  )
)

#let resolve(root: none, merge: (:), base: (:)) = styles.resolve(
  default,
  root: root,
  merge: merge,
  base: base
)