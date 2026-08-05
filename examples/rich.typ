// Everything at once: icons, three ranks, cross-links, a free-form hub.
#import "../lib.typ": *
#set page(width: 22cm, height: auto, margin: 1cm, fill: white)
#set text(font: "New Computer Modern", size: 9pt)
#set par(justify: false, leading: 0.72em)

#let ic(c, g) = text(fill: c, weight: "bold", g)

#mindmap(
  [*Le cycle\ de l'eau*],
  hub-shape: "rounded", hub-ratio: 1.3, radius: 1.9,
  leaf-width: 3.4, weight: 1.1pt, shape: "note",
  links: (
    link(0, 1, label: [forme]),
    link(1, 2, label: [donne]),
    link(2, 3, label: [nourrit]),
    link(3, 0, via: "inside", label: [recommence]),
  ),
  branch(title: [Évaporation], icon: ic(rgb("#C0392B"), [▲]), children: (
    branch(title: [soleil], children: (branch[énergie],)),
    branch[océans],
  ))[L'eau passe à l'état gazeux.],
  branch(title: [Condensation], icon: ic(rgb("#2980B9"), [◆]), children: (
    branch[altitude], branch[nuages],
  ))[La vapeur se refroidit.],
  branch(title: [Précipitations], icon: ic(rgb("#27AE60"), [●]), children: (
    branch[pluie], branch[neige],
  ))[L'eau retombe au sol.],
  branch(title: [Ruissellement], icon: ic(rgb("#8E44AD"), [■]))[
    Elle rejoint les rivières.
  ],
)
