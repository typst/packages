// =======================================================================
// DATEI: design-system.typ
// ZWECK: Design-System: Definiert die Farbpaletten (Primär, Branding, Alerts) und UI-Tokens der Vorlage.
// =======================================================================

#import "einstellungen.typ"
// NUR der Import wird aktualisiert
#import "@preview/cetz:0.5.2": canvas, draw

// Text-Wrapper (Bewährter draw.content-Ansatz, funktioniert in 0.3.3 und 0.5.2)
#let draw-text(pos, inhalt, size: 10pt, fill: black, weight: "regular", anchor: "center", angle: none) = {
  let styled = text(size: size, fill: fill, weight: weight)[#inhalt]
  if angle != none { 
    draw.content(pos, rotate(angle, styled), anchor: anchor) 
  } else { 
    draw.content(pos, styled, anchor: anchor) 
  }
}

// Polygon aus Linien (Bewährter, versionsunabhängiger Ansatz)
#let polygon(points, stroke: 1pt + black, close: true) = {
  let n = points.len()
  for i in range(n - 1) { draw.line(points.at(i), points.at(i + 1), stroke: stroke) }
  if close and n > 2 { draw.line(points.at(n - 1), points.at(0), stroke: stroke) }
}

// ... (AB HIER DEN REST DEINER DATEI UNVERÄNDERT LASSEN) ...

// Globale Tabellen-Optik
#show heading: it => block(sticky: true)[#it]
#show figure.where(kind: table): set block(breakable: true)
#show figure.caption: set block(sticky: true)
#let inner-v-stroke = if einstellungen.show-vertical-lines { 0.5pt + einstellungen.stroke-color } else { none }
#let outer-stroke = if einstellungen.show-outer-lines { 0.5pt + einstellungen.stroke-color } else { none }
#set table(
  fill: (x, y) => { if y == 0 { einstellungen.header-bg } else if y >= 2 and calc.even(y) { einstellungen.zebra-bg } else { none } },
  stroke: (x, y) => (
    top: if y == 0 { 1.0pt + einstellungen.main-color } else { none },
    bottom: if y == 0 { 1.0pt + einstellungen.main-color } else { 0.5pt + einstellungen.stroke-color },
    left: outer-stroke, right: outer-stroke, x: inner-v-stroke,
  ),
  inset: einstellungen.table-inset,
)
#show table.cell.where(y: 0): it => [
  #set text(weight: "bold", fill: if einstellungen.dev-mode { oklch(100%, 0, 0deg) } else { einstellungen.main-color })
  #it
]
#show figure.where(kind: table): set align(einstellungen.table-alignment)

// Hilfsfunktionen
#let format-de(n) = {
  let s = str(n).replace(".", ",")
  let parts = s.split(",")
  let int-part = parts.at(0)
  let result = ""
  let len = int-part.len()
  for i in range(len) {
    if i > 0 and calc.rem(len - i, 3) == 0 { result += " " } // Normales Leerzeichen als Tausendertrenner
    result += int-part.at(i)
  }
  if parts.len() > 1 { result += "," + parts.at(1) }
  return result
}
#let kat-farbe(index) = {
  let farben = (einstellungen.accent-1, einstellungen.accent-2, einstellungen.accent-3, einstellungen.accent-4, einstellungen.accent-5, einstellungen.accent-6)
  return farben.at(calc.rem(index, 6))
}
#let ampel-symbol(rang) = {
  if not einstellungen.ampel-symbole { return "" }
  if rang == 1 { return " ✓" } else if rang == 2 { return " ○" } else if rang == 3 { return " ✗" } else { return "" }
}
#let get-rank-color(pos) = {
  if pos == 0 { return einstellungen.color-1st } else if pos == 1 { return einstellungen.color-2nd } else if pos == 2 { return einstellungen.color-3rd } else { return none }
}

// Diagramm-Bausteine
#let plot-hintergrund(breite, hoehe) = {
  draw.rect((0, 0), (breite, hoehe), fill: einstellungen.plot-bg, stroke: none)
}
#let datenlabel(x, y, inhalt, anchor: "center") = {
  draw.rect((x - 0.3, y - 0.18), (x + 0.3, y + 0.18), fill: einstellungen.data-label-bg, stroke: 0.3pt + einstellungen.stroke-color)
  draw-text((x, y), inhalt, size: einstellungen.data-label-size, weight: "bold", fill: einstellungen.main-color, anchor: anchor)
}
#let legende-zeichnen(eintraege, x, y, spalten: 1) = {
  let zh = 0.5
  let eb = 3.0
  let gh = eintraege.len() * zh / spalten + 0.3
  let gb = eb * spalten + 0.3
  draw.rect((x, y), (x + gb, y - gh), fill: oklch(100%, 0, 0deg), stroke: 0.5pt + einstellungen.stroke-color)
  for (i, eintrag) in eintraege.enumerate() {
    let label = eintrag.at(0)
    let farbe = eintrag.at(1)
    let sp = calc.floor(i / calc.ceil(eintraege.len() / spalten))
    let ze = calc.rem(i, calc.ceil(eintraege.len() / spalten))
    let ex = x + 0.2 + sp * eb
    let ey = y - 0.3 - ze * zh
    draw.rect((ex, ey), (ex + 0.3, ey - 0.25), fill: farbe, stroke: 0.3pt + einstellungen.stroke-color)
    draw-text((ex + 0.45, ey - 0.12), label, size: einstellungen.legend-size, fill: einstellungen.label-color, anchor: "west")
  }
}

