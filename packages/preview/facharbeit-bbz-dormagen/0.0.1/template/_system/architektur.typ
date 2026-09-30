// =======================================================================
// DATEI: architektur.typ
// ZWECK: Architektur & Layout-Struktur: Definiert das globale Seitenlayout, Kopf-/Fußzeilen und das Inhaltsverzeichnis.
// =======================================================================

#import "einstellungen.typ"

// ==========================================
// ARCHITEKTUR & LAYOUT
// ==========================================
// Hier wird das visuelle Design definiert. 

#let vakat-pagebreak(weak: false) = {
  [#metadata("vakat")<vakat-start>]
  if einstellungen.duplex-druck {
    pagebreak(to: "odd", weak: weak)
  } else {
    pagebreak(weak: weak)
  }
  [#metadata("vakat")<vakat-end>]
}

#let is-vakatseite() = {
  let page-num = here().page()
  let starts = query(<vakat-start>)
  let ends = query(<vakat-end>)
  
  let is-vakat = false
  for (start, end) in starts.zip(ends) {
    if start.location().page() < page-num and page-num < end.location().page() {
      is-vakat = true
    }
  }
  return is-vakat
}

#let tab-standard(columns: auto, ..args) = {
  let pos = args.pos()
  let col-count = 0
  if type(columns) == int { col-count = columns }
  else if type(columns) == array { col-count = columns.len() }

  if col-count > 0 and pos.len() >= col-count {
    let head = pos.slice(0, col-count)
    let body = pos.slice(col-count)
    table(
      columns: columns,
      ..args.named(),
      table.header(..head),
      ..body
    )
  } else {
    table(columns: columns, ..args)
  }
}

#let tab-zebra(columns: auto, ..args) = {
  let pos = args.pos()
  let col-count = 0
  if type(columns) == int { col-count = columns }
  else if type(columns) == array { col-count = columns.len() }

  if col-count > 0 and pos.len() >= col-count {
    let head = pos.slice(0, col-count)
    let body = pos.slice(col-count)
    table(
      columns: columns,
      ..args.named(),
      table.header(..head),
      ..body
    )
  } else {
    table(columns: columns, ..args)
  }
}

// Kopfzeile: Zeigt nur die aktuelle Hauptüberschrift an (rechtsbündig)
#let get-hauptteil-header() = context {
  if is-vakatseite() { return none }

  set text(size: 10pt, fill: einstellungen.primärfarbe)
  let akt = here().page()
  // Auf Seiten, wo ein neues Kapitel beginnt (H1), keine Kopfzeile anzeigen
  if query(heading.where(level: 1)).filter(h => h.location().page() == akt).len() > 0 { return none }
  
  // Letzte H1 Überschrift finden
  let h1 = query(selector(heading.where(level: 1)).before(here())).filter(h => h.numbering != none)
  
  let h1t = if h1.len() > 0 { [#counter(heading).display(at: h1.last().location()) #h1.last().body] } else { none }
  
  if h1t != none {
    align(right)[#h1t]
  }
}

// Fußzeile: Seitenzahlen (wechselnd bei Duplexdruck)
#let get-hauptteil-footer() = context {
  if is-vakatseite() { return none }

  let loc = here()
  let elements = query(selector(<start-selbsterklaerung>))
  let s_loc = if elements.len() > 0 { elements.first().location() } else { none }
  
  if s_loc != none and loc.page() >= s_loc.page() {
    return none
  }
  
  set text(size: 10pt)
  let akt = counter(page).get().first()
  let maxs = if s_loc != none { counter(page).at(s_loc).first() - 1 } else { counter(page).final().first() }
  
  let page-string = if einstellungen.seitennummerierung-format == "Seite x von y" {
    [Seite #akt von #maxs]
  } else if einstellungen.seitennummerierung-format == "x/y" {
    [#akt/#maxs]
  } else {
    [#akt]
  }

  if einstellungen.duplex-druck {
    if calc.even(here().page()) { [#page-string #h(1fr)] } else {
      [#h(1fr) #page-string]
    }
  } else { [#h(1fr) #page-string] }
}
