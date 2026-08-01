#import "../_system/ui.typ": bild, einfache-tabelle, hinweisbox, definition, beispiel, merke
#import "../_system/utils.typ": a3-seite
#import "@preview/cetz:0.5.2": canvas, draw
#import "../_system/einstellungen.typ"
#import "../_system/design-system.typ": format-de, diagramm-figur, tabellen-figur

= Anhang

#set heading(numbering: none)

#heading(level: 2, numbering: none, outlined: false)[Anlagenverzeichnis]
#context {
  let entries = query(heading.where(level: 2).after(here()))
  for e in entries {
    if e.outlined {
      link(e.location())[
        #box(width: 100%)[
          #e.body
          #box(width: 1fr, if einstellungen.verzeichnis-fuellzeichen {
            repeat[#text(size: einstellungen.verzeichnis-fuellzeichen-groesse, baseline: 0.5pt)[.]#h(
                einstellungen.verzeichnis-fuellzeichen-abstand,
              )]
          } else { none })
          #counter(page).at(e.location()).first()
        ]
      ]
      parbreak()
    }
  }
}

#hinweisbox(titel: "Wichtig für den Anhang")[
  Im Anhang werden sämtliche Materialien platziert, welche den Lesefluss im Hauptteil beeinträchtigen würden (beispielsweise umfangreiche Tabellen, Fragebögen oder Code-Listings). Bei der Auslagerung von Inhalten in den Anhang ist stets ein expliziter Verweis im Haupttext erforderlich.
]
#show figure.where(kind: table): set figure.caption(position: top)

#set page(flipped: true)
== Anlage A: Typst Markdown Cheat Sheet <anlage-A>

#tabellen-figur(
  caption-text: [Typst Formatierungs-Spickzettel],
  source-text: [Eigene Darstellung],
  table(
    columns: (1.2fr, 1.5fr, 2fr),
    align: left,
    table.header([*Kategorie / Element*], [*Typst-Code (Eingabe)*], [*Bedeutung / Ergebnis*]),
    [Fett], [`*Gefahrgutverordnung*`], [Formatiert den Text *Gefahrgutverordnung* fett],
    [Kursiv], [`_Just-in-Time_`], [Formatiert den Text _Just-in-Time_ kursiv],
    [Überschrift 1. Ebene], [`= Einleitung`], [Neues Hauptkapitel "Einleitung"],
    [Überschrift 2. Ebene], [`== Methode`], [Unterkapitel "Methode"],
    [Überschrift 3. Ebene], [`=== Datenerhebung`], [Unter-Unterkapitel "Datenerhebung"],
    [Aufzählung (ungeordnet)],
    [`- Beschaffungslogistik`\
      `- Produktionslogistik`\
      `- Distributionslogistik`],
    [
      - Beschaffungslogistik
      - Produktionslogistik
      - Distributionslogistik
    ],

    [Aufzählung (nummeriert)],
    [`+ Wareneingangsprüfung`\
      `+ Einlagerung`\
      `+ Kommissionierung`],
    [
      + Wareneingangsprüfung
      + Einlagerung
      + Kommissionierung
    ],

    [Link], [`#link("url")[Google]`], [Klickbarer Hyperlink "Google"],
    [Label setzen], [`<swot-tabelle>`], [Markierung für Querverweise],
    [Verweis], [`@swot-tabelle`], [Verweist auf z.B. "Tabelle 2"],
    [Literaturzitat], [`@oelfke2023[S. 5]`], [Fußnote "Oelfke (2023), S. 5"],
    [Mathematische Formel], [`$E = m c^2$`], [$E = m c^2$],
    [Zusammenhalten (Box)], [`#box[BBZ Dormagen]`], [Verhindert Silbentrennung],
    [Manueller Umbruch], [`#pagebreak()`], [Erzwingt eine neue Seite],
  )
)
#set page(flipped: false)

#let caption-supplement-weight = "regular" // "Tabelle 1:" ist normal
#let caption-body-weight = "bold"          // Der Titel ist fett

// ============================================================================
// ZENTRALE KAPTION-KONFIGURATION (Global anpassbar)
// ============================================================================

// ============================================================================
// 5. HELPER: TITEL UND TABELLE ZUSAMMENHALTEN
// Verhindert zuverlässig den Seitenumbruch zwischen Überschrift und Tabelle.
// ============================================================================
#let tabelle-mit-titel(level, titel, tabellen-inhalt) = {
  block(breakable: false)[
    heading(level: level)[#titel]
    tabellen-inhalt
  ]
}

// ============================================================================
// 6. FUNKTION: EINFACHE TABELLE (Zentral optimiert)
// ============================================================================
// ... (deine ganzen #let Farb- und Stil-Definitionen von oben) ...

// ============================================================================
// HELPER: TITEL UND TABELLE ZUSAMMENHALTEN
// ============================================================================
#let tabelle-mit-titel(level, titel, tabellen-inhalt) = {
  block(breakable: false)[
    heading(level: level)[#titel]
    tabellen-inhalt
  ]
}

// ============================================================================
// FUNKTION: EINFACHE TABELLE
// ============================================================================
#let logistik-tabelle(
  columns,
  align: left,
  caption-text: "",
  source-text: "",
  footer-data: none,
  header-data: (),
  body-data: (),
) = {
  let table-cells = ()
  if header-data != () {
    table-cells.push(table.header(..header-data))
  }
  table-cells += body-data

  if footer-data != none {
    table-cells.push(table.hline(stroke: 1.2pt + einstellungen.main-color))
    table-cells += footer-data
  }

  let resolved-columns = if einstellungen.table-width == auto and type(columns) == array {
    columns.map(c => if type(c) == fraction { auto } else { c })
  } else {
    columns
  }

  let q-element-grid = if source-text != "" and not einstellungen.source-in-outline [
    #set text(size: 0.85em, style: "italic", fill: einstellungen.source-color)
    Quelle: #source-text
  ]
  let q-element-caption = if source-text != "" and einstellungen.source-in-outline [
    \ Quelle: #source-text
  ]
  let is-caption-bottom = einstellungen.table-caption-position == bottom
  let append-to-caption = not einstellungen.source-in-outline and (einstellungen.source-position == "caption" or is-caption-bottom)

  if append-to-caption {
    show figure.caption: it => [ #it #q-element-grid ]
    figure(
      kind: table,
      supplement: text(weight: caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        block(
          width: einstellungen.table-width,
          table(
            columns: resolved-columns,
            align: align,
            inset: 8pt,
            ..table-cells
          ),
        )
      )
    )
  } else {
    let place-source-bottom = (einstellungen.source-position == "bottom") or (einstellungen.source-position == "auto")
    figure(
      kind: table,
      supplement: text(weight: caption-supplement-weight)[Tabelle],
      caption: [
        #caption-text#q-element-caption
      ],
      grid(
        columns: 1,
        row-gutter: einstellungen.source-spacing,
        align: left,
        if not place-source-bottom { q-element-grid },
        block(
          width: einstellungen.table-width,
          table(
            columns: resolved-columns,
            align: align,
            inset: 8pt,
            ..table-cells
          ),
        ),
        if place-source-bottom { q-element-grid }
      )
    )
  }
}

// ============================================================================
// ============================================================================
#pagebreak()
== Anlage B: Frachtbrief (CMR) <anlage-B>
#logistik-tabelle(
  (0.6fr, 1.2fr, 1.2fr, 0.8fr),
  align: (left, left, left, right),
  caption-text: [Beispielhafte Frachtbrief-Daten (CMR)],
  source-text: [Eigene Darstellung nach CMR-Standard, 2024],
  header-data: ([Sendungs-Nr.], [Absender], [Empfänger], [Gewicht (kg)]),
  body-data: (
    [SN-2024-001],
    [Müller Spedition GmbH],
    [Schmidt Logistik KG],
    [1~250],
    [SN-2024-002],
    [Weber Fracht GmbH],
    [Fischer Handel AG],
    [450],
    [SN-2024-003],
    [Becker Transport],
    [Schulz Einzelhandel],
    [80],
    [SN-2024-004],
    [Hahn Cargo],
    [Koch Industriebedarf],
    [3~100],
  ),
)

// ============================================================================
// TABELLE 2: Transportkosten
// ============================================================================
#pagebreak()
== Anlage C: Transportkostenvergleich <anlage-C>
#logistik-tabelle(
  (0.8fr, 1fr, 0.8fr, 0.9fr),
  align: (left, left, right, right),
  caption-text: [Vergleich der Transportmittel und Kosten],
  source-text: [Interne Kalkulation, Logistikabteilung, 2024],
  header-data: ([Transportmittel], [Route], [Dauer (h)], [Kosten (€)]),
  footer-data: (
    text(weight: "bold")[Summe],
    [-],
    [-],
    text(weight: "bold")[2~060,00],
  ),
  body-data: (
    [LKW (Plane)],
    [Hamburg – München],
    [8],
    [850,00],
    [Güterbahn],
    [Hamburg – München],
    [14],
    [620,00],
    [Kombinierter Verkehr],
    [Hamburg – München],
    [18],
    [590,00],
  ),
)

// ============================================================================
// TABELLE 3: Abfahrtskontrolle
// ============================================================================
#pagebreak()
== Anlage D: Tourenplan <anlage-D>

