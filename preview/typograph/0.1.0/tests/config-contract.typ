// Contextual contract for the state-backed config stack.
#import "/src/config.typ": config, current-defaults

#config(
  scale: 0.8cm,
  baseline: 6pt,
  node-styles: (z: (fill: red), x: (fill: blue)),
  edge-styles: (highlight-width: 4pt),
)[
  #config(
    node-styles: (z: (stroke: 1pt + black)),
    edge-styles: (label-offset: 3pt),
  )[
    #context {
      let current = current-defaults()
      assert(current.scale == 0.8cm)
      assert(current.baseline == 6pt)
      assert(current.node-styles.z.fill == red)
      assert(current.node-styles.z.stroke == 1pt + black)
      assert(current.node-styles.x.fill == blue)
      assert(current.edge-styles.highlight-width == 4pt)
      assert(current.edge-styles.label-offset == 3pt)
    }
  ]
  #context {
    let current = current-defaults()
    assert(current.scale == 0.8cm)
    assert(current.baseline == 6pt)
    assert(current.node-styles.z.fill == red)
    assert("stroke" not in current.node-styles.z)
    assert(current.edge-styles.highlight-width == 4pt)
    assert("label-offset" not in current.edge-styles)
  }
]

#context {
  let current = current-defaults()
  assert("scale" not in current)
  assert("baseline" not in current)
  assert("node-styles" not in current)
  assert("edge-styles" not in current)
}
