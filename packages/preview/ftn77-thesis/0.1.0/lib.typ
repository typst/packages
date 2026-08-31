#import "src/common.typ": azbuka, graph, sr-numbering
#import "src/components.typ": (
  assignment-form-heading, form-heading, ftn-logo, ftn-logo-new, uns-logo,
)
#import "style.typ" as style
#import "src/pre.typ" as pre
#import "src/glossary.typ" as glossary
#let _gls = glossary

#import "src/cover.typ": cover, cover-new
#import "src/form/assignment.typ": assignment
#let _assignment = assignment
#import "src/form/kwd.typ": kwd
#import "src/form/conflict.typ": conflict


#let bibliography = std.bibliography.with(style: "assets/csl/ieee.xml")

#let _appendices = state("appendices", none)

#let appendices(body) = context {
  _appendices.update(_appendices.get() + body)
  none
}


#let outlines = (
  std.outline(depth: 3),
  std.outline(title: "Списак слика", target: figure.where(kind: image)),
  std.outline(title: "Списак табела", target: figure.where(kind: table)),
  std.outline(title: "Списак листинга", target: figure.where(kind: raw)),
  std.outline(title: "Списак графика", target: figure.where(kind: graph)),
)


#let thesis(
  title: [],
  author: (
    name: "Именко Презимић",
    id: "",
  ),
  mentor: (
    name: "Ранко Презимић",
  ),
  keywords: (),
  abstract: none,
  program: [],
  degree: [Основне академске студије],
  field: [],
  discipline: [],
  assignment: [],
  date: auto,
  bio: none,
  glossary: (:),
  glossary-links: false,
  glossary-all: false,
  outlines: outlines,
  chapter-relative-fig-nums: true,
  appendices: none,
  accession-number: [],
  identification-number: [],
  document-type: [],
  type-of-record: [],
  contents-code: [],
  text-lang: [],
  abstract-lang: [],
  publication: (
    publisher: [],
    country: [],
    locality: [],
    place: [],
    year: [],
  ),
  physical: auto,
  subject-keywords: [],
  uc: [],
  holding-data: [],
  note: [],
  accepted-date: [],
  defense: (
    date: [],
    president: [],
    member1: [],
    member2: [],
    mentor: [],
  ),

  en: (
    title: [],
    author: (
      name: "Imenko Prezimić",
      id: "",
    ),
    mentor: (
      name: "Ranko Prezimić",
    ),
    keywords: (),
    abstract: none,
    program: [],
    degree: [Основне академске студије],
    field: [],
    discipline: [],

    accession-number: [],
    identification-number: [],
    document-type: [],
    type-of-record: [],
    contents-code: [],
    text-lang: [],
    abstract-lang: [],
    publication: (
      publisher: [],
      country: [],
      locality: [],
      place: [],
      year: [],
    ),
    physical: auto,
    subject-keywords: [],
    uc: [],
    holding-data: [],
    note: [],
    accepted-date: [],
    defense: (
      date: [],
      president: [],
      member1: [],
      member2: [],
      mentor: [],
    ),
  ),

  bibliography: none,
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  new-cover: false,
  duplex: false,

  style: style,
  body,
  ..sink,
) = {
  set document(
    title: title,
    author: author.name,
    keywords: keywords + en.keywords,
  )

  set page(
    margin: margin,
    paper: paper,
  )

  show: style.pre

  set text(
    lang: "sr",
    region: "RS",
  )

  let pagebreak(weak: true, to: if duplex { "odd" } else { none }) = {
    set page(header: none, footer: none)
    std.pagebreak(weak: weak, to: to)
  }

  show heading.where(level: 1): h1 => context {
    if chapter-relative-fig-nums {
      let fig-kinds = query(figure).map(fig => fig.kind).dedup()

      for kind in fig-kinds {
        counter(figure.where(kind: kind)).update(0)
      }
    }

    h1
  }

  set page(numbering: "i")

  if new-cover {
    cover-new
  } else {
    cover
  }(
    title: title,
    author: author,
    date: date,
    degree: degree,
    style: style,
  )

  pagebreak()
  _assignment(
    assignment,
    title: title,
    program: program,
    degree: degree,
    field: field,
    author: author,
    mentor: mentor,
    style: style,
  )

  show: _gls.init-glossary.with(glossary, term-links: glossary-links)

  {
    show: style.base
    show heading.where(level: 1): h1 => pagebreak() + h1

    {
      set footnote.entry(separator: none)
      show footnote: none
      show footnote.entry: none

      outlines.sum()
    }

    _gls.glossary(
      show-all: glossary-all,
    )
  }

  pagebreak()
  metadata("page-count-reset")
  counter(page).update(1)

  set page(numbering: "1")

  {
    show: style.base
    show heading.where(level: 1): h1 => pagebreak() + h1

    {
      show: style.main

      counter(heading).update(0)

      show heading.where(level: 1): h1 => h1 + metadata("h:chapter")

      body
    }

    bibliography

    {
      show: style.appendices

      counter(heading).update(0)

      show heading.where(level: 1): h1 => h1 + metadata("h:appendix")

      context appendices + _appendices.final()
    }

    if type(bio) == str [
      = Биографија
    ]

    bio
  }

  pagebreak()
  kwd(
    lang: "sr",
    acession-number: accession-number,
    identification-number: identification-number,
    document-type: document-type,
    type-of-record: type-of-record,
    contents-code: contents-code,
    author: author,
    mentor: mentor,
    title: title,
    text-lang: text-lang,
    abstract-lang: abstract-lang,
    publication: publication,
    physical: physical,
    field: field,
    discipline: discipline,
    subject-keywords: subject-keywords,
    uc: uc,
    holding-data: holding-data,
    note: note,
    abstract: abstract,
    accepted-date: accepted-date,
    defense: defense,
    style: style,
  )

  pagebreak()
  kwd(
    lang: "en",
    acession-number: en.accession-number,
    identification-number: en.identification-number,
    document-type: en.document-type,
    type-of-record: en.type-of-record,
    contents-code: en.contents-code,
    author: en.author,
    mentor: en.mentor,
    title: en.title,
    text-lang: text-lang,
    abstract-lang: abstract-lang,
    publication: en.publication,
    physical: en.physical,
    field: en.field,
    discipline: en.discipline,
    subject-keywords: en.subject-keywords,
    uc: en.uc,
    holding-data: en.holding-data,
    note: en.note,
    abstract: en.abstract,
    accepted-date: en.accepted-date,
    defense: en.defense,
    style: style,
  )

  pagebreak()
  conflict(style: style)
}