#logistik-tabelle(
  (0.5fr, 1fr, 1fr, 1.5fr),
  align: (right, left, left, left),
  caption-text: [Tourenplan für die DACH-Region],
  source-text: [Telematikdaten, Fleet Management System, 2024],
  header-data: ([Tag], [Standort], [Fahrzeug], [Aktivitäten]),
  body-data: (
    [1],
    [Hamburg, DE],
    [LKW-Plane 40~t],
    [Ladung: Elektronik, Abfahrt 06:00],
    [2],
    [Berlin, DE],
    [LKW-Plane 40~t],
    [Auslieferung, Rückladung: Autoteile],
    [3],
    [München, DE],
    [LKW-Kühlkoffer],
    [Temperaturkontrolle, Entladung],
    [4],
    [Zürich, CH],
    [LKW-Kühlkoffer],
    [Zollabfertigung, Auslieferung],
    [5],
    [Hamburg, DE],
    [LKW-Plane 40~t],
    [Rückkehr, Fahrzeugkontrolle],
  ),
)

// ============================================================================
// TABELLE 7: Schichtplan
// ============================================================================
#pagebreak()
== Anlage E: Schichtplan Disposition <anlage-E>
#logistik-tabelle(
  (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  align: (x, y) => if x == 0 or y == 0 { left } else { center },
  caption-text: [Dispositions- und Schichtplan],
  source-text: [Personaleinsatzplanung, 2024],
  header-data: ([Mitarbeiter], [Montag], [Dienstag], [Mittwoch], [Donnerstag], [Freitag]),
  body-data: (
    [Max Mustermann],
    table.cell(colspan: 2)[Einsatz: Route Nord],
    table.cell(colspan: 2)[_Werkstatt_],
    [*Urlaub*],
    [Erika Musterfrau],
    [_Werkstatt_],
    table.cell(colspan: 4)[Einsatz: Route Süd],
  ),
)

// ============================================================================
// TABELLE 8: Gefahrgut (A4 Querformat)
// ============================================================================

#set page("a4", flipped: true)
#pagebreak()
== Anlage F: Abfahrtskontrolle (VDI 2700) <anlage-F>

#logistik-tabelle(
  (0.3fr, 2fr),
  align: (center, left),
  caption-text: [Abfahrtskontrolle für LKW-Fahrer],
  source-text: [Checkliste nach VDI 2700, 2024],
  header-data: (
    [Status],
    [Prüfpunkt],
  ),
  body-data: (
    [☒],
    [Reifendruck und Profiltiefe geprüft],
    [☒],
    [Ladungssicherung gemäß VDI 2700 dokumentiert],
    [☐],
    [Frachtpapiere (CMR) vollständig und unterschrieben],
    [☐],
    [Kühltemperatur geprüft und auf -18~°C eingestellt],
  ),
)

// ============================================================================
// TABELLE 4: Incoterms 2020
// ============================================================================
#pagebreak()
#set page("a3", flipped: true)
#set text(hyphenate: false)
== Anlage G: Gefahrgutübersicht (ADR) <anlage-G>
#logistik-tabelle(
  (1fr, 0.6fr, 0.6fr, 1fr, 0.8fr, 1.2fr, 1.5fr, 1fr, 1.2fr, 0.8fr),
  align: (left, center, center, center, center, left, left, center, left, right),
  caption-text: [Detaillierte Gefahrgut- und Sicherheitsübersicht \ für den Transport],
  source-text: [Gefahrgutbeauftragter, Unternehmensrichtlinie, 2024],
  header-data: (
    [Gefahrgut],
    [UN-Nr.],
    [Klasse],
    [Verpackungs-\ gruppe],
    [Tunnelcode],
    [Besonderheiten],
    [Sicherheits-\ maßnahmen],
    [Gefahrzettel],
    [Zusatz-\ ausrüstung],
    [Menge\ (max)],
  ),
  body-data: (
    [Benzin],
    [1203],
    [3],
    [II],
    [D/E],
    [Leichtentzündlich],
    [Feuerlöscher Klasse B, Erdung],
    [Flamme (Rot)],
    [Warndreieck, Warnweste],
    [3000 L],
    [Schwefelsäure],
    [1830],
    [8],
    [II],
    [D/E],
    [Ätzend],
    [Schutzkleidung, Augenschutz],
    [Ätzend (S/W)],
    [Augenspülflasche],
    [1000 L],
    [Natriumhydroxid],
    [1823],
    [8],
    [II],
    [D/E],
    [Ätzend, wassergefährdend],
    [Chemikalienschutzhandschuhe],
    [Ätzend (S/W)],
    [Schutzhandschuhe],
    [500 kg],
    [Aceton],
    [1090],
    [3],
    [II],
    [D/E],
    [Leichtentzündlich],
    [Belüftung, Explosionsgefahr],
    [Flamme (Rot)],
    [Erdungskabel],
    [1500 L],
    [Wasserstoff],
    [1049],
    [2.1],
    [-],
    [B/D],
    [Extrem entzündlich],
    [Druckbehälter prüfen, Rauchverbot],
    [Flamme (Rot)],
    [Atemschutz],
    [500 kg],
    [Dieselkraftstoff],
    [1202],
    [3],
    [III],
    [D/E],
    [Entzündlich],
    [Feuerlöscher, Auffangwanne],
    [Flamme (Rot)],
    [Kanalabdeckung],
    [5000 L],
    [Ammoniumnitrat],
    [1942],
    [5.1],
    [III],
    [D/E],
    [Oxidierend],
    [Getrennt von brennbaren Stoffen],
    [Flamme über Kreis],
    [Besen, Schaufel],
    [2000 kg],
    [Kaliumpermanganat],
    [1490],
    [5.1],
    [II],
    [D/E],
    [Oxidierend, ätzend],
    [Schutzbrille, Handschuhe],
    [Flamme über Kreis],
    [Augenspülflasche],
    [1000 kg],
    [Methanol],
    [1230],
    [3],
    [II],
    [D/E],
    [Giftig, entzündlich],
    [Atemschutzmaske],
    [Totenkopf, Flamme],
    [Vollmaske],
    [800 L],
    [Chlor],
    [1017],
    [2.3],
    [-],
    [C/D],
    [Giftig, ätzend],
    [Gasschutzanzug, Vollmaske],
    [Totenkopf, Ätzend],
    [Fluchtfilter],
    [200 kg],
  ),
)

Die Tabelle fasst die wichtigsten Gefahrgutklassen für den straßengebundenen Transport zusammen. Sie dient dem Fahrpersonal als schnelle Referenz für die korrekte Beladung und die Einhaltung der Tunnelkategorien gemäß ADR.

// ============================================================================
// TABELLE 9: Quartalsübersicht
// ============================================================================
#set page("a4")
#pagebreak()
== Anlage H: Risikoübergang (Incoterms 2020) <anlage-H>
#logistik-tabelle(
  (1fr, 1.5fr, 1.5fr),
  align: left,
  caption-text: [Risikoübergang nach Incoterms 2020],
  source-text: [ICC Incoterms 2020],
  header-data: ([], [*EXW (Ab Werk)*], [*DDP (Geliefert verzollt)*]),
  body-data: (
    [*Transportkosten*],
    [_Käufer_],
    [_Verkäufer_],
    [*Versicherung*],
    [_Käufer_],
    [_Verkäufer_],
    [*Risikoübergang*],
    table.cell(stroke: 1.0pt + einstellungen.main-color, fill: einstellungen.color-3rd.lighten(60%))[
      _Beim Verladen_ \ Frühzeitiges Risiko für den Käufer.
    ],
    table.cell(stroke: 1.0pt + einstellungen.main-color, fill: einstellungen.color-1st.lighten(60%))[
      _Bei Ankunft_ \ Maximale Sicherheit für den Käufer.
    ],
  ),
)

// ============================================================================
// 5. HELPER-FUNKTIONEN
// ============================================================================



// Ampelfarbe basierend auf dem Rang eines LKW ermitteln
#let get-rank-color = (name, sortiert) => {
  let pos = sortiert.position(it => it.name == name)
  if pos == 0 { return einstellungen.color-1st }
  if pos == 1 { return einstellungen.color-2nd }
  if pos == 2 { return einstellungen.color-3rd }
  return none
}

// ============================================================================
// 6. DATENBASIS DER NUTZWERTANALYSE
// ============================================================================
#let gewichtungen = (
  (kriterium: "Kraftstoffeffizienz", gew: 30),
  (kriterium: "Anschaffungspreis", gew: 25),
  (kriterium: "Wartung & Service-Netz", gew: 20),
  (kriterium: "Fahrerkomfort & Assistenz", gew: 15),
  (kriterium: "Telematik-Integration", gew: 10),
)

#let bewertung_a = (8, 7, 9, 8, 7)
#let bewertung_b = (9, 6, 8, 9, 8)
#let bewertung_c = (7, 8, 7, 7, 9)

// ============================================================================
// 7. AUTOMATISCHE BERECHNUNG
// ============================================================================
#let teilnutzen_a = ()
#let teilnutzen_b = ()
#let teilnutzen_c = ()

#let gesamt_a = 0.0
#let gesamt_b = 0.0
#let gesamt_c = 0.0

#for i in range(gewichtungen.len()) {
  let w = gewichtungen.at(i).gew
  let ba = bewertung_a.at(i)
  let bb = bewertung_b.at(i)
  let bc = bewertung_c.at(i)

  let tna = calc.round(w * ba / 10.0, digits: 1)
  let tnb = calc.round(w * bb / 10.0, digits: 1)
  let tnc = calc.round(w * bc / 10.0, digits: 1)

  teilnutzen_a += (tna,)
  teilnutzen_b += (tnb,)
  teilnutzen_c += (tnc,)

  gesamt_a += tna
  gesamt_b += tnb
  gesamt_c += tnc
}

