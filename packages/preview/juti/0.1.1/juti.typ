#import "@preview/numbly:0.1.0": numbly

#let warn(body) = {
  show: highlight.with(fill: red.lighten(75%))
  body
}
#let empty-warn(body) = {
  if body == "" or body == [] or body == none {
    show: warn
    lorem(6)
  } else {
    body
  }
}
#let link-b(url, body) = {
  // show: underline
  // show: text.with(fill: rgb(0, 0, 238))

  if url != none {
    link(url, if body == [] {
      url
    } else {
      body
    })
  } else {
    body
  }
}
#let parse-date(date-str) = {
  let (year, month, day) = date-str.split("-")
  return datetime(year: int(year), month: int(month), day: int(day))
}
#let phantom(body) = place(top, scale(x: 0%, y: 0%, hide(body)))
#let inline-enum(
  join-sym: [,],
  last-join: [and],
  prefix-fn: i => [(#{ i + 1 }) ],
  join-sym-on-two: false,
  ..entries,
) = {
  entries = entries.pos()
  let n = entries.len()
  if n == 1 {
    return entries.at(0)
  }
  for (i, v) in entries.enumerate() {
    if i > 0 {
      if n != 2 and not join-sym-on-two [#join-sym ]
      if n != 0 and i == n - 1 {
        if last-join != none [#last-join ]
      }
    }
    let prefix = if prefix-fn != none {
      prefix-fn(i)
    }
    [#prefix#v]
  }
}
#let nth(ordinal-num, sup: bool) = {
  // Conditinally define ordinal-num, and if it's an integer change it to a string
  let ordinal-str = if type(ordinal-num) == int {
    str(ordinal-num)
  } else {
    ordinal-num
  }
  // Main if-else tree for this function
  let ordinal-suffix = if ordinal-str.ends-with(regex("1[0-9]")) {
    "th"
  } else if ordinal-str.last() == "1" {
    "st"
  } else if ordinal-str.last() == "2" {
    "nd"
  } else if ordinal-str.last() == "3" {
    "rd"
  } else {
    "th"
  }
  // Check whether sup attribute is set, and if so return suffix superscripted
  if sup == true {
    return ordinal-str + super(ordinal-suffix)
  } else {
    return ordinal-str + ordinal-suffix
  }
}

// define nths function, which is just nth with sup attribute applied
#let nths(ordinal) = {
  nth(ordinal, sup: true)
}

#let i(body) = {
  set cite(form: "prose")
  body
}

#let debug-outline() = {
  block(fill: red.lighten(80%), inset: 1em, outline())
}

#let format-date(d) = {
  if (
    type(d) == datetime
  ) [
    #d.display("[month repr:short]") #nths(d.day()), #d.display("[year]")] else [
    #d]
}

#let arrayfy(v) = if type(v) == array {
  v
} else {
  (v,)
}

#let JOURNAL-NAME = [JUTI: Jurnal Ilmiah Teknologi Informasi]
#let get-align-by-page(pagei) = if calc.rem-euclid(pagei, 2) == 0 {
  left
} else {
  right
}

#let paper-idx = state("paper-idx", "single")
#let book-state = state(
  "book-state",
  (
    volume: [-],
    number: [-],
    month: 2,
    year: 2025,
    start-page: 1,
  ),
)

#let contributions = (
  /* 0  */ [Conceptualization],
  /* 1  */ [Methodology],
  /* 2  */ [Software],
  /* 3  */ [Validation],
  /* 4  */ [Formal analysis],
  /* 5  */ [Investigation],
  /* 6  */ [Resources],
  /* 7  */ [Data Curation],
  /* 8  */ [Writing -- Original Draft],
  /* 9  */ [Writing -- Review & Editing],
  /* 10 */ [Visualization],
  /* 11 */ [Supervision],
  /* 12 */ [Project Administration],
  /* 13 */ [Funding Acquisition],
)
#let get-contributions(author) = author.contribution-refs.map(i => contributions.at(i)).join([, ])

#let credits(authors) = authors.map(author => [*#author.short:* #get-contributions(author).]).join([ ])

