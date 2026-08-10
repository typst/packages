// Should fail: smooth() cannot be combined with bend:.
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  edge(node(0, 0), smooth(node(1, 1)), node(2, 0), bend: 0.3)
})
