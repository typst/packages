// Should fail: bend: and from:/to: are alternatives, not combinable.
#import "/src/lib.typ" as typ
#typ.diagram({
  let a = typ.node(0, 0)
  let b = typ.node(1, 0)
  typ.edge(a, b, bend: 0.3, from: right)
})
