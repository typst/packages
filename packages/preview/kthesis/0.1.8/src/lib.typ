#import "./covers.typ": *
#import "./front-matter.typ": *
#import "./styling-setup.typ": *
#import "./for-diva.typ": for-diva-json
#import "./utils.typ": (
  assert-arg-type, extract-name, get-one-liner, maybe-sans-serif, z,
  z-arbitrarily-keyed-dict, z-matches-regex,
)

#let kth-thesis(
  // Primary document language; either "en" or "sv"
  primary-lang: "en",
  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "sv" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "sv".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"sv" langs.
  // If desired, any "subtitle" field may be set to none (to omit it entirely).
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
    subject-area: "Computer Science and Engineering",
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
  trita-number: "2026:0000",
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
      year: 2026,
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
  // Optional image to show on the front cover.
  // This should either be none, or an "image" element. For example,
  // cover-image: image("./assets/cover.png", width: 100%)
  // If provided, the image can be formatted arbitrarily to look however desired
  // (especially its height, width, and fit mode). However, the recommended
  // styles are (width: 100%) or (width: 16cm, height: 10cm, fit: "contain").
  cover-image: none,
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
  // Miscellaneous settings affecting the document's appearance
  style: (:),
  // Document body
  body,
) = context {
  // manual type checking because typst sadly has no strong typing and sometimes
  // incorrect arguments can lead to very strange errors that are hard to debug
  // (especially when accidentally using `(x)` instead of `(x,)` to construct an
  // array, leading to no array being constructed at all)
  // note that this is not necessarily exhaustive and is intended just as a
  // convenience, so that obvious problems surface immediately and clearly

  assert-arg-type("primary-lang", primary-lang, z.choice(("en", "sv")))
  assert-arg-type("localized-info", localized-info, z-arbitrarily-keyed-dict(
    "localized-info",
    z.string(assertions: (z.assert.length.equals(2),)),
    z.dictionary(
      (
        alpha-3: z.string(optional: true, assertions: (
          z.assert.length.equals(3),
        )),
        title: z.string(min: 1),
        subtitle: z.string(optional: true, min: 1),
        abstract: z.content(),
        keywords: z.array(z.string(min: 1)),
      ),
    ),
    min: 1,
    require-keys: ("en", "sv"),
  ))
  assert-arg-type("authors", authors, z.array(
    z.dictionary((
      first-name: z.string(min: 1),
      last-names: z.string(min: 1),
      email: z.email(optional: true),
      user-id: z.string(optional: true, min: 1),
      school: z.string(optional: true, min: 1),
      department: z.string(optional: true, min: 1),
    )),
    min: 1,
  ))
  let internal-person = z.dictionary((
    first-name: z.string(min: 1),
    last-names: z.string(min: 1),
    email: z.email(),
    user-id: z.string(min: 1),
    school: z.string(min: 1),
    department: z.string(min: 1),
  ))
  assert-arg-type("supervisors", supervisors, z.array(
    z.either(internal-person, z.dictionary((
      first-name: z.string(min: 1),
      last-names: z.string(min: 1),
      email: z.email(),
      external-org: z.string(min: 1),
    ))),
    min: 1,
  ))
  assert-arg-type("examiner", examiner, internal-person)
  assert-arg-type("course", course, z.dictionary((
    code: z.string(min: 1),
    credits: z.number(min: 1),
  )))
  assert-arg-type("degree", degree, z.dictionary((
    code: z.string(min: 1),
    name: z.string(min: 1),
    subject-area: z.string(min: 1),
    kind: z.string(min: 1),
    cycle: z.number(min: 1, max: 2), // better error messages than z.choice
  )))
  assert-arg-type(
    "national-subject-categories",
    national-subject-categories,
    z.array(
      z.string(min: 3, max: 5, assertions: z-matches-regex(
        "^\d+$",
        "All characters must be digits",
      )),
      min: 1,
    ),
  )
  assert-arg-type("school", school, z.choice((
    "ABE",
    "EECS",
    "ITM",
    "CBH",
    "SCI",
  )))
  assert-arg-type("trita-number", trita-number, z.string(
    assertions: z-matches-regex("\d{4}:\d+", "Must follow format `2026:0000`"),
  ))
  assert-arg-type("host-company", host-company, z.string(
    optional: true,
    min: 1,
  ))
  assert-arg-type("host-org", host-org, z.string(optional: true, min: 1))
  assert-arg-type("opponents", opponents, z.array(
    z.string(min: 1),
    optional: true,
    min: 1,
  ))
  assert-arg-type("presentation", presentation, z.dictionary(
    (
      language: z.choice(("en", "sv")),
      slot: z.date(),
      online: z.dictionary(
        (service: z.string(min: 1), link: z.string(min: 1)),
        optional: true,
      ),
      location: z.dictionary(
        (
          room: z.string(min: 1),
          address: z.string(min: 1),
          city: z.string(min: 1),
        ),
        optional: true,
      ),
    ),
    optional: true,
    assertions: (
      (
        condition: (_, it) => (
          it.at("online", default: none) != none
            or it.at("location", default: none) != none
        ),
        message: (_, it) => "Either \"online\" or \"location\" must be set",
      ),
    ),
  ))
  assert-arg-type("cover-image", cover-image, z.content(optional: true))
  assert-arg-type(
    "acknowledgements",
    acknowledgements,
    z.content(optional: true),
  )
  assert-arg-type("extra-preambles", extra-preambles, z.array(z.dictionary((
    heading: z.string(min: 1),
    body: z.content(),
  ))))
  assert-arg-type("doc-date", doc-date, z.date())
  assert-arg-type("doc-city", doc-city, z.string(min: 1))
  assert-arg-type("doc-extra-keywords", doc-extra-keywords, z.array(
    z.string(min: 1),
  ))
  assert-arg-type("with-for-diva", with-for-diva, z.boolean())
  assert-arg-type("style", style, z.dictionary(
    (
      use-arial: z.boolean(optional: true),
      more-sans-serif: z.boolean(optional: true),
      fancy-chapters: z.boolean(optional: true),
    ),
    optional: true,
  ))

  // ---------- END OF MANUAL TYPE CHECKING ----------

  let style = (
    (
      more-sans-serif: false,
      use-arial: false,
      fancy-chapters: false,
    )
      + style // provided values have higher precedence over default values
  )

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
    description: get-one-liner(alt-lang, alt-info), // Subject field
    date: doc-date,
    keywords: primary-info.at("keywords") + doc-extra-keywords,
    author: author-names,
  )
  set page("a4")
  set text(lang: primary-lang, size: 12pt)

  front-cover(
    title: primary-info.at("title"),
    subtitle: primary-info.at("subtitle", default: none),
    authors: author-names,
    subject-area: degree.at("subject-area"),
    cycle: degree.at("cycle"),
    credits: course.at("credits"),
    cover-image: cover-image,
    style,
  )

  page[] // blank

  set text(font: maybe-sans-serif(style))

  title-page(
    title: primary-info.at("title"),
    subtitle: primary-info.at("subtitle", default: none),
    alt-title: alt-info.at("title"),
    alt-subtitle: alt-info.at("subtitle", default: none),
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

  global-setup(style, {
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

    // text.font reflects original font because of the `context` surrounding
    // this entire function (prior to when the font was changed)
    set text(font: text.font)

    set page(numbering: "1")
    counter(page).update(1)

    styled-body(style, body)
  })

  let trita-series = school + "-EX"

  [#metadata(()) <content-end>]
  pagebreak(to: "odd")

  page[] // empty
  back-cover(
    trita-series: trita-series,
    trita-number: trita-number,
    year: doc-date.year(),
    style,
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
