// sprig 0.8.0 — buzan : la carte mentale radiale, telle qu'on la dessine à la
// main. Le mot porte la branche : le trait de marqueur part du nuage, reste
// épais SOUS tout le mot, puis court dans le vide là où les idées d'après
// s'ouvrent en Y. Un rang plus bas n'est plus qu'un trait de stylo, et son
// étiquette se tient au-dessus de lui.
#import "@preview/sprig:0.8.0": *

#set page(width: 29.7cm, height: 21cm, margin: 0.8cm, fill: white)
#set text(font: ("New Computer Modern",), size: 10.5pt)
#set align(center)

// 1 — LA CARTE, comme sur le carnet. `knot:` est la largeur du trait comme
// fraction de la hauteur du mot : à 0.8, le mot se lit ASSIS sur la couleur.
// `shade:` laisse l'encre plus dense à la base du trait et la fait courir
// jusqu'à la pointe, comme un feutre qui se soulève ; `taper:` affime chaque
// rang ; `fit: 100%` rend la carte à la largeur du texte, si bien qu'aucun
// rameau ne peut plus être coupé par la page — la page n'a plus à suivre la
// carte, c'est la carte qui suit la page.
#buzan([*Apprentissage*],
  start: 90deg,
  dist: 0.62,
  dist-step: 0.82,
  knot: 0.8,
  taper: 0.6,
  bow: 0.04,
  wave: 0.2,
  wave-step: 2.1,
  gap: 0.55,
  min-angle: 16deg,
  shade: 22%,
  upper: true,
  shrink: 0.84,
  size: 1.25,
  // `cloud` est la forme de moyeu par défaut.
  // `cumulus` est la variante procédurale réglable par les options `hub-*`.
  hub-ratio: 1.2,
  hub-pad: 0.55,
  fit: 100%,
  palette: ("#E07A1E", "#2C6FB5", "#3D9B4F", "#8A3FA8", "#C43A51"),
  branch(title: [Mémoire], icon: text(size: 1.1em, "◆"), children: (
    branch([j+1, j+7, j+30], title: [répétition]),
    branch[Réseau de mots],
    branch[Sommeil],
  )),
  branch(title: [Vitesse], children: (
    branch[lecture],
    branch(title: [écriture], children: (
      branch[prise de notes],
      branch[croquis],
    )),
  )),
  branch([le mot juste], title: [Compréhension], children: (
    branch[questions],
    branch[contre-exemples],
  )),
  branch(title: [Plaisir], icon: text(size: 1.1em, "★"), children: (
    branch[curiosité],
    branch[jeu],
  )),
)

#pagebreak()


// 2 — LE MÊME SUJET, MAIS PLACÉ À LA MAIN : `angle:` épingle la direction
// d'une branche (le rayon est pris tel quel, il ne prend pas de part du
// cercle, et les autres se le partagent quand même), `spread:` décide de
// l'éventail sous cette branche, et `dx:` / `dy:` décalent son point de
// départ, en centimètres. C'est la sortie de secours quand l'auto-partage a
// raison pour vous mais pas pour votre feuille.
#buzan([*Mind map*],
  dist: 0.6,
  knot: 0.78,
  taper: 0.62,
  bow: 0.05,
  wave: 0.22,
  wave-step: 2.4,
  shade: 24%,
  min-angle: 20deg,
  gap: 0.5,
  upper: true,
  size: 1.3,
  hub-shape: "cumulus",
  hub-ratio: 1.35,
  hub-pad: 0.5,
  // Onze lobes inégaux, un léger biais et une autre graine : la variante
  // procédurale `cumulus` montre les réglages `hub-*`.
  hub-puffs: 11,
  hub-lump: 0.3,
  hub-bump: 2.6,
  hub-tilt: -6deg,
  seed: 1242,
  fit: 100%,
  leaf-ink: black,
  palette: ("#C43A51", "#2C6FB5", "#E07A1E", "#7DB528", "#1E88A8"),
  branch([FORMAT], angle: 152deg, icon: text(size: 1.05em, "▭"), children: (
    branch[marges], branch[croquis],
  )),
  branch([STYLE], angle: 32deg, spread: 76deg, children: (
    branch[global], branch[précis], branch[couleur],
  )),
  branch([STRUCTURE], angle: 202deg, dx: 0.5, children: (
    branch[hiérarchie], branch[irradiante],
  )),
  branch([SYMBOLES], angle: 338deg, spread: 84deg, children: (
    branch[mots], branch[images], branch[cle],
  )),
)

#pagebreak()

