// =======================================================================
// DATEI: ui.typ
// ZWECK: UI-Komponenten (Hinweisboxen, Formatierungs-Boxen, Tabellen-Wrapper)
// =======================================================================

#import "einstellungen.typ"
#import "architektur.typ": tab-zebra
#import "@preview/showybox:2.0.4": showybox
#import "utils.typ": parse-breite

// Ein Bild einbinden (zentriert, mit Beschriftung und Quelle)
#let bild(pfad, ..args, Breite: 80%) = {
  let pos = args.pos()
  let beschreibung = if pos.len() > 0 { pos.at(0) } else { "" }
  let quelle = if pos.len() > 1 { pos.at(1) } else { "Eigene Darstellung" }
  
  let has_warn = beschreibung == ""
  let parsed-breite = parse-breite(Breite)
  let named = args.named()
  let alt-text = if "alt" in named { named.at("alt") } else { none }
  
  let q-text = if quelle != "" [ #quelle ] else [ #text(fill: red, weight: "bold")[FEHLT: Quelle] ]
  
  let q-element-grid = if not einstellungen.source-in-outline [
    #set text(size: einstellungen.quellen-size, style: einstellungen.quellen-formatierung)
    Quelle: #q-text
  ]
  
  let q-element-caption = if einstellungen.source-in-outline [
    \ Quelle: #q-text
  ]

  let is-caption-bottom = einstellungen.chart-caption-position == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)

  let inhalt = image(pfad, width: parsed-breite, alt: alt-text)

  let content = if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      inhalt,
      caption: [
        #if beschreibung != "" [ #beschreibung ] else [ #text(fill: red, weight: "bold")[FEHLT: Beschreibung] ]
        #q-element-caption
      ]
    )
  } else {
    let place-source-top = false
    figure(
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        if place-source-top { q-element-grid },
        inhalt,
        if not place-source-top { q-element-grid }
      ),
      caption: [
        #if beschreibung != "" [ #beschreibung ] else [ #text(fill: red, weight: "bold")[FEHLT: Beschreibung] ]
        #q-element-caption
      ]
    )
  }
  
  if has_warn {
    block(stroke: (left: 4pt + red), inset: (left: 8pt), width: 100%)[
      #content
      #v(0.5em)
      #text(fill: red, weight: "bold", size: 9pt)[⚠️ WARNUNG: Bildbeschreibung oder Quelle fehlt! Diese müssen für die Facharbeit zwingend angegeben werden.]
    ]
  } else {
    content
  }
}

// Eine simple Tabelle einbinden (Zebramuster, keine vertikalen Linien)
#let einfache-tabelle(spalten, quelle: "eigene Erhebung", align: auto, ..inhalt) = {
  let q-element-grid = if quelle != "" and not einstellungen.source-in-outline [
    #set text(size: einstellungen.quellen-size, style: einstellungen.quellen-formatierung)
    Quelle: #quelle
  ]
  
  let q-element-caption = if quelle != "" and einstellungen.source-in-outline [
    \ Quelle: #quelle
  ]
  
  let is-caption-bottom = einstellungen.table-caption-position == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)

  [
  #if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      caption: [Tabellarische Übersicht#q-element-caption],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        tab-zebra(
          columns: spalten,
          align: align,
          ..inhalt
        )
      )
    )
  } else {
    let place-source-bottom = (einstellungen.source-position == "bottom") or (einstellungen.source-position == "auto")
    figure(
      caption: [Tabellarische Übersicht#q-element-caption],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        if not place-source-bottom { q-element-grid },
        tab-zebra(
          columns: spalten,
          align: align,
          ..inhalt
        ),
        if place-source-bottom { q-element-grid }
      )
    )
  }
  ]
}

// Hinweisbox (farbig eingerahmt für wichtige Informationen)
#let hinweisbox(titel: "Hinweis", inhalt) = block(
  breakable: false,
  fill: if einstellungen.dev-mode { rgb("2a3a5a") } else { rgb("f0f5fa") },
  stroke: (left: einstellungen.box-rand-breite + einstellungen.box-rand-farbe),
  inset: 1em,
  width: 100%,
)[
  #text(weight: "bold", fill: einstellungen.primärfarbe)[#titel] \
  #v(0.5em)
  #text(fill: if einstellungen.dev-mode { rgb("e0e0e0") } else { rgb("333333") })[#inhalt]
]

// ==========================================
// SHOWYBOX KOMPONENTEN (Corporate Design)
// ==========================================

#let definition(titel: "Definition", inhalt) = {
  showybox(
    breakable: false,
    frame: (
      border-color: einstellungen.box-rand-farbe,
      title-color: einstellungen.header-bg,
      body-color: if einstellungen.dev-mode { rgb("1a1a2e") } else { rgb("ffffff") },
      radius: 0pt,
      thickness: 1pt
    ),
    title: [#text(fill: einstellungen.table-text-color, weight: "bold")[#titel]],
    [#inhalt]
  )
}

#let beispiel(titel: "Beispiel", inhalt) = {
  showybox(
    breakable: false,
    frame: (
      border-color: einstellungen.box-rand-farbe,
      title-color: einstellungen.header-bg,
      body-color: if einstellungen.dev-mode { rgb("1a1a2e") } else { rgb("ffffff") },
      radius: 0pt,
      thickness: (left: einstellungen.box-rand-breite, rest: 0.5pt)
    ),
    title: [#text(fill: einstellungen.table-text-color, weight: "bold")[#titel]],
    [#inhalt]
  )
}

#let merke(titel: "Merke", inhalt) = {
  showybox(
    breakable: false,
    frame: (
      border-color: einstellungen.box-rand-farbe,
      title-color: einstellungen.header-bg,
      body-color: if einstellungen.dev-mode { rgb("2a3a5a") } else { rgb("f0f5fa") },
      radius: 0pt,
      thickness: 1pt,
      dash: "dashed"
    ),
    title: [#text(fill: einstellungen.table-text-color, weight: "bold")[#titel]],
    [#inhalt]
  )
}