#let gesamt_a = calc.round(gesamt_a, digits: 1)
#let gesamt_b = calc.round(gesamt_b, digits: 1)
#let gesamt_c = calc.round(gesamt_c, digits: 1)

#let ergebnisse = (
  (name: "LKW A (Mercedes-Benz Actros)", punkte: gesamt_a),
  (name: "LKW B (Volvo FH)", punkte: gesamt_b),
  (name: "LKW C (MAN TGX)", punkte: gesamt_c),
)

#let sortiert = ergebnisse.sorted(key: it => it.punkte).rev()

// ============================================================================
// 8. DOKUMENTENINHALT
// ============================================================================

// --- TABELLE 1: MUSS- UND KANN-KRITERIEN ZUSAMMENGEFASST ---
#let table-content = {
  let rows = ()

  // HEADER (mit table.header umschlossen für Wiederholung auf Folgeseiten)
  rows += (
    table.header(
      [*Bewertung*],
      [*Anforderung / Gew.*],
      table.cell(colspan: 2, align: center)[*LKW A*],
      table.cell(colspan: 2, align: center)[*LKW B*],
      table.cell(colspan: 2, align: center)[*LKW C*],
      [],
      [],
      [*Pkte*],
      [*TN*],
      [*Pkte*],
      [*TN*],
      [*Pkte*],
      [*TN*],
    ),
  )

  // MUSS-KRITERIEN (LKW-Bewertungen über 2 Spalten zentriert, exakt 8 Spalten: 1+1+2+2+2)
  rows += (
    ["Zuladung"],
    ["mind. 12 t"],
    table.cell(colspan: 2, align: center)[13 t (✔)],
    table.cell(colspan: 2, align: center)[12,5 t (✔)],
    table.cell(colspan: 2, align: center)[12 t (✔)],
  )

  rows += (
    ["Abgasnorm"],
    ["Euro 6d"],
    table.cell(colspan: 2, align: center)[Euro 6d (✔)],
    table.cell(colspan: 2, align: center)[Euro 6d (✔)],
    table.cell(colspan: 2, align: center)[Euro 6d (✔)],
  )

  rows += (
    ["Fahrerhaus"],
    ["Schlafkabine"],
    table.cell(colspan: 2, align: center)[Großraum (✔)],
    table.cell(colspan: 2, align: center)[Globetrotter (✔)],
    table.cell(colspan: 2, align: center)[XXL (✔)],
  )

  // Trennlinie
  rows += (table.hline(stroke: 1.0pt + einstellungen.main-color),)

  // KANN-KRITERIEN (exakt 8 Spalten)
  for i in range(gewichtungen.len()) {
    rows += (
      gewichtungen.at(i).kriterium,
      [#{ gewichtungen.at(i).gew } %],
      [#{ bewertung_a.at(i) }],
      [#{ format-de(teilnutzen_a.at(i)) }],
      [#{ bewertung_b.at(i) }],
      [#{ format-de(teilnutzen_b.at(i)) }],
      [#{ bewertung_c.at(i) }],
      [#{ format-de(teilnutzen_c.at(i)) }],
    )
  }

  // Trennlinie
  rows += (table.hline(stroke: 1.0pt + einstellungen.main-color),)

  // GESAMTNUTZEN (farbig hinterlegt, exakt 8 Spalten: 1+1+1+1+1+1+1+1)
  rows += (
    [*Gesamtnutzen*],
    [*100 %*],
    [],
    table.cell(
      fill: get-rank-color("LKW A (Mercedes-Benz Actros)", sortiert),
      align: center,
    )[*#{ format-de(gesamt_a) }*],
    [],
    table.cell(fill: get-rank-color("LKW B (Volvo FH)", sortiert), align: center)[*#{ format-de(gesamt_b) }*],
    [],
    table.cell(fill: get-rank-color("LKW C (MAN TGX)", sortiert), align: center)[*#{ format-de(gesamt_c) }*],
  )

  rows
}

#pagebreak()
== Anlage I: Nutzwertanalyse: Fuhrparkerweiterung <anlage-I>
#tabellen-figur(
  caption-text: [Vollständige Nutzwertanalyse: Muss- und Kann-Kriterien mit \ Teilnutzen (TN) und Gesamtnutzen.],
  source-text: [Eigene Darstellung in Anlehnung an die Entscheidungsmethodik nach Zangemeister (1970).],
  // Die 'fr'-Einheiten in 'columns' dehnen die Tabelle automatisch auf 100% der verfügbaren Breite.
  // Ein explizites 'width' Argument ist bei 'table' nicht erlaubt.
  table(
    columns: (1.5fr, 1fr, 0.5fr, 0.5fr, 0.5fr, 0.5fr, 0.5fr, 0.5fr),
    align: (left, left, center, center, center, center, center, center),
    fill: (x, y) => if y <= 1 { einstellungen.header-bg } else if calc.odd(y) { if einstellungen.dev-mode { rgb("2a3a5a") } else { einstellungen.zebra-bg } } else { none },
    ..table-content,
  ),
)

Die Hintergrundfarben zeigen die Platzierung (Grün = 1., Gelb = 2., Rot = 3.)

#v(2em)


// --- TABELLE 2: RANGFOLGE (SEPARAT) ---
#let name-1 = sortiert.at(0).name
#let punkte-1 = format-de(sortiert.at(0).punkte)
#let name-2 = sortiert.at(1).name
#let punkte-2 = format-de(sortiert.at(1).punkte)
#let name-3 = sortiert.at(2).name
#let punkte-3 = format-de(sortiert.at(2).punkte)

#tabellen-figur(
  caption-text: [Ergebnis der Nutzwertanalyse: Endgültige \ Rangfolge der Alternativen],
  source-text: [Eigene Berechnung.],
  // Für eine feste Breite (z. B. 60%) muss die Tabelle in einen 'block' oder 'box' gepackt werden.
  block(
    width: auto,
    table(
      columns: (auto, auto, auto),
      align: (center, left, center),
      table.header[*Platz*][*Fahrzeug*][*Gesamtnutzen*],
      table.cell(fill: einstellungen.color-1st)[*1.*], [*#{ name-1 }*], [*#{ punkte-1 }*],
      table.cell(fill: einstellungen.color-2nd)[*2.*], [*#{ name-2 }*], [*#{ punkte-2 }*],
      table.cell(fill: einstellungen.color-3rd)[*3.*], [*#{ name-3 }*], [*#{ punkte-3 }*],
    ),
  ),
)

#v(1em)

#pagebreak()
== Anlage J: Lagerkennzahlen <anlage-J>
#[
  #set table(inset: 8pt)
  #logistik-tabelle(
    3,
    align: center + horizon,
    caption-text: [Lagerkennzahlen im Überblick],
    source-text: [Handbuch Materialwirtschaft, 2023],
    header-data: ([Kennzahl], [Vorteil], [Nachteil]),
    body-data: (
      [_Lagerumschlagshäufigkeit_],
      [Zeigt Kapitalbindung],
      [Rechenaufwand hoch],
      [_Durchschn. Lagerbestand_],
      [Einfach zu ermitteln],
      [Ungenau bei Schwankungen],
      [_Lieferbereitschaftsgrad_],
      [Kundenorientiert],
      [Erfordert hohe Bestände],
    ),
  )
]

// ============================================================================
#set page("a3", flipped: true)
#pagebreak()
#set text(hyphenate: false)
== Anlage K: Lagerbestandsanalyse <anlage-K>

#let col-a = einstellungen.color-3rd.lighten(70%)
#let col-b = einstellungen.color-2nd.lighten(60%)
#let col-c = einstellungen.color-1st.lighten(70%)
#let col-x = einstellungen.accent-2.lighten(50%)
#let col-y = einstellungen.accent-4.lighten(60%)
#let col-z = einstellungen.accent-6.lighten(70%)
#let col-hl = einstellungen.color-2nd.lighten(60%)
#let col-subtotal = einstellungen.zebra-bg

#logistik-tabelle(
  // 1. Spalte fest auf 1.7cm, Rest verteilt sich über fr optimal auf die A3-Breite
  (
    1.7cm,
    2.5fr,
    1.5fr,
    0.6fr,
    0.5fr,
    0.5fr,
    0.5fr,
    0.5fr,
    0.8fr,
    0.7fr,
    0.7fr,
    0.8fr,
    0.9fr,
    0.8fr,
    0.5fr,
    0.9fr,
  ),
  align: (
    left,
    left,
    left,
    center,
    center,
    center,
    center,
    center,
    right,
    right,
    right,
    right,
    right,
    right,
    center,
    center,
  ),
  caption-text: [Detaillierte Lagerbestands- und Umsatzanalyse],
  source-text: [Lagerverwaltungssystem (LVS), Stichtag 16.07.2026],
  header-data: (
    [Artikel-Nr.],
    [Bezeichnung],
    [Hersteller],
    [Einheit],
    [Zone],
    [Regal],
    [Ebene],
    [Platz],
    [Akt. Best.],
    [Mindestbest.],
    [Maximalbest.],
    [Umschlag p.a.],
    [Lagerwert (€)],
    [Einzelpreis (€)],
    [ABC-Klasse],
    [Letzte \Lieferung],
  ),
  footer-data: (
    table.cell(colspan: 2)[*Gesamtsumme*],
    [-],
    [-],
    [-],
    [-],
    [-],
    [-],
    text(weight: "bold")[2~147],
    [-],
    [-],
    text(weight: "bold")[Ø 33,0],
    text(weight: "bold")[52~025,00],
    text(weight: "bold")[Ø 110,10],
    [-],
    [-],
  ),
  body-data: (
    // ── A-1001 ──
    [A-1001],
    [Gabelstapler-Gabel 2,4 m],
    [Hubtex],
    [Stk],
    [Z-A],
    [04],
    [02],
    [12],
    [45],
    [10],
    [60],
    [8,5],
    table.cell(fill: col-hl)[12~500,00],
    [250,00],
    [A],
    [10.07.],

    // ── A-1002 ──
    [A-1002],
    [Hydrauliköl 20L Kanister],
    [Shell],
    [L],
    [Z-B],
    [12],
    [01],
    [05],
    [120],
    [30],
    [150],
    [24,0],
    [4~800,00],
    [40,00],
    [B],
    [12.07.],

    // ── A-1003 ──
    [A-1003],
    [Sicherheitsweste EN ISO],
    [Uvex],
    [Stk],
    [Z-A],
    [01],
    [03],
    [22],
    table.cell(fill: col-hl)[350],
    table.cell(fill: col-hl)[100],
    table.cell(fill: col-hl)[500],
    [42,0],
    [3~150,00],
    [9,00],
    [C],
    [13.07.],

    // ── B-2001 ──
    [B-2001],
    [Europalette EPAL],
    [EPAL],
    [Stk],
    [Z-C],
    [Bod],
    [-],
    [-],
    table.cell(fill: col-hl)[850],
    table.cell(fill: col-hl)[200],
    table.cell(fill: col-hl)[1000],
    table.cell(fill: col-hl)[120,0],
    table.cell(fill: col-hl)[10~200,00],
    [12,00],
    [A],
    [15.07.],

    // ── B-2002 ──
    [B-2002],
    [Kantenschutzprofil],
    [Cordstrap],
    [Stk],
    [Z-B],
    [08],
    [02],
    [14],
    [85],
    [20],
    [100],
    [15,2],
    [1~275,00],
    [15,00],
    [C],
    [08.07.],

    // ── C-3001 ──
    [C-3001],
    [Lackierpistole prof.],
    [SATA],
    [Stk],
    [Z-D],
    [02],
    [04],
    [08],
    [12],
    [5],
    [20],
    [6,0],
    [4~800,00],
    table.cell(fill: col-hl)[400,00],
    [B],
    [05.07.],

    // ── C-3002 ──
    [C-3002],
    [Atemschutzmaske FFP3],
    [Dräger],
    [Stk],
    [Z-D],
    [02],
    [04],
    [09],
    [200],
    [50],
    [300],
    [36,0],
    [1~800,00],
    [9,00],
    [C],
    [13.07.],

    // ── D-4001 ──
    [D-4001],
    [Barcode-Scanner],
    [Zebra],
    [Stk],
    [Z-A],
    [05],
    [01],
    [03],
    [25],
    [5],
    [30],
    [12,0],
    [7~500,00],
    table.cell(fill: col-hl)[300,00],
    [B],
    [09.07.],

    // ── D-4002 ──
    [D-4002],
    [Thermo-Etiketten 100x],
    [Brady],
    [Rolle],
    [Z-B],
    [15],
    [03],
    [11],
    table.cell(fill: col-hl)[400],
    [100],
    [500],
    table.cell(fill: col-hl)[48,0],
    [2~400,00],
    [6,00],
    [A],
    [14.07.],

    // ── E-5001 ──
    [E-5001],
    [Zurrkette 5~t 8~m],
    [Thule],
    [Stk],
    [Z-C],
    [09],
    [02],
    [18],
    [60],
    [15],
    [80],
    [18,5],
    [3~600,00],
    [60,00],
    [C],
    [11.07.],
  ),
)



// ==========================================================
// 1. ABC-ANALYSE MIT ZWISCHENSUMMEN
// ==========================================================
#set page("a4", flipped: true)
#pagebreak()
== Anlage L: ABC-Analyse nach Lagerwert <anlage-L>

#tabellen-figur(
  caption-text: [ABC-Analyse nach Lagerwert],
  source-text: [Lagerverwaltungssystem (LVS), Stichtag 16.07.2026],
  table(
    columns: (auto, 1fr, auto, auto, auto, auto),
    align: (center, left, right, right, right, center),
    table.header([*Rang*], [*Artikel & Bezeichnung*], [*Lagerwert (€)*], [*kumul. (€)*], [*kumul. %*], [*Kl.*]),
    // A-Güter
    [1], [A-1001: Gabelstapler-Gabel 2,4 m], [12~500,00], [12~500,00], [24,0], table.cell(fill: col-a)[*A*],
    [2], [B-2001: Europalette EPAL], [10~200,00], [22~700,00], [43,6], table.cell(fill: col-a)[*A*],
    [3], [D-4001: Barcode-Scanner Mobil], [7~500,00], [30~200,00], [58,0], table.cell(fill: col-a)[*A*],
    [4], [A-1002: Hydrauliköl 20L Kanister], [4~800,00], [35~000,00], [67,3], table.cell(fill: col-a)[*A*],
    [5], [C-3001: Lackierpistole prof.], [4~800,00], [39~800,00], [76,5], table.cell(fill: col-a)[*A*],
    // Zwischensumme A
    table.cell(colspan: 2, fill: col-subtotal)[*Zwischensumme A-Güter*],
    table.cell(fill: col-subtotal)[*39~800,00*], [-], [-], [-],
    // B-Güter
    [6], [E-5001: Zurrkette 5~t 8~m], [3~600,00], [43~400,00], [83,4], table.cell(fill: col-b)[*B*],
    [7], [A-1003: Sicherheitsweste EN ISO], [3~150,00], [46~550,00], [89,5], table.cell(fill: col-b)[*B*],
    [8], [D-4002: Thermo-Etiketten 100x], [2~400,00], [48~950,00], [94,1], table.cell(fill: col-b)[*B*],
    // Zwischensumme B
    table.cell(colspan: 2, fill: col-subtotal)[*Zwischensumme B-Güter*],
    table.cell(fill: col-subtotal)[*9~550,00*], [-], [-], [-],
    // C-Güter
    [9], [C-3002: Atemschutzmaske FFP3], [1~800,00], [50~750,00], [97,5], table.cell(fill: col-c)[*C*],
    [10], [B-2002: Kantenschutzprofil], [1~275,00], [52~025,00], [100,0], table.cell(fill: col-c)[*C*],
    // Zwischensumme C
    table.cell(colspan: 2, fill: col-subtotal)[*Zwischensumme C-Güter*],
    table.cell(fill: col-subtotal)[*3~075,00*], [-], [-], [-],
    // Gesamtsumme
    table.cell(colspan: 2)[*Gesamtsumme*], [*52~025,00*], [-], [-], [-],
  ),
)

#v(1em)









// ==========================================================
// 2. ABC-XYZ-MATRIX
// ==========================================================
#pagebreak()
== Anlage M: ABC-XYZ-Matrix & Strategieableitung <anlage-M>

#align(center)[
  #show figure.where(kind: table): it => it
  #tabellen-figur(
  caption-text: [ABC-XYZ-Matrix mit Strategieableitung],
  source-text: [Lagerverwaltungssystem (LVS), Stichtag 16.07.2026],
  table(
    columns: (2.5cm, 3.8cm, 3.8cm, 3.8cm),
    align: (center, center, center, center),
    inset: (x: 0.6em, y: 0.8em),
    stroke: 0.5pt,
    // Header Zeile
    table.header(
      [],
      table.cell(fill: col-x)[*X* (stetiger Verbrauch)],
      table.cell(fill: col-y)[*Y* (schwankender Verbrauch)],
      table.cell(fill: col-z)[*Z* (unregelmäßiger Verbrauch)],
    ),
    // Zeile A
    table.cell(fill: col-a)[*A* (hochwertig)],
    [*AX-Strategie* \ Just-in-Time \ Geringer Sicherheitsbestand \ #text(size: 7pt)[Bsp.: B-2001 (Paletten)]],
    [*AY-Strategie* \ Prognosegesteuert \ Moderater Sicherheitsbestand \ #text(size: 7pt)[Bsp.: A-1002 (Hydrauliköl)]],
    [*AZ-Strategie* \ Hoher Sicherheitsbestand \ Auftragsorientierte Beschaffung \ #text(size: 7pt)[Bsp.: D-4001 (Scanner)]],
    // Zeile B
    table.cell(fill: col-b)[*B* (mittelwertig)],
    [*BX-Strategie* \ Standarddisposition \ Automatisierte Nachbestellung \ #text(size: 7pt)[Bsp.: D-4002 (Etiketten)]],
    [*BY-Strategie* \ Regelmäßige Überprüfung \ Saisonale Anpassung \ #text(size: 7pt)[Bsp.: E-5001 (Zurrkette)]],
    [*BZ-Strategie* \ Bedarfsorientiert bestellen \ Keine Vorratshaltung wenn möglich \ #text(size: 7pt)[Bsp.: A-1003 (Westen)]],
    // Zeile C
    table.cell(fill: col-c)[*C* (geringwertig)],
    [*CX-Strategie* \ Vorratshaltung \ Einfache Bestellpunktsteuerung \ #text(size: 7pt)[Bsp.: C-3002 (Masken)]],
    [*CY-Strategie* \ Große Losgrößen \ Geringer Verwaltungsaufwand \ #text(size: 7pt)[Bsp.: B-2002 (Kantenschutz)]],
    [*CZ-Strategie* \ Extrem geringe Priorität \ Nur bei konkretem Bedarf \ #text(size: 7pt)[Bsp.: C-3001 (Lackierpistole)]],
  ),
)
]

#v(1em)






// ==========================================================
// 3. DETAILLIERTE ZUORDNUNG
// ==========================================================
#pagebreak()
#set page(flipped: true)
#set text(hyphenate: false)
== Anlage N: Detaillierte Artikelzuordnung <anlage-N>

#tabellen-figur(
  caption-text: [Detaillierte Artikelzuordnung mit ABC-XYZ-Klassifikation],
  source-text: [Eigene Darstellung basierend auf Lagerdaten, Stichtag 16.07.2026],
  table(
    columns: (1.8cm, 7cm, 1.2cm, 1.2cm, 3cm, 7cm),
    align: (left, left, center, center, right, left),
    // Header
    table.header([*Artikel-Nr.*], [*Bezeichnung*], [*ABC*], [*XYZ*], [*Lagerwert (€)*], [*Empfohlene Strategie*]),
    // Daten
    [A-1001],
    [Gabelstapler-Gabel 2,4 m],
    table.cell(fill: col-a)[A],
    table.cell(fill: col-z)[Z],
    [12~500,00],
    [AZ: Auftragsorientierte Beschaffung],
    [A-1002],
    [Hydrauliköl 20L Kanister],
    table.cell(fill: col-a)[A],
    table.cell(fill: col-x)[X],
    [4~800,00],
    [AX: Just-in-Time],
    [A-1003],
    [Sicherheitsweste EN ISO],
    table.cell(fill: col-b)[B],
    table.cell(fill: col-y)[Y],
    [3~150,00],
    [BY: Regelmäßige Überprüfung],
    [B-2001],
    [Europalette EPAL],
    table.cell(fill: col-a)[A],
    table.cell(fill: col-x)[X],
    [10~200,00],
    [AX: Just-in-Time],
    [B-2002],
    [Kantenschutzprofil],
    table.cell(fill: col-c)[C],
    table.cell(fill: col-y)[Y],
    [1~275,00],
    [CY: Große Losgrößen],
    [C-3001],
    [Lackierpistole prof.],
    table.cell(fill: col-a)[A],
    table.cell(fill: col-z)[Z],
    [4~800,00],
    [AZ: Hoher Sicherheitsbestand],
    [C-3002],
    [Atemschutzmaske FFP3],
    table.cell(fill: col-c)[C],
    table.cell(fill: col-x)[X],
    [1~800,00],
    [CX: Bestellpunktsteuerung],
    [D-4001],
    [Barcode-Scanner Mobil],
    table.cell(fill: col-a)[A],
    table.cell(fill: col-z)[Z],
    [7~500,00],
    [AZ: Hoher Sicherheitsbestand],
    [D-4002],
    [Thermo-Etiketten 100x],
    table.cell(fill: col-b)[B],
    table.cell(fill: col-x)[X],
    [2~400,00],
    [BX: Standarddisposition],
    [E-5001],
    [Zurrkette 5~t 8~m],
    table.cell(fill: col-b)[B],
    table.cell(fill: col-y)[Y],
    [3~600,00],
    [BY: Saisonale Anpassung],
  ),
)

#set page(flipped: false)
#set text(hyphenate: true)
#pagebreak()
== Anlage O: Break-Even-Analysen <anlage-O>

#v(1em)
*Klassische Break-Even-Analyse*
Die nachfolgende Grafik zeigt ein klassisches Break-Even-Diagramm zur Darstellung von Fixkosten, Gesamtkosten und Umsatz. Der Schnittpunkt markiert den Break-Even-Point (Gewinnschwelle).

#diagramm-figur(
  caption-text: [Klassisches Break-Even-Diagramm],
  source-text: [Eigene Darstellung],
  canvas({
    import draw: *
    import "@preview/cetz-plot:0.1.4": plot
    let FK = 10000
    let VK = 50
    let P = 100
    let max_M = 400
    let BEP = FK / (P - VK)
    let BEP_wert = P * BEP
    plot.plot(
      size: (12, 8),
      x-label: [Menge (Stück)],
      y-label: [Betrag in €],
      x-min: 0,
      x-max: max_M,
      y-min: 0,
      y-max: 50000,
      x-tick-step: 100,
      y-tick-step: none,
      y-ticks: range(0, 50001, step: 10000).map(y => (y, text(format-de(y)))),
      legend: "inner-north-west",
      x-grid: true,
      y-grid: true,
      {
        plot.add(((0, FK), (max_M, FK)), label: [Fixkosten], style: (stroke: (paint: einstellungen.color-3rd, thickness: 1.0pt)))
        plot.add(range(0, max_M + 1, step: 50).map(m => (m, FK + VK * m)), label: [Gesamtkosten], style: (
          stroke: (paint: einstellungen.accent-1, thickness: 1.0pt),
        ))
        plot.add(range(0, max_M + 1, step: 50).map(m => (m, P * m)), label: [Umsatz], style: (
          stroke: (paint: einstellungen.color-1st, thickness: 1.0pt),
        ))
        plot.add(
          ((BEP, BEP_wert),),
          mark: "o",
          mark-size: 0.15,
          style: (stroke: einstellungen.main-color, fill: einstellungen.color-2nd),
          label: [BEP: 200 St.],
        )
        plot.annotate({
          line((BEP, 0), (BEP, BEP_wert), stroke: (paint: einstellungen.main-color.lighten(60%), dash: "dotted"))
        })
      },
    )
  }),
)

#pagebreak()
#v(2em)
*Erweiterte Break-Even-Analyse (Gewinn-/Verlustzone)*
In dieser erweiterten Darstellung sind die Verlustzone (unterhalb der Gewinnschwelle) sowie die Gewinnzone (oberhalb der Gewinnschwelle) farblich hervorgehoben.

#diagramm-figur(
  caption-text: [Break-Even-Diagramm mit hervorgehobenen Zonen],
  source-text: [Eigene Darstellung],
  canvas({
    import draw: *
    import "@preview/cetz-plot:0.1.4": plot
    let FK = 15000
    let VK = 40
    let P = 90
    let maxQ = 500
    let BEP = FK / (P - VK)
    plot.plot(
      size: (12, 8),
      x-label: [Produktionsmenge (Stück)],
      y-label: [Kosten / Umsatz in €],
      x-min: 0,
      x-max: maxQ,
      y-min: 0,
      y-max: 60000,
      x-tick-step: 100,
      y-tick-step: none,
      y-ticks: range(0, 60001, step: 10000).map(y => (y, text(format-de(y)))),
      legend: "inner-north-west",
      x-grid: true,
      y-grid: true,
      {
        plot.add-fill-between(
          ((0, FK), (BEP, FK + VK * BEP)),
          ((0, 0), (BEP, P * BEP)),
          style: (fill: einstellungen.color-3rd.lighten(60%), stroke: none),
        )
        plot.add-fill-between(
          ((BEP, FK + VK * BEP), (maxQ, FK + VK * maxQ)),
          ((BEP, P * BEP), (maxQ, P * maxQ)),
          style: (fill: einstellungen.color-1st.lighten(60%), stroke: none),
        )
        plot.add(((0, FK), (maxQ, FK)), label: [Fixkosten], style: (stroke: (paint: einstellungen.color-3rd, thickness: 1.0pt)))
        plot.add(((0, FK), (maxQ, FK + VK * maxQ)), label: [Gesamtkosten], style: (
          stroke: (paint: einstellungen.accent-1, thickness: 1.0pt),
        ))
        plot.add(((0, 0), (maxQ, P * maxQ)), label: [Umsatz], style: (
          stroke: (paint: einstellungen.color-1st, thickness: 1.0pt),
        ))
        plot.add(((BEP, P * BEP),), mark: "o", mark-size: 0.15, style: (stroke: einstellungen.main-color, fill: einstellungen.color-2nd), label: none)
        plot.annotate({
          content((BEP / 2, 35000), text(fill: einstellungen.color-3rd, weight: "bold")[Verlustzone])
          content((BEP + (maxQ - BEP) / 2, 20000), text(fill: einstellungen.color-1st, weight: "bold")[Gewinnzone])
        })
        plot.add-hline(0, style: (stroke: black))
        plot.add-vline(0, style: (stroke: black))
        plot.add-hline(60000, style: (stroke: black))
        plot.add-vline(maxQ, style: (stroke: black))
      },
    )
  }),
) <chart_bep>

#pagebreak()
#v(2em)
*Detaillierte Break-Even-Analyse*
Diese Detailansicht schlüsselt zusätzlich den Verlauf der variablen Kosten auf und veranschaulicht somit die genaue Zusammensetzung der Gesamtkosten.

#diagramm-figur(
  caption-text: [Detaillierte Break-Even-Analyse inkl. variabler Kosten],
  source-text: [Eigene Darstellung],
  canvas({
    import draw: *
    import "@preview/cetz-plot:0.1.4": plot
    let FK = 20000
    let VK = 60
    let P = 120
    let maxM = 600
    let BEP = FK / (P - VK)
    plot.plot(
      size: (12, 8),
      x-label: [Absatzmenge],
      y-label: [Betrag in €],
      x-min: 0,
      x-max: maxM,
      y-min: 0,
      y-max: 80000,
      x-tick-step: 100,
      y-tick-step: none,
      y-ticks: range(0, 80001, step: 10000).map(y => (y, text(format-de(y)))),
      legend: "inner-north-west",
      x-grid: true,
      y-grid: true,
      {
        plot.add-fill-between(
          ((0, FK), (BEP, FK + VK * BEP)),
          ((0, 0), (BEP, P * BEP)),
          style: (fill: einstellungen.color-3rd.lighten(60%), stroke: none),
        )
        plot.add-fill-between(
          ((BEP, FK + VK * BEP), (maxM, FK + VK * maxM)),
          ((BEP, P * BEP), (maxM, P * maxM)),
          style: (fill: einstellungen.color-1st.lighten(60%), stroke: none),
        )
        plot.add(((0, 0), (maxM, VK * maxM)), label: [Variable Kosten], style: (
          stroke: (paint: einstellungen.accent-3, thickness: 1.0pt, dash: "dashed"),
        ))
        plot.add(((0, FK), (maxM, FK)), label: [Fixkosten], style: (stroke: (paint: einstellungen.color-3rd, thickness: 1.0pt)))
        plot.add(((0, FK), (maxM, FK + VK * maxM)), label: [Gesamtkosten], style: (
          stroke: (paint: einstellungen.accent-1, thickness: 1.0pt),
        ))
        plot.add(((0, 0), (maxM, P * maxM)), label: [Umsatz], style: (
          stroke: (paint: einstellungen.color-1st, thickness: 1.0pt),
        ))
        plot.add(((BEP, P * BEP),), mark: "o", mark-size: 0.15, style: (stroke: einstellungen.main-color, fill: einstellungen.color-2nd), label: none)
        plot.annotate({
          line((BEP, 0), (BEP, P * BEP), stroke: (paint: einstellungen.main-color.lighten(60%), thickness: 0.5pt, dash: "dashed"))
          line((0, P * BEP), (BEP, P * BEP), stroke: (paint: einstellungen.main-color.lighten(60%), thickness: 0.5pt, dash: "dashed"))
          content(
            (BEP - 60, P * BEP + 4500),
            box(fill: white.transparentize(20%), inset: 3pt, radius: 2pt)[#text(
              size: 9pt,
              weight: "bold",
            )[BEP: #format-de(calc.round(BEP)) St.]],
            anchor: "east",
          )
          content(
            (BEP + 100, P * BEP - 4000),
            box(fill: white.transparentize(20%), inset: 3pt, radius: 2pt)[#text(
              size: 9pt,
              weight: "bold",
            )[Umsatz: #format-de(calc.round(P * BEP)) €]],
            anchor: "west",
          )
          content((BEP / 2 - 50, 45000), text(fill: einstellungen.color-3rd, weight: "bold")[Verlustzone])
          content((BEP + (maxM - BEP) / 2, 69000), text(fill: einstellungen.color-1st, weight: "bold")[Gewinnzone])
        })
        plot.add-hline(0, style: (stroke: black))
        plot.add-vline(0, style: (stroke: black))
        plot.add-hline(80000, style: (stroke: black))
        plot.add-vline(maxM, style: (stroke: black))
      },
    )
  }),
)

#v(1cm)
#v(1em)
*Mathematische Berechnung und Erläuterung*

Der *Stückdeckungsbeitrag* ($d b$) ergibt sich aus der Differenz zwischen dem Preis pro Stück ($p$) und den variablen Stückkosten ($k_v$). Er gibt an, wie viel ein einzelnes verkauftes Produkt zur Deckung der Fixkosten beiträgt:

$
  d b & = p - k_v \
      & = 120","00 thin € - 60","00 thin € \
      & = 60","00 thin €
$

Der *Break-Even-Point* (Gewinnschwelle) errechnet sich, indem die gesamten Fixkosten ($K_f$) durch den Stückdeckungsbeitrag geteilt werden. Das Ergebnis ist die Absatzmenge, bei der weder Gewinn noch Verlust erwirtschaftet wird:

$
  "BEP" & = K_f / d_b \
        & = (20 thin 000","00 thin €) / (60","00 thin €) \
        & = 333","33 thin "Stück"
$

*Erläuterung des Diagramms:* Das Liniendiagramm veranschaulicht diesen Zusammenhang grafisch. Die horizontale Achse zeigt die Absatzmenge, während auf der vertikalen Achse der Betrag in Euro abgetragen ist.

- Die *Fixkosten* (rote Linie) verlaufen waagerecht bei 20~000 €, da sie unabhängig von der Produktionsmenge stets in voller Höhe anfallen.
- Die *variablen Kosten* (lila gestrichelt) steigen mit jedem produzierten Stück linear um 60 € an.
- Die *Gesamtkosten* (blaue Linie) setzen sich aus Fixkosten und variablen Kosten zusammen. Sie beginnen daher auf der vertikalen Achse bei 20~000 € und steigen parallel zu den variablen Kosten.
- Der *Umsatz* (grüne Linie) beginnt bei 0 € und steigt steiler an als die Gesamtkosten, da der Verkaufspreis (120 €) höher ist als die variablen Stückkosten (60 €).

Der Punkt, an dem sich die grüne Umsatzlinie und die blaue Gesamtkostenlinie exakt schneiden, markiert den berechneten Break-Even-Point von rund 333 Stück bei einem Umsatz von exakt 40~000 €. Links von diesem Punkt liegen die Gesamtkosten über dem Umsatz, das Unternehmen befindet sich in der *Verlustzone* (rötlich hinterlegt). Rechts vom Break-Even-Point übersteigt der Umsatz die Gesamtkosten, womit die *Gewinnzone* (grünlich hinterlegt) erreicht ist.

#pagebreak()
== Anlage P: Quartalsübersicht Transportvolumen <anlage-P>
#show figure.where(kind: table): set block(breakable: true)

#logistik-tabelle(
  (1fr, 1fr, 1fr),
  align: (left, right, right),
  caption-text: [Quartalsübersicht: Transportvolumen],
  source-text: [Jahresabschluss Logistik, 2024],
  header-data: ([Quartal], [Sendungsanzahl], [Ø Gewicht (kg)]),
  footer-data: (
    text(weight: "bold")[Gesamtjahr],
    text(weight: "bold")[5~440],
    text(weight: "bold")[Ø 349],
  ),
  body-data: (
    [Q1 2024],
    [1~250],
    [340],
    [Q2 2024],
    [1~410],
    [315],
    [Q3 2024],
    [1~180],
    [360],
    [Q4 2024],
    [1~600],
    [380],
  ),
)

// ============================================================================




#pagebreak()
#block(breakable: false)[
  == Anlage Q: SWOT-Analyse <anlage-Q>
  #let quadrant-size = 130pt
  #let blue-dark = einstellungen.main-color
  #let blue-header-bg = einstellungen.header-bg
  #let color-s = rgb("#dcfce7")
  #let color-w = rgb("#fef3c7")
  #let color-o = rgb("#c7d2fe")
  #let color-t = rgb("#fee2e2")
  #align(center)[
    #show figure.where(kind: table): it => it
    #tabellen-figur(
  caption-text: [SWOT-Analyse: Übersicht interner und externer Faktoren],
  source-text: [Eigene Darstellung.],
  table(
        columns: (auto, quadrant-size, quadrant-size),
        rows: (auto, auto, auto),
        inset: 8pt,
        stroke: (
          top: 1.0pt + blue-dark,
          bottom: 1.0pt + blue-dark,
          left: none,
          right: none,
          y: 0.5pt + rgb("#cbd5e1"),
        ),
        // ZEILE 1: KOPFZEILE
        table.header(
          table.cell(fill: blue-header-bg)[],
          table.cell(fill: blue-header-bg)[
            #text(weight: "bold", fill: blue-dark)[*Positiv*]
          ],
          table.cell(fill: blue-header-bg)[
            #text(weight: "bold", fill: blue-dark)[*Negativ*]
          ],
        ),
        // ZEILE 2: INTERNE FAKTOREN
        table.cell(fill: blue-header-bg)[
          #text(weight: "bold", fill: blue-dark)[*Intern*]
        ],
        table.cell(fill: color-s, align: top + left)[
          *Stärken* \
          (Strengths) \
          \
          - Kernkompetenz A \
          - Ressource B
        ],
        table.cell(fill: color-w, align: top + left)[
          *Schwächen* \
          (Weaknesses) \
          \
          - Hohe Kosten \
          - Fehlende Erfahrung
        ],
        // ZEILE 3: EXTERNE FAKTOREN
        table.cell(fill: blue-header-bg)[
          #text(weight: "bold", fill: blue-dark)[*Extern*]
        ],
        table.cell(fill: color-o, align: top + left)[
          *Chancen* \
          (Opportunities) \
          \
          - Neuer Markt \
          - Technologie X
        ],
        table.cell(fill: color-t, align: top + left)[
          *Risiken* \
          (Threats) \
          \
          - Neue Konkurrenz \
          - Regulatorik
        ],
      ),
)
  ]
]

#pagebreak()
#block(breakable: false)[
  == Anlage R: BCG-Matrix (Portfolio-Analyse) <anlage-R>
  #set text(font: "Noto Sans", lang: "de")
  #set figure.caption(position: top)

  // 1. FARBDEFINITIONEN
  #let blue-dark = einstellungen.main-color
  #let blue-header-bg = einstellungen.header-bg
  #let color-stars = rgb("#dcfce7")
  #let color-question = rgb("#fef3c7")
  #let color-cows = rgb("#c7d2fe")
  #let color-dogs = rgb("#fee2e2")

  // 2. GRÖSSENDEFINITION
  #let quadrant-size = 130pt

  // ZENTRIERUNG DIREKT UM DIE FIGUR
  #align(center)[
    #show figure.where(kind: table): it => it
    #tabellen-figur(
  caption-text: [Portfolio-Analyse: PKW-Markt Deutschland],
  source-text: [Eigene Darstellung in Anlehnung an Henderson (1970).],
  table(
        columns: (auto, quadrant-size, quadrant-size),
        rows: (auto, auto, auto),
        inset: 8pt,
        stroke: (
          top: 1.0pt + blue-dark,
          bottom: 1.0pt + blue-dark,
          left: none,
          right: none,
          y: 0.5pt + rgb("#cbd5e1"),
        ),
        // --- ZEILE 1: KOPFZEILE ---
        table.cell(fill: blue-header-bg)[],
        table.cell(fill: blue-header-bg, align: center + bottom)[
          #text(weight: "bold", fill: blue-dark)[
            *Hoher relativer* \
            *Marktanteil*
          ]
        ],
        table.cell(fill: blue-header-bg, align: center + bottom)[
          #text(weight: "bold", fill: blue-dark)[
            *Niedriger relativer* \
            *Marktanteil*
          ]
        ],
        // --- ZEILE 2: HOHES MARKTWACHSTUM ---
        table.cell(fill: blue-header-bg, align: center)[
          #text(weight: "bold", fill: blue-dark)[
            *Hohes* \
            *Marktwachstum*
          ]
        ],
        table.cell(fill: color-stars, align: top + left)[
          *🌟 Stars* \
          \
          - BYD \
          - Tesla (DE)
        ],
        table.cell(fill: color-question, align: top + left)[
          *❓ Question Marks* \
          \
          - Polestar \
          - NIO
        ],
        // --- ZEILE 3: GERINGES MARKTWACHSTUM ---
        table.cell(fill: blue-header-bg, align: center)[
          #text(weight: "bold", fill: blue-dark)[
            *Geringes* \
            *Marktwachstum*
          ]
        ],
        table.cell(fill: color-cows, align: top + left)[
          *💰 Cash Cows* \
          \
          - VW \
          - BMW \
          - Mercedes
        ],
        table.cell(fill: color-dogs, align: top + left)[
          *🐕 Dogs* \
          \
          - Ford \
          - Opel \
          - Rest (DE)
        ],
      ),
)
  ]
]

