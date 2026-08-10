// Should fail: a theme palette is a named dictionary.
#import "/src/lib.typ" as typ
#typ.diagram(theme: typ.theme(palette: red), {})
