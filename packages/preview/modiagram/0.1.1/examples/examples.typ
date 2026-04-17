#import "../src/lib.typ" as mo
#set text(font: "IBM Plex Sans", weight: "light")
#show math.equation: set text(font: "Fira Math", weight: "light")

#set page(width: auto, height: auto, margin: 10pt)
//#set text(font: "IBM Plex Sans", weight: "light", size: 8pt)
//#show math.equation: set text(font: "Fira Math", weight: "light")

// Quick start
#figure({
  import mo: *
  modiagram(
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),
    energy-axis(title: [Energy]),
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
	ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: $sigma_(2s)$),
	ao(name: "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$, bar-stroke-w: 1pt, bar-color: purple, label-color: black),
	ao(name: "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$, el-stroke-w: .8pt, el-color: purple),
	ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

	ao(name: "s2pz", x: 1.00, energy: 2.00, electrons: "pair", label: $sigma_(2p_z)$, ao-width: 0.5),
	ao(name: "π1", x: 0.75, energy: 3.00, electrons: "pair", label: $pi_(2p_x)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π2", x: 1.25, energy: 3.00, electrons: "pair", label: $pi_(2p_y)$, color: red, label-size: 6pt, label-gap: 0.2cm),
	ao(name: "π3", x: 0.75, energy: 4.00, electrons: "up", label: $pi_(2p_x)^*$, el-color: blue),
	ao(name: "π4", x: 1.25, energy: 4.00, electrons: "up", label: $pi_(2p_y)^*$, el-color: blue),
	ao(name: "S2pz", x: 1.00, energy: 5.00, electrons: "", label: $sigma_(2p_z)^*$, label-color: purple, ao-width: 0.5),

	ao(name: "lp1", x: +0.00, energy: 3.50, electrons: "up", label: $2p_z$, up-el-pos: 2.5pt, el-color: green),
	ao(name: "lp2", x: -0.50, energy: 3.50, electrons: "up", label: $2p_y$, up-el-pos: 0pt),
	ao(name: "lp3", x: -1.00, energy: 3.50, electrons: "pair", label: $2p_x$),

	ao(name: "rp1", x: +2.00, energy: 3.5, electrons: "pair", label: $2p_x$),
	ao(name: "rp2", x: +2.50, energy: 3.5, electrons: "up", label: $2p_y$),
	ao(name: "rp3", x: +3.00, energy: 3.5, electrons: "up", label: $2p_z$),  
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(

  ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: [test]),
  ao(name:      "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$, bar-stroke-w: 1pt, bar-color: purple, label-color: black),
  ao(name:      "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$, el-stroke-w: .8pt, el-color: purple),
  ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

  connect("2s1 & sigma2s1", "sigma2s1 & 2s2", style: "gray"),
  connect("2s1 & sigma2s2", "sigma2s2 & 2s2", style: "solid", color: olive),

  ao(name: "s2pz", x: 1.00, energy: 2.00, electrons: "pair", label: $sigma_(2p_z)$, ao-width: 0.5),
  ao(name:   "π1", x: 0.75, energy: 3.00, electrons: "pair", label: $pi_(2p_x)$, color: red, label-size: 6pt, label-gap: 0.2cm),
  ao(name:   "π2", x: 1.25, energy: 3.00, electrons: "pair", label: $pi_(2p_y)$, color: red, label-size: 6pt, label-gap: 0.2cm),
  ao(name:   "π3", x: 0.75, energy: 4.00, electrons:   "up", label: $pi_(2p_x)^*$, el-color: blue),
  ao(name:   "π4", x: 1.25, energy: 4.00, electrons:   "up", label: $pi_(2p_y)^*$, el-color: blue),
  ao(name: "S2pz", x: 1.00, energy: 5.00, electrons:     "", label: $sigma_(2p_z)^*$, label-color: purple, ao-width: 0.5),

  ao(name: "lp1", x: +0.00, energy: 3.50, electrons:  "up", label: $2p_z$, up-el-pos: 2.5pt, el-color: green),
  ao(name: "lp2", x: -0.50, energy: 3.50, electrons:  "up", label: $2p_y$, up-el-pos: 0pt),
  ao(name: "lp3", x: -1.00, energy: 3.50, electrons: "pair", label: $2p_x$),

  ao(name: "rp1", x: +2.00, energy: 3.5, electrons: "pair", label: $2p_x$),
  ao(name: "rp2", x: +2.50, energy: 3.5, electrons:   "up", label: $2p_y$),
  ao(name: "rp3", x: +3.00, energy: 3.5, electrons:   "up", label: $2p_z$),

  connect("rp3 & rp2","rp2 & rp1"),
  connect("lp3 & lp2", "lp2 & lp1"),
  connect("lp1 & π1", "π1 & π2", "π2 & rp1", color: red, style: "dashed", dash-length: 0.5mm),
  connect("lp1 & π3", "π3 & π4", "π4 & rp1"),
  connect("lp1 & S2pz", "S2pz & rp1"),
  connect("lp1 & s2pz", "s2pz & rp1"),

  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.7),
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
  
  config(color: blue),
  ao(name: "sigma2s1", x: 1.00, energy: 0.00, electrons: "pair", label: $sigma_(2s)$),
  ao(name:      "2s1", x: 0.00, energy: 0.50, electrons: "pair", label: $2s$),
  ao(name:      "2s2", x: 2.00, energy: 0.50, electrons: "pair", label: $2s$),
  ao(name: "sigma2s2", x: 1.00, energy: 1.00, electrons: "pair", label: $sigma_(2s)^*$),

  connect("2s1 & sigma2s1", "sigma2s1 & 2s2",),
  connect("2s1 & sigma2s2", "sigma2s2 & 2s2",),

  config(el-color: red, bar-color: olive, label-color: maroon, label-size: 6pt, label-gap: 6pt, energy-scale: 0.7, up-el-pos: -1.5pt, down-el-pos: 1.5pt),

  ao(name: "s2pz", x: 1.00, energy: 2.00+1, electrons: "pair", label: $sigma_(2p_z)$),
  ao(name:   "π1", x: 0.75, energy: 3.00+1, electrons: "pair", label: $pi_(2p_x)$),
  ao(name:   "π2", x: 1.25, energy: 3.00+1, electrons: "pair", label: $pi_(2p_y)$),
  ao(name:   "π3", x: 0.75, energy: 4.00+1, electrons:   "up", label: $pi_(2p_x)^*$),
  ao(name:   "π4", x: 1.25, energy: 4.00+1, electrons:   "up", label: $pi_(2p_y)^*$),
  ao(name: "S2pz", x: 1.00, energy: 5.00+1, electrons:     "", label: $sigma_(2p_z)^*$),

  ao(name: "lp1", x: +0.00, energy: 3.50+1, electrons:  "up", label: $2p_z$),
  ao(name: "lp2", x: -0.50, energy: 3.50+1, electrons:  "up", label: $2p_y$),
  ao(name: "lp3", x: -1.00, energy: 3.50+1, electrons: "pair", label: $2p_x$),

  ao(name: "rp1", x: +2.00, energy: 3.5+1, electrons: "pair", label: $2p_x$),
  ao(name: "rp2", x: +2.50, energy: 3.5+1, electrons:   "up", label: $2p_y$),
  ao(name: "rp3", x: +3.00, energy: 3.5+1, electrons:   "up", label: $2p_z$),

  connect("rp3 & rp2","rp2 & rp1"),
  connect("lp3 & lp2", "lp2 & lp1"),
  connect("lp1 & π1", "π1 & π2", "π2 & rp1"),
  connect("lp1 & π3", "π3 & π4", "π4 & rp1"),
  connect("lp1 & S2pz", "S2pz & rp1"),
  connect("lp1 & s2pz", "s2pz & rp1"),

  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    config(energy-scale: 0.3),
    en-pathway(
      -4, 4, -1, 2, -8,
      labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
      show-energies: true,
      name-prefix: "black"
      ),
    en-pathway(
      -1, 2, -5, 5, -4,
      labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
      color: olive,
      name-prefix: "olive"
    ),

    energy-axis(title: "E"),
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    config(energy-scale: 0.3),
    en-pathway(
      -4, 4, -1, 2, -8,
      labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
      show-energies: true,
      name-prefix: "black"
      ),
    en-pathway(
      -1, 2, -5, 5, -4,
      labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
      color: olive,
      name-prefix: "olive"
    ),

    energy-axis(title: "E"),
    
    raw((xs, ys, anchors) => {
      let p = at("black-3", anchors, edge: "right")
      draw.content((p.at(0) + 0.2, p.at(1)), [#align(center, [BEST \ TS])], anchor: "west")
    })
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    config(style: "square"),
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.2),
  )
})

#figure({
  import mo: *
  modiagram(
    config(style: "round"),
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.2),
  )
})