// 1. FARBDEFINITIONEN
#let blue-dark = einstellungen.main-color
#let blue-header-bg = einstellungen.header-bg
#let color-diff = rgb("#dcfce7")          // Grün: Differenzierung
#let color-cost = rgb("#c7d2fe")          // Indigo: Kostenführerschaft
#let color-focus = rgb("#fef3c7")         // Gelb: Fokussierung

// 2. GRÖSSENDEFINITION (ANGEPASST FÜR A4)
#let quadrant-size = 180pt

#pagebreak()
#block(breakable: false)[
  #set text(font: "Noto Sans", lang: "de")
  #set figure.caption(position: top)
  == Anlage S: Porter's Basisstrategien <anlage-S>

  #align(center)[
    #show figure.where(kind: table): it => it
    #tabellen-figur(
  caption-text: [3 Basisstrategien nach Porter],
  source-text: [Eigene Darstellung in Anlehnung an Porter (1985).],
  table(
        columns: (auto, 1fr, 1fr),
        rows: (auto, auto, auto),
        inset: 12pt,
        stroke: (
          top: 1.0pt + blue-dark,
          bottom: 1.0pt + blue-dark,
          left: none,
          right: none,
          y: 0.5pt + rgb("#cbd5e1"),
        ),
        // --- ZEILE 1: KOPFZEILE ---
        table.cell(fill: blue-header-bg)[],
        table.cell(fill: blue-header-bg, align: center + bottom)[
          #text(weight: "bold", fill: blue-dark)[
            *Gesamtmarkt*
          ]
        ],
        table.cell(fill: blue-header-bg, align: center + bottom)[
          #text(weight: "bold", fill: blue-dark)[
            *Teilmarkt*
          ]
        ],
        // --- ZEILE 2: LEISTUNGSVORTEIL ---
        table.cell(fill: blue-header-bg, align: center)[
          #text(weight: "bold", fill: blue-dark)[
            *Leistungs- \
            vorteil*
          ]
        ],
        table.cell(fill: color-diff, align: top + left)[
          *Differenzierungsstrategie* \
          \
          ✓ Marketing \
          ✓ Innovation \
          ✓ Kreativität \
          ✓ Qualität \
          ✓ Reputation \
          \
          *Beispiele:* \
          - Apple \
          - Mercedes-Benz, BMW, Porsche \
          - Miele
        ],
        table.cell(fill: color-focus, align: top + left)[
          *Strategie der Fokussierung (Nische)* \
          \
          Kombination genannter \
          Maßnahmen mit Bezug \
          auf Zielobjekt \
          \
          *Beispiele:* \
          - Ferrari \
          - Rolex \
          - Tesla (früher) \
          - Liebherr \
          - Braun
        ],
        // --- ZEILE 3: KOSTENVORTEIL ---
        table.cell(fill: blue-header-bg, align: center)[
          #text(weight: "bold", fill: blue-dark)[
            *Kosten- \
            vorteil*
          ]
        ],
        table.cell(fill: color-cost, align: top + left)[
          *Strategie der* \
          *Kostenführerschaft* \
          \
          ✓ Finanzkraft \
          ✓ Investition \
          ✓ Verfahrensinnovation \
          ✓ Controlling \
          ✓ kostengünstiger \
          Vertrieb \
          \
          *Beispiele:* \
          - Aldi, Lidl \
          - Ryanair \
          - IKEA, Amazon
        ],
        table.cell(fill: color-focus, align: top + left)[
          *Strategie der Fokussierung (Nische)* \
          \
          Kombination genannter \
          Maßnahmen mit Bezug \
          auf Zielobjekt \
          \
          *Beispiele:* \
          - Rolex \
          - Ferrari \
          - Maybach \
          - A. Lange & Söhne \
          - Miele (Premium)
        ],
      ),
)
  ]
]
#pagebreak()
== Anlage T: eEPK Auftragsprozess <anlage-T>
#diagramm-figur(
  caption-text: [Beispielhafte eEPK zur Auftragsprüfung],
  source-text: [Eigene Darstellung],
  canvas(length: 0.92cm, {
    import draw: *
    let text-box(label, w: 3cm) = box(width: w, align(center + horizon)[#set text(
        hyphenate: false,
        top-edge: "bounds",
        bottom-edge: "bounds",
      ); #set align(center); #set par(justify: false, leading: 0.5em); #label])
    let eepk-event(pos, label) = {
      group({
        set-origin(pos)
        line(
          (-1.5, -0.7),
          (1.5, -0.7),
          (1.8, 0),
          (1.5, 0.7),
          (-1.5, 0.7),
          (-1.8, 0),
          close: true,
          fill: einstellungen.eepk-ev-fill,
          stroke: einstellungen.eepk-ev-stroke,
        )
        content((0, 0), text-box(label))
      })
    }
    let eepk-function(pos, label) = {
      group({
        set-origin(pos)
        rect((-1.8, -0.7), (1.8, 0.7), fill: einstellungen.eepk-fn-fill, stroke: einstellungen.eepk-fn-stroke)
        content((0, 0), text-box(label))
      })
    }
    let eepk-org(pos, label) = {
      group({
        set-origin(pos)
        circle((0, 0), radius: (1.5, 0.5), fill: einstellungen.eepk-org-fill, stroke: einstellungen.eepk-org-stroke)
        content((0, 0), text-box(label, w: 2.8cm))
      })
    }
    let eepk-sys(pos, label) = {
      group({
        set-origin(pos)
        rect((-1.5, -0.6), (1.5, 0.6), fill: einstellungen.eepk-sys-fill, stroke: einstellungen.eepk-sys-stroke)
        line((-1.3, -0.6), (-1.3, 0.6), stroke: einstellungen.eepk-sys-stroke)
        line((-1.1, -0.6), (-1.1, 0.6), stroke: einstellungen.eepk-sys-stroke)
        content((0, 0), text-box(label, w: 2cm))
      })
    }
    let eepk-op(pos, label) = {
      group({
        set-origin(pos)
        circle((0, 0), radius: 0.55, fill: einstellungen.eepk-xor-fill, stroke: einstellungen.eepk-xor-stroke)
        content((0, 0), text-box(label, w: 0.8cm))
      })
    }
    // --- KNOTEN ---
    eepk-event((0, 0), [Kundenanfrage\ eingegangen])
    eepk-function((0, -2.5), [Anfrage\ prüfen])
    eepk-sys((-4.5, -2.5), [ERP-\ System])
    eepk-org((4.5, -2.5), [Vertrieb])
    eepk-op((0, -5), "XOR")
    // Linker Pfad (Nicht machbar)
    eepk-event((-4.0, -7.5), [Anfrage nicht\ machbar])
    eepk-function((-4.0, -10), [Absage\ erteilen])
    // Rechter Pfad (Machbar)
    eepk-event((4.0, -7.5), [Anfrage\ machbar])
    eepk-function((4.0, -10), [Angebot\ erstellen])
    eepk-sys((0, -10), [ERP-\ System])
    eepk-org((8.5, -10), [Vertrieb])
    eepk-event((4.0, -12.5), [Angebot\ erstellt])
    eepk-function((4.0, -15), [Angebot\ versenden])
    eepk-org((8.5, -15), [Vertrieb])
    eepk-op((0, -17.5), "XOR")
    eepk-event((0, -20), [Vorgang\ abgeschlossen])
    // --- KANTEN ---
    // Ablauf
    line((0, -0.7), (0, -1.8), mark: (end: ">")) // e1 to f1
    line((0, -3.2), (0, -4.6), mark: (end: ">")) // f1 to x1
    line((-0.3, -5.3), (-4.0, -6.8), mark: (end: ">")) // x1 to e2
    line((-4.0, -8.2), (-4.0, -9.3), mark: (end: ">")) // e2 to f2
    line((-4.0, -10.7), (-0.3, -17.2), mark: (end: ">")) // f2 to x2
    line((0.3, -5.3), (4.0, -6.8), mark: (end: ">")) // x1 to e3
    line((4.0, -8.2), (4.0, -9.3), mark: (end: ">")) // e3 to f3
    line((4.0, -10.7), (4.0, -11.8), mark: (end: ">")) // f3 to e4
    line((4.0, -13.2), (4.0, -14.3), mark: (end: ">")) // e4 to f4
    line((4.0, -15.7), (0.3, -17.2), mark: (end: ">")) // f4 to x2
    line((0, -17.9), (0, -19.3), mark: (end: ">")) // x2 to e5
    // Zugehörigkeiten (Org & Sys)
    line((-3, -2.5), (-1.8, -2.5), mark: (end: ">", start: ">")) // s1 to f1
    line((3, -2.5), (1.8, -2.5)) // o1 to f1
    line((1.5, -10), (2.2, -10), mark: (end: ">", start: ">")) // s2 to f3
    line((7.0, -10), (5.8, -10)) // o2 to f3
    line((7.0, -15), (5.8, -15)) // o3 to f4
  }),
)

