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
  show: underline
  show: text.with(fill: rgb(0, 0, 238))

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
  ..entries,
) = {
  entries = entries.pos()
  let n = entries.len()
  if n == 1 {
    return entries.at(0)
  }
  for (i, v) in entries.enumerate() {
    if i > 0 {
      [#join-sym ]
    }
    if n != 0 and i == n - 1 and last-join != none {
      [#last-join ]
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

#let init-authors(authors) = {
  for (i, author) in authors.enumerate() {
    if author.at("short", default: none) == none {
      authors.at(i).short = author
        .name
        .split(" ")
        .enumerate()
        .map(((j, v)) => {
          if j == authors.len() - 1 {
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
  title: "Preparation of Papers for JUTI (JURNAL ILMIAH TEKNOLOGI INFORMASI)",
  authors: (
    (
      name: "First Alpha Author",
      institution-ref: 0,
      email: "first.author@email.com",
      contribution: [],
      contribution-refs: range(0, 10),
    ),
    (
      name: "Second Beta Author",
      institution-ref: 0,
      email: "second.author@email.com",
      contribution: [],
      contribution-refs: range(7, 13),
    ),
    (
      name: "Third Charlie Author",
      institution-ref: 1,
      email: "third.author@email.com",
      contribution: [],
      contribution-refs: range(7, 13),
    ),
  ),
  corresponding-ref: 0,
  institutions: (
    (
      name: "Department and institution name of authors",
      address: "Address of institution",
    ),
    (
      name: "Department and institution name of authors",
      address: "Address of institution",
    ),
  ),
  abstract: [],
  keywords: (),
  meta: (
    // No need to change
    received: [will be set by the editor],
    revised: [will be set by the editor],
    accepted: [will be set by the editor],
    online: [will be set by the editor],
    doi: [will be set by the editor],
  ),
  start-page: 1,
  body,
  bib: none,
) = context {
  let paper-id = paper-idx.get()
  let book = book-state.get()
  counter(heading).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: math.equation)).update(0)
  counter(figure.where(kind: raw)).update(0)
  if start-page != none {
    counter(page).update(start-page)
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
            place(float: true, bottom, dy: .5em, image("logo.jpg", height: 1.5em)), align(right, right-content),
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
  show figure.where(kind: table): set figure(placement: top, supplement: [Table])
  set table(align: left)
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
  show table: set par(justify: false)
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
    set align(center)
    set text(size: 16pt, weight: "bold")
    // show: upper
    empty-warn(title)
    phantom(heading(title, bookmarked: true))
  }

  //? Author names
  {
    set align(center)
    set text(size: 12pt, weight: "bold")
    let names = authors
      .enumerate()
      .map(((i, v)) => box[#empty-warn(v.name) #super[#{ i + 1 }#if corresponding-ref == i [,\*])]])

    inline-enum(prefix-fn: none, ..names)
  }

  //? Institutions
  {
    set align(center)
    set text(size: 10pt)

    for (i-institution, institution) in institutions.enumerate() {
      let author-indices = authors
        .enumerate()
        .map(((i, v)) => (
          ..v,
          _index: i,
        ))
        .filter(v => if type(v.institution-ref) == array {
          v.institution-ref.contains(i-institution)
        } else {
          v.institution-ref == i-institution
        })
        .map(v => v._index + 1)

      [
        #super[#inline-enum(last-join: none, prefix-fn: none, ..author-indices.map(v => [#v])))] #empty-warn(
          institution.name,
        ) \
        #institution.address

      ]
    }
  }

  //? Emails
  {
    set align(center)
    set text(size: 10pt)
    let emails = authors
      .enumerate()
      .map(
        //
        ((i, v)) => box(if type(v.email) == array {
          v.email.map(v => [#empty-warn(v)#super[#{ i + 1 })]]).join([, ])
        } else [
          #empty-warn(v.email)#super[#{ i + 1 })]
        ]),
      )

    [E-mail: ]
    inline-enum(prefix-fn: none, ..emails)
  }

  v(.5em)
  line(length: 100%)

  //? Abstract Title
  {
    set align(center)
    set text(size: 10pt, weight: "bold")
    [ABSTRACT]
  }

  //? Abstract
  {
    set text(
      size: 10pt,
      // weight: "regular",
      // style: "italic",
    )
    set par(justify: true, first-line-indent: (amount: 2em, all: true))
    empty-warn(abstract)
  }

  //? Keywords
  {
    set text(
      size: 10pt,
      // weight: "regular",
      // style: "italic",
    )
    set par(justify: true)
    [*Keywords:* ]
    inline-enum(prefix-fn: none, last-join: none, ..keywords.map(v => empty-warn(v)))
  }

  line(length: 100%)
  v(.5em)

  //? Numberings
  set heading(outlined: false, numbering: (num1, ..nums) => {
    let l = nums.pos().len()
    // numbering("1.1.1.", num1, ..nums)
    if l == 0 {
      numbering("1.", num1)
      // h(10pt)
    } else if l == 1 {
      numbering("1.1.", num1, ..nums)
      // h(7pt)
    } else if l == 2 {
      numbering("A.", ..nums.pos().slice(1), ..nums.named())
    } else {
      panic("Unhandled heading 4 or more.")
    }
  })
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

  let format-date(d) = {
    if (
      type(d) == datetime
    ) [
      #d.display("[month repr:long]") #nths(d.day()), #d.display("[year]")] else [
      #d]
  }
  //? Metadata Footnote
  figure(
    pad(bottom: -1.2em)[
      #set align(left)
      #set text(size: 9pt)

      \* Corresponding author. \
      Received: #format-date(meta.received).
      Revised: #format-date(meta.revised).
      Accepted: #format-date(meta.accepted).

      #pad(y: -.65em, line(length: 100%))

      Available online: #format-date(meta.online). \
      © #datetime.today().display("[year]") The Authors. This is an open access article under the CC BY-SA license (#link-b("https://creativecommons.org/licenses/by-sa/4.0/")[])\ DOI: #meta.doi
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
