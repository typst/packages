#import "pages/frontpage.typ": frontpage
#import "pages/thirdpage.typ": thirdpage
#import "pages/fourthpage.typ": fourthpage
#import "pages/abspage.typ": abspage
#import "pages/ackpage.typ": ackpage
#import "pages/tocpage.typ": tocpage, flex-caption
#import "font-sizes.typ"

#let thesisblue = rgb("#0066CC")
#let thesisred = rgb("#CC0000")
#let thesispurple = rgb("#6600CC")
#let thesisgray = rgb("#666666")

#let runtime-state = state("chalmers-cse-thesis-runtime", (oneside: false))

#let heading-supplement(it) = if it.depth == 1 {
  [Chapter]
} else {
  [Section]
}

#let appendix-heading-supplement(it) = if it.depth == 1 {
  [Appendix]
} else {
  [Section]
}

#let footer(numbering: "1") = context {
  let oneside = runtime-state.get().oneside
  let page-number = counter(page).get().at(0)
  if oneside {
    align(center, counter(page).display(numbering))
  } else if page-number.bit-and(1) == 0 {
    align(left, counter(page).display(numbering))
  } else {
    align(right, counter(page).display(numbering))
  }
}

#let header(numbering: (x) => x, text: (idx, name) => [#idx. #name]) = context {
  let oneside = runtime-state.get().oneside
  let nextsel = selector(heading.where(level: 1)).after(here())
  let nextheaders = query(nextsel)
  let needs-header = true

  if nextheaders.len() > 0 and nextheaders.first().location().page() == here().page() {
    needs-header = false
  }

  if needs-header {
    let prevsel = selector(heading.where(level: 1)).before(here())
    let prevheaders = query(prevsel)

    if prevheaders.len() > 0 {
      let marker = if counter(heading).get().at(0) == 0 {
        prevheaders.last().body
      } else {
        text(numbering(counter(heading).get().at(0)), prevheaders.last().body)
      }

      if oneside {
        align(center, marker)
      } else if counter(page).get().at(0).bit-and(1) == 0 {
        align(left, marker)
      } else {
        align(right, marker)
      }

      v(-0.8em)
      line(length: 100%, stroke: black + 0.3pt)
    }
  }
}

#let pagebreak-next(oneside: false) = {
  if oneside {
    pagebreak()
  } else {
    pagebreak(to: "odd")
  }
}

#let as-content-node(node, width: auto, height: auto) = {
  if node == none {
    none
  } else if type(node) == str {
    image(node, width: width, height: height)
  } else {
    node
  }
}

#let prelude-pages(
  extra-faithful,
  title-font,
  school,
  date,
  title,
  subtitle,
  authors,
  department,
  subject,
  supervisor,
  advisor,
  examiner,
  abstract,
  keywords,
  acknowledgements,
  notation,
  figures,
  tables,
  listings,
  city,
  cover-background,
  titlepage-logo,
  typeset-with,
  cover-caption,
  printed-by,
  oneside,
) = {
  let blankpagebreak(..args) = {
    set page(footer: none, header: none)
    pagebreak(..args)
  }

  frontpage(
    extra-faithful,
    title-font,
    school,
    date.year(),
    title,
    subtitle,
    authors.join([\ ]),
    department,
    subject,
    city,
    cover-background,
  )

  if oneside {
    pagebreak()
  } else {
    pagebreak(to: "odd")
  }

  thirdpage(
    extra-faithful,
    school,
    date.year(),
    title,
    subtitle,
    authors.join([\ ]),
    department,
    city,
    titlepage-logo,
  )

  if oneside {
    pagebreak()
  } else {
    pagebreak(to: "even")
  }

  set page(footer: footer(numbering: "i"), header: none)
  fourthpage(
    extra-faithful,
    school,
    date.year(),
    title,
    subtitle,
    authors,
    department,
    supervisor,
    advisor,
    examiner,
    city,
    typeset-with,
    cover-caption,
    printed-by,
  )

  abspage(extra-faithful, school, title, subtitle, authors, department, abstract, keywords)

  blankpagebreak()
  ackpage(date, authors, acknowledgements, city)
  blankpagebreak()

  set page(
    footer: footer(numbering: "i"),
    header: header(text: (idx, body) => body),
    header-ascent: 10%,
  )
  tocpage(figures, tables, listings, oneside: oneside)

  if notation != none {
    pagebreak()
    notation
  }

  pagebreak-next(oneside: oneside)
  counter(page).update(1)
}

