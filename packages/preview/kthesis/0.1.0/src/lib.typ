#import "./covers.typ": *
#import "./front-matter.typ": *
#import "./styling-setup.typ": *
#import "./for-diva.typ": for-diva-json
#import "./utils.typ": get-one-liner, extract-name

#let kth-thesis(
  // Primary document language; either "en" or "sv"
  primary-lang: "en",
  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "sv" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "sv".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"sv" langs.
  localized-info: (
    en: (
      title: "How to Abandon Dinosaur-Age TypeSetting Software",
      subtitle: "A Modern Approach to Problem-Solving",
      abstract: lorem(300),
      keywords: ("Dogs", "Chicken nuggets"),
    ),
    sv: (
      title: "Svenska Översättningen av Titeln",
      subtitle: "Svenska Översättningen av Undertiteln",
      abstract: lorem(300),
      keywords: ("Hundar", "Kycklingnuggets"),
    ),
    pt: (
      alpha-3: "por",
      title: "Tradução em Português do Título",
      subtitle: "Tradução em Português do Subtítulo",
      abstract-heading: "Resumo",
      keywords-heading: "Palavras-chave",
      abstract: lorem(300),
      keywords: ("Cães", "Nuggets de frango"),
    ),
  ),
  // Ordered author information; only first and last names fields are mandatory
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
      email: "john.doe@example.com",
      user-id: "jod",
      school: "School of Electrical Engineering and Computer Science",
      department: "Department of Typesetting Sanity",
    ),
    (
      first-name: "Jane",
      last-names: "Doe",
    ),
  ),
  // Ordered supervisor information; "external-org" replaces userid/school/dept
  supervisors: (
    (
      first-name: "Alice",
      last-names: "Smith",
      email: "alice@example.com",
      user-id: "alice",
      school: "School of Electrical Engineering and Computer Science",
      department: "Department of Loyal Supervision",
    ),
    (
      first-name: "Bob",
      last-names: "Jones",
      email: "bob@example.com",
      external-org: "Företag AB",
    ),
  ),
  // Thesis examiner; must be internal to the school so all fields are mandatory
  examiner: (
    first-name: "Charlie",
    last-names: "Johnson",
    email: "charlie@example.com",
    user-id: "chj",
    school: "School of Electrical Engineering and Computer Science",
    department: "Department of Fair Examination",
  ),
  // Degree project course within which the thesis is being conducted.
  // All fields are mandatory; credits are the course's ECTS credits (hp).
  course: (
    code: "DA237X",
    credits: 30,
  ),
  // Degree as part of which the thesis is conducted; all fields are mandatory.
  // Subject area is main field of study as listed in the second dropdown here:
  // https://www.kth.se/en/student/studier/examen/examensregler-1.5685
  // Kind is the degree title conferred as listed in the third dropdown above.
  // Cycle is either 1 (Bachelor's) or 2 (Master's), per Bologna.
  degree: (
    code: "TCYSM",
    name: "Master's Program, Cybersecurity",
    subject-area: "Technology",
    kind: "Master of Science",
    cycle: 2,
  ),
  // National subject category codes; mandatory for DiVA classification.
  // One or more 3-to-5 digit codes, with preference for 5-digit codes, from:
  // https://www.scb.se/contentassets/10054f2ef27c437884e8cde0d38b9cc4/standard-for-svensk-indelning--av-forskningsamnen-2011-uppdaterad-aug-2016.pdf
  national-subject-categories: ("10201", "10206"),
  // School that the thesis is part of (abbreviation)
  school: "EECS",
  // TRITA number assigned to thesis after final examiner approval
  trita-number: "2024:0000",
  // Host company collaborating for this thesis; may be none
  host-company: "Företag AB",
  // Host organization collaborating for this thesis; may be none
  host-org: none,
  // Names of opponents for this thesis; may be none until they're assigned
  opponents: ("Mary Ignatia", "Alexander Smith"),
  // Thesis presentation details; may be none until it's scheduled and set.
  // Either "online" or "location" fields may be none, but not both.
  presentation: (
    language: "en",
    slot: datetime(
      year: 2025,
      month: 6,
      day: 14,
      hour: 13,
      minute: 0,
      second: 0,
    ),
    online: (service: "Zoom", link: "https://kth-se.zoom.us/j/111222333"),
    location: (
      room: "F1 (Alfvénsalen)",
      address: "Lindstedtsvägen 22",
      city: "Stockholm",
    ),
  ),
  // Acknowledgements body
  acknowledgements: {
    par(lorem(100))
    par(lorem(150))
  },
  // Additional front-matter sections, each with keys "heading" and "body".
  // For example, ((heading: "Acronyms and Abbreviations", body: glossary),)
  extra-preambles: (),
  // Document date; hardcode for determinism/reproducibility
  doc-date: datetime.today(),
  // Document city (where it's being signed/authored/submitted)
  doc-city: "Stockholm",
  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),
  // Whether to include trailing "For DiVA" metadata structure section
  with-for-diva: true,
  // Document body
  body,
) = {
  let alt-lang = if primary-lang == "en" {
    "sv"
  } else if primary-lang == "sv" {
    "en"
  } else {
    panic("Invalid primary language " + primary-lang)
  }

  let primary-info = localized-info.at(primary-lang)
  let alt-info = localized-info.at(alt-lang)

  let author-names = authors.map(extract-name)

  set document(
    title: get-one-liner(primary-lang, primary-info),
    // vvv - will be available in Typst 0.13.0 (update typst.toml#compiler!)
    // description: get-one-liner(alt-lang, alt-info), // Subject field
    date: doc-date,
    keywords: primary-info.at("keywords") + doc-extra-keywords,
    author: author-names,
  )
  set page("a4")
  set text(lang: primary-lang, size: 12pt)

  front-cover(
    title: primary-info.at("title"),
    subtitle: primary-info.at("subtitle"),
    authors: author-names,
    subject-area: degree.at("subject-area"),
    cycle: degree.at("cycle"),
    credits: course.at("credits"),
  )

  page[] // blank

  title-page(
    title: primary-info.at("title"),
    subtitle: primary-info.at("subtitle"),
    alt-title: alt-info.at("title"),
    alt-subtitle: alt-info.at("subtitle"),
    alt-lang: alt-lang,
    degree: degree.at("name"),
    date: doc-date,
    authors: author-names,
    supervisors: supervisors.map(extract-name),
    examiner-name: extract-name(examiner),
    examiner-school: examiner.at("school"),
    host-company: host-company,
    host-org: host-org,
  )

  copyright-page(year: doc-date.year(), authors: author-names)

  global-setup({
    set page(numbering: "i")
    counter(page).update(1)

    for (lang, info) in localized-info {
      page(
        localized-abstract(
          lang: lang,
          abstract-heading: info.at("abstract-heading", default: none),
          keywords-heading: info.at("keywords-heading", default: none),
          keywords: info.at("keywords"),
          info.at("abstract"),
        ),
      )
      page(header: none, footer: none, []) // blank
    }

    page(
      signed-acknowledgements(
        city: doc-city,
        date: doc-date,
        authors: author-names,
        acknowledgements,
      ),
    )

    page(indices)

    for extra in extra-preambles {
      extra-preamble(title: extra.at("heading"), extra.at("body"))
    }

    [#metadata(()) <front-matter-end>]
    pagebreak(to: "odd")

    set page(numbering: "1")
    counter(page).update(1)

    styled-body(body)
  })

  let trita-series = school + "-EX"

  [#metadata(()) <content-end>]
  pagebreak(to: "odd")

  page[] // empty
  back-cover(
    trita-series: trita-series,
    trita-number: trita-number,
    year: doc-date.year(),
  )

  context if with-for-diva {
    let page-series-counts = (
      numbering("i", ..counter(page).at(<front-matter-end>)),
      numbering("1", ..counter(page).at(<content-end>)),
    )

    page(
      for-diva-json(
        primary-lang: primary-lang,
        alt-lang: alt-lang,
        localized-info: localized-info,
        authors: authors,
        supervisors: supervisors,
        examiner: examiner,
        course: course,
        degree: degree,
        national-subject-categories: national-subject-categories,
        trita-series: trita-series,
        trita-number: trita-number,
        host-company: host-company,
        host-org: host-org,
        opponents: opponents,
        presentation: presentation,
        doc-date: doc-date,
        page-series-counts: page-series-counts,
      ),
    )
  }
}
