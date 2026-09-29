// colours of the Ghent University corporate identity
#let colour-primary=rgb("#1e64c8") // = rgb(30, 100, 200)
#let colour-secondary=rgb("#ffd200")
#let colour-tertiary=rgb("#e9f0fa")

// fonts of the Ghent University corporate identity
#let font-primary="UGent Panno Text"
#let font-secondary="Arial"

#let light-gray=luma(245)
#let default-numbering="1" // for figures and equations (for equations parentheses are added by default)
#let default-separator="."
#let default-figure-fill=light-gray
#let default-figure-inset=0.5em
#let default-figure-font-size=90%
#let default-caption-position=(table: top, rest: bottom)
#let default-caption-separator=sym.colon+sym.space
#let default-subfigure-numbering="a"
#let default-subfigure-ref-numbering="a"
#let default-caption-prefix-text=(weight: "semibold")
#let default-font="Libertinus Serif"


#let languages=("en", "nl")
#let default-language=languages.at(0)
#let default-region=(
  en: "GB",
  nl: "BE")
#let locale-sep="-"

#let default-terminology=(
  // prefix for last element in a list
  prefix-last: (
    en: (
      " and",
      ", and"
      ),
    nl: " en"
  ),
  // supplement for part
  part: (   
    en: ("Part", "Parts"), 
    nl: ("Deel", "Delen")
  ), 
  // supplement for chapters
  chapter: (
    en: ("Chapter", "Chapters"), 
    nl: ("Hoofdstuk", "Hoofdstukken")
  ), 
  // supplement for appendices 
  appendix: ("Appendix","Appendices"),
  // supplement for other sections 
  section: (
    en: ("Section", "Sections"),
    nl: ("Paragraaf","Paragrafen")
  ),  
  // title of the bibliography of the main text
//   bibliography: (
//     en: "Bibliography",        => commented => Default Typst values  
//     nl: "Bibliografie"), 
  // title of the "References" section in the extended abstract 
  references: (
    en: "References", 
    nl: "Referenties"
  ),   
  supervisor: (
    en: ("Supervisor","Supervisors"),
    nl: ("Promotor","Promotoren")
  ),
  counsellor: (
    en: ("Counsellor","Counsellors"),
    nl: ("Begeleider","Begeleiders")
  ),
  abstract: (
    en: [Abstract---], 
    nl: [Samenvatting --- ]
  ),
  keywords: (
    en: [Keywords---], 
    nl: [Trefwoorden --- ]
  ),
  extended-abstract: (
    en: "Extended Abstract",
    nl: "Uitgebreide samenvatting"
  ),  
  title-page: (
    en: "Title Page",
    nl: "Titelblad"
  ),
  table-of-contents: (
    en: "Table of Contents", 
    nl: "Inhoudsopgave"
  ),
  list-of-abbreviations: (
    en: "List of Abbreviations", 
    nl: "Lijst van afkortingen"
  ),
// *** Supplements (singular and plural) and outline titles for various elements ***:
  // math.equation
  math-equation: (
    supplement: (
      en: ("Equation","Equations"), 
      nl: ("Vergelijking","Vergelijkingen")
    ),
    outline-title: (
      en: "List of Equations",
      nl: "Lijst van vergelijkingen"
    )
  ), 
  // figure(kind: image) 
  figure-image: (
    supplement: (
      en: ("Figure","Figures"),
      nl: ("Figuur","Figuren")
    ),
    outline-title: (
      en: "List of Figures",
      nl: "Lijst van figuren"
    )   
  ),
  // figure(kind: table)  
  figure-table: (
     supplement: (
      en: ("Table","Tables"),
      nl: ("Tabel","Tabellen")
    ),
    outline-title: (
      en: "List of Tables",
      nl: "Lijst van tabellen"
    )  
  ),
  // figure(kind: raw)  
  figure-raw: (
     supplement: (
      en: ("Listing","Listings"),
      nl: ("Codevoorbeeld","Codevoorbeelden")
    ),
    outline-title: (
      en: "List of Listings",
      nl: "Lijst van codevoorbeelden"
    )   
  )
)
