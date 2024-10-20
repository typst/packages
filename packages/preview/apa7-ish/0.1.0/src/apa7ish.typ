#let script-size = 8pt
#let footnote-size = 8.5pt
#let small-size = 9.25pt
#let normal-size = 11pt
#let large-size = 12pt


#let conf(
  title: "",
  subtitle: none,
  abstract: none,
  authors: (),
  date: none,
  documenttype: none,
  keywords: none,
  disclosure: none,
  funding: none,
  anonymous: false,
  language: "en",
  fontfamily: "Libertinus Serif",
  papersize: "a4",
  body,
) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  // todo: dont show header on first (title) page
  set page(numbering: "1",
            paper: papersize,
            number-align: top + right,
            margin: 33mm,
            header: {
            context if counter(page).get().at(0) > 1 [
              #smallcaps(lower(title))
              #h(1fr)
              #here().page()
              ]
            }
            )
  set text(font: fontfamily,
            lang: language,
            size: normal-size)

  // Set paragraph spacing.
  // show par: set block(above: 0.58em, below: 0.58em)
  set par(spacing: 0.58em)

  // Set Heading styles
  show heading: it => {
    // set textsize: normal-size)

    if it.level == 1 {
    align(text(it, size: normal-size), center)
    v(15pt, weak: true)
    }
    else {
      let wght = "bold"
      if it.level > 2 {
        wght = "regular"
      }
      align(emph(text(it, size: normal-size, weight: wght)))
      v(normal-size, weak: true)
    }
  }


  // Bibliography
  set bibliography(title: "References", style: "american-psychological-association")
  show bibliography: set block(spacing: 0.58em)
  show bibliography: set par(first-line-indent: 0em)

  // Figures
  show figure: set block(above: 2em, below: 2em)

  // Title Page
  align(center)[
    #if documenttype != none [
    #smallcaps(lower(documenttype)) \ ]
    #text(1.5em, title) \
    #if subtitle != none [
    #text(1.2em, subtitle) \ ]
    #v(1em, weak: true)
  ]

  // utility function: go through all authors and check their affiliations
  // purpose is to group authors with the same affiliations
  // returns a dict with two keys:
  // "authors" (modified author array)
  // "affiliations": array with unique affiliations
  let parse_authors(authors) = {
    let affiliations = ()
    let parsed_authors = ()
    let corresponding = ()
    let pos = 0
    for author in authors {
      if "affiliation" in author {
        if author.affiliation not in affiliations {
          affiliations.push(author.affiliation)
        }
        pos = affiliations.position(a => a == author.affiliation)
        author.insert("affiliation_parsed", pos)
      } else {
        // if author has no affiliation, just use the same as the previous author
        author.insert("affiliation_parsed", pos)
      }
      parsed_authors.push(author)
      if "corresponding" in author {
        if author.corresponding {
          corresponding = author
        }
      }
    }
    (authors: parsed_authors,
     affiliations: affiliations,
     corresponding: corresponding)
  }

  // utility function to turn a number into a letter
  // simulates footnotes
  let number2letter(num) = {
    "abcdefghijklmnopqrstuvwxyz".at(num)
  }

  let authors_parsed = parse_authors(authors)

  // List Authors
  if not anonymous {
  pad(
    top: 0.3em,
    bottom: 0.3em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors_parsed.authors.len()),
      gutter: 1em,
      ..authors_parsed.authors.map(author => align(center)[
        #author.name#super[#number2letter(author.affiliation_parsed)] \
      ]),
    ),
  )


  let affiliation_counter = counter("affiliation_counter")
  affiliation_counter.update(1)

  align(center)[
    #for affiliation in authors_parsed.affiliations [
      #context super(affiliation_counter.display("a"))#h(1pt)#emph(affiliation) #affiliation_counter.step() \
    ]
    #v(1em, weak: true)
    #date
    #v(2em, weak: true)
  ]
  } else {
    align(center)[
      #date
    ]
  }


  set par(justify: true)
  // Abstract & Keywords
  if abstract != none {
    heading(outlined: false, numbering: none, text(11pt, weight: "regular", [Abstract]))
    align(center)[
      #block(width: 90%, [
        #align(left)[
          #abstract \
          #v(1em, weak: true)
          #if keywords != none [
          #emph("Keywords: ") #keywords
          ]
        ]
        ]
      )
    ]
  }


  let orcid(height: 10pt, o) = [
    #box(height: height, baseline: 10%, image("assets/orcid.svg") ) #link("https://orcid.org/" + o)
  ]

  // Author Note
  if not anonymous {

  heading(outlined: false, numbering: none, text(11pt, weight: "bold", [Author Note]))

  // ORCID IDs
  for author in authors_parsed.authors [
    #author.name #orcid(author.orcid) \
  ]
  // Disclosures and Acknowledgements
  if disclosure != none [
    #disclosure \
  ] else [
    We have no conflicts of interest to disclose. \ ]

  if funding != none [
    #funding \
  ]

  // Contact Information
  [Correspondence concerning this article should be addressed to
   #authors_parsed.corresponding.name,]
   if "postal" in authors_parsed.corresponding [ #authors_parsed.corresponding.postal]
   [
   Email: #link("mailto:" + authors_parsed.corresponding.email, authors_parsed.corresponding.email)
   ]
   }

  pagebreak()

  // Main body.
  set par(first-line-indent: 2em)

  body
}