// S/W-Muster
#let muster-zeichnen(x1, y1, x2, y2, muster-index, farbe) = {
  if not einstellungen.sw-patterns { return }
  let mt = calc.rem(muster-index, 6)
  if mt == 0 { return }
  let sp = 0.22
  let sw = 0.3pt + farbe
  if mt == 1 {
    let steps = calc.ceil((y2 - y1) / sp)
    for i in range(1, steps) {
      let yy = y1 + i * sp
      draw.line((x1, yy), (x2, yy), stroke: sw)
    }
  } else if mt == 2 {
    let steps = calc.ceil((x2 - x1) / sp)
    for i in range(1, steps) {
      let xx = x1 + i * sp
      draw.line((xx, y1), (xx, y2), stroke: sw)
    }
  } else if mt == 3 {
    let sx = calc.ceil((x2 - x1) / sp)
    let sy = calc.ceil((y2 - y1) / sp)
    for ix in range(sx) {
      for iy in range(sy) {
        draw.circle((x1 + ix * sp + sp / 2, y1 + iy * sp + sp / 2), radius: 0.03, fill: farbe, stroke: none)
      }
    }
  } else if mt == 4 {
    let sx = calc.ceil((x2 - x1) / sp)
    let sy = calc.ceil((y2 - y1) / sp)
    for ix in range(sx) {
      for iy in range(sy) {
        let cx = x1 + ix * sp + sp / 2
        let cy = y1 + iy * sp + sp / 2
        draw.line((cx - 0.06, cy), (cx + 0.06, cy), stroke: sw)
        draw.line((cx, cy - 0.06), (cx, cy + 0.06), stroke: sw)
      }
    }
  } else if mt == 5 {
    let sx = calc.ceil((x2 - x1) / sp)
    let sy = calc.ceil((y2 - y1) / sp)
    for i in range(1, sy) { draw.line((x1, y1 + i * sp), (x2, y1 + i * sp), stroke: sw) }
    for i in range(1, sx) { draw.line((x1 + i * sp, y1), (x1 + i * sp, y2), stroke: sw) }
  }
}

// Ein Diagramm/Bild in einem standardisierten Wrapper einbinden
#let diagramm-figur(caption-text: "", source-text: "", caption-pos: auto, breite: auto, inhalt) = {
  let pos = if caption-pos == auto { einstellungen.chart-caption-position } else { caption-pos }
  show figure.caption: set figure.caption(position: pos)
  let q-element-grid = if source-text != "" and not einstellungen.source-in-outline [
    #set text(size: 0.85em, style: "italic", fill: einstellungen.source-color)
    Quelle: #source-text
  ]
  let q-element-caption = if source-text != "" and einstellungen.source-in-outline [
    \ Quelle: #source-text
  ]
  let is-caption-bottom = pos == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)

  if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      kind: image,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Abbildung],
      caption: [
        #caption-text#q-element-caption
      ],
      if breite == auto { inhalt } else { block(width: breite)[#inhalt] }
    )
  } else {
    let place-source-top = false // The only other option for images is bottom (since caption is top and source is bottom) 
    figure(
      kind: image,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Abbildung],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        if place-source-top { q-element-grid },
        if breite == auto { inhalt } else { block(width: breite)[#inhalt] },
        if not place-source-top { q-element-grid }
      )
    )
  }
}

// Eine Tabelle in einem standardisierten Wrapper einbinden
#let tabellen-figur(caption-text: "", source-text: "", caption-pos: auto, breite: auto, inhalt) = {
  let cap-pos = if caption-pos == auto { einstellungen.table-caption-position } else { caption-pos }
  show figure.caption: set figure.caption(position: cap-pos)
  let q-element-grid = if source-text != "" and not einstellungen.source-in-outline [
    #set text(size: 0.85em, style: "italic", fill: einstellungen.source-color)
    Quelle: #source-text
  ]
  let q-element-caption = if source-text != "" and einstellungen.source-in-outline [
    \ Quelle: #source-text
  ]
  let is-caption-bottom = cap-pos == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)

  if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      kind: table,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        if breite == auto { inhalt } else { block(width: breite)[#inhalt] }
      )
    )
  } else {
    let place-source-bottom = (einstellungen.source-position == "bottom") or (einstellungen.source-position == "auto")
    figure(
      kind: table,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        if not place-source-bottom { q-element-grid },
        if breite == auto { inhalt } else { block(width: breite)[#inhalt] },
        if place-source-bottom { q-element-grid }
      )
    )
  }
}