// 3 — DEUX RÉGLAGES QUI CHANGENT LE VISAGE. À gauche le brouillon :
// `rough: true` fait trembler le CONTOUR du centre (une branche est un aplat,
// elle n'a pas de contour — sa main est dans `bow:` et `taper:`), et
// `angle-label: false` laisse les mots à l'horizontale au bout du trait. À
// droite l'ardoise : `theme: "print"`, plus une goutte d'encre de couleur, et
// le `dir: rtl` qui mirroie tout l'éventail.
#grid(columns: 2, column-gutter: 0.7cm, align: center + horizon,
  [#buzan([*Projet*],
    rough: true,
    hand: "sketch",
    angle-label: false,
    dist: 0.75,
    knot: 0.8,
    taper: 0.6,
    bow: 0.05,
    wave: 0.3,
    wave-step: 1.6,
    shade: 0%,
    hub-shape: "round",
    hub-pad: 0.42,
    fit: 100%,
    palette: ("#C43A51", "#2C6FB5", "#3D9B4F"),
    branch(title: [Cahier], children: (
      branch[besoins], branch[risques],
    )),
    branch(title: [Équipe], children: (
      branch[rôles], branch[rythme],
    )),
    branch(title: [Live], children: (
      branch[test], branch[bilan],
    )),
  )],
  [#buzan([*الأسرة*],
    theme: "print",
    dir: rtl,
    dist: 0.7,
    knot: 0.85,
    taper: 0.6,
    bow: 0.05,
    wave: 0.24,
    upper: true,
    size: 1.1,
    hub-shape: "ellipse",
    hub-ratio: 1.3,
    fit: 100%,
    branch(title: [الجدّ], children: (
      branch[الأب], branch[العمّ],
    )),
    branch(title: [الحفيد], children: (
      branch[ابني], branch[ابنتي],
    )),
    branch(title: [المصاهرة], children: (
      branch[الخال],
    )),
  )])

#pagebreak()

// 4 — LES MOTS AU BOUT DU TRAIT. `label-at: "tip"` ne laisse plus le mot dormir
// dans sa bande de couleur : le trait s'arrête à la pastille et le mot s'écrit
// AU-DELÀ, comme une main écrit au bout de sa ligne. `label-width:` tient tous
// les mots à la même largeur — la `width:` d'une branche ne règle qu'elle, et
// `label-box: "draw"` enferme le mot dans une contour à lui, la pastille
// restant dehors. La ligne entière (pastille, air, mot) est ce qui mesure la
// branche : l'éventail, l'anti-collision et la boîte de la carte en paient la
// place, sinon deux étiquettes de trois lignes se marchent dessus.
#let pt = circle(radius: 3.2pt, fill: rgb("#E8A11F"))
#grid(columns: (1fr, 0.66fr, 1fr), column-gutter: 0.5cm, align: center + horizon,
  [#buzan([*Compétences*],
      dir: ltr,
      label-at: "tip",
      label-width: 2.2cm,
      start: 270deg,
      spread: 168deg,
      min-angle: 34deg,
      dist: 1.5,
      dist-step: 1.0,
      gap: 1.2,
      knot: 0.14,
      taper: 1.0,
      bow: 0.05,
      wave: 0.06,
      shade: 0%,
      angle-label: false,
      leaf-ink: black,
      size: 1.05,
      palette: ("#1A1A1A",),
      hub-shape: "banner",
      hub-ratio: 2.6,
      hub-pad: 0.45,
      hub-fill: gradient.linear(rgb("#F4B82C"), rgb("#D88600"),
        angle: 90deg, relative: "self"),
      hub-text: black,
      fit: 100%,
      branch(icon: pt)[résolution de problèmes],
      branch(icon: pt)[organisation de données],
      branch(icon: pt)[grandeurs et mesures],
      branch(icon: pt)[vocabulaire de géométrie],
    )],
  [#block(above: 0.4em, below: 0.4em, inset: (left: 6pt),
    stroke: (left: 2pt + rgb("#F4B82C")),
    text(size: 8.5pt, style: "italic")[À gauche le mot nu, à droite le mot dans
      sa pastille (`label-box: "draw"`, `label-shape: "pill"`, `label-pad:`) —
      et la largeur du trait d'union se règle au mot près : la branche
      du bas porte sa propre `width:`, que la carte ne discute pas.])],
  [#buzan([*Compétences*],
      dir: ltr,
      label-at: "tip",
      label-width: 2.2cm,
      label-box: "draw",
      label-shape: "pill",
      label-pad: 0.14,
      start: 270deg,
      spread: 168deg,
      min-angle: 34deg,
      dist: 1.5,
      dist-step: 1.0,
      gap: 1.2,
      knot: 0.14,
      taper: 1.0,
      bow: 0.05,
      wave: 0.06,
      shade: 0%,
      angle-label: false,
      leaf-ink: black,
      size: 1.05,
      palette: (rgb("#F1AB1E"),),
      leaf-stroke: 1pt,
      hub-shape: "banner",
      hub-ratio: 2.6,
      hub-pad: 0.45,
      hub-fill: gradient.linear(rgb("#F4B82C"), rgb("#D88600"),
        angle: 90deg, relative: "self"),
      hub-text: black,
      fit: 100%,
      branch(icon: pt)[résolution de problèmes],
      branch(icon: pt)[organisation de données],
      branch(icon: pt, width: 3.2cm)[grandeurs et mesures, longueurs, aires],
    )])
