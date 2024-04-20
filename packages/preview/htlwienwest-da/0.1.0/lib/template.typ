#import "elements.typ" as elems
#import "settings.typ" as settings
#import "fontchecker.typ" as fc
#import "assertions.typ": *

#let diplomarbeit(
  titel: none, 
  abteilung: none,
  unterschrifts_datum: none,
  schuljahr: none,
  autoren: none,
  kurzfassung: none,
  abstract: none, 
  vorwort: none,
  danksagung: none,
  anhang: none,
  literaturverzeichnis: none,
  body
) = {

assertNotNone(titel, message: "Der Titel muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(abteilung, message: "Die Abteilung muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(schuljahr, message: "Das Schuljahr muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(unterschrifts_datum, message: "Das Datum der Unterschrift für die Eidesstaatliche-Erklärung muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(autoren, message: "Die Autoren müssen in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(kurzfassung, message: "Die Kurzfassung muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(abstract, message: "Der Abstract muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(vorwort, message: "Das Vorwort muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(danksagung, message: "Die Danksagung muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")
assertNotNone(literaturverzeichnis, message: "Der Pfad zum Literaturverzeichnis muss in den Diplomarbeits-Konfigurationen (`diplomarbeit.with(...)`) gesetzt sein")

if anhang != none {
  assertType(anhang, "content", message: "Wenn der Parameter `anhang` gesetzt ist, muss er `content` sein. Alternativ kann er auf `none` gesetzt oder aus den Übergabeparametern entfernt werden")
}

// check autoren
assertType(autoren, "array", message: "Der Parameter `autoren` hat einen falschen Typen")
for t in autoren {
  assertType(t, "dictionary", message: "Autor hat falschen Typen")
  assertDictKeys(t, ("vorname", "nachname", "klasse", "betreuer"), message: "Autor ist ungültig")
  assertDictKeys(t.betreuer, ("name", "geschlecht"), message: "Betreuer eines Autors ist ungültig")
  assertEnum(t.betreuer.geschlecht, ("male","female"), message: "`betreuer_geschlecht` muss korrekten Wert enthalten")
}
  
let title = titel
  
// ========== global definitions ============

set page("a4")

set page(margin: (
  inside: settings.PAGE_MARGIN_INSIDE, 
  outside: settings.PAGE_MARGIN_OUTSIDE, 
  bottom: 2cm,
))

// ------ text, paragraph and block ------

set text(
  11pt,
  font: settings.FONT_PRIMARY, 
  hyphenate: false, 
  lang: "de"
)
set par(leading: 0.7em, justify: true)
set block(below: 1.7em)


// ----------- headings ----------

// heading settings
show heading: set text(weight: "regular")
show heading.where(level: 1): set text(size: 16pt)
show heading.where(level: 2): set text(size: 14pt)
show heading.where(level: 3): set text(size: 12pt)
// numbering
show heading: it => {
  let elems = ()
  if (it.numbering != none and it.body != [Inhaltsverzeichnis]) {
      elems.push(counter(heading).display())
  }
  elems.push(it.body)
  grid(
    columns: 2,
    column-gutter: 4mm,
    ..elems
  )
}
// support `Ausgearbeitet von ...` substrings
show heading: it => {
  if it.level > 2 { return it }  
  let author = elems.elaborated_by
  it
  text(9pt, author, style: "italic")
}

show heading: set block(below: 0pt)
// spacing
show heading: it => {
  if it.level == 1 {
    pad(bottom: 8mm, it)
  } else if it.level == 2 {
    pad(top: 3mm, bottom: 6mm, it)
  } else {

    pad(top: 0mm, bottom: 4mm, it)
  }
} 

// -------- figures --------

show figure: set text(9pt, style: "italic", fill: rgb("#44546c"))
set figure(gap: 3.5mm)
show figure: set block(below: 8mm)


// --------- outline and bibliography -------

// add outlines to Inhaltsverzeichnis, except for Inhaltsverzeichnis itself
// and make first level entries bold
show outline.where(title: [Inhaltsverzeichnis]): it => {
   set heading(outlined: false)
   it
}
show outline: set heading(outlined: true)
show outline: set heading(numbering: "1")
show bibliography: set heading(numbering: "1")

// modify spacing of entires


// modify outline entries
// add spacing between numbering and text
show outline.entry: it => {
  let t = counter(heading).display()
  let e = it.element
  if (
    e.has("supplement") 
    and e.supplement == [Abschnitt] 
    and e.numbering != none
  ) {
    let c = counter(heading).at(it.element.location())
    numbering(it.element.numbering, ..c)
    h(2mm)
    it.element.body
    box(width: 1fr, it.fill)
    it.page
    
  } else {
    it
  }
}


// show outline.entry: it => {
//   // v(1.5em, weak: true)
//   it
// }


// ------- Common Elements -------------

show link: underline

show raw.where(block: true): set block(stroke: 0.2pt, inset: 2mm)
show raw.where(block: false): box.with(
  fill: luma(235),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

set list(
  indent: 6mm, 
  marker: ([$circle.filled.small$], [$circle.stroked.small$], [$square.filled.tiny$]),
  body-indent: 3mm,
  
)
set enum(
  indent: 6mm, 
  numbering: "1.a.i.",
  body-indent: 3mm,
)


// =============== Content ==============

// -------- Check if Fonts are available

fc.checkfont(settings.FONT_PRIMARY)
fc.checkfont(settings.FONT_ACCENT)

// -------- Vordefinierte Seiten -------


//Deckblatt
import "pages/deckblatt.typ": deckblatt
deckblatt(title, abteilung, schuljahr, autoren)

// keep one blank page
pagebreak(to: "odd")

set page(numbering: "i")
// set correct header margin
set page(
  margin: (
    outside: settings.PAGE_MARGIN_OUTSIDE,
    inside: settings.PAGE_MARGIN_INSIDE,
    top: settings.HEADER_HEIGHT,
  )
)
// set common header and footer
set page(
  header: elems.common_header(title),
  footer: elems.common_footer(autoren),
  footer-descent: 0%,
)
counter(page).update(1)

{
  
  //Eidesstattliche Erklärung
  import "pages/eidesstattliche.typ": eidesstattliche
  let persons = autoren.map(e => [#e.vorname #e.nachname])
  eidesstattliche(datum: unterschrifts_datum, persons: persons)
  pagebreak()

  //Eidesstattliche Erklärung
  import "pages/dokumentation.typ": dokumentation
  dokumentation()
  pagebreak()
  
  //Kurzfassung
  [= Kurzfassung <Kurzfassung>] 
  kurzfassung
  pagebreak()
  
  //Abstract
  [= Abstract <Abstract>]
  abstract
  pagebreak()

  //Vorwort
  [= Vorwort <Vorwort>]
  vorwort
  pagebreak()
  
  //Inhaltsverzeichnis
  outline(
    title: "Inhaltsverzeichnis",
    indent: 2em
  ) 

}
// -------------------------------

// Numerierung der Seiten festlegen
set page(numbering: "1")
counter(page).update(1)

// Danksagung
[= Danksagung <Danksagung>]
danksagung
pagebreak(weak: true)

// Nummerierung der Kapitel festlegen
set heading(numbering: "1.1")
counter(heading).update(0)

// start of actual DA writing
[#metadata((type: "start-of-body")) <startOfBody>]

{  
  // add pagebreak before each level 1 heading (except for first heading after outline)
  show heading.where(level: 1): it => {
    if counter(heading).at(it.location()).first() != 1 {
      pagebreak()
    }  
    it
  }

  body
}

pagebreak()

[#metadata((type: "end-of-body")) <endOfBody>]

// -------- Vordefinierte Seiten --------

//Abbildungsverzeichnis
outline(
  title: "Abbildungsverzeichnis",
  target: figure.where(kind: image),
)
pagebreak()

//Tabellenverzeichnis
outline(
  title: "Tabellenverzeichnis",
  target: figure.where(kind: table),
)
pagebreak()

// Literaturverzeichnis
literaturverzeichnis(
      title: [Literaturverzeichnis]
    )
pagebreak()

counter(heading).update(0)
set heading(numbering: "A")

// Arbeitsaufteilung
import "pages/arbeitsaufteilung.typ": arbeitsaufteilung
let aufteilungen = autoren
  .map(a => ([#a.vorname #a.nachname], a.aufgaben))
arbeitsaufteilung(aufteilungen: aufteilungen)

// Anhang
if (anhang != none) {
  pagebreak()
  [= Anhang <Anhang>]
  anhang
}

}

// This is used by the 
#let autor(author) = {
  metadata((type: "author", value: author))
}