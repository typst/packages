// =======================================================================
// DATEI: template.typ
// ZWECK: Haupt-Template der Facharbeit. Kapselt alle globalen Set-Regeln und das Layout.
// =======================================================================

#import "einstellungen.typ"

#import "architektur.typ"
#import "ui.typ"
#import "utils.typ"

#import "validation.typ": validate-einstellungen

#let h1-pagebreak-skip = state("h1-pagebreak-skip", false)
#let in-raw = state("in-raw", false)

#let facharbeit(userdata: none, einstellungen: none, body) = [

// Typ-Validierungen
#validate-einstellungen(einstellungen, userdata)

// ═══════════════════════════════════════════════════════════════════════════
// 2. GLOBALE SET-REGELN (Root-Scope)
// ═══════════════════════════════════════════════════════════════════════════

// Automatische Konfigurations-Übersicht (für Studierende und Kontrolle)
#import "uebersicht.typ": render-uebersicht
#render-uebersicht()

// PDF/UA-Metadaten (Barrierefreiheit: Titel + Autor für Screenreader)
#set document(
  title: userdata.pdf-titel,
  author: userdata.pdf-autor,
  keywords: userdata.pdf-stichwoerter,
  date: auto,
)

// Seiteneinstellungen
#set page(fill: einstellungen.bg-color, margin: einstellungen.rand-setup)

// Text-Grundeinstellungen
#set text(
  lang: "de",
  region: "DE",
  font: einstellungen.hauptschriftart,
  size: if einstellungen.large-print { 12pt } else { einstellungen.schriftgroesse },
  fill: einstellungen.text-color,
  hyphenate: true,
  ligatures: true,
  costs: einstellungen.trennkosten,
  overhang: einstellungen.optischer-randausgleich,
)

// Linie (für #line() Befehle)
#set line(stroke: einstellungen.primärfarbe)

// Absatz
#set par(justify: einstellungen.blocksatz, leading: einstellungen.zeilenabstand)

// Code-Schrift
#show raw: it => {
  in-raw.update(true)
  set text(font: einstellungen.codeschriftart)
  it
  in-raw.update(false)
}

// Automatische Einheitenformatierung (geschütztes Leerzeichen zwischen Zahl und Einheit)
#show regex("\b(\d+(?:,\d+)?)\s?(t|kg|g|mg|km|m|cm|mm|l|ml|Stk|TEU|FEU|LDM|cbm|Pal|Ktn|VPE|h|min|s|lbs|oz|ton|MT|in|ft|yd|mi|gal|pt|qt|cft|pcs|qty|box|crt|ctn)\b"): it => {
  let m = it.text.match(regex("\b(\d+(?:,\d+)?)\s?(t|kg|g|mg|km|m|cm|mm|l|ml|Stk|TEU|FEU|LDM|cbm|Pal|Ktn|VPE|h|min|s|lbs|oz|ton|MT|in|ft|yd|mi|gal|pt|qt|cft|pcs|qty|box|crt|ctn)\b"))
  if m != none {
    [#m.captures.at(0)~#m.captures.at(1)]
  } else {
    it
  }
}
#show regex("\b(\d+(?:,\d+)?)\s?(€|%|°C|°F|[$]|£|¥|CHF)"): it => {
  let m = it.text.match(regex("\b(\d+(?:,\d+)?)\s?(€|%|°C|°F|[$]|£|¥|CHF)"))
  if m != none {
    [#m.captures.at(0)~#m.captures.at(1)]
  } else {
    it
  }
}



// ═══════════════════════════════════════════════════════════════════════════
// GLOBALE TABELLEN-OPTIK (Root-Scope -> gilt fuer JEDE Tabelle im Dokument:
// rohe Tabellen, einfache-tabelle, Tabellen aus jedem Makro/Include)
// ═══════════════════════════════════════════════════════════════════════════

// Senkrechte / äussere Linien nur nach Schalter
#let inner-v-stroke = if einstellungen.show-vertical-lines { 0.5pt + einstellungen.stroke-color } else { none }
#let outer-stroke = if einstellungen.show-outer-lines { 0.5pt + einstellungen.stroke-color } else { none }

#set table(
  fill: (x, y) => {
    if y == 0 {
      einstellungen.header-bg
    } else if calc.even(y) and y != 0 {
      einstellungen.zebra-bg
    } else {
      none
    }
  },
  stroke: (x, y) => {
    let s = 0.5pt + einstellungen.stroke-color
    if einstellungen.show-vertical-lines {
      return s
    } else {
      return (top: s, bottom: s, left: none, right: none)
    }
  },
  inset: einstellungen.table-inset,
)

