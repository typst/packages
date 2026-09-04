// =======================================================================
// DATEI: uebersicht.typ
// ZWECK: Variablen-Übersicht: Generiert die interaktive Konfigurations-Übersichtsseite (nur im Dev-Mode sichtbar).
// =======================================================================

#import "../St_Individualisierungen.typ" as ind
#import "defaults.typ" as def

#let zwingende-felder = ("titel", "vorname", "nachname", "schuelernummer", "fach", "klasse", "abgabedatum")
#let nicht-aendern = ("schulname", "bildungsgang")
#let farben = ("main-color", "color-1st", "color-2nd", "color-3rd", "accent-1", "accent-2", "accent-3", "accent-4", "accent-5", "accent-6", "header-bg", "zebra-bg", "data-label-bg", "eepk-ev-fill", "eepk-ev-stroke", "eepk-fn-fill", "eepk-fn-stroke", "eepk-org-fill", "eepk-org-stroke", "eepk-sys-fill", "eepk-sys-stroke", "eepk-xor-fill", "eepk-xor-stroke", "eepk-edge")

#let variables = (
  ("schulname", ind.schulname, def.schulname, "A.1 Institution & Rahmen"),
  ("bildungsgang", ind.bildungsgang, def.bildungsgang, "A.1 Institution & Rahmen"),
  ("fach", ind.fach, def.fach, "A.1 Institution & Rahmen"),
  ("pruefer-anrede", ind.pruefer-anrede, def.pruefer-anrede, "A.2 Prüfung & Korrektur"),
  ("pruefer-name", ind.pruefer-name, def.pruefer-name, "A.2 Prüfung & Korrektur"),
  ("fachlehrer-anrede", ind.fachlehrer-anrede, def.fachlehrer-anrede, "A.2 Prüfung & Korrektur"),
  ("fachlehrer-name", ind.fachlehrer-name, def.fachlehrer-name, "A.2 Prüfung & Korrektur"),
  ("mit-zweitkorrektur", ind.mit-zweitkorrektur, def.mit-zweitkorrektur, "A.2 Prüfung & Korrektur"),
  ("zweitkorrektor-anrede", ind.zweitkorrektor-anrede, def.zweitkorrektor-anrede, "A.2 Prüfung & Korrektur"),
  ("zweitkorrektor-name", ind.zweitkorrektor-name, def.zweitkorrektor-name, "A.2 Prüfung & Korrektur"),
  ("art-der-arbeit", ind.art-der-arbeit, def.art-der-arbeit, "A.3 Angaben zur Arbeit"),
  ("titel", ind.titel, def.titel, "A.3 Angaben zur Arbeit"),
  ("untertitel", ind.untertitel, def.untertitel, "A.3 Angaben zur Arbeit"),
  ("abgabeort", ind.abgabeort, def.abgabeort, "A.3 Angaben zur Arbeit"),
  ("abgabedatum", ind.abgabedatum, def.abgabedatum, "A.3 Angaben zur Arbeit"),
  ("mit-sperrvermerk", ind.mit-sperrvermerk, def.mit-sperrvermerk, "A.3 Angaben zur Arbeit"),
  ("student-anrede", ind.student-anrede, def.student-anrede, "A.4 Persönliche Daten"),
  ("vorname", ind.vorname, def.vorname, "A.4 Persönliche Daten"),
  ("nachname", ind.nachname, def.nachname, "A.4 Persönliche Daten"),
  ("schuelernummer", ind.schuelernummer, def.schuelernummer, "A.4 Persönliche Daten"),
  ("klasse", ind.klasse, def.klasse, "A.4 Persönliche Daten"),
  ("ausbildungsbetrieb", ind.ausbildungsbetrieb, def.ausbildungsbetrieb, "A.5 Betrieb (optional – leer lassen, wenn nicht benötigt)"),
  ("uebersichtsseite-drucken", ind.uebersichtsseite-drucken, def.uebersichtsseite-drucken, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("uebersicht-wasserzeichen", ind.uebersicht-wasserzeichen, def.uebersicht-wasserzeichen, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("large-print", ind.large-print, def.large-print, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("klammern-um-roemische-seiten", ind.klammern-um-roemische-seiten, def.klammern-um-roemische-seiten, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("sw-patterns", ind.sw-patterns, def.sw-patterns, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("ampel-symbole", ind.ampel-symbole, def.ampel-symbole, "DOKUMENTEN-STEUERUNG & BARRIEREFREIHEIT"),
  ("main-color", ind.main-color, def.main-color, "C.1 Hauptfarbe", "Überschriften, Linien, Zitate, primäre Akzente"),
  ("box-rand-breite", ind.box-rand-breite, def.box-rand-breite, "C.1 Hauptfarbe"),
  ("box-rand-farbe", ind.box-rand-farbe, def.box-rand-farbe, "C.1 Hauptfarbe"),
  ("caption-size", ind.caption-size, def.caption-size, "C.1 Hauptfarbe"),
  ("quellen-size", ind.quellen-size, def.quellen-size, "C.1 Hauptfarbe"),
  ("color-1st", ind.color-1st, def.color-1st, "C.5 Ampelfarben (Nutzwertanalyse, KPI-Bewertung)", "Platz 1, Positiv-Werte (Grün)"),
  ("color-2nd", ind.color-2nd, def.color-2nd, "C.5 Ampelfarben (Nutzwertanalyse, KPI-Bewertung)", "Platz 2, Neutral-Werte (Gelb)"),
  ("color-3rd", ind.color-3rd, def.color-3rd, "C.5 Ampelfarben (Nutzwertanalyse, KPI-Bewertung)", "Platz 3, Negativ-Werte (Rot)"),
  ("accent-1", ind.accent-1, def.accent-1, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Balken- und Liniendiagramme (Serie 1)"),
  ("accent-2", ind.accent-2, def.accent-2, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Diagramme (Serie 2), eEPK-Operatoren"),
  ("accent-3", ind.accent-3, def.accent-3, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Diagramme (Serie 3)"),
  ("accent-4", ind.accent-4, def.accent-4, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Diagramme (Serie 4)"),
  ("accent-5", ind.accent-5, def.accent-5, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Diagramme (Serie 5)"),
  ("accent-6", ind.accent-6, def.accent-6, "C.2 Kategoriefarben (für Diagramme mit mehreren Datenreihen)", "Diagramme (Serie 6)"),
  ("header-bg", ind.header-bg, def.header-bg, "C.3 Tabellen-Farben", "Tabellenköpfe und Showybox-Titel"),
  ("zebra-bg", ind.zebra-bg, def.zebra-bg, "C.3 Tabellen-Farben", "Tabellen-Zebramuster"),

  ("data-label-bg", ind.data-label-bg, def.data-label-bg, "C.4 Diagramm-Farben", "Hintergrund hinter Diagramm-Zahlen"),
  ("eepk-ev-fill", ind.eepk-ev-fill, def.eepk-ev-fill, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Ereignisse (Füllung)"),
  ("eepk-ev-stroke", ind.eepk-ev-stroke, def.eepk-ev-stroke, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Ereignisse (Rand)"),
  ("eepk-fn-fill", ind.eepk-fn-fill, def.eepk-fn-fill, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Funktionen (Füllung)"),
  ("eepk-fn-stroke", ind.eepk-fn-stroke, def.eepk-fn-stroke, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Funktionen (Rand)"),
  ("eepk-org-fill", ind.eepk-org-fill, def.eepk-org-fill, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Organisationseinheiten (Füllung)"),
  ("eepk-org-stroke", ind.eepk-org-stroke, def.eepk-org-stroke, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Organisationseinheiten (Rand)"),
  ("eepk-sys-fill", ind.eepk-sys-fill, def.eepk-sys-fill, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Anwendungssysteme (Füllung)"),
  ("eepk-sys-stroke", ind.eepk-sys-stroke, def.eepk-sys-stroke, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Anwendungssysteme (Rand)"),
  ("eepk-xor-fill", ind.eepk-xor-fill, def.eepk-xor-fill, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Operatoren (Füllung)"),
  ("eepk-xor-stroke", ind.eepk-xor-stroke, def.eepk-xor-stroke, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Operatoren (Rand)"),
  ("eepk-edge", ind.eepk-edge, def.eepk-edge, "C.6 Spezifische Farben (z.B. eEPK Diagramme)", "eEPK Kanten und Pfeile"),
  ("pdf-titel", ind.pdf-titel, def.pdf-titel, "Tab 1: Beschreibung (Description)"),
  ("pdf-autor", ind.pdf-autor, def.pdf-autor, "Tab 1: Beschreibung (Description)"),
  ("pdf-thema", ind.pdf-thema, def.pdf-thema, "Tab 1: Beschreibung (Description)"),
  ("pdf-stichwoerter", ind.pdf-stichwoerter, def.pdf-stichwoerter, "Tab 1: Beschreibung (Description)"),
  ("pdf-erstellt-mit", ind.pdf-erstellt-mit, def.pdf-erstellt-mit, "Tab 1: Beschreibung (Description)"),
  ("pdf-vorlagen-version", ind.pdf-vorlagen-version, def.pdf-vorlagen-version, "Tab 1: Beschreibung (Description)"),
  ("pdf-sprache", ind.pdf-sprache, def.pdf-sprache, "Tab 1: Beschreibung (Description)"),
  ("pdf-status", ind.pdf-status, def.pdf-status, "Tab 1: Beschreibung (Description)"),
  ("pdf-security", ind.pdf-security, def.pdf-security, "Tab 2: Sicherheit (Security)"),
  ("embed-fonts", ind.embed-fonts, def.embed-fonts, "Tab 3: Schriften (Fonts)"),
  ("pdf-initial-view", ind.pdf-initial-view, def.pdf-initial-view, "Tab 4: Ansicht beim Öffnen (Initial View)"),
  ("pdf-bildungsgang", ind.pdf-bildungsgang, def.pdf-bildungsgang, "Tab 5: Benutzerdefiniert (Custom)"),
  ("pdf-matrikelnummer", ind.pdf-matrikelnummer, def.pdf-matrikelnummer, "Tab 5: Benutzerdefiniert (Custom)"),
)

#let render-uebersicht() = {
  if not ind.uebersichtsseite-drucken { return }

  set page(
    margin: (x: 2cm, y: 1.5cm),
    header: none,
    footer: none,
    flipped: true, // Querformat
    background: {
      if ind.uebersicht-wasserzeichen {
        place(center + horizon)[
          #rotate(-30deg)[
            #text(size: 80pt, fill: rgb(255, 0, 0, 20), weight: "bold")[NICHT BINDEN]
          ]
        ]
      }
    }
  )

  text(size: 16pt, weight: "bold")[Automatische Konfigurations-Übersicht]
  v(0.5em)
  text(size: 10pt)[Erstellungsdatum der PDF: #datetime.today().display("[day].[month].[year]") | Typst Compiler: v#sys.version]
  v(1em)

  // -------------------------------------------------------------
  // STATUS-BOX BERECHNEN (alles im context, da Seiten gezählt werden müssen)
  // -------------------------------------------------------------
  context {
    // 1. Zwingende Felder prüfen (Fehler, wenn Wert = Standardwert)
    let fehler-zwingend = variables.filter(v => zwingende-felder.contains(v.at(0)) and v.at(1) == v.at(2)).len()
    
    // 2. Konstanten prüfen (Fehler, wenn Wert != Standardwert)
    let fehler-konstant = variables.filter(v => nicht-aendern.contains(v.at(0)) and v.at(1) != v.at(2)).len()
    
    // 3. Seitenanzahl
    let fehler-seiten = 0
    let start-labels = query(<start-hauptteil>)
    let end-labels = query(<ende-hauptteil>)
    if start-labels.len() > 0 and end-labels.len() > 0 {
      let start-page = start-labels.first().location().page()
      let end-page = end-labels.first().location().page()
      let count = end-page - start-page + 1
      if count < 20 or count > 25 { fehler-seiten = 1 }
    } else {
      fehler-seiten = 1 // Labels fehlen -> Fehler
    }
    
    // 4. Verzeichnisse
    let fehler-verzeichnisse = 0
    let lits = query(heading.where(level: 1)).filter(h => h.body == [Literaturverzeichnis])
    let eigen = query(heading.where(level: 1)).filter(h => h.body == [Eigenständigkeitserklärung])
    if lits.len() == 0 or eigen.len() == 0 { fehler-verzeichnisse = 1 }

    let gesamtfehler = fehler-zwingend + fehler-konstant + fehler-seiten + fehler-verzeichnisse

    if gesamtfehler == 0 {
      rect(width: 100%, fill: green.lighten(80%), stroke: 2pt + green.darken(20%), radius: 4pt, inset: 1em)[
        #align(center)[
          #text(size: 18pt, fill: green.darken(50%), weight: "bold")[FORMALE PRÜFUNG BESTANDEN]\
          #text(size: 12pt, fill: green.darken(50%))[Alle automatischen Checks waren erfolgreich. Bitte prüfen Sie dennoch die manuellen Punkte (am Ende).]
        ]
      ]
    } else {
      rect(width: 100%, fill: red.lighten(80%), stroke: 2pt + red.darken(20%), radius: 4pt, inset: 1em)[
        #align(center)[
          #text(size: 18pt, fill: red.darken(50%), weight: "bold")[FORMALE PRÜFUNG NICHT BESTANDEN - BITTE KORRIGIEREN]\
          #text(size: 12pt, fill: red.darken(50%))[Es wurden Fehler gefunden. Bitte beheben Sie die rot markierten Einträge in der Tabelle und unter den Statistiken.]\
          #v(0.5em)
          #text(size: 12pt, fill: red.darken(20%), weight: "bold")[WICHTIG: Alle Änderungen müssen in der Datei "St_Individualisierungen.typ" vorgenommen werden!]
        ]
      ]
    }
  }
  
  v(1em)

  let check-var(name, val-ind, val-def, category) = {
    let changed = val-ind != val-def
    let is-zwingend = zwingende-felder.contains(name)
    let is-nicht-aendern = nicht-aendern.contains(name)
    let is-farbe = farben.contains(name)

    if is-farbe { return () }

    let status = if name == "large-print" and changed {
      text(fill: rgb(220, 100, 0), weight: "bold")[⚠ NUR NACH RÜCKSPRACHE]
    } else if is-nicht-aendern and changed {
      text(fill: red, weight: "bold")[⛔ NICHT ÄNDERN]
    } else if is-nicht-aendern {
      text(fill: green.darken(20%), weight: "bold")[✓ OK]
    } else if is-zwingend and not changed {
      text(fill: red, weight: "bold")[⚠ MUSS GEÄNDERT WERDEN]
    } else if is-zwingend and changed {
      text(fill: green.darken(20%), weight: "bold")[✓ ERLEDIGT]
    } else {
      text(fill: luma(100))[ℹ PRÜFEN]
    }

    let val-str(v) = {
      if type(v) == str and v == "" { "<leer>" } else { repr(v) }
    }

    let act-val = if is-zwingend and not changed {
      text(fill: red, weight: "bold")[#val-str(val-ind)]
    } else if is-nicht-aendern and changed {
      text(fill: red, weight: "bold")[#val-str(val-ind)]
    } else if changed {
      text(fill: green.darken(20%), weight: "bold")[#val-str(val-ind)]
    } else {
      text()[#val-str(val-ind)]
    }

    (
      text(size: 9pt)[#category],
      text(size: 9pt)[#status],
      text(size: 9pt, weight: "bold")[#name],
      text(size: 9pt)[#act-val],
      if changed { text(size: 9pt, fill: red.darken(20%))[#val-str(val-def)] } else { text(size: 9pt, fill: luma(150))[#val-str(val-def)] }
    )
  }

  table(
    columns: (1fr, auto, 1fr, 2fr, 2fr),
    fill: (col, row) => if row == 0 { luma(230) } else { none },
    stroke: 0.5pt + luma(200),
    table.header([*Bereich / Gruppe*], [*Status*], [*Feld in St_Individualisierungen.typ*], [*Aktueller Wert*], [*Standardwert*]),
    ..variables.filter(v => not farben.contains(v.at(0))).map(v => check-var(v.at(0), v.at(1), v.at(2), v.at(3))).flatten()
  )

  pagebreak()

  text(size: 16pt, weight: "bold")[Farben & Farb-Swatches]
  v(1em)
  text(size: 10pt)[Die folgende Tabelle zeigt alle Farbreferenzen der Vorlage. Diese Farben werden primär für das Corporate Design der Dokumente verwendet.]
  v(1em)

  let swatch(c) = {
    let parsed = c
    if type(c) == str {
      if c.starts-with("oklch(") or c.starts-with("rgb(") or c.starts-with("luma(") or c.starts-with("cmyk(") or c.starts-with("color(") {
        parsed = eval(c)
      }
    }
    
    if type(parsed) == color {
      box(width: 1cm, height: 0.5cm, fill: parsed, stroke: 0.5pt + luma(100))
    } else {
      text(size: 8pt)[Keine Farbe]
    }
  }

  let swatch-gray(c) = {
    let parsed = c
    if type(c) == str {
      if c.starts-with("oklch(") or c.starts-with("rgb(") or c.starts-with("luma(") or c.starts-with("cmyk(") or c.starts-with("color(") {
        parsed = eval(c)
      }
    }
    
    if type(parsed) == color {
      box(width: 1cm, height: 0.5cm, fill: luma(parsed), stroke: 0.5pt + luma(100))
    } else {
      text(size: 8pt)[Keine Farbe]
    }
  }

  let farb-zeile(name, val-ind, val-def, usage) = {
    let changed = val-ind != val-def
    (
      [#text(size: 10pt, weight: "bold")[#name] \ #text(size: 8pt, style: "italic")[#usage]],
      swatch(val-ind),
      swatch-gray(val-ind),
      if changed { text(size: 10pt, fill: green.darken(20%), weight: "bold")[#repr(val-ind)] } else { text(size: 10pt)[#repr(val-ind)] },
      swatch(val-def),
      swatch-gray(val-def),
      if changed { text(size: 10pt, fill: red.darken(20%))[#repr(val-def)] } else { text(size: 10pt, fill: luma(150))[#repr(val-def)] }
    )
  }

  table(
    columns: (2fr, auto, auto, 2fr, auto, auto, 2fr),
    fill: (col, row) => if row == 0 { luma(230) } else { none },
    stroke: 0.5pt + luma(200),
    table.header([*Farb-Variable*], [*Swatch*], [*Grau*], [*Wert (Aktuell)*], [*Swatch*], [*Grau*], [*Wert (Standard)*]),
    ..variables.filter(v => farben.contains(v.at(0))).map(v => farb-zeile(v.at(0), v.at(1), v.at(2), v.at(4))).flatten()
  )

  pagebreak()

  text(size: 16pt, weight: "bold")[Qualitätssicherung & Statistiken]
  v(1em)

  // 1. Seitenzahl des Haupttexts prüfen
  context {
    let start-labels = query(<start-hauptteil>)
    let end-labels = query(<ende-hauptteil>)
    
    if start-labels.len() > 0 and end-labels.len() > 0 {
      let start-page = start-labels.first().location().page()
      let end-page = end-labels.first().location().page()
      let count = end-page - start-page + 1
      
      text(size: 12pt, weight: "bold")[1. Umfang der Arbeit (Haupttext)]
      v(0.5em)
      text(size: 10pt)[Berechnete Seitenanzahl: #count Seiten]
      
      if count < 20 {
        v(0.5em)
        text(size: 10pt, fill: red, weight: "bold")[⚠ WARNUNG: Die Arbeit hat weniger als 20 Seiten (Haupttext)!]
      } else if count > 25 {
        v(0.5em)
        text(size: 10pt, fill: red, weight: "bold")[⚠ WARNUNG: Die Arbeit hat mehr als 25 Seiten (Haupttext)!]
      } else {
        v(0.5em)
        text(size: 10pt, fill: green.darken(20%), weight: "bold")[✓ OK: Der Umfang liegt im erwarteten Bereich (20-25 Seiten).]
      }
    }
  }

  v(2em)

  // 2. Zwingende Bestandteile prüfen
  context {
    let lits = query(heading.where(level: 1)).filter(h => h.body == [Literaturverzeichnis])
    let eigen = query(heading.where(level: 1)).filter(h => h.body == [Eigenständigkeitserklärung])
    
    text(size: 12pt, weight: "bold")[2. Zwingende Bestandteile]
    v(0.5em)
    
    if lits.len() == 0 {
      text(size: 10pt, fill: red, weight: "bold")[⚠ WARNUNG: Das Literaturverzeichnis fehlt (oder die Überschrift wurde umbenannt)!]
    } else {
      text(size: 10pt, fill: green.darken(20%), weight: "bold")[✓ OK: Literaturverzeichnis gefunden.]
    }
    
    if eigen.len() == 0 {
      text(size: 10pt, fill: red, weight: "bold")[⚠ WARNUNG: Die Eigenständigkeitserklärung fehlt (oder die Überschrift wurde umbenannt)!]
    } else {
      text(size: 10pt, fill: green.darken(20%), weight: "bold")[✓ OK: Eigenständigkeitserklärung gefunden.]
    }
  }

  v(2em)

  // 3. Manuelle Prüfpunkte
  text(size: 12pt, weight: "bold")[3. Manuelle Prüfpunkte für Studierende und Fachlehrer]
  v(0.5em)
  text(size: 10pt)[Die folgenden Aspekte können von der Software nicht automatisiert gemessen werden und erfordern eine manuelle Sichtprüfung:]
  
  set list(marker: [—])
  list(
    [*Layout & Abstände:* Achten Sie beim Scrollen durch das Dokument auf ungewöhnlich große Zeilenabstände, übergroße Grafiken oder unnatürliche Umbrüche. Insbesondere manuelle Zeilenabstandsänderungen (im Fließtext oder in Tabellen) müssen kontrolliert werden. Eine automatisierte Erkennung von künstlichem Leerraum ist technisch in Typst derzeit nicht zuverlässig möglich.],
    [*Kaputte Bestandteile:* Die Kompilierung war erfolgreich, weshalb alle Bilder und Verzeichnisse technisch intakt sind. Achten Sie jedoch auf unaufgelöste Querverweise im Text (diese tauchen als *[?]* oder *?* auf). Fehlt eine Quelle im Literaturverzeichnis, hat Typst im Text ein ? eingefügt.],
    [*Händische Unterschriften:* Vergessen Sie nicht, das gedruckte Exemplar der Arbeit an den dafür vorgesehenen Stellen (Eigenständigkeitserklärung und ggf. Sperrvermerk) händisch zu unterschreiben!]
  )
}