#figure({
  import mo: *
  modiagram(
    config(style: "circle"),
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.2),
  )
})

#figure({
  import mo: *
  modiagram(
    config(style: "fancy"),
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", "1s-R & S", "1s-L & S*", "1s-R & S*"),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.2),
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    config(style: "fancy"),
    ao(name: "1s-L", x: -1, energy:    0, electrons: "pair", label: $1s$, style: "square"),
    ao(name: "1s-R", x:  1, energy:    0, electrons: "pair", label: $1s$, style: "round"),
    ao(name: "S",    x:  0, energy: -0.5, electrons: "pair", label: $sigma$),
    ao(name: "S*",   x:  0, energy:  0.5, electrons: "",     label: $sigma^*$),
    connect("1s-L & S", style: "dotted"),
    connect-label("1s-L","S", [dotted], size: 6pt, pad: 0.1),
    connect("1s-R & S", style: "dashed"),
    connect-label("S","1s-R", [dashed], size: 6pt, pad: 0.1),
    connect("1s-L & S*", style: "solid"),
    connect-label("1s-L","S*", [solid], size: 6pt, pad: 0.1),
    connect("1s-R & S*", style: "gray"),
    connect-label("S*", "1s-R", [gray], size: 6pt, pad: 0.1),

    energy-axis(title: [Energy], style: "horizontal", pad: 0.2),
  )
})