// Tabellen-Caption zentriert + Tabellen nicht ueber Seiten reissen
#show figure.where(kind: table): set align(einstellungen.table-alignment)
#show figure.where(kind: table): set block(breakable: true)

// Header-Styling (Fängt auch Tabellen ohne explizites table.header() ab, aber nur innerhalb von Tabellen-Figuren)
#show figure.where(kind: table): it => {
  show table.header: set text(
    weight: "bold",
    fill: if einstellungen.dev-mode { oklch(100%, 0, 0deg) } else { einstellungen.main-color },
  )
  show table.cell.where(y: 0): set text(
    weight: "bold",
    fill: if einstellungen.dev-mode { oklch(100%, 0, 0deg) } else { einstellungen.main-color },
  )
  it
}

#show figure.caption: set block(sticky: true)

// Semantisches Padding für alle Figure-Typen (ersetzt manuelle #v(1em))
#show figure: set block(spacing: 2em)

// Einheitliche Formatierung für ALLE Bild- und Tabellenunterschriften im Fließtext
#show figure.caption: set text(size: einstellungen.caption-size)
#show figure.caption: it => block(width: 100%, {
  show regex("(?i)Quelle:.*"): set text(style: einstellungen.quellen-formatierung, size: einstellungen.quellen-size, fill: einstellungen.source-color, weight: "regular")
  [#it.supplement~#context it.counter.display(it.numbering)#it.separator#text(weight: einstellungen.caption-body-weight)[#it.body]]
})

// Tabellenziffern (Tabular Figures) für exakte Spaltenausrichtung von Zahlen
#show table: set text(features: ("tnum",))


// ═══════════════════════════════════════════════════════════════════════════
// 3. HEADING-FORMATIERUNG
// ═══════════════════════════════════════════════════════════════════════════

#set heading(numbering: "1.1.1.1.1.1")
#show strong: it => text(weight: einstellungen.schriftgewicht-fett)[#it.body]

#show heading: set text(fill: einstellungen.primärfarbe, hyphenate: false)
#show heading: it => {
  set text(fill: einstellungen.primärfarbe)
  block(above: if it.level == 1 { 0em } else { 1.8em }, below: 1em, sticky: true)[#it]
}
#show heading.where(level: 1): it => {
  context {
    if not h1-pagebreak-skip.get() {
      architektur.vakat-pagebreak(weak: true)
    }
  }
  h1-pagebreak-skip.update(false)
  it
}


// ═══════════════════════════════════════════════════════════════════════════
// 4. AUFZÄHLUNGEN, FUSSNOTEN, VERZEICHNISSE
// ═══════════════════════════════════════════════════════════════════════════

// Aufzählungen (4 Ebenen)
#set list(marker: (
  text(fill: einstellungen.primärfarbe)[•],
  text(fill: einstellungen.primärfarbe)[◦],
  text(fill: einstellungen.primärfarbe)[–],
  text(fill: einstellungen.primärfarbe)[·],
))

// Checkboxen
#show regex("\[ \]") : it => context {
  if in-raw.get() {
    it
  } else {
    box(width: 0.9em, height: 0.9em, stroke: 0.8pt + einstellungen.primärfarbe, radius: 1pt, baseline: 0pt)
  }
}
#show regex("\[x\]"): it => context {
  if in-raw.get() {
    it
  } else {
    box(width: 0.9em, height: 0.9em, stroke: 0.8pt + einstellungen.primärfarbe, fill: white, radius: 1pt, baseline: -0.05em, align(center + horizon)[#text(fill: einstellungen.color-1st.darken(20%), weight: "bold", size: 0.8em)[#sym.checkmark]])
  }
}

// Inhaltsverzeichnis: Füllzeichen und Abstände
#show outline.entry: set outline.entry(fill: if einstellungen.verzeichnis-fuellzeichen {
  repeat[#text(size: einstellungen.verzeichnis-fuellzeichen-groesse, baseline: 0.5pt)[.]#h(einstellungen.verzeichnis-fuellzeichen-abstand)]
} else { none })
#show outline.entry.where(level: 1): set outline.entry(fill: none)
#show outline.entry: it => {
  show regex("(?i)Quelle:.*"): set text(style: einstellungen.quellen-formatierung, size: einstellungen.quellen-size)
  set par(leading: einstellungen.verzeichnis-zeilenabstand)
  if it.element.func() == heading and it.level == 1 {
    v(1.2em, weak: true)
    text(weight: "semibold")[#it]
  } else {
    v(einstellungen.verzeichnis-eintragsabstand, weak: true)
    it
  }
}

