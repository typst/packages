// NOTE: compile with ppi=144 to reproduce
#set page(margin: 1cm, width: auto, height: auto)
#set text(2cm)
#import "@preview/symbolx:1.1.0": symbol, symbolx-rule

#let (map, tensor) = symbol("⊗", ("r", $times.circle_RR$), ("c", $times.circle_CC$))
#let (map, subset) = symbol(map, "⊂", ("c", $class("binary", subset subset)$))
#let (map, exists) = symbol(map, (sym.exists,), ("unique", $exists!$))
#let (map, union) = symbol(map, (sym.union,), (sym.union, var => {
	let (modifs, value) = if type(var) == str { ("", var) } else { var }
	if "big" in modifs { return () }
	if modifs != "" { modifs += "." }
	(modifs + "unary", math.class("unary", value))
}))
#show: symbolx-rule(map)

$ (CC^2)^(tensor n) = (CC^2)^(tensor.c n) != (CC^2)^(tensor.r n) $

#pagebreak()

$ A subset.c B $

#pagebreak()

$ exists.not x forall y exists.unique z. phi(x, y, z) $

#pagebreak()

$ x union.dot (union.dot.unary x) $
