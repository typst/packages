#import "@preview/grayness:0.3.0": *
#let translations = yaml("translations.yaml")

#let sizes = (
  tiny: 8pt,
  scriptsize: 10pt,
  footnotesize: 9pt,
  small: 10pt,
  normalsize: 12pt,
  medium: 13pt,
  big: 14pt,
  large: 16pt,
  LARGE: 18pt,
  huge: 20pt,
  HUGE: 22pt,
)

#let template(
  title: [Thesis title],
  subtitle: [Subtitle],
  candidate: (), // is passed as candidate:(name: "Mario Rossi", number: "123456")
  supervisor: (),
  co-supervisor: (),
  course: (),
  date: (),
  logo: image("images/Unive.svg", width: 20%),
  is-master: false,
  abstract: (),
  lang: "en",
  bib: (),
  body,
) = {

  // If the inserted language doesn't exists, defaults to english
  let ref = if lang in translations { translations.at(lang) } else { translations.at("en") }

  // State to track the current chapter
  let current-chapter = state("current-chapter", none)

  // State to track new chapter pages
  let chapter-start-page = state("chapter-start-page", none)

  set document(title: title, author: candidate.name)

  set page(
    numbering: "1",
  )
  set math.equation(numbering: "(1)")

  set text(size: sizes.normalsize, lang: lang)

  set par(
    justify: true,
    spacing: 10pt,
  )

  set heading(numbering: "1.1.1")
  show heading.where(level: 1): item => {
    if item.body == [#ref.table_contents] {
      // if is table of contents
      text(size: sizes.HUGE, item, weight: "bold")
      v(20pt)
    } else if item.body == [#ref.bibliography] or item.body == [#ref.acknowledgements] {
      pagebreak()
      // Mark this page as a chapter start
      chapter-start-page.update(counter(page).get().first())
      block(width: 100%, height: 10%)[
        #set align(left + horizon)
        #set text(size: sizes.HUGE, weight: "bold")
        #text([#item.body])
      ]
      // Update current chapter for special sections
      current-chapter.update(item.body)
    } else {
      pagebreak()
      // Mark this page as a chapter start
      chapter-start-page.update(counter(page).get().first())
      // Update current chapter
      current-chapter.update(item.body)
      block(width: 100%, below: 5%)[ // above: 30%
        #set align(left + horizon)
        #set text(size: sizes.HUGE, weight: "bold")
        #text([#ref.chapter #counter(heading).display() - #item.body])
      ]
    }
  }
  show heading.where(level: 2): item => {
    block(width: 100%, above: 5%, below: 3%)[
      #set align(left + horizon)
      #set text(size: sizes.LARGE, weight: "bold")
      #text([#item])
    ]
  }
  show heading.where(level: 3): item => {
    block(width: 100%, above: 5%, below: 3%)[
      #set align(left + horizon)
      #set text(size: sizes.large, weight: "bold")
      #text([#item])
    ]
  }
  show heading.where(level: 4): item => {
    block(width: 100%, above: 5%, below: 3%)[
      #set align(left + horizon)
      #set text(size: sizes.big, weight: "bold")
      #text([#item])
    ]
  }

  set page(
    header: context {
      let chapters = query(selector(heading.where(level: 1)))
      // Get the current page
      let current-page = counter(page).get().first()

      // Check if current page is any chapter start page
      let chapter-pages = chapters.map(c => c.location().page())
      if current-page in chapter-pages {
        return // Don't show header on chapter start pages
      }

      // Find which chapter we're currently in
      let relevant-chapters = chapters.filter(c => c.location().page() <= current-page)
      if relevant-chapters.len() > 0 {
        let current-chapter = relevant-chapters.last()
        let chapter-text = current-chapter.body

        if calc.odd(current-page) {
          h(1fr)
          text([#chapter-text], style: "italic")
        } else {
          h(1fr)
          text(chapter-text, style: "italic")
        }
      }
    },
    footer: context {
      let page = counter(page).get().first()
      // Show centered page number in footer
      align(center, [#page])
    },
  )

  if logo != none {
    align(left + top, block[
      #logo\
      // TODO: trovare font per fare la scritta
      //#text(size: sizes.LARGE, ref.unive_1, weight: "light", font: "Newsreader")\
      //#text(size: sizes.LARGE, ref.unive_2, weight: "light", font: "Newsreader")\
      //#text(size: sizes.LARGE, ref.unive_3, weight: "light", font: "Newsreader")
    ])
  }

  v(40pt) // Corso di laurea in ...
  align(center, text(size: sizes.big, if is-master { ref.master } else { ref.bachelor }, weight: "regular"))
  align(center, text(size: sizes.large, course, weight: "regular"))

  v(40pt) // "Tesi di laurea"
  align(center, text(size: sizes.LARGE, ref.thesis, weight: "regular"))

  v(40pt) // titolo
  align(center, text(size: sizes.huge, title, weight: "bold"))
  v(5pt) // sottotitolo
  align(center, text(size: sizes.large, subtitle, weight: "regular"))

  align(left + bottom, block[
    // Relatore
    #text(size: sizes.medium, ref.supervisor, weight: "bold") \
    #text(size: sizes.normalsize, supervisor, weight: "regular") \

    #v(10pt)
    // Co-relatore
    #text(size: sizes.medium, ref.cosupervisor, weight: "bold") \
    #text(size: sizes.normalsize, co-supervisor, weight: "regular") \

    #v(20pt)
    // Nome, cognome e matricola del laureando
    #text(size: sizes.medium, ref.candidate, weight: "bold") \
    #text(size: sizes.normalsize, candidate.name, weight: "regular") \
    #text(size: sizes.normalsize, ref.serial_number, weight: "regular")
    #text(size: sizes.normalsize, candidate.number, weight: "regular", style: "italic") \

    #v(10pt)
    // anno accademico
    #text(size: sizes.medium, ref.academic_year, weight: "bold") \
    #text(size: sizes.normalsize, date, weight: "regular") \
  ])

  let data = read("images/UNIVE_square.png", encoding: none)
  set page(
    background: pad(x: 20pt, y: 20pt, align(left + top, image-transparency(data, alpha: 50%, width: 10%))),
    margin: (top: 100pt)
  )

  if abstract != () {
    page()[
      #block(width: 100%, height: 15%)[
        #align(center, text(size: sizes.LARGE, "Abstract", weight: "bold"))
      ]
      //#include abstract
      #abstract
    ]
  }

  show outline.entry: it => {
    if it.element.body == [#ref.acknowledgements] or it.element.body == [#ref.bibliography] {
      block(width: 100%, above: 3%)[
        #text(size: sizes.medium, [#it.inner()], weight: "bold")
          
      ]
    } else {
      if it.level == 1 {
        block(width: 100%, above: 3%)[
          #text(size: sizes.medium, it, weight: "bold")
        ]
      } else {
        block(width: 100%, above: 1.5%)[
          #text(size: sizes.medium, it, weight: "regular")
        ]
      }
    }
  }
  page()[
    #outline()
  ]

  body

  if bib != () {
    // pagebreak()
    bib
  }
}
