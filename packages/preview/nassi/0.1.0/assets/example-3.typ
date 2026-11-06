#set page(width: 13cm, height:auto, margin: 5mm)

#import "../src/nassi.typ"

#nassi.diagram({
	import nassi.elements: *

	function("ggt(a, b)", {
		loop("a > b and b > 0", {
			branch("a > b", {
				assign("a", "a - b")
			}, {
				assign("b", "b - a",
          fill: gradient.linear(..color.map.rainbow),
          stroke:red + 2pt
        )
			})
		})
		branch("b == 0", { process("return a") }, { process("return b") })
	})
})
