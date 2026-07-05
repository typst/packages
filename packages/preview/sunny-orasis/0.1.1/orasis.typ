// Patron de format Typst pour soumettre un article long à ORASIS (ou RFIAP).
// Sans garanties. 
// Deux colonnes, pas de numérotation et 10 points.

#let orasis(
  title: none,
  authors: none,
  affiliations: none,
  emails: none,
  abstract-fr: none,
  keywords-fr: none,
  abstract-en: none,
  keywords-en: none,
  document-fonts: ("TeX Gyre Termes",),
  body,
) = {

  set page(
    paper: "a4",
    margin: (left: 1.9cm, right: 1.9cm, top: 3cm, bottom: 3cm),
    numbering: none,
    columns: 2,
  )

  set columns(gutter: 1cm)
  set text(font: document-fonts, size: 10pt)
  set text(lang: "fr")

  
  show heading: set text(font: document-fonts, weight: "bold", size: 12pt)
  set footnote.entry(clearance: 4pt)

  // Title header in single column.
  place(
    top + center,
    float: true,
    scope: "parent",
    clearance: 3em,
  )[
    // Title row.
    #pad(top: 1.5em, bottom: 0.5em)[
      #text(weight: "bold", size: 14pt)[#title]
    ]
    
    // Author information.
    #set text(font: document-fonts, size: 12pt)
    #pad(
      bottom: 0.3em,
      x: 7.5em,
      grid(
        columns: (1fr,) * calc.min(4, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(center)[
          #author.name#super[#author.affiliation]
        ]),
      ),
    )

    // Affiliations informations.
    #for (i, inst) in affiliations.enumerate() {
      [#super[#(i+1)] #inst]
      linebreak()
    }
    #v(0.5em)
    
    #for email in emails {
      email
      linebreak()
    }
  ]
  
  set par(justify: true, leading: 5.6pt, spacing: 5.6pt)
  show heading: set block(above: 10pt, below: 10pt)

  // Abstracts and Keywords Sections.
  heading(level: 2, "Résumé")
  text(lang: "fr", style: "italic")[#abstract-fr]
  
  heading(level: 2, "Mots Clef")
  text(lang: "fr")[#keywords-fr]
  
  heading(level: 2, "Abstract")
  text(lang: "en", style: "italic")[#abstract-en]
  
  heading(level: 2, "Keywords")
  text(lang: "en")[#keywords-en]

  // Body of the article.
  set heading(numbering: "1.1   ")
  show heading: it => [
    // Format headings depending on level and numbering
    #if it.numbering == none and it.level == 1  { // for Bibliography
      set text(14pt) // could be 12pt, but kept 14pt to mimic LaTeX template
      block(it)
    } else if it.level == 1 { // numbered Headings
      set text(14pt) // could be 12pt, but kept 14pt to mimic LaTeX template
      block(it)
    } else { // sub-section Headings
      set text(12pt)
      block(it)
    }
  ]
  
  text(lang: "fr")[#body]
}