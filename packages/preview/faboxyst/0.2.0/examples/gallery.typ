// faboxyst — exhaustive gallery: one cell per exported box family, with
// its name as caption. Compile to PDF for a map of the whole package.
#import "@preview/faboxyst:0.2.0": *

#set page(width: 21cm, height: 29.7cm, margin: 1.1cm, fill: rgb("#F5F4F0"))
#set text(size: 8.5pt, fill: rgb("#222222"))

#let cap(name) = text(size: 6.8pt, fill: rgb("#77808A"),
  font: ("DejaVu Sans Mono",), name)

#let cell(name, render) = block(width: 100%, {
  align(center + horizon, block(width: 100%, inset: 2pt, render))
  v(1pt)
  align(center, cap(name))
})

#let T = [Titre]

#align(center)[#text(size: 16pt, weight: "bold")[faboxyst — galerie exhaustive]]
#v(2pt)
#align(center)[#text(size: 8pt, fill: rgb("#77808A"))[une cellule par fonction exportée — Typst 0.15.1]]
#v(0.5cm)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 10pt,
  row-gutter: 9pt,

  cell("fabox", fabox(title: T)[fabox]),
  cell("fabox-sign", fabox-sign(size: 1.8)[fabox-sign]),
  cell("fabox-note", fabox-note[fabox-note]),
  cell("iconbox / tip-card", tip-card[tip-card]),
  cell("crestbox", crestbox(title: T)[crestbox]),
  cell("ribbonbox", ribbonbox(title: T)[ribbonbox]),

  cell("helixbox", helixbox(title: T)[helixbox]),
  cell("swooshbox", swooshbox(title: T)[swooshbox]),
  cell("circuitbox", circuitbox(title: T)[circuitbox]),
  cell("keybox", keybox[keybox]),
  cell("ringbox", ringbox[ringbox]),
  cell("punchbox", punchbox(number: [7])[punchbox]),

  cell("plannerbox", plannerbox(title: T)[plannerbox]),
  cell("filebox", filebox[filebox]),
  cell("stubbox", stubbox(stub: [12])[stubbox]),
  cell("stackbox", stackbox(title: T)[stackbox]),
  cell("calloutbox", calloutbox(title: T)[calloutbox]),
  cell("tapebox", tapebox(title: T)[tapebox]),

  cell("boardbox / chalkbox", chalkbox[chalkbox]),
  cell("markerbox", markerbox[markerbox]),
  cell("screwbox", screwbox[screwbox]),
  cell("sashbox / ruban", sashbox[sashbox]),
  cell("flagbox", flagbox(title: T)[flagbox]),
  cell("notebook-box", notebook-box(title: T)[notebook-box]),

  cell("notebook-box-clean", notebook-box-clean[notebook-box-clean]),
  cell("ticket / ticketbox", ticket(stub: [12])[ticket]),
  cell("post-it", post-it[post-it]),
  cell("folder", folder(title: T)[folder]),
  cell("terminal", terminal(title: [sh])[terminal]),
  cell("neon", neon[neon]),

  cell("polaroid", polaroid(caption: [Juin 2026])[#text(size: 7.5pt,
    fill: white, weight: "bold")[On écrit directement\ dans la zone photo]]),
  cell("speech-bubble", speech-bubble[speech-bubble]),
  cell("joined-bubbles", joined-bubbles(a: [Qui ?], b: [Quoi ?])),
  cell("torn-note", torn-note(width: 5.6)[torn-note]),
  cell("ruled-sheet", ruled-sheet(width: 5.6)[ruled-sheet]),
  cell("stamp-card", stamp-card(width: 5.6)[stamp-card]),

  cell("index-card", index-card(width: 5.6, heading: [Relevé])[index-card]),
  cell("deckle-tag", deckle-tag(width: 5.6)[deckle-tag]),
  cell("notepad", notepad(width: 5.6)[notepad]),
  cell("scrapbook / felt", felt(colour: rgb("#F7C948"))[surlignage]),
  cell("khatambox", khatambox(title: T, badge: [1])[khatambox]),
  cell("zellijbox", zellijbox(title: T)[zellijbox]),

  cell("mihrabbox", mihrabbox(title: T)[mihrabbox]),
  cell("arabesquebox", arabesquebox(title: T)[arabesquebox]),
  cell("mosaicbox", mosaicbox(title: T)[mosaicbox]),
  cell("fleuronbox", fleuronbox(title: T)[fleuronbox]),
  cell("lacebox", lacebox(title: T)[lacebox]),
  cell("ogeebox / banniere", ogeebox[ogeebox]),

  cell("frisebox / frise", frisebox[frisebox]),
  cell("medallion", medallion[A]),
  cell("gelbox / bouton", gelbox[gelbox]),
  cell("insetbox / boite-creusee", insetbox[insetbox]),
  cell("coilbox / cahier", coilbox(title: T)[coilbox]),
  cell("tornpage / page-dechiree", tornpage(title: T)[tornpage]),

  cell("plankbox / pancarte", plankbox(title: T)[plankbox]),
  cell("volutebox / cadre-volute", volutebox[volutebox]),
  cell("parchemin / lettre", parchemin(title: T)[parchemin]),
  cell("highway-sign", highway-sign(title: [Sortie 23])[highway-sign]),
  cell("sale-poster", sale-poster(old: [19,90 €], body: [9,90 €])),
  cell("banner-tri", banner-tri(title: T)[banner-tri]),

  cell("bicolor-title", bicolor-title(end: [Maison])[Devoir maison]),
  cell("meter / difficulty", difficulty(3)),
  cell("pictocible", pictocible(3, size: 1.0cm)),
  cell("pictoskills", pictoskills(3, size: 1.0cm)),
  cell("leconbox / lecon", leconbox(num: 1)[leconbox]),
  cell("pinbox / epingle", pinbox(diameter: 2.3cm)[Année][2026]),

  cell("brushbox / pinceau", brushbox(text-size: 0.85em)[brushbox aquarelle]),
  cell("matierebox / cartouche", matierebox(subject: [Physique], year: [2027], height: 1.05cm, text-size: 0.68em)),
  cell("vintageframe / cadre-vintage", vintageframe(style: "volutes", text-size: 0.8em)[vintageframe]),
  cell("vintagebox / plaque-vintage", vintagebox(variant: "banniere", height: 1.5cm, text-size: 0.75em)[VINTAGE]),
  cell("halftone / trame (fill)", rect(width: 100%, height: 1.2cm, radius: 4pt, fill: halftone(rgb("#45B3BE"), backdrop: rgb("#DFF3F4")))),
  cell("relief (fill creux)", insetbox(radius: 5pt)[ombre interne]),
  cell("banner-tri arrondi (kit)", banner-tri(style: "arrondi", title: T)[variante arabic-exam-kit]),
  cell("smooth-pts", polygon(fill: rgb("#7FA6C9"),
    ..smooth-pts(((0cm, 0cm), (3cm, 0cm), (3.6cm, 0.6cm), (3cm, 1.2cm), (0cm, 1.2cm)), 0.22cm))),
  cell("tikzpattern NE lines", rect(width: 100%, height: 1.2cm, radius: 4pt,
    fill: tikzpattern(kind: "north east lines", color: rgb("#B03030")))),
  cell("tikzpattern dots + bricks", grid(columns: 2, column-gutter: 3pt,
    rect(width: 100%, height: 1.2cm, fill: tikzpattern(kind: "dots")),
    rect(width: 100%, height: 1.2cm, fill: tikzpattern(kind: "bricks")))),
  cell("tikzpattern étoiles 5/6", grid(columns: 2, column-gutter: 3pt,
    rect(width: 100%, height: 1.2cm, fill: tikzpattern(kind: "fivepointed stars", color: rgb("#5B7DB1"))),
    rect(width: 100%, height: 1.2cm, fill: tikzpattern(kind: "sixpointed stars", color: rgb("#5B7DB1"))))),
  cell("motif-tikz (alias)", rect(width: 100%, height: 1.2cm, radius: 4pt,
    fill: motif-tikz(kind: "crosshatch", color: teal, backdrop: rgb("#E8F6F5")))),

  cell("banner-tri-bis", banner-tri-bis(title: [Exercice 1], points: [3 pts])[
    Le ruban kit au-dessus du corps, LTR ou RTL.]),
  cell("rosettebox / cadre-rosette", rosettebox(title: [Édition], scale: 0.42)[
    Le cadre dédicace adapté à son contenu.]),
  cell("rosette-pages (frame)", rosettebox([], width: 100%, height: 1.7cm,
    scale: 0.38, diamonds: 3)),
)
