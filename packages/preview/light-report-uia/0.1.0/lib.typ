// This is just a latex copy of a LaTeX template. Originally made by these guys: Morten Goodwin Olsen, Andreas Prinz, Astrid Stifoss-Hanssen, Stein Bergsmark, Sigurd M. Assev, Christian Auby

// english and norwegian support
#let translations = (
  en: (
    contents: "Contents",
    figure: "Figure",
    table: "Table",
    listing: "Listing",
    list_of_figures: "Figures",
    list_of_tables: "Tables",
    list_of_listings: "Listings",
    consisting_of: "consisting of",
    and_: "and",
    in_: "in",
    faculty: "Faculty of Engineering and Science",
    university: "University of Agder",
    references: "References",
  ),
  no: (
    contents: "Innhold",
    figure: "Figur",
    table: "Tabell",
    listing: "Listing",
    list_of_figures: "Figurer",
    list_of_tables: "Tabeller",
    list_of_listings: "Listinger",
    consisting_of: "av",
    and_: "og",
    in_: "i",
    faculty: "Fakultet for teknologi og realfag",
    university: "Universitetet i Agder",
    references: "Referanser",
  )
)

#let report(
  title: none,
  authors: none,
  group_name: none,
  course_code: none,
  course_name: none,
  date: none,
  lang: "en",
  location: "Grimstad", // possibly different?
  references: "references.yml", // in case user wants to use their own file
  body 
) = {
  set document(title: [#title - #group_name], author: authors)
  set text(font: "Linux Libertine", lang: lang)
  set par(justify: true) // blocky paragraphs
  show link: underline
  show heading: set block(above: 18pt, below: 18pt)

  
  if lang == "nb" or lang == "nn" {
    lang = "no"
  }
  
  assert(lang in translations.keys(), message: "Unsupported language code: " + lang + ". Supported codes are: " + translations.keys().join(", "))
    
  let t = translations.at(lang)

  // to have language-specific figure namings (and correct targeted outlines)
  show figure.where(kind: image): set figure(supplement: t.figure)
  show figure.where(kind: table): set figure(supplement: t.table)
  show figure.where(kind: raw): set figure(supplement: t.listing)

  let format_authors(authors, and_word) = {
    if authors.len() == 1 {
      authors.first()
    } else {
      authors.slice(0, -1).join(", ") + " " + and_word + " " + authors.last()
    }
  }

  // FRONT PAGE
  set align(center)
  block(height: 25%, image("media/UIA_" + lang + ".svg", height: 140%))
  
  v(1cm)
  text(25pt, weight: "bold", title)
  v(3mm)
  text(18pt, group_name) 
  v(3mm)
  text(12pt, t.consisting_of)
  v(3mm)
  text(18pt, format_authors(authors, t.and_))
  v(3mm)
  text(12pt, t.in_)
  v(3mm)
  text(18pt)[
    #course_code
    #linebreak()
    #course_name
  ]
  v(1fr) // to bottom
  text(12pt)[
    #t.faculty
    #linebreak()
    #t.university
  ]
  v(3mm)
  text(15pt)[#location, #date]

  pagebreak()

  // contents page
  set align(left)
  set heading(numbering: "1.")
  outline(indent:auto, title: t.contents)

  pagebreak()

  // Page with lists of figures, tables and listings. Each list, or potentially the entire page, will be hidden if there's no matching elements
  context {
    let has_type(type) = query(figure.where(kind: type)).len() > 0
    let show_this_page = false
    
    if has_type(image) {
      show_this_page = true
      [ #outline(title: t.list_of_figures, target: figure.where(kind: image)) ]
    }

    if has_type(table) {
      show_this_page = true
      [ #outline(title: t.list_of_tables, target: figure.where(kind: table)) ]
    }

    if has_type(raw) {
      show_this_page = true
      [ #outline(title: t.list_of_listings, target: figure.where(kind: raw)) ]
    }
    
    if show_this_page {
      pagebreak()
    }
  }
  
  // after the front page and content things
  set page(numbering: "1", number-align: center)

  // main.typ
  body

  pagebreak()

  // https://github.com/typst/hayagriva/blob/main/docs/file-format.md
  bibliography("template/" + references, title: t.references)
}