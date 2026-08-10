// Should fail: highlight: accepts at most 2 colors (one above, one below
// the wire) — a third color is meaningless.
#import "/src/lib.typ" as typ
#typ.diagram({
  let a = typ.node(0, 0)
  let b = typ.node(1, 0)
  typ.edge(a, b, highlight: (red, green, blue))
})