// Fußnoten
#set footnote.entry(clearance: 1.5em, separator: line(length: 30%, stroke: 0.5pt + einstellungen.primärfarbe))
#show footnote.entry: it => context {
  set par(hanging-indent: 0pt, first-line-indent: 0pt, justify: true, leading: 0.55em)
  
  // 1. Alle Fußnoten der aktuellen Seite abfragen
  let notes-on-page = query(footnote).filter(n => n.location().page() == here().page())
  
  // 2. Größte Fußnotennummer auf dieser Seite ermitteln
  let max-nr = 1
  if notes-on-page.len() > 0 {
    let max-note = notes-on-page.last()
    max-nr = counter(footnote).at(max-note.location()).first()
  }
  
  // Aktuelle Fußnotennummer
  let nr = counter(footnote).at(it.note.location()).first()
  
  // 3. Exakte Breite der größten Nummer berechnen
  let max-nr-str = str(max-nr) + "."
  let nr-width = measure(text(size: 9.5pt, weight: "regular")[#max-nr-str]).width
  
  // 4. Grid mit dynamischer Breite rendern
  block(inset: (left: 0pt, right: 0pt), width: 100%, grid(
    columns: (nr-width, 1fr),
    gutter: 0.4em,
    align: (right + top, left + top),
    text(size: 9.5pt, weight: "regular")[#nr.], text(size: 9.5pt)[#it.note.body],
  ))
}

// Blockzitate (Quotes) visuell aufwerten
#show quote.where(block: true): it => {
  block(
    stroke: (left: 2pt + einstellungen.primärfarbe),
    inset: (left: 1em, top: 0.2em, bottom: 0.2em),
    text(style: "italic")[#it.body]
  )
}

// Tabellen-Textfarbe (global)
#show table: set text(fill: einstellungen.table-text-color)

// Silbentrennung in Tabellenzellen erzwingen
#show table.cell: set text(hyphenate: true)

// Automatische Rechtsbündigkeit für Tabellenzellen, die nur aus Zahlen (und Kommata/Leerzeichen) bestehen
#show table.cell: it => {
  if type(it.body) == content and it.body.has("text") {
    let t = it.body.text.trim()
    if t.match(regex("^-?\d+([~ ]\d{3})*(,\d+)?$")) != none {
      set align(right)
      it
    } else {
      it
    }
  } else {
    it
  }
}

// Gender-Logik
#let label-student = if userdata.student-anrede == "Frau" [Studentin:] else [Student:]
#let label-pruefer = if userdata.pruefer-anrede == "Frau" [Betreuerin:] else [Betreuer:]
#let label-zweitkorrektor = if userdata.zweitkorrektor-anrede == "Frau" [Zweitgutachterin:] else [Zweitgutachter:]


// ═══════════════════════════════════════════════════════════════════════════
// 5. TITELBLATT
// ═══════════════════════════════════════════════════════════════════════════

#page(numbering: none, header: none, footer: none)[
  #place(top + right, dx: 0cm, dy: 0.5cm, {
    if einstellungen.logo-rahmen {
      box(stroke: 0.5pt + luma(150), inset: einstellungen.logo-rahmen-abstand, image("../Abbildungen/LogoNEU.jpg", width: 1.5cm, alt: "Logo der Bildungseinrichtung"))
    } else {
      image("../Abbildungen/LogoNEU.jpg", width: 1.5cm, alt: "Logo der Bildungseinrichtung")
    }
  })
  #v(1cm)
  #align(center)[
    #text(size: 14pt)[#userdata.vorname #userdata.nachname \ ]
    #v(0.5cm)
    #text(size: 18pt, weight: "bold", fill: einstellungen.primärfarbe)[\ #userdata.titel]
    #if userdata.untertitel != "" [
      #v(0.2cm)
      #text(size: 14pt)[#userdata.untertitel]
    ]
    #v(0.5cm)
    #image(
      "../Abbildungen/Titelbild.jpg",
      height: 8cm,
      fit: "contain",
      alt: "Schreibtisch mit Laptop und Büchern (Symbolbild)",
    )
    #text(size: einstellungen.quellen-size)[Abbildung: Schreibtisch (symbolisch) \ (Quelle: lizenzfreies Symbolbild)]
    #v(0.5cm)
    //#text(size: 12pt)[#userdata.art-der-arbeit]
    // #text(size: 12pt)[im Bildungsgang: #userdata.bildungsgang]
    #v(0.5cm)
    #text(size: 12pt)[
      #label-pruefer #userdata.pruefer-anrede #userdata.pruefer-name \
      #if userdata.mit-zweitkorrektur [
        #label-zweitkorrektor #userdata.zweitkorrektor-anrede #userdata.zweitkorrektor-name \
      ]
      #if userdata.fachlehrer-name != "" [
        Fachlehrer: #userdata.fachlehrer-anrede #userdata.fachlehrer-name \
      ]
      Abgabedatum: #userdata.abgabedatum
    ]
    #v(1fr)
    #text(size: 12pt)[Diese Facharbeit wird in der Abschlussprüfung im\ #userdata.bildungsgang \ am #userdata.schulname vorgelegt.]
    #v(0.3cm)
    #text(size: 12pt)[#userdata.abgabeort, #datetime.today().year()]
  ]
]


