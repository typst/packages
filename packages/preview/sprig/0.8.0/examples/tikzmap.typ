// Sprig 0.8.0 — tikzmap : la carte conceptuelle, dans la manière de TikZ.
// Un anneau `grow cyclic`, un plan `edge from parent fork down`, et deux
// variantes : les cercles évidés, et l'ardoise sans encre.
#import "@preview/sprig:0.8.0": *

#set page(width: 33cm, height: auto, margin: 0.8cm, fill: white)
#set text(font: ("New Computer Modern",), size: 9.5pt)
#set align(center)

// 1 — L'ANNEAU. Le premier rang se partage le cercle selon le nombre d'idées
// qu'il porte : `Théorie`, avec quatre concepts dessous, occupe deux fois la
// place de `Technologie`, qui n'en porte que deux.
#tikzmap([*Informatique*],
  start: 90deg,
  level-dist: 1.0,
  text-width: 2.3,
  inner: 0.26,
  clearance: 0.34,
  separators: true,
  branch-weight: 0.11,
  concept(title: [*Systèmes*], children: (
    concept[Réseaux], concept[Bases de données],
  )),
  concept(title: [*Théorie*], children: (
    concept[Complexité],
    concept(title: [Langages], children: (
      concept[grammaires], concept[automates],
    )),
  )),
  concept(title: [*Technologie*], children: (
    concept[Matériel], concept[Logiciels],
  )),
  concept(title: [*Pédagogie*], children: (
    concept[par le jeu], concept[par le projet],
  )),
)

#pagebreak()
// 2 — LE PLAN, forké vers le bas : `edge from parent fork down`, trois rangs,
// et le concept du milieu qui porte le plus de monde.
#tikzmap([*Sujet*],
  grow: "down",
  level-dist: 1.2,
  sibling-dist: 0.7,
  shape: "rounded",
  text-width: 4.0,
  inner: 0.26,
  branch-weight: 0.09,
  tint: 74%,
  concept(title: [*Introduction*], children: (
    concept[accroche], concept[problématique],
  )),
  concept(title: [*Développement*], children: (
    concept(title: [Partie I], children: (concept[thèse], concept[args])),
    concept(title: [Partie II], children: (concept[antithèse], concept[nuance])),
  )),
  concept(title: [*Conclusion*], children: (
    concept[synthèse], concept[ouverture],
  )),
)


// 3 — CERCLES ÉVIDÉS, angle entre frères fixe, et l'ardoise : `theme:
// "print"` ne garde que le trait, ce qui laisse la carte imprimable en noir
// et blanc. En `rtl`, l'anneau tourne à l'envers et se lit de droite à gauche.
#grid(columns: 2, gutter: 0.5cm, align: center + horizon,
  tikzmap([*Phrases*],
    shape: "circle",
    fill: false,
    sibling-angle: 40deg,
    size: "small",
    clearance: 0.34,
    scale: 0.86,
    text-width: 2.2,
    inner: 0.20,
    weight: 0.9pt,
    branch-weight: 0.05,
    curve: 0.34,
    palette: "ink",
    concept[déclarative], concept[interrogative], concept[exclamative],
    concept[impérative], concept[inclusive],
    concept(title: [négative], children: (concept[négation],)),
  ),
  tikzmap([*الحساب*],
    dir: rtl,
    theme: "print",
    size: "small",
    clearance: 0.30,
    scale: 0.86,
    text-width: 2.4,
    inner: 0.24,
    shape: "ellipse",
    concept(title: [الكسور], children: (concept[التبسيط], concept[التوحيد])),
    concept(title: [القوى], children: (concept[الأسس],)),
    concept(title: [الجذور], children: (concept[الحساب],)),
    concept(title: [المعادلات]),
  ),
)
