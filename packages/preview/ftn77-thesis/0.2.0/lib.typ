#import "src/common.typ": azbuka, graph, sr-numbering
#import "src/components.typ": (
  assignment-form-heading, form-heading, ftn-logo, ftn-logo-new, ftn-logo-template, uns-logo,
  uns-logo-template,
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


#let bibliography = std.bibliography.with(style: style.ieee)

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
  cover-title: auto,
  author: (
    name: "Именко Презимић",
    id: "",
  ),
  mentor: (
    name: "Ранко Презимић",
  ),
  keywords: (),
  abstract: none,
  abstract-page: none,
  dedication: none,
  acknowledgement: none,
  program: [],
  degree: [Основне академске студије],
  field: [],
  discipline: [],
  assignment: [],
  assignment-number: [],
  assignment-date: [],
  date: auto,
  bio: none,
  glossary: (:),
  glossary-links: true,
  glossary-all: false,
  outlines: outlines,
  chapter-relative-fig-nums: true,
  url-footnotes: true,
  accent: style.navy,
  old-style-numbers: true,
  body-size: 11pt,
  body-font: ("Times New roman", "Segoe UI Symbol", "Liberation Serif", "Noto Sans Symbols2"),
  math-size: 11pt,
  math-font: ("Cambria Math", "Tex Gyre Pagella Math", "Libertinus Math"),
  raw-size: 10pt,
  raw-font: ("Courier New", "Liberation Mono"),
  hydra-main: true,
  hydra-appendices: false,
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
  ),

  en: (
    title: [],
    author: (
      name: "Imenko Prezimić",
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
    ),
    subject-keywords: [],
    uc: [],
    holding-data: [],
    note: [],
    defense: (
      president: [],
      member1: [],
      member2: [],
    ),
  ),

  bibliography: none,
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
  new-cover: false,
  duplex: false,
  copy-for: none,

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
    set page(header: metadata("empty-page"), footer: none)
    std.pagebreak(weak: weak, to: to)
  }

  show heading.where(level: 1): h1 => context {
    if chapter-relative-fig-nums {
      let fig-kinds = query(figure).map(fig => fig.kind).dedup()

      for kind in fig-kinds {
        counter(figure.where(kind: kind)).update(0)
      }

      counter(math.equation).update(0)
    }

    h1
  }

  set page(numbering: "i")

  if new-cover {
    cover-new
  } else {
    cover
  }(
    title: cover-title,
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
    copy-for: copy-for,
    date: assignment-date,
    number: assignment-number,
    style: style,
  )

  show: _gls.init-glossary.with(glossary, term-links: glossary-links)

  {
    show: style.base.with(
      body-size: body-size,
      body-font: body-font,
      math-size: math-size,
      math-font: math-font,
      raw-size: raw-size,
      raw-font: raw-font,
      accent: accent,
      old-style-numbers: old-style-numbers,
      url-footnotes: url-footnotes,
    )
    show heading.where(level: 1): h1 => pagebreak() + h1

    if abstract-page in ("sr", "both") [
      #if type(abstract) in (str, bytes) [= Извод]
      #abstract
    ]

    if abstract-page in ("en", "both") [
      #if type(en.abstract) in (str, bytes) [= Abstract]
      #en.abstract
    ]

    if type(dedication) in (str, bytes) {
      show heading: hide
      show heading: align.with(center + horizon)
      set par(justify: false)
      show par: place.with(center + horizon)

      [= Посвета]

      dedication
    } else { dedication }

    if type(acknowledgement) in (str, bytes) [
      = Захвалница
      #acknowledgement
    ] else { acknowledgement }

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
    show: style.base.with(
      body-size: body-size,
      body-font: body-font,
      math-size: math-size,
      math-font: math-font,
      raw-size: raw-size,
      raw-font: raw-font,
      accent: accent,
      old-style-numbers: old-style-numbers,
      url-footnotes: url-footnotes,
    )
    show heading.where(level: 1): h1 => pagebreak() + h1

    {
      show: style.main.with(
        accent: accent,
        hydra: hydra-main,
        chapter-relative-fig-nums: chapter-relative-fig-nums,
      )

      counter(heading).update(0)

      show heading.where(level: 1): h1 => h1 + metadata("h:chapter")

      body
    }

    bibliography

    {
      show: style.appendices.with(
        accent: accent,
        hydra: hydra-appendices,
        chapter-relative-fig-nums: chapter-relative-fig-nums,
      )

      counter(heading).update(0)

      show heading.where(level: 1): h1 => h1 + metadata("h:appendix")

      context appendices + _appendices.final()
    }

    if type(bio) in (str, bytes) [= Биографија]

    bio
  }

  pagebreak()
  kwd(
    lang: "sr",
    accession-number: accession-number,
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
    abstract: {
      set heading(outlined: false, bookmarked: false)
      show heading.where().or(terms): none

      abstract
    },
    accepted-date: accepted-date,
    defense: (
      mentor: mentor.name,
      ..defense,
    ),
    style: style,
  )

  pagebreak()
  kwd(
    lang: "en",
    accession-number: en.at("accession-number", default: accession-number),
    identification-number: en.at("identification-number", default: identification-number),
    document-type: en.document-type,
    type-of-record: en.type-of-record,
    contents-code: en.contents-code,
    author: en.author,
    mentor: en.mentor,
    title: en.title,
    text-lang: text-lang,
    abstract-lang: abstract-lang,
    publication: (
      year: publication.year,
      ..en.publication,
    ),
    physical: en.at("physical", default: physical),
    field: en.field,
    discipline: en.discipline,
    subject-keywords: en.subject-keywords,
    uc: en.uc,
    holding-data: en.holding-data,
    note: en.note,
    abstract: {
      set heading(outlined: false, bookmarked: false)
      show heading.where().or(terms): none

      en.abstract
    },
    accepted-date: en.at("accepted-date", default: accepted-date),
    defense: (
      mentor: en.mentor.name,
      date: defense.date,
      ..en.defense,
    ),
    style: style,
  )

  pagebreak()
  conflict(style: style)
}