#let a3-seite(inhalt) = {
  if not einstellungen.auto-a3 { return inhalt }
  if einstellungen.a3-landscape { return page(width: 297mm, height: 420mm, flipped: true)[#inhalt] }
  else { return page(width: 297mm, height: 420mm)[#inhalt] }
}

// Tabellen-Makro
#let einfache-tabelle(columns, align: left, caption-text: "", source-text: "", footer-data: none, header-data: (), body-data: (), caption-position-override: auto) = {
  let cap-pos = if caption-position-override == auto { einstellungen.table-caption-position } else { caption-position-override }
  let table-cells = ()
  table-cells += header-data
  table-cells += body-data
  if footer-data != none {
    table-cells += (table.hline(stroke: 1.2pt + einstellungen.main-color),)
    table-cells += footer-data
  }
  let resolved-columns = if einstellungen.table-width == auto and type(columns) == array {
    columns.map(c => if type(c) == fraction { auto } else { c })
  } else { columns }
  show figure.caption: set figure.caption(position: cap-pos)
  
  let q-element-grid = if source-text != "" and not einstellungen.source-in-outline [
    #set text(size: 0.85em, style: "italic", fill: einstellungen.source-color)
    Quelle: #source-text
  ]
  let q-element-caption = if source-text != "" and einstellungen.source-in-outline [
    \ Quelle: #source-text
  ]
  let is-caption-bottom = cap-pos == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)
  
  if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      kind: table,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        block(width: einstellungen.table-width, table(columns: resolved-columns, align: align, table.header(..header-data), ..table-cells.slice(header-data.len())))
      )
    )
  } else {
    let place-source-bottom = true
    figure(
      kind: table,
      supplement: text(weight: einstellungen.caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        if not place-source-bottom { q-element-grid },
        block(width: einstellungen.table-width, table(columns: resolved-columns, align: align, table.header(..header-data), ..table-cells.slice(header-data.len()))),
        if place-source-bottom { q-element-grid }
      )
    )
  }
}

// Nutzwertanalyse
#let teilnutzen-a = ()
#let teilnutzen-b = ()
#let teilnutzen-c = ()
#let gesamt-a = 0.0
#let gesamt-b = 0.0
#let gesamt-c = 0.0
#for i in range(einstellungen.gewichtungen.len()) {
  let w = einstellungen.gewichtungen.at(i).gew
  let tna = calc.round(w * einstellungen.bewertung-a.at(i) / 10.0, digits: 1)
  let tnb = calc.round(w * einstellungen.bewertung-b.at(i) / 10.0, digits: 1)
  let tnc = calc.round(w * einstellungen.bewertung-c.at(i) / 10.0, digits: 1)
  teilnutzen-a += (tna,)
  teilnutzen-b += (tnb,)
  teilnutzen-c += (tnc,)
  gesamt-a += tna
  gesamt-b += tnb
  gesamt-c += tnc
}
#let gesamt-a = calc.round(gesamt-a, digits: 1)
#let gesamt-b = calc.round(gesamt-b, digits: 1)
#let gesamt-c = calc.round(gesamt-c, digits: 1)
#let nwa-ergebnisse = (
  (name: "LKW A (Mercedes-Benz Actros)", punkte: gesamt-a),
  (name: "LKW B (Volvo FH)", punkte: gesamt-b),
  (name: "LKW C (MAN TGX)", punkte: gesamt-c),
)
#let nwa-sortiert = nwa-ergebnisse.sorted(key: it => it.punkte).rev()

// Kompatibilitäts-Aliase
#let sortiert = nwa-sortiert
#let get-rank-color = (name, sortiert) => {
  let pos = sortiert.position(it => it.name == name)
  if pos == 0 { return einstellungen.color-1st } else if pos == 1 { return einstellungen.color-2nd } else if pos == 2 { return einstellungen.color-3rd } else { return none }
}
#let teilnutzen_a = teilnutzen-a
#let teilnutzen_b = teilnutzen-b
#let teilnutzen_c = teilnutzen-c
#let gesamt_a = gesamt-a
#let gesamt_b = gesamt-b
#let gesamt_c = gesamt-c
#let bewertung_a = einstellungen.bewertung-a
#let bewertung_b = einstellungen.bewertung-b
#let bewertung_c = einstellungen.bewertung-c