#pagebreak()
== Anlage U: Beispiel-Fragebogen Kundenzufriedenheit <anlage-U>
Dieser Fragebogen wurde komplett in Typst mit Checkboxen und Tabellen (ohne Rahmen) gestaltet.

#align(center)[#text(size: 16pt, weight: "bold")[Kundenbefragung 2024]]

Wir freuen uns über Ihr Feedback. Bitte füllen Sie den Fragebogen ehrlich aus.
Ihre Daten werden anonymisiert ausgewertet.

*1. Wie zufrieden sind Sie insgesamt mit unserem Service?* \
#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  row-gutter: 0.8em,
  column-gutter: 0.5em,
  stroke: none,
  align: center,
  [Sehr zufrieden], [Zufrieden], [Teils/Teils], [Unzufrieden], [Sehr unzufrieden],
  [[ ]], [[ ]], [[x]], [[ ]], [[ ]],
)

#v(1cm)
*2. Welche unserer Leistungen nutzen Sie am häufigsten?* (Mehrfachnennung möglich) \
#grid(
  columns: (auto, 1fr),
  row-gutter: 0.8em,
  column-gutter: 0.8em,
  stroke: none,
  [[x]], [Logistik & Transport],
  [[ ]], [Lagerung & Fulfillment],
  [[ ]], [Beratung & Supply Chain Management],
  [[x]], [Verpackungsservice],
)