#let orcid(authors) = {
  set par(first-line-indent: 0pt)
  (
    authors.map(author => {
      let id = author.at("orcid", default: "")
      let url = "https://orcid.org/" + id
      [#author.name: #if id != "" { link(url, url) } else { [N/A] }]
    })
  ).join(linebreak())
}

#let init-authors(authors) = {
  for (i, author) in authors.enumerate() {
    if author.at("short", default: none) == none {
      let cleaned = author.name.replace(regex("[^a-zA-Z ]"), "")
      let splitted = cleaned.split(" ")
      authors.at(i).short = splitted
        .enumerate()
        .map(((j, v)) => {
          if j == splitted.len() - 1 {
            v
          } else {
            v.slice(0, 1) + "."
          }
        })
        .join(" ")
    }
  }

  authors
}

#let enumlist-level = state("enumlist-level", 1)

#let template(
  title: "Preparation of Papers for jurnal ilmiah teknologi informasi",
  title-content: [],
  authors: (
    (
      name: "First Alpha Author",
      institution-ref: 0,
      contribution: [],
      contribution-refs: range(0, 10),
    ),
    (
      name: "Second Beta Author",
      institution-ref: 0,
      contribution: [],
      contribution-refs: range(7, 13),
      orcid: "XXXX-XXXX-XXXX-XXXX",
    ),
    (
      name: "Third Charlie Author",
      institution-ref: 1,
      contribution: [],
      contribution-refs: range(7, 13),
      orcid: "XXXX-XXXX-XXXX-XXXX",
    ),
  ),
  corresponding-ref: 0,
  corresponding-email: none,
  institutions: (
    (
      name: "Department and institution name of authors",
      address: "Address of the first institution",
    ),
    (
      name: "Department and institution name of authors",
      address: "Address of the second institution",
    ),
  ),
  abstract: [],
  keywords: (
    "Keyword1",
    "Keyword2",
    "Keyword3",
    "Keyword4",
  ),
  meta: (
    // No need to change
    received: datetime(year: 9999, month: 12, day: 31),
    revised: datetime(year: 9999, month: 12, day: 31),
    accepted: datetime(year: 9999, month: 12, day: 31),
    online: datetime(year: 9999, month: 12, day: 31),
    doi: "https://doi.org/10.12962/j24068535.vXXXX.aXXXX",
  ),
  start-page: 1,
  body,
  bib: none,
) = context {
  let paper-id = paper-idx.get()
  let book = book-state.get()
  let institution-ref-all = authors.map(a => arrayfy(a.institution-ref)).flatten()
  let institutions = institutions.enumerate().filter(((i, v)) => institution-ref-all.contains(i)).map(((i, v)) => v)
  let single-institution = institutions.len() == 1
  let corresponding-email = (
    if corresponding-email != none { corresponding-email } else {
      authors.at(corresponding-ref).at("email", default: warn[No Email Defined for Corrseponding Author])
    }
  )
  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: math.equation)).update(0)
  counter(figure.where(kind: raw)).update(0)
  if start-page != none {
    counter(page).update(start-page)
  }
  let title-content = if title-content == none or title-content == [] {
    [#title]
  } else {
    title-content
  }
  set page(
    paper: "a4",
    header: context {
      show: pad.with(bottom: 1em)
      let paper-page-range = (
        counter(page).at(query(label(paper-id + ":start")).last().location()).at(0),
        counter(page).at(query(label(paper-id + ":end")).last().location()).at(0),
      )
      let pagei = counter(page).get().at(0)
      let aligned-pagei = pagei + paper-page-range.at(0) + 1
      set text(size: 9pt)
      set align(get-align-by-page(aligned-pagei))
      if calc.rem-euclid(aligned-pagei, 2) == 0 {
        if authors.len() > 2 {
          [#empty-warn(authors.at(0).short) et al.]
        } else {
          let names = authors.enumerate().map(((i, v)) => [#empty-warn(v.short)])
          inline-enum(prefix-fn: none, ..names)
        }
        [ -- ]
        text(style: "italic", empty-warn(title.replace("\n", " ")))
      } else {
        let month-year = datetime(
          year: book.year,
          month: book.month,
          day: 1,
        ).display("[month repr:long] [year]")
        let right-content = [#JOURNAL-NAME -- _Volume #book.volume, Number #book.number, #month-year: #paper-page-range.map(v => [#v]).join([ -- ])_]
        if pagei == paper-page-range.at(0) {
          grid(
            columns: (auto, 1fr),
            column-gutter: 2em,
            place(float: true, top, dy: 1em, image("logo.svg", height: 6em)), align(right, right-content),
          )
        } else {
          right-content
        }
      }
    },
    footer: context {
      let pagei = counter(page).get().at(0)
      set text(size: 10pt)
      set align(get-align-by-page(pagei))
      pagei
    },
    margin: (
      x: 0.65in,
      y: 1in,
    ),
  )
  set text(font: ("Liberation Serif", "Segoe UI Symbol"), fallback: false)
  // set text(font: "Times New Roman", fallback: false)
  set bibliography(
    style: "ieee",
    title: none,
  )
  set par(linebreaks: "optimized")

  //? Figure
  // set figure(placement: top)

  //? Image
  show figure.where(kind: image): set figure(placement: top, supplement: [Fig.])
  show figure.where(kind: image): set text(size: .8em)

  //? Table
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): set figure(placement: top, supplement: [Table])
  set table(align: left)

  //? Algorithm
  show figure.where(kind: "algorithm"): set figure(placement: top, supplement: [Algorithm])

  //? Caption
  set figure.caption(separator: [. ])
  show figure.caption: set align(left)
  show figure.caption: set par(first-line-indent: 0pt)
  show figure.caption: it => context [
    *#it.supplement #it.counter.get().at(0)#it.separator* #it.body
  ]

  // TODO: Still not fixed
  // show enum.item: it => {
  //   enumlist-level.update(l => l + 1)
  //   it
  //   enumlist-level.update(l => l - 1)
  // }
  set enum(indent: 1em)
  // show enum: it => context {
  //   set enum(indent: 0em) if enumlist-level.get() > 0
  //   it
  // }
  // show list.item: it => {
  //   enumlist-level.update(l => l + 1)
  //   it
  //   enumlist-level.update(l => l - 1)
  // }
  set list(indent: 1em)
  // show list: it => context {
  //   set list(indent: 0em) if enumlist-level.get() > 0
  //   it
  // }
  show table: set enum(indent: 0em)
  show table: set list(indent: 0em)
  show table: set par(justify: false, first-line-indent: 0em)
  show table.header: set text(weight: "bold")
  set table(stroke: none)
  show figure.where(kind: table): set text(size: .8em)
  show figure.where(kind: table): set figure.caption(position: top)

  //? Equation
  // show math.equation: set text(font: "New Computer Modern Math")
  set math.equation(numbering: "(1)")
  show math.equation: math.italic
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      link(el.location(), numbering(el.numbering, ..counter(eq).at(el.location())))
    } else {
      // Other references as usual.
      it
    }
  }

  //? START OF CONTENT
  [#metadata(none)#label(paper-id + ":start")]

  //? Title
  {
    set align(left)
    set text(size: 16pt, weight: "bold")
    // show: upper
    empty-warn(title-content)
    phantom(heading(title-content, bookmarked: true))
  }

  //? Author names
  {
    set align(left)
    set text(size: 12pt, weight: "bold")
    let names = authors
      .enumerate()
      .map(((i, v)) => box[
        #empty-warn(v.name)
        #set text(weight: "regular")
        #if single-institution [
          #if corresponding-ref == i {
            super[\*]
          }
        ] else [
          #super[
            #let values = arrayfy(v.institution-ref).map(v => [#{ v + 1 }])
            #if corresponding-ref == i {
              values = values + ([\*],)
            }
            #values.join([, ])
          ]
        ]
        #if v.at("orcid", default: "") != "" [ #link("https://orcid.org/" + v.orcid, box(height: .8em, image(
          "ORCID-iD_icon_vector.svg",
          height: .8em,
        )))]])

    inline-enum(prefix-fn: none, last-join: none, ..names)
  }

  //? Institutions
  {
    set align(left)
    set text(size: 8pt, style: "italic")
    set par(spacing: .5em)

    for (i-institution, institution) in institutions.enumerate() {
      [
        #if not single-institution {
          super[#{ i-institution + 1 }]
        }
        #empty-warn(institution.name), #institution.address

      ]
    }
  }

  v(.5em)
  grid(
    columns: (25%, auto),
    column-gutter: 1.5em,
    {
      line(length: 100%, stroke: 0.6pt)
      {
        set align(left)
        set text(size: 10pt, weight: "regular")
        [ARTICLE INFO]
      }
      set text(size: 8pt, style: "italic")
      [

        //? Keywords
        Keywords: \
        #{
          [
            #inline-enum(prefix-fn: none, last-join: none, join-sym: [\ ], ..keywords.sorted().map(v => empty-warn(v)))
          ]
        }
        #v(.6em)
        \* Corresponding author: \ #corresponding-email \
        #v(.6em)
        Article history: \
        Received: #format-date(meta.received) \
        Revised: #format-date(meta.revised) \
        Accepted: #format-date(meta.accepted) \
        Available online: #format-date(meta.online) \
      ]
    },
    {
      line(length: 100%, stroke: 0.6pt)

      //? Abstract Title
      {
        set align(left)
        set text(size: 10pt, weight: "regular")
        [ABSTRACT]
      }

      //? Abstract
      {
        set text(
          size: 10pt,
          // weight: "regular",
          // style: "italic",
        )
        // set par(justify: true, first-line-indent: (amount: 2em, all: true))
        set par(justify: true)
        empty-warn(abstract)
      }
    },
  )
  line(length: 100%, stroke: 0.6pt)
  v(.5em)

  //? Numberings
  set heading(
    numbering: numbly(
      "{1}.",
      "{1}.{2}.",
      "{3:A}.",
    ),
  )
  // set enum(numbering: "1)")
  //? Heading 1
  show heading.where(level: 1): it => {
    // set align(center)
    set text(size: 11pt, weight: "bold")
    it
    // smallcaps(it)
    v(.5em)
  }
  //? Heading 2
  show heading.where(level: 2): it => {
    set text(
      size: 11pt,
      weight: "regular",
      style: "italic",
    )
    it
  }
  //? Heading 3
  show heading.where(level: 3): it => {
    set text(
      size: 11pt,
      weight: "regular",
      style: "italic",
    )
    it
  }
  //? Heading 4
  show heading.where(level: 4): it => {
    set text(
      size: 11pt,
      weight: "regular",
      style: "italic",
    )
    it
  }

  //? Metadata Footnote
  figure(
    pad(bottom: -1.2em)[
      #set align(left)
      #set text(size: 9pt)

      #pad(y: -.65em, line(length: 100%))

      © #context { book-state.get().year } The Authors. This is an open access article under the CC BY-SA license (#link-b("https://creativecommons.org/licenses/by-sa/4.0/")[])\ DOI: #link-b(meta.doi)[]
    ],
    placement: bottom,
    supplement: none,
    kind: "footnote-metadata",
  )

  set par(justify: true, first-line-indent: (amount: 2em, all: true))
  set text(size: 11pt, weight: "regular")

  body

  //? References
  if bib != none {
    heading(numbering: none, outlined: false)[References]

    set text(size: 8pt)
    set par(spacing: .65em)
    bib
  }
  //? END OF CONTENT
  [#metadata(none)#label(paper-id + ":end")]
}

