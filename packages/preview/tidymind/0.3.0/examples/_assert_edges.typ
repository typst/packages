#import "../src/draw.typ": edge-color, edge-curve, ribbon
#set page(width: auto, height: auto)

#let dist(p, q) = calc.sqrt(calc.pow(p.at(0) - q.at(0), 2) + calc.pow(p.at(1) - q.at(1), 2))

// The curved edge keeps the 0.2.0 control points: halfway in x, level with each end.
#let c = edge-curve((0, 0), (100, -40))
#assert(c.at(1) == (50.0, 0) and c.at(2) == (50.0, -40))

// A ribbon is two sides of steps+1 points each, w1 wide at the start and w2 at the end.
#let r = ribbon((0, 0), (100, -40), 6, 2, steps: 24)
#assert.eq(r.len(), 50)
#assert(calc.abs(dist(r.at(0), r.at(49)) - 6) < 0.01, message: "start width")
#assert(calc.abs(dist(r.at(24), r.at(25)) - 2) < 0.01, message: "end width")

// Going left (negative dx) works the same way.
#let l = ribbon((0, 0), (-100, -40), 6, 2, steps: 24)
#assert(calc.abs(dist(l.at(0), l.at(49)) - 6) < 0.01)

// Deeper edges are lighter, except in "boxed", which keeps 0.2.0's flat color.
#assert(edge-color(red, 1, "technical") == red)
#assert(edge-color(red, 2, "technical") != red)
#assert(edge-color(red, 3, "technical") != edge-color(red, 2, "technical"))
#assert(edge-color(red, 3, "boxed") == red)
#[OK]
