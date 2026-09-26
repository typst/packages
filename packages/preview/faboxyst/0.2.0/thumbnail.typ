// faboxyst — thumbnail source for Typst Universe: an exhaustive mosaic of
// the package's box families (49 cells + wide bands), square 1200x1200.
//   typst compile thumbnail.typ --format png --ppi 144 thumb-2x.png
//   magick thumb-2x.png -resize 1200x1200 thumbnail.png
#import "@preview/faboxyst:0.2.0": *

#set page(width: 1200pt, height: 1200pt, margin: 0pt,
  fill: gradient.linear(rgb("#FBFAF6"), rgb("#EFEDE4"), angle: 160deg))
#set text(lang: "fr", size: 6.5pt)

#let cell(render) = block(width: 100%, height: 86pt, clip: true,
  breakable: false, align(center + horizon, render))

#let T = [Titre]

#place(top + left, block(width: 100%, height: 100%, inset: 44pt, {
  set align(center)

  // ------------------------------------------------------------ title
  text(size: 44pt, weight: "bold", fill: rgb("#1A1A1A"),
    font: ("DejaVu Serif",), tracking: 1.2pt)[faboxyst]
  h(10pt)
  text(size: 13pt, fill: rgb("#6B7280"),
    font: ("DejaVu Sans",))[boîtes, cadres & planches vectorielles — 0.2.0]
  v(10pt)

  // ------------------------------------------------------------ ribbon + trame
  align(center, block(width: 86%,
    matierebox(subject: [Physique], year: [2026/2027],
      height: 46pt, text-size: 1.7em)))
  v(5pt)
  grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 3pt,
    rect(width: 100%, height: 6pt, radius: 3pt,
      fill: halftone(rgb("#45B3BE"), backdrop: rgb("#E4F4F5"), spacing: 4.5pt)),
    rect(width: 100%, height: 6pt, radius: 3pt,
      fill: tikzpattern(kind: "north east lines", color: rgb("#B03030"),
        distance: 5pt, line-width: 0.7pt, backdrop: rgb("#FBECEA"))),
    rect(width: 100%, height: 6pt, radius: 3pt,
      fill: tikzpattern(kind: "dots", color: rgb("#2E7D32"),
        distance: 6pt, radius: 1.1pt, backdrop: rgb("#EDF5EE"))),
    rect(width: 100%, height: 6pt, radius: 3pt,
      fill: tikzpattern(kind: "bricks", color: rgb("#6D4C41"),
        distance: 5pt, line-width: 0.7pt, backdrop: rgb("#F3EDEA"))))
  v(9pt)

  // ------------------------------------------------------------ 49 cells
  grid(
    columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
    column-gutter: 7pt,
    row-gutter: 6pt,

    cell(fabox(title: T)[fabox]),
    cell(fabox-sign(size: 1.35)[fabox-sign]),
    cell(fabox-note[fabox-note]),
    cell(tip-card[tip-card]),
    cell(crestbox(title: T)[crestbox]),
    cell(ribbonbox(title: T)[ribbonbox]),
    cell(helixbox(title: T)[helixbox]),

    cell(swooshbox(title: T)[swooshbox]),
    cell(circuitbox(title: T)[circuitbox]),
    cell(keybox[keybox]),
    cell(ringbox[ringbox]),
    cell(punchbox(number: [7])[punchbox]),
    cell(plannerbox(title: T)[plannerbox]),
    cell(filebox[filebox]),

    cell(stubbox(stub: [12])[stubbox]),
    cell(stackbox(title: T)[stackbox]),
    cell(calloutbox(title: T)[calloutbox]),
    cell(tapebox(title: T)[tapebox]),
    cell(chalkbox[chalkbox]),
    cell(markerbox[markerbox]),
    cell(screwbox[screwbox]),

    cell(sashbox[sashbox]),
    cell(flagbox(title: T)[flagbox]),
    cell(notebook-box(title: T)[notebook-box]),
    cell(notebook-box-clean[notebook-clean]),
    cell(ticket(stub: [12])[ticket]),
    cell(post-it[post-it]),
    cell(folder(title: T)[folder]),

    cell(terminal(title: [sh])[terminal]),
    cell(neon[neon]),
    cell(polaroid(caption: [cap], width: 2.9cm, photo-height: 0.8cm, angle: -3deg)[
      #text(size: 5pt, fill: white)[photo]]),
    cell(speech-bubble[speech-bubble]),
    cell(joined-bubbles(a: [Qui ?], b: [Quoi ?])),
    cell(torn-note(width: 5.2)[torn-note]),
    cell(ruled-sheet(width: 5.2)[ruled-sheet]),

    cell(stamp-card(width: 5.2)[stamp-card]),
    cell(index-card(width: 5.2, heading: [Relevé])[index-card]),
    cell(deckle-tag(width: 5.2)[deckle-tag]),
    cell(notepad(width: 5.2)[notepad]),
    cell(felt(colour: rgb("#F7C948"))[surlignage felt]),
    cell(khatambox(title: T, badge: [1])[khatambox]),
    cell(zellijbox(title: T)[zellijbox]),

    cell(mihrabbox(title: T)[mihrabbox]),
    cell(arabesquebox(title: T)[arabesquebox]),
    cell(mosaicbox(title: T)[mosaicbox]),
    cell(fleuronbox(title: T)[fleuronbox]),
    cell(lacebox(title: T)[lacebox]),
    cell(ogeebox[ogeebox]),
    cell(gelbox(width: 90%, text-size: 0.9em)[gelbox]),

    cell(medallion[A]),
    cell(frisebox[frisebox]),
    cell(block(width: 100%, {
      banner-tri(title: [pointue])[banniere]
      v(4pt)
      banner-tri(style: "arrondi", title: [kit])[arrondie]
    })),
    cell(difficulty(3)),
    cell(pictocible(3, size: 0.85cm)),
    cell(pictoskills(3, size: 0.85cm)),
    cell(bicolor-title(end: [Maison])[Devoir]),
  )
  v(9pt)

  // ------------------------------------------------------------ wide bands
  text(lang: "ar", dir: rtl)[
    #leconbox(num: 1, min-height: 2.4em, text-size: 1.7em)[بنية وهندسة أفراد بعض الأنواع الكيميائية]
  ]
  v(8pt)
  grid(columns: (auto, 1.25fr, 0.88fr, 1.05fr, 0.82fr, 1.02fr), column-gutter: 8pt,
    align(center + horizon, pinbox(diameter: 96pt)[السنة الأولى][1 ج م ع ت]),
    align(center + horizon, text(lang: "ar", dir: rtl,
      brushbox(text-size: 1.5em)[البرنامج السنوي لمادة العلوم الفيزيائية])),
    align(center + horizon,
      vintageframe(style: "volutes", width: 100%,
        inset: (x: 0.6em, y: 0.7em), text-size: 1.5em)[vintageframe]),
    align(center + horizon,
      vintagebox(variant: "banniere", width: 100%, height: 78pt,
        text-size: 1.5em)[VINTAGE]),
    align(center + horizon, insetbox(radius: 4pt, width: 100%)[#text(size: 1.2em)[insetbox]]),
    align(center + horizon,
      rosettebox(width: 100%, scale: 0.26, diamonds: 1, inset: 1.2mm)[#text(size: 1.05em)[rosettebox]]),
  )

  v(1fr)
  text(size: 10pt, fill: rgb("#9AA1AB"), font: ("DejaVu Sans",))[
    #("@preview/faboxyst:0.2.0 — 70+ fonctions : fabox, ornate, scrapbook, pictos, RTL…")]
}))