#pagebreak()

#figure({
  import mo: *
  modiagram(
    config(energy-scale: 0.3),
    line("olive-2", rel(0.9,3), stroke: 0.5pt+blue, mark:(end: ">>", fill: blue, scale: 0.5)),
    circle("olive-2", radius: 0.6, stroke: 0.5pt+blue, fill: yellow.lighten(80%)),
    content("olive-2", dx: 1.7, dy: 1.1, text(fill: blue)[example\ of content]),
    content("red-1.right", pad: 0.6, )[#align(center)[#text(size: 7pt)[Another\ way to\ include\ content]]],
    content("red-1.left", pad: 0.6)[#image("../images/Caffeine_structure.svg", width: 1.3cm)],

    en-pathway(
      -4, 4, -1, 2, -8,
      labels: ([SM], [TS$alpha$-1], [Key], [TS$beta$-1], [P]),
      show-energies: true,
      color: red,
      name-prefix: "red"
      ),
    en-pathway(
      -1, 2, -5, 5.15, -4,
      labels: ([SM], [$gamma$], [Int], [Ex], [`code`]),
      color: olive,
      name-prefix: "olive"
    ),

    ao(x: 4.8, energy: 0, electrons: "pair"),
    ao(x: 2.4, energy: 1, electrons: "up", up-el-pos: 0),

    ep-annotation("red-0", "red-2", [Step 1]),
    ep-annotation("olive-3", "olive-4", [Step 2], color: blue),

    en-difference("olive-2", "red-1", ratio: 70%, color: red, pad: 5.7),
    en-difference("olive-3", "red-4", color: purple, pad: 1.3, title: [TS]),
    en-difference("olive-1", "olive-2", color: blue, pad: 3, ratio: 25%),

    energy-axis(title: "Energy in kcal/mol", style: "horizontal"),
    x-axis(title: "reaction coordinate", style: "below", pad: 1)

  )
})