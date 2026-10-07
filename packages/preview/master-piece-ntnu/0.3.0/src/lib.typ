#import "./covers.typ": *
#import "./front-matter.typ": *
#import "./styling-setup.typ": *
#import "./utils.typ": (
  assert-arg-type, extract-name, get-one-liner, maybe-sans-serif, thesis-type-keys, z, z-arbitrarily-keyed-dict,
  z-matches-regex,
)

// Use codly for rendering `raw` content (code)
// See: https://typst.app/universe/package/codly for a reference
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#import "@preview/equate:0.3.3": equate

#let master-piece-ntnu(
  // Primary document language; either "en" or "no"
  primary-lang: "en",

  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "no" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "no".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"no" langs.
  // If desired, any "subtitle" field may be set to none (to omit it entirely).
  localized-info: (
    en: (
      title: "Hoping Nobody Hacks You",
      subtitle: "Security by optimism and prayer",
      abstract: lorem(300),
      keywords: ("Ctrl+C", "Ctrl+V", "Imposter Syndrome"),
    ),
    no: (
      title: "Hvordan Skrive Ubrukelige Commit-Meldinger",
      subtitle: "git commit -m 'endringer'",
      abstract: lorem(300),
      keywords: ("Ctrl+C", "Ctrl+V", "Imposter Syndrome"),
    ),
  ),

  // Ordered author information; only first and last names fields are mandatory
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
      email: "john.doe@example.com",
      user-id: "jod",
      faculty: "Faculty of Educated Guesses",
      department: "Department of Applied Guesswork",
    ),
    (
      first-name: "Jane",
      last-names: "Doe",
    ),
  ),

  // Ordered supervisor information; "external-org" replaces userid/faculty/dept
  supervisors: (
    (
      first-name: "Alice",
      last-names: "Smith",
      email: "alice@example.com",
      user-id: "alice",
      faculty: "Faculty of Impossible Expectations",
      department: "Department of Loyal Supervision",
    ),
    (
      first-name: "Bob",
      last-names: "Jones",
      email: "bob@example.com",
      external-org: "Selskap AS",
    ),
  ),

  // Degree as part of which the thesis is conducted; all fields are mandatory.
  // Kind is the degree title conferred as listed in the third dropdown above.
  // Level is either "project", "bachelor", "master" or "phd"
  degree: (
    code: "MTEG",
    name: "Master's Program, Educated Guesses",
    kind: "Master of Unapplied Sciences",
    level: "master",
  ),

  // Faculty that the thesis is part of
  faculty: "Faculty of Turning It Off and On Again",

  // Department that the thesis is part of
  department: "Department of Loyal Supervision",

  // Information about the cover page for the thesis
  cover: (
    // Whether to generate a cover page at all. Note that for the official submission,
    // NTNU will automatically generate a cover page, so this should probably be disabled
    // before submitting.
    enable: true,

    // Colour of rectangle to be used on the front cover.
    // Should either be none, or a "color" element.
    color: rgb("#8DA7CF"),
  ),

  // Logo
  logo: none,

  // Different margins for alternating pages. Adds extra margins to the inside-side of
  // each page, which helps keep all text legible when binding the thesis like a book,
  // but can look weird when presented as a PDF on a screen.
  alternating-margins: true,

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
  doc-city: "Trondheim",

  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),

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

  assert-arg-type("primary-lang", primary-lang, z.choice(("en", "no")))
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
    require-keys: ("en", "no"),
  ))
  assert-arg-type("authors", authors, z.array(
    z.dictionary((
      first-name: z.string(min: 1),
      last-names: z.string(min: 1),
      email: z.email(optional: true),
      user-id: z.string(optional: true, min: 1),
      faculty: z.string(optional: true, min: 1),
      department: z.string(optional: true, min: 1),
    )),
    min: 1,
  ))
  let internal-person = z.dictionary((
    first-name: z.string(min: 1),
    last-names: z.string(min: 1),
    email: z.email(),
    user-id: z.string(min: 1),
    faculty: z.string(min: 1),
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
  assert-arg-type("degree", degree, z.dictionary((
    code: z.string(min: 1),
    name: z.string(min: 1),
    kind: z.string(min: 1),
    level: z.choice(thesis-type-keys.keys()),
  )))
  assert-arg-type("faculty", faculty, z.string(min: 1))
  assert-arg-type("department", department, z.string(min: 1))
  assert-arg-type("cover", cover, z.dictionary((
    enable: z.boolean(),
    color: z.color(),
  )))
  assert-arg-type("logo", logo, z.any(optional: true))
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
    "no"
  } else if primary-lang == "no" {
    "en"
  } else {
    panic("Invalid primary language " + primary-lang)
  }

  let primary-info = localized-info.at(primary-lang)
  let alt-info = localized-info.at(alt-lang)

  let author-names = authors.map(extract-name)
  let supervisor-names = supervisors.map(extract-name)

  set document(
    title: get-one-liner(primary-lang, primary-info),
    description: get-one-liner(alt-lang, alt-info), // Subject field
    date: doc-date,
    keywords: primary-info.at("keywords") + doc-extra-keywords,
    author: author-names,
  )
  set page("a4")
  set text(lang: primary-lang, size: 12pt)

  if cover.enable {
    front-cover(
      title: primary-info.title,
      subtitle: primary-info.at("subtitle", default: none),
      authors: author-names,
      supervisors: supervisor-names,
      degree-name: degree.name,
      faculty: faculty,
      department: department,
      level: degree.level,
      date: doc-date,
      lang: primary-lang,
      cover-color: cover.color,
      style,
    )

    page[] // blank
  }

  set text(font: maybe-sans-serif(style))

  title-page(
    title: primary-info.title,
    subtitle: primary-info.at("subtitle", default: none),
    authors: author-names,
    supervisors: supervisor-names,
    degree-name: degree.name,
    faculty: faculty,
    department: department,
    level: degree.level,
    date: doc-date,
    lang: primary-lang,
    style,
  )

  // Initialize Codly (external package)
  show: codly-init.with() // Comment this out to disable codly style formatting
  codly(languages: codly-languages)
  codly(zebra-fill: rgb("#f9f9f9"))

  // Initialize Equate (external package)
  show: equate.with(breakable: true, sub-numbering: true) // Comment this out to disable sub-equation numbering (note this will break equations, preventing compilation)
  set math.equation(numbering: "(1.1)")

  copyright-page(year: doc-date.year(), authors: author-names)

  global-setup(style, alternating-margins, {
    set page(numbering: "i")
    counter(page).update(1)

    for (lang, info) in localized-info {
      localized-abstract(
        lang: lang,
        abstract-heading: info.at("abstract-heading", default: none),
        keywords-heading: info.at("keywords-heading", default: none),
        keywords: info.at("keywords"),
        info.at("abstract"),
      )
      page(header: none, footer: none, []) // blank
    }

    signed-acknowledgements(
      city: doc-city,
      date: doc-date,
      authors: author-names,
      acknowledgements,
    )
    indices

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

  [#metadata(()) <content-end>]
  pagebreak(to: "odd")

  page[] // empty
  back-cover(
    year: doc-date.year(),
    ..if cover.color != none { (cover-color: cover.color) } else { (:) },
    style,
  )
}
