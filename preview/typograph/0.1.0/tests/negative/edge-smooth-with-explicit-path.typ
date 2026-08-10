// Should fail: smooth() cannot be combined with explicit quad()/cubic().
#import "/src/lib.typ" as typ
#typ.diagram({
  import typ: *
  edge(node(0, 0), smooth(node(1, 1)), quad((2, 1), node(3, 0)))
})
