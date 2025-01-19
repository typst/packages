// Raccourcis


#let shows-shortcuts(contenu) = {
  show "SCH": align(
    center,
    box(fill: gray.lighten(70%), inset: 2cm, stroke: 1pt, [#emoji.warning *METTRE SCHEMA ICI* #emoji.warning]),
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
  contenu
}




// Mathématiques


#let recurrence(p: "Propriété", d: $n in NN$, ini: "", hd: "", cl: "") = {
  [
    Montrons par récurrence que la propriété $P(n) : $ "#p" est vraie pour tout #d

    - #underline[Initialisation :] #ini
    - #underline[Hérédité :] #hd
    - #underline[Conclusion :] #cl


  ]
}

#let congru = $eq.triple$

// Physique

#let dt = $dif t$
#let ar = math.arrow
#let Nar(c) = math.norm(math.arrow(c))
#let dot2 = math.dot.double
#let dot3 = math.dot.triple
#let grad = ar("grad")

#let RTSG = "Référentiel terrestre supposé galiléen"
#let TEC = "Théorème de l'énergie cinétique"