#let appendices(content) = {
  set page(
    footer: footer(numbering: "I"),
    header: header(numbering: (i) => numbering("A", i)),
    numbering: "I",
    header-ascent: 10%,
  )
  counter(page).update(1)
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: appendix-heading-supplement)

  content
}

#let template(
  font: "Latin Modern Roman",
  title-font: "Latin Modern Sans",
  extra-faithful: false,
  school: ("Chalmers University of Technology", "University of Gothenburg"),
  date: datetime.today(),
  title: "A Chalmers University of Technology Master's thesis template for Typst",
  subtitle: "A subtitle that can be very long if necessary",
  authors: ("Name Familyname 1", "Name Familyname 2"),
  department: "Department of Computer Science and Engineering",
  subject: "Computer Science and Engineering",
  supervisor: ("Supervisor Supervisorsson", "Department"),
  advisor: none,
  examiner: ("Examiner Examinersson", "Department"),
  abstract: [Abstract text about your project in Computer Science and Engineering],
  keywords: ("Keyword 1", "keyword 2"),
  acknowledgements: [Here, you can thank people that supported you during your project.],
  notation: none,
  figures: true,
  tables: true,
  listings: false,
  draft: false,
  oneside: false,
  margin: (top: 3cm, bottom: 3cm, inside: 3cm, outside: 3cm),
  city: "Gothenburg, Sweden",
  cover-background: none,
  titlepage-logo: none,
  typeset-with: "Typst",
  cover-caption: none,
  printed-by: none,
  content,
) = {
  runtime-state.update((oneside: oneside))

  set page(
    footer: none,
    header: none,
    numbering: "i",
    margin: margin,
  )
  set text(size: 12pt, font: font)
  set par(justify: true)

  if draft {
    show image: it => box(
      width: 100%,
      inset: 8pt,
      stroke: (paint: thesisgray, thickness: 0.8pt, dash: "dashed"),
      fill: luma(97%),
      [DRAFT IMAGE]
    )
  }

  show heading: set text(weight: "semibold")
  show heading.where(level: 1): set text(size: 20pt)
  show heading.where(level: 2): set text(size: 16pt)
  show heading.where(level: 3): set text(size: 14pt)
  show heading.where(level: 4): set text(size: 12pt)

  set math.equation(
    supplement: [Eq.],
  )
  set figure(numbering: (..nums) => {
    let fig-idx = nums.pos().last()
    numbering("1.1", counter(heading).get().at(0), fig-idx)
  })

  show link: set text(fill: thesisblue)
  show cite: set text(fill: thesisblue)
  show ref: set text(fill: thesisblue)

  show outline.entry: it => {
    set text(fill: thesisblue)
    show link: set text(fill: thesisblue)
    show cite: set text(fill: thesisblue)
    show ref: set text(fill: thesisblue)
    it
  }

  let cover-background-node = as-content-node(cover-background, width: 100%, height: 100%)
  let titlepage-logo-node = as-content-node(titlepage-logo, width: 25%)

  prelude-pages(
    extra-faithful,
    title-font,
    school,
    date,
    title,
    subtitle,
    authors,
    department,
    subject,
    supervisor,
    advisor,
    examiner,
    abstract,
    keywords,
    acknowledgements,
    notation,
    figures,
    tables,
    listings,
    city,
    cover-background-node,
    titlepage-logo-node,
    typeset-with,
    cover-caption,
    printed-by,
    oneside,
  )

  set page(
    footer: footer(numbering: "1"),
    header: header(),
    numbering: "1",
    header-ascent: 10%,
    margin: margin,
  )

  show figure.caption: it => box(
    align(left)[
      #text(weight: "bold")[
        #it.supplement
        #context it.counter.display(it.numbering):
      ]
      #h(0.35em)
      #it.body
    ]
  )

  show figure.where(kind: table): set figure.caption(position: top)

  set heading(numbering: "1.1", supplement: heading-supplement)
  counter(heading).update(0)

  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)

    if oneside {
      pagebreak(weak: true)
    } else {
      pagebreak(to: "odd", weak: true)
    }

    align(center, {
      v(38pt)
      text(50pt, weight: "regular", counter(heading).display())
      v(-30pt)
      text(24pt, it.body)
      v(30pt)
    })
  }

  show heading.where(level: 2): it => {
    block(sticky: true, [#counter(heading).display() #h(0.55em) #it.body])
  }

  show bibliography: it => {
    show heading.where(level: 1): h => {
      if oneside {
        pagebreak(weak: true)
      } else {
        pagebreak(to: "odd", weak: true)
      }
      counter(heading).update(0)
      align(center, {
        v(100pt)
        text(24pt, h.body)
        v(30pt)
      })
    }
    it
  }

  content
}