#v(1cm)
*3. Wie wahrscheinlich ist es, dass Sie uns weiterempfehlen?* (1 = sehr unwahrscheinlich, 10 = sehr wahrscheinlich) \
#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  row-gutter: 0.8em,
  column-gutter: 0.3em,
  stroke: none,
  align: center,
  [1], [2], [3], [4], [5], [6], [7], [8], [9], [10],
  [[ ]], [[ ]], [[ ]], [[ ]], [[ ]], [[ ]], [[x]], [[ ]], [[ ]], [[ ]],
)

#v(1cm)
*4. Haben Sie weitere Anmerkungen oder Verbesserungsvorschläge?* \
#box(width: 100%, height: 4cm, stroke: 0.5pt + gray)[
  #v(0.2cm)
  #h(0.2cm) _(Bitte hier eintragen)_
]

#v(2cm)
#align(right)[_Vielen Dank für Ihre Teilnahme!_]
#pagebreak()
== Anlage V: Projekt-Kostenplan <anlage-V>
Das nachfolgende Beispiel demonstriert eine professionelle Tabelle mit korrekter typografischer Ausrichtung. Textinhalte werden in der Regel linksbündig (`left`) gesetzt, während numerische Werte und Währungsangaben zwingend rechtsbündig (`right`) zu positionieren sind.

