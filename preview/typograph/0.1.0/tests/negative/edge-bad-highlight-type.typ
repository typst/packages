// Should fail: highlight must be none, a color, or an array of 0-2 colors.
// — a string is not a color.
#import "/src/lib.typ" as typ
#typ.diagram({
  let a = typ.node(0, 0)
  let b = typ.node(1, 0)
  typ.edge(a, b, highlight: "green")
})
