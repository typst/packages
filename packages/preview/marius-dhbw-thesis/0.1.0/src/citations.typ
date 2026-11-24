// ============================================================
// Zitationsfunktionen
// ============================================================
//
// Diese Datei enthält generische Funktionen für:
//
// - Einzelzitate
// - Mehrfachzitate
// - manuelle Jahresangaben
// - Jahreszusätze wie 2025a und 2025b
// - optionale Kurztitel
//
// Projektspezifische Sonderfälle werden in main.typ definiert.
// ============================================================


// ============================================================
// Standard-Resolver
// ============================================================
//
// Ohne einen eigenen Resolver werden keine Jahreszusätze und
// keine Kurztitel ergänzt.
// ============================================================

#let no-year-suffix(key) = none

#let no-short-title(key) = none


// ============================================================
// Jahr einschließlich Jahreszusatz ausgeben
// ============================================================
//
// Beispiele:
//
// Jahr aus bibliography.bib:
//   2025
//
// Jahr mit Jahreszusatz:
//   2025a
//
// Manuell überschriebenes Jahr:
//   o. J.
//
// Manuell überschriebenes Jahr mit Zusatz:
//   o. J. a
// ============================================================

#let render-citation-year(
  key,
  year-override: none,
  year-suffix: auto,
  year-suffix-resolver: no-year-suffix,
) = {
  let year = if year-override == none {
    cite(key, form: "year")
  } else {
    year-override
  }

  let suffix = if year-suffix == auto {
    year-suffix-resolver(key)
  } else {
    year-suffix
  }

  if suffix == none {
    year
  } else if year-override == none {
    [#year#suffix]
  } else {
    [#year #suffix]
  }
}


// ============================================================
// Einzelzitat
// ============================================================
//
// Einfaches Zitat:
//
// #vglcite(<mustermann2025>, loc: [S. 10])
//
// Ohne Seitenangabe:
//
// #vglcite(<mustermann2025>)
//
// Ohne bekanntes Erscheinungsjahr:
//
// #vglcite(
//   <webseite>,
//   year-override: [o. J.],
// )
//
// Mit manuellem Jahreszusatz:
//
// #vglcite(
//   <mustermann2025>,
//   year-suffix: [a],
//   loc: [S. 10],
// )
// ============================================================

#let vglcite(
  key,
  loc: none,
  year-override: none,
  year-suffix: auto,
  year-suffix-resolver: no-year-suffix,
  short-title-resolver: no-short-title,
) = {
  let year = render-citation-year(
    key,
    year-override: year-override,
    year-suffix: year-suffix,
    year-suffix-resolver: year-suffix-resolver,
  )

  let short-title = short-title-resolver(key)

  [
    (vgl. #cite(key, form: "author"), #year
    #if short-title != none {[, „#short-title“]}
    #if loc != none {[, #loc]})
  ]
}


// ============================================================
// Mehrfachzitat
// ============================================================
//
// Unterstützte Formen:
//
// Nur Quellenschlüssel:
//
// #vglcites(
//   <quelle1>,
//   <quelle2>,
// )
//
// Mit Fundstellen:
//
// #vglcites(
//   (<quelle1>, [S. 10]),
//   (<quelle2>, [S. 20–22]),
// )
//
// Vollständige Tupelform:
//
// (<Schlüssel>, <Fundstelle>, <Jahres-Override>, <Jahreszusatz>)
//
// Alle Angaben nach dem Schlüssel sind optional.
//
// Beispiel:
//
// #vglcites(
//   (<quelle1>, [S. 10]),
//   (<quelle2>, none, [o. J.]),
//   (<quelle3>, [S. 20], none, [a]),
// )
//
// Eigene Resolver können als benannte Argumente ergänzt werden:
//
// #vglcites(
//   (<quelle1>, [S. 10]),
//   (<quelle2>, [S. 20]),
//   year-suffix-resolver: my-year-suffix,
//   short-title-resolver: my-short-title,
// )
// ============================================================

#let vglcites(
  ..items,
  year-suffix-resolver: no-year-suffix,
  short-title-resolver: no-short-title,
) = {
  let parts = items.pos().map(item => {
    let key = if type(item) == label {
      item
    } else {
      item.at(0)
    }

    let loc = if type(item) == label {
      none
    } else if item.len() > 1 {
      item.at(1)
    } else {
      none
    }

    let year-override = if type(item) == label {
      none
    } else if item.len() > 2 {
      item.at(2)
    } else {
      none
    }

    let year-suffix = if type(item) == label {
      auto
    } else if item.len() > 3 {
      item.at(3)
    } else {
      auto
    }

    let year = render-citation-year(
      key,
      year-override: year-override,
      year-suffix: year-suffix,
      year-suffix-resolver: year-suffix-resolver,
    )

    let short-title = short-title-resolver(key)

    [
      #cite(key, form: "author"), #year
      #if short-title != none {[, „#short-title“]}
      #if loc != none {[, #loc]}
    ]
  })

  [(vgl. #parts.join([; ]))]
}