#einfache-tabelle(
  (auto, auto, auto),
  align: (left, right, right),
  [*Kostenstelle*],
  [*Anteil*],
  [*Betrag in €*],
  [Personal (Entwicklung)],
  [60~%],
  [12~500,00],
  [Lizenzen & Software],
  [15~%],
  [3~125,50],
  [Hardware & Server],
  [20~%],
  [4~166,00],
  [Sonstiges],
  [5~%],
  [1~041,50],
  [*Gesamtkosten*],
  [*100~%*],
  [*20~833,00*],
)

Dieser fiktive Kostenplan veranschaulicht eindrücklich, wie Tabellen durch eine klare Spaltenstruktur und den bewussten Verzicht auf störende vertikale Linien ihre optimale Lesbarkeit behalten.
#pagebreak()
== Anlage W: Checkliste Facharbeit <anlage-W>

Damit Sie auf dem Weg zu Ihrer fertigen Facharbeit keinen wichtigen Schritt vergessen, können Sie sich an diesem chronologischen Ablaufplan orientieren:

#logistik-tabelle(
  (auto, 1fr),
  align: (left, left),
  caption-text: [Ablaufplan zur Facharbeit],
  source-text: [Eigene Darstellung],
  header-data: (
    [Status],
    [Arbeitsschritt],
  ),
  body-data: (
    [[ ]], [*1. Themenfindung:* Identifikation eines konkreten, kaufmännischen Problems aus der Praxis (z. B. in Ihrem Ausbildungsbetrieb).],
    [[ ]], [*2. Grobgliederung:* Erstellung eines ersten, logischen roten Fadens (Einleitung, Analyse, Lösung, Fazit).],
    [[ ]], [*3. Abstimmung (Gliederung):* Vorlage und Besprechung der Gliederung bei Ihrer betreuenden Lehrkraft zur Genehmigung.],
    [[ ]], [*4. Titelfindung:* Festlegen des finalen, präzisen Titels der Arbeit und offizielle Einreichung bei der Schule.],
    [[ ]], [*5. Technische Vorbereitung (Typst):* Entscheidung für Web-Editor oder VS Code. Eintragen Ihrer echten Daten in die Datei `St_Individualisierungen.typ` (Wichtig: Platzhalter "Max Mustermann" zwingend überschreiben!).],
    [[ ]], [*6. Literaturrecherche:* Sammeln von Fachliteratur und direktes Eintragen der Quellen in die Datei `St_Facharbeit.bib`.],
    [[ ]], [*7. Strukturierung:* Übersichtliches Strukturieren der Facharbeit durch die direkte Nutzung der vorgesehenen Kapitel in der `St_Vorlage.typ`.],
    [[ ]], [*8. Schreibphase:* Ausformulieren der Arbeit unter Anwendung der im Unterricht gelernten betriebswirtschaftlichen Instrumente (Nutzwertanalyse, Break-Even, etc.).],
    [[ ]], [*9. Typografischer Feinschliff:* Kontrolle auf harte Seitenumbrüche, Hurenkinder/Schusterjungen und zentrierte Tabellen/Bilder.],
    [[ ]], [*10. System-Check:* Überprüfen, ob das Dokument fehlerfrei und ohne rote Fehlermeldungen des Typst-Compilers generiert wird.],
    [[ ]], [*11. Einreichen der Facharbeit:* Drucken und Binden der Arbeit (z.B. Ringbindung) sowie digitale Abgabe (PDF + ZIP-Ordner des gesamten Codes). *Idealerweise reichen Sie alles schon wenige Tage vor dem finalen Abgabetermin ein, um Technik-Stress am letzten Tag zu vermeiden!*],
  )
)

