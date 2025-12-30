// Template fait à partir de celui de l'ENSIAS, merci a eux
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#let IMAGE_BOX_MAX_WIDTH = 120pt
#let IMAGE_BOX_MAX_HEIGHT = 50pt

#let supported-langs = ("en", "fr", "ar")

#let full-page-chapter = state("full-page-chapter", false)


#let no-num(content) = {
  math.equation(
    block: true, 
    numbering: none, 
    content
  )
}
#let project(
  titre: "",
  subtitle: none,
  school-logo: image("images/logo_ecl.svg"),
  company-logo: none,
  sl-size : 50%,
  cl-size : 50%,
  auteurs: (),
  mentors: (),
  jury: (),
  date: none,
  french: true,
  footer-text: "École Centrale de Lyon",
  features: ("header-chapter-name"),
  heading-numbering: "1.1",
  accent-color: rgb("#b42135"),
  defense-date: none,
  fig-table: false,
  tab-table: false,
  body
) = {
  set text(lang: "fr")
  let dict = json("ressources/fr.json")
  // Normalisation des types pour eviter un probleme d'affichage
  let auteurs = if type(auteurs) == str { (auteurs,) } else { auteurs }
  let mentors = if type(mentors) == str { (mentors,) } else { mentors }
  let jury = if type(jury) == str { (jury,) } else { jury }
  set math.equation(numbering: "(1)")
  // Set the document's basic properties.
  set document(author: auteurs, title: titre)

  show : codly-init.with()
  codly(display-name:false, display-icon:false)

  set page(header: context {
    let headings = query(heading.where(level: 1).before(here()))
    let current-page-headings = query(heading.where(level: 1).after(here())).filter(h => h.location().page() == here().page())
    if headings == () {
      []
    } else {
      let current-chapter = headings.last()
      if current-chapter.level == 1 and current-chapter.numbering != none {
        let in-page-heading = if current-page-headings.len() > 0 { current-page-headings.first() } else { none }
        if in-page-heading == none or in-page-heading.level != 1 or in-page-heading.numbering == none {
          let count = counter(heading).at(current-chapter.location()).at(0)
          align(end)[
            #upper(
            text(accent-color, weight: "bold")[
              #dict.chapter #count :
            ])
            #current-chapter.body
            #line(length: 100%)
          ]
        }
      }
    }

  },     
  background: 
    [#place(
        bottom + left, // Corner alignment
        dx: -5cm,       // Optional: horizontal offset from edge
        dy: 1cm,      // Optional: vertical offset from edge
        image("images/motif.png", width: 45%)
      )
    ]
    ) if features.contains("header-chapter-name")

  set page(
    numbering: "1",
    number-align: center,
    footer: context {
    let page-number = counter(page).display()
    let physical-page = here().page()

    if physical-page > 1 and not full-page-chapter.get() {
      // Position the shield container at the bottom right
      place(bottom + right, dx: 1.5cm, dy: 0cm)[
        // Use a box to stack the image and text on top of each other
        #box(width: 1cm)[ // Adjust width to match your shield size
          #image("images/blason.png", width: 100%),
          #place(center + horizon, dy:-0.6cm, 
            text(size: 12pt, weight: "bold", fill: white)[#page-number]
          )
        ]
      ]
    }
    full-page-chapter.update(false)
  }
  )

  set heading(numbering: heading-numbering)

  show heading: it => {
      if it.level == 1 and it.numbering != none {
        if features.contains("full-page-chapter-title") {
          pagebreak()
          full-page-chapter.update(true)

          v(1fr)
          [
            #text(weight: "regular", size: 30pt)[
              #dict.chapter #counter(heading).display()
            ]
            #linebreak()
            #text(weight: "bold", size: 36pt)[
              #it.body
            ]
            #line(start: (0%, -1%), end: (15%, -1%), stroke: 2pt + accent-color)
          ]
          v(1fr)

          pagebreak()
        } else {
          //pagebreak()
          full-page-chapter.update(false)
          v(10pt)
          
          let heading-content = text(size: 20pt)[
            //#dict.chapter 
            #counter(heading).display(). #h(0.2cm) #it.body
          ]
          let text-width = measure(heading-content).width
          
          heading-content
          v(-0.6em)
          line(
            length: text-width * 75%, 
            stroke: 2pt + accent-color 
          )
          v(10pt)
        }
      } else {
        full-page-chapter.update(false)
        [#it]
        v(5pt)
      }
  }



  // Pour le gros logo central
  if company-logo == none {
    h(1fr)
    box(width: 80%)[
      #align(center)[
        #text(weight: "medium")[
          #school-logo
        ]
      ]
    ]
    h(1fr)
  }
  else {
    block[
      #box(width: 100%)[
        #box(width: sl-size)[
            #school-logo
        ]
        #h(1fr)
        #box(width: cl-size)[
            #company-logo
        ]
      ]
    ]
  }


  // Title box
  align(center + horizon)[
    #if subtitle != none {
      text(size: 14pt, tracking: 2pt)[
        #smallcaps[
          #subtitle
        ]
      ]
    }
    #line(length: 100%, stroke: 0.5pt)
    #text(size: 20pt, weight: "bold")[#titre]
    #line(length: 100%, stroke: 0.5pt)
  ]

  // Credits
  box()
  h(1fr)
  grid(
    columns: (auto, 1fr, auto),
    [
      // Auteurs
      #if auteurs.len() > 0 {
        [
          #text(weight: "bold")[
            #if auteurs.len() > 1 {
              dict.author_plural
            } else {
              dict.author
            }
            #linebreak()
          ]
          #for auteur in auteurs {
            [#auteur #linebreak()]
          }
        ]
      }
    ],
    [
      // Mentor
      #if mentors != none and mentors.len() > 0 {
        align(end)[
          #text(weight: "bold")[
            #if mentors.len() > 1 {
              dict.mentor_plural
            } else {
              dict.mentor
            }
            #linebreak()
          ]
          #for mentor in mentors {
            mentor
            linebreak()
          }
        ]
      }
      // Jury
      #if defense-date == none and jury != none and jury.len() > 0 {
        align(end)[
          *#dict.jury* #linebreak()
          #for prof in jury {
            [#prof #linebreak()]
          }
        ]
      }
    ]
  )

  align(center + bottom)[
    #if defense-date != none and jury != none and jury.len() > 0 {
      [*#dict.defended_on_pre_date #defense-date #dict.defended_on_post_date:*]
      // Jury
      align(center)[
        #for prof in jury {
          [#prof #linebreak()]
        }
      ]
      v(60pt)
    }
    #if date != none {
      [#date]
    } else {
      [#datetime.today().display("[day]/[month]/[year]")]
    }
  ]


  pagebreak()

  show outline.entry.where(level: 1): set text(weight: "bold")
  // Table des matieres
  counter(page).update(1)
  outline(depth: 3, indent: auto, title: "Table des matières")
  pagebreak()

  
  if fig-table {
    // Table des figures
    outline(
      title: dict.figures_table,
      target: figure.where(kind: image)
    )
  
    pagebreak()
  }
  if tab-table {
    // Table des tableaux
    outline(
      title: dict.tables_table,
      target: figure.where(kind: table)
    )
  
    pagebreak()
  }

  // Main
  body
}