#let cover(
  issn: "1412-6389",
  eissn: "2406-8535",
  papers: (),
) = context {
  let book = book-state.get()
  let juti-blue = rgb("#113E68")
  let juti-yellow = rgb("FFBD07")
  let primary-color = white
  let accent-color = rgb("#1e90ff")

  set page(
    paper: "a4",
    margin: (x: 0.65in, y: 0.65in),
    header: none,
    footer: none,
    background: image("cover_background.png", width: 100%, height: 100%),
  )
  set text(font: ("Liberation Sans", "Arial", "Helvetica"), fallback: true)

  // ISSN top right — stays above shield zone (shield center y≈52pt in content)
  {
    set align(right)
    set text(size: 12pt, fill: primary-color, weight: "bold")
    [P-ISSN #issn \ E-ISSN #eissn]
  }

  v(-5em)

  // JUTI large — left-aligned, clear of binary data motif (that's in margin)
  {
    set text(size: 72pt, weight: "black", fill: juti-yellow.lighten(50%))
    [JUTI]
  }

  v(-5em)

  // Full name
  {
    set text(size: 28pt, weight: "bold", fill: juti-yellow.lighten(50%))
    [Jurnal Ilmiah Teknologi Informasi]
  }

  linebreak()

  // Subtitle italic
  {
    set text(size: 16pt, style: "italic", weight: "regular", fill: primary-color)
    [Scientific Journal of Information Technology]
  }

  v(1em)
  line(length: 100%, stroke: 2pt + primary-color)
  v(1em)

  // TOC entries — left-padded 36% to avoid robot head + brain circle
  // (robot occupies x=0–177pt in content, brain circle x=0–120pt; both y=46–85% of page)
  pad(left: 0%, {
    {
      set align(center)
      set text(size: 18pt, weight: "bold", fill: primary-color)
      let month-year = datetime(year: book.year, month: book.month, day: 1).display("[month repr:long] [year]")
      [Vol. #book.volume, No. #book.number, #month-year]
    }

    v(1em)
    set text(size: 10pt, fill: primary-color)
    set par(justify: false, leading: .5em, spacing: 1.2em)
    for paper in papers {
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
        {
          text(weight: "bold", fill: juti-yellow.lighten(50%), upper(paper.title))
          linebreak()
          text(style: "italic", paper.authors)
        },
        {
          set align(right + top)
          if paper.at("pages", default: none) != none {
            text(fill: juti-yellow.lighten(50%), weight: "bold", paper.pages)
          }
        },
      )
    }
  })

  set text(weight: "bold")
  place(bottom + left, text(size: 10pt, fill: primary-color, link("https://juti.if.its.ac.id/")))
  place(bottom + right, text(size: 10pt, fill: primary-color, [Published by Institut Teknologi Sepuluh Nopember]))
}

#let cover2(
  issn: "1412-6389",
  eissn: "2406-8535",
  papers: (),
) = context {
  let book = book-state.get()
  let juti-blue = rgb("#113E68")
  let juti-yellow = rgb("FFBD07")
  let primary-color = white
  let accent-color = rgb("#1e90ff")

  set page(
    paper: "a4",
    margin: (x: 0.65in, y: 0.65in),
    header: none,
    footer: none,
    background: image("cover_background.jpeg", width: 100%, height: 100%),
  )
  set text(font: ("Liberation Sans", "Arial", "Helvetica"), fallback: true)

  v(17.5em)

  {
    set align(right)
    set text(size: 18pt, weight: "bold", fill: primary-color)
    let month-year = datetime(year: book.year, month: book.month, day: 1).display("[month repr:long] [year]")
    [Vol. #book.volume, No. #book.number, #month-year]
  }

  v(3em)

  // TOC entries — left-padded 36% to avoid robot head + brain circle
  // (robot occupies x=0–177pt in content, brain circle x=0–120pt; both y=46–85% of page)

  set text(size: 10pt, fill: primary-color)
  set par(justify: false, leading: .5em, spacing: 1.2em)
  for paper in papers {
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      {
        text(weight: "bold", upper(paper.title))
        linebreak()
        text(style: "italic", paper.authors)
      },
      {
        set align(right + top)
        if paper.at("pages", default: none) != none {
          text(weight: "bold", paper.pages)
        }
      },
    )
  }

  set text(weight: "bold")
  place(bottom + left, text(size: 10pt, fill: primary-color, link("https://juti.if.its.ac.id/")))
  place(bottom + right, text(size: 10pt, fill: primary-color, [Published by Institut Teknologi Sepuluh Nopember]))
}