// --- BEISPIEL: SHOWYBOX (FORMATIERUNGS-BOXEN) ---
// Sie können diese Beispiele einfach löschen oder überschreiben.

#pagebreak()
== Anlage X: Spezielle Formatierungs-Boxen (Showybox) <anlage-X>

Mit den Befehlen #definition, #beispiel und #merke können Sie Inhalte im Corporate Design der Vorlage (ohne weiche Rundungen oder weiche Schatten, streng passend zu den Tabellen) hervorheben.

#definition(titel: "Definition: Nutzwertanalyse")[
  Die Nutzwertanalyse (NWA) ist eine qualitative, nicht-monetäre Analysemethode der Entscheidungstheorie, die es ermöglicht, verschiedene Handlungsalternativen anhand mehrerer, oft inkommensurabler Kriterien systematisch zu bewerten und zu vergleichen.
]

#v(1em)

#beispiel(titel: "Beispiel: ABC-Analyse")[
  Ein Unternehmen hat 1~000 Artikel auf Lager. Die A-Artikel machen nur 15 % der Menge aus, binden aber 80 % des Gesamtwerts. Die C-Artikel machen 50 % der Menge aus, binden aber nur 5 % des Wertes.
]

#v(1em)

#merke(titel: "Wichtiger Merksatz")[
  Der Sperrvermerk und die Eigenständigkeitserklärung dürfen niemals mit einer Seitenzahl im Inhaltsverzeichnis auftauchen. Achten Sie bei der Strukturierung Ihrer Arbeit stets auf die exakte Einhaltung der Formvorschriften.
]


