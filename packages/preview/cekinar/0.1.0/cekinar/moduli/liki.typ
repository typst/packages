#import "stil.typ": barve

#let vstavitev(
	x1: 0mm,
	y1: 0mm,
	vstavek: none,
) = place(
	dx: x1,
	dy: y1,
	vstavek,
)

#let oznaka(
	x1: 0mm,
	y1: 0mm,
	besedilo: "",
) = place(
	dx: x1,
	dy: y1,
	besedilo,
)

#let skener(
	x1: 0mm,
	y1: 0mm,
) = place(
	dx: x1,
	dy: y1,
	square(size: 1.5mm, fill: barve.črna),
)