// ═══════════════════════════════════════════════════════════════════════════
// 6. SPERRVERMERK
// ═══════════════════════════════════════════════════════════════════════════

#if userdata.mit-sperrvermerk {
  import "sperrvermerk.typ": render_sperrvermerk
  render_sperrvermerk(userdata)
}


// ═══════════════════════════════════════════════════════════════════════════
// 7. VERZEICHNISSE (Römische Nummerierung)
// ═══════════════════════════════════════════════════════════════════════════

#architektur.vakat-pagebreak()
#set page(numbering: if userdata.klammern-um-roemische-seiten { "(i)" } else { "i" }, header: none, footer: context {
  if architektur.is-vakatseite() { return none }
  set text(size: 10pt)
  align(center)[#counter(page).display()]
})
#counter(page).update(1)

// Fußnoten in den Verzeichnissen ausblenden
#show outline.entry: it => {
  show footnote: none
  show cite: none
  it
}

#outline(title: [Inhaltsverzeichnis], depth: 3, indent: auto)
#v(2.5em)

#heading(numbering: none, outlined: true)[Abkürzungsverzeichnis]
#v(1.5em)
#[
#show table.cell.where(y: 0): set text(weight: "regular", fill: einstellungen.text-color)
#show table.cell.where(y: 0): set table.cell(fill: none)
#table(
  columns: 2,
  column-gutter: 2em,
  row-gutter: 0.8em,
  stroke: none,
  fill: (x, y) => { if calc.odd(y) { if einstellungen.dev-mode { rgb("2a3a5a") } else { einstellungen.zebra-bg } } else { none } },
  [#strong[3PL]], [Third-Party Logistics],
  [#strong[DTP]], [Desktop-Publishing],
  [#strong[ERP]], [Enterprise Resource Planning],
  [#strong[FTL]], [Full Truck Load],
  [#strong[JIT]], [Just-in-Time],
  [#strong[KEP]], [Kurier-, Express- und Paketdienste],
  [#strong[LTL]], [Less than Truck Load],
  [#strong[MDE]], [Mobile Datenerfassung],
  [#strong[PDF]], [Portable Document Format],
  [#strong[SCM]], [Supply Chain Management],
  [#strong[VS Code]], [Visual Studio Code (Entwicklungsumgebung)],
)
]
#v(2.5em)

#heading(numbering: none, outlined: true)[Abbildungsverzeichnis]
#v(1.5em)
#show outline: set text(hyphenate: false)
// Typografische Bereinigung für Abbildungs- und Tabellenverzeichnis: 
// Fette (strong) und kursive (emph) Formatierungen aus den Bildunterschriften ignorieren,
// damit das Verzeichnis extrem sauber und einheitlich wirkt.
#show outline.entry: it => {
  show strong: set text(weight: "regular")
  show emph: set text(style: "normal")
  show footnote: none
  show cite: none
  
  if it.element != none and it.element.func() == figure {
    let fig = it.element
    let num = counter(figure.where(kind: fig.kind)).at(fig.location()).first()
    let prefix = [#fig.supplement #num]
    
    let prefix-width = if fig.kind == image { 7em } else { 5.5em }
    
    set par(leading: einstellungen.verzeichnis-zeilenabstand)
    v(einstellungen.verzeichnis-eintragsabstand, weak: true)
    link(fig.location())[
      #grid(
        columns: (prefix-width, 1fr),
        align: (left, left),
        prefix,
        [#fig.caption.body #box(width: 1fr, it.fill) #it.page()]
      )
    ]
  } else {
    it
  }
}
#outline(title: none, target: figure.where(kind: image))
#v(2.5em)

#heading(numbering: none, outlined: true)[Tabellenverzeichnis]
#v(1.5em)
#outline(title: none, target: figure.where(kind: table))


// ═══════════════════════════════════════════════════════════════════════════
// 8. HAUPTTEIL (Arabische Nummerierung)
// ═══════════════════════════════════════════════════════════════════════════

#architektur.vakat-pagebreak()
#set page(numbering: "1", header: architektur.get-hauptteil-header(), footer: architektur.get-hauptteil-footer())
#counter(page).update(1)
#h1-pagebreak-skip.update(true)

  #body
]
