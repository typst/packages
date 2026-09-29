#import "./front-matter.typ": *
#import "./styling-setup.typ": (
  ucy-page-setup,
  global-setup,
  styled-body,
  setup-appendices,
  default-style,
)
#import "./utils.typ": (
  author-names,
  resolve-logo,
  thesis-title,
  tl,
  t,
  ucy-lang,
  primary-t,
)
#import "./i18n.typ": chapter-lt, section-lt, body-lt, bullets-lt, localized-text

/// University of Cyprus diploma thesis template (ADE guidelines).
///
/// Guidelines:
/// - https://www.cs.ucy.ac.cy/index.php/el/education/undergrad/prodiagrafes-ade
/// - Word template: see `tl("guidelines-word-url", "en")` in lang.toml
#let ucy-thesis(
  /// Primary document language: `"en"` or `"el"`.
  primary-lang: "en",
  /// Per-language metadata and front-matter text. Must include `primary-lang`.
  /// Each entry may set `show: false` to omit that language's abstract (default `true`).
  localized-info: (
    en: (
      diploma-project: "Diploma Project",
      title: "Thesis title",
      faculty: "Faculty of Pure and Applied Sciences",
      department: "Department of Computer Science",
      abstract: [
        An abstract must be fully self-contained and make sense without further
        reference to outside sources or the actual paper. It highlights key content
        areas, the research purpose, the relevance or importance of your work, and
        the main outcomes. Write up to 150–200 words, and do not exceed one page.
      ],
      keywords: ("keyword1", "keyword2", "keyword3", "keyword4"),
    ),
    el: (
      diploma-project: "Ατομική Διπλωματική Εργασία",
      title: "Τίτλος εργασίας",
      faculty: "Σχολή Θετικών και Εφαρμοσμένων Επιστημών",
      department: "Τμήμα Πληροφορικής",
      abstract: [
        Εδώ θα γράψετε μία περίληψη της ΑΔΕ σας. Θα πρέπει να είναι σύντομη και να δίδει
        με σαφήνεια το θέμα που μελετήσατε και τα αποτελέσματά σας. Η περίληψη δεν
        πρέπει να υπερβαίνει την μία σελίδα.
      ],
      keywords: ("λέξη1", "λέξη2", "λέξη3", "λέξη4"),
    ),
  ),
  /// Student(s); `first-name` and `last-names` are required per entry.
  authors: (
    (
      first-name: "Student",
      last-names: "Name",
    ),
  ),
  /// Advisor(s); `first-name` and `last-names` are required per entry.
  advisors: (
    (
      first-name: "Advisor",
      last-names: "Name",
    ),
  ),
  /// Reserved for future presets; ignored unless `logo-image` is set.
  logo: "general",
  /// Cover logo (not bundled): file path or `image(...)`. You must supply a logo you may use.
  logo-image: none,
  /// Submission date (month and year shown on cover pages).
  doc-date: datetime.today(),
  /// Include the research ethics declaration page (ADE requirement).
  with-declaration: true,
  /// Page numbers in the footer (bottom-right). On by default (LaTeX ADE style).
  with-page-numbers: true,
  /// Optional advisory committee page (off by default; see LaTeX template).
  with-advisory-committee: false,
  /// Required when `with-advisory-committee` is true.
  advisory-committee: none,
  /// Acknowledgements body for the primary language.
  acknowledgements: [
    I would like to thank [...], for [...]
  ],
  /// Manual list-of-abbreviations table; `none` omits it (use `glossary` for glossarium instead).
  abbreviations: none,
  /// List of abbreviations page: `none` (default) or `print-glossary(acronyms)`.
  glossary: none,
  /// Extra front-matter sections: `((heading: "...", body: [...]), ...)`
  extra-preambles: (),
  /// Typography tuning (tracking, line spacing); see `default-style` in styling-setup.
  style: (:),
  /// Document body (chapters, bibliography, appendices).
  body,
) = context {
  let style = default-style + style
  ucy-lang.update(primary-lang)

  if primary-lang not in localized-info {
    panic(
      "localized-info must include an entry for primary-lang \""
        + primary-lang
        + "\"",
    )
  }

  let primary-info = localized-info.at(primary-lang)
  for key in ("diploma-project", "title", "faculty", "department", "keywords") {
    if key not in primary-info {
      panic(
        "localized-info[\""
          + primary-lang
          + "\"] is missing required field \""
          + key
          + "\"",
      )
    }
  }

  let abstract-entries = localized-info
    .pairs()
    .filter(((_, info)) => info.at("show", default: true))

  if abstract-entries.len() == 0 {
    panic(
      "at least one language in localized-info must print an abstract "
        + "(set show: true or omit show; cannot set show: false on every entry)",
    )
  }

  let names = author-names(authors)
  let logo-content = resolve-logo(logo: logo, logo-image: logo-image)

  set document(
    title: thesis-title(primary-info.at("title")),
    author: names,
    date: doc-date,
    keywords: primary-info.at("keywords"),
  )

  ucy-page-setup(with-page-numbers: with-page-numbers, {
    // ---- Cover (primary language) ----
    framed-cover(
      lang: primary-lang,
      localized-info: localized-info,
      authors: names,
      date: doc-date,
      logo-content,
    )

    // ---- Submission page (primary language) ----
    submission-page(
      lang: primary-lang,
      localized-info: localized-info,
      authors: names,
      advisors: advisors,
      date: doc-date,
    )

    if with-declaration {
      declaration-page(lang: primary-lang)
    }

    if with-advisory-committee {
      if advisory-committee == none {
        panic("advisory-committee must be set when with-advisory-committee is true")
      }
      advisory-committee-page(
        lang: primary-lang,
        localized-info: localized-info,
        authors: names,
        committee: advisory-committee,
        date: doc-date,
      )
    }

    global-setup({
      acknowledgements-page(lang: primary-lang, acknowledgements)

      for (lang, info) in abstract-entries {
        if lang == primary-lang {
          localized-abstract(
            lang: lang,
            abstract-heading: info.at("abstract-heading", default: none),
            keywords-heading: info.at("keywords-heading", default: none),
            keywords: info.at("keywords"),
            info.at("abstract"),
          )
        }
      }
      for (lang, info) in abstract-entries {
        if lang != primary-lang {
          localized-abstract(
            lang: lang,
            abstract-heading: info.at("abstract-heading", default: none),
            keywords-heading: info.at("keywords-heading", default: none),
            keywords: info.at("keywords"),
            info.at("abstract"),
          )
        }
      }

      if glossary != none {
        pagebreak()
        heading(
          outlined: false,
          bookmarked: true,
          depth: 1,
          upper(tl("list-of-abbreviations", primary-lang)),
        )
        glossary
      }

      indices(
        lang: primary-lang,
        abbreviations: abbreviations,
      )

      for extra in extra-preambles {
        pagebreak()
        heading(outlined: false, depth: 1, extra.at("heading"))
        extra.at("body")
      }
    })

    [#metadata(()) <front-matter-end>]
    pagebreak()

    set text(lang: primary-lang)
    styled-body(style, body)
  })
}

/// Bibliography heading in the document's `primary-lang` (set in `ucy-thesis.with`).
/// Use as `#bibliography(..., title: bibliography-heading())` in the document body.
#let bibliography-heading() = context {
  upper(tl("bibliography", ucy-lang.get()))
}

/// Abbreviations list heading; usually unnecessary if you pass `glossary:` to `ucy-thesis`.
#let abbr-list-heading() = context {
  upper(tl("list-of-abbreviations", ucy-lang.get()))
}

/// Re-export guideline URLs for use in template comments.
///
/// For localized chapter/section text, use `chapter-lt`, `section-lt`, and `body-lt`
/// in your content files (see template `content/`).
#let guidelines = (
  ade: t("guidelines-url"),
  word: t("guidelines-word-url"),
)
