// Shortcuts
#let shows-shortcuts(content) = {
  show "SCH": align(
    center,
    box(fill: gray.lighten(70%), inset: 2cm, stroke: 0.65pt, text(size: 20pt)[#emoji.warning *Schema* #emoji.warning]),
  )

  show "ARL": place(
    dx: -2.7cm,
    dy: -1cm,
    circle(stroke: 1pt, radius: 1.5cm, fill: red.lighten(20%), outset: -0.5cm)[
      #set align(center + horizon)
      #set text(black, size: 12pt, font: "TeX Gyre Chorus")

      *Nécessite\ relecture*
    ],
  )

  content
}

// ...
#let tab = h(30pt)
#let pointer = [\ #h(26pt) #sym.triangle.filled.r]
#let sep = context align(center, line(length: 90%, stroke: 0.65pt + text.fill))
#let sep-short = context align(center, line(length: 60%, stroke: 0.65pt + text.fill))

// Maths
#let scal(x,y) = $angle.l #x, #y angle.r$


#let congru = $eq.triple$

#let card = "card"
#let ah = $arrow.r.hook$
#let Inter = $inter.big$
#let Union = $union.big$ 
#let Id = "Id"
#let Mat = "Mat"
#let Vect = "Vect"
#let Ann = $"Ann"$
#let diag = "diag"
#let Ker = "Ker"
#let Im = "Im"
#let End = "End"
#let GL = $cal(G L)$
#let SO = $cal(S O)$
#let Sp = $cal(S p)$

// Physics
#let dt = $dif t$
#let dx = $dif x$
#let dtheta = $dif theta$

#let ar = math.arrow
#let nar(c) = math.norm(math.arrow(c))

#let dot2 = math.dot.double
#let dot3 = math.dot.triple

#let grad = ar("grad")
