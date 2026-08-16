#import "@preview/pergamon:0.8.0": *

#let lst-template-version = "0.1.0"
#let prepared-string = "Prepared with the owl-lst-thesis Typst template, version " + lst-template-version + "."

#let titlepage-bottom-fontsize = 10pt

#let uds-blue-screen = rgb(0, 72, 118)
#let uds-blue = uds-blue-screen
#let text-gray = luma(95)

#let lst-mode-settings(mode) = {
  if mode == "screen" {
    (
      blue: uds-blue-screen,
      lst_logo: "logos/rgb/lst-logo.svg",
      uds_logo: "logos/rgb/uds-logo.svg",
      page_margin: (bottom: 3cm, top: 3cm, inside: 2.75cm, outside: 2.75cm),
    )
  } else if mode == "print" {
    (
      blue: uds-blue-screen,
      lst_logo: "logos/rgb/lst-logo.svg",
      uds_logo: "logos/rgb/uds-logo.svg",
      page_margin: (bottom: 3cm, top: 3cm, inside: 3cm, outside: 2.5cm),
    )
  } else {
    panic("unknown LST template mode: " + repr(mode))
  }
}

// Built-in strings for the parts of the thesis that the template creates.
// The selected language comes from `#set text(lang: "...")`; unsupported
// languages fall back to English.
#let lst-translations = (
  en: (
    bibliography: "Bibliography",
    declaration: "Declaration",
    declaration-text: [
      I hereby confirm that the thesis presented here is my own work, with all assistance
      acknowledged. I assure that the electronic version is identical in content to the printed
      version of the thesis.
    ],
    contents: "Contents",
    abstract: "Abstract",
    acknowledgments: "Acknowledgments",
    chapter: "Chapter",
    matriculation-number: "Matriculation Number",
    submission-date: "Submission Date",
    department: "Department of Language Science and Technology",
    university: "Saarland University",
    bib-in: "In",
  ),
  de: (
    bibliography: "Literaturverzeichnis",
    declaration: "Erklärung",
    declaration-text: [
      Hiermit bestätige ich, dass die vorliegende Arbeit von mir selbstständig verfasst wurde
      und alle verwendeten Hilfsmittel angegeben sind. Ich versichere, dass die elektronische
      Version inhaltlich mit der gedruckten Version der Arbeit übereinstimmt.
    ],
    contents: "Inhaltsverzeichnis",
    abstract: "Zusammenfassung",
    acknowledgments: "Danksagung",
    chapter: "Kapitel",
    matriculation-number: "Matrikelnummer",
    submission-date: "Abgabedatum",
    department: "FR Sprachwissenschaft und Sprachtechnologie",
    university: "Universität des Saarlandes",
    bib-in: "In",
  ),
)

#let lst-current-translations() = {
  let lang = text.lang
  if lst-translations.keys().contains(lang) {
    lst-translations.at(lang)
  } else {
    lst-translations.en
  }
}

#let degree-programs = (
  langsci: (
    name: "BA Language Science",
    thesis-type: (
      en: "Bachelor's Thesis",
      de: "Bachelorarbeit",
    ),
  ),
  coli: (
    name: "BSc Computerlinguistik",
    thesis-type: (
      en: "Bachelor's Thesis",
      de: "Bachelorarbeit",
    ),
  ),
  lst: (
    name: "MSc Language Science and Technology",
    thesis-type: (
      en: "Master's Thesis",
      de: "Masterarbeit",
    ),
  ),
  lct: (
    name: "MSc Language and Communication Technologies",
    thesis-type: (
      en: "Master's Thesis",
      de: "Masterarbeit",
    ),
  ),
  tst: (
    name: "MA Translation Science and Technology",
    thesis-type: (
      en: "Master's Thesis",
      de: "Masterarbeit",
    ),
  ),
)

#let localized-thesis-type(thesis-type) = {
  let lang = text.lang
  if thesis-type.keys().contains(lang) {
    thesis-type.at(lang)
  } else {
    thesis-type.en
  }
}

#let lst-text(key) = context {
  lst-current-translations().at(key)
}

// Public helper for the end of the thesis. It keeps the bibliography heading
// consistent with the front matter and delegates the actual entries to Pergamon.
#let print-lst-bibliography() = {
  heading(level: 100)[#lst-text("bibliography")]
  v(-2em)
  print-bibliography(
    title: none
  )
}

// Render grouped supervisor/advisor entries. Each group is expected to have the
// role label first and one or more names afterwards.
#let advisors(supervisors) = {
  set text(size: titlepage-bottom-fontsize)
  for (j, sup) in supervisors.enumerate() {
    let role = sup.at(0)
    let names = sup.slice(1)

    strong(role)
    for (i, name) in names.enumerate() {
      linebreak()
      name
    }

    if j < supervisors.len() - 1 {
      linebreak()
      linebreak()
    }
  }
}

// The title page is separated from `lst` so the main wrapper can focus on page
// setup and document flow. Localized strings are passed in explicitly because
// the title page is built inside a context block.
#let title-page(mode-settings, strings, thesis-type, degree-program, title, author, matriculation-number, supervisors, date) = {
  set text(font: "Open Sans")

  stack(dir: ltr,
    box(
      text(size: 12pt, fill: mode-settings.blue)[
        *#thesis-type*\
        #degree-program\
        #strings.university
      ]
    ),
    h(1fr),

    stack(dir: ltr,
      move(dy: -0.08cm, image(mode-settings.lst_logo, width: 1.9cm)),
      h(0.6cm),
      image(mode-settings.uds_logo, width: 1.6cm)
    )
  )

  v(4.3cm)

  text(size: 18pt, author)
  v(0em)
  text(size: 24pt, weight: "bold", fill: mode-settings.blue, title)

  v(1fr)


  advisors(supervisors)

  place(bottom + right)[
    #set text(size: titlepage-bottom-fontsize)
    *#strings.matriculation-number*\
    #matriculation-number\
    \
    *#strings.submission-date*\
    #date
  ]
}




// Main thesis wrapper. Use it through `#show: lst.with(...)` so the
// student's document body becomes `content` after the template has inserted the
// title page, declaration, optional front matter, and table of contents.
#let lst(thesis-type: none,
          degree-program: none,
          title: none,
          author: none,
          matriculation-number: none,
          supervisors: none,
          date: none,
          city: "Saarbrücken",
          mode: "screen",
          abstract: none,
          acknowledgments: none,
          content) = [
  #let mode-settings = lst-mode-settings(mode)
  #let uds-blue = mode-settings.blue

  #if title != none and author != none {
    set document(title: title, author: author, description: prepared-string, keywords: (prepared-string,))
  } else if title != none {
    set document(title: title, description: prepared-string, keywords: (prepared-string,))
  } else if author != none {
    set document(author: author, description: prepared-string, keywords: (prepared-string,))
  } else {
    set document(description: prepared-string, keywords: (prepared-string,))
  }

  #set page(
      paper: "a4", margin: mode-settings.page_margin,
      numbering: none,
      number-align: center,
    )

  #set text(size: 11pt)
  #let leading-space = 0.7em
  #let paragraph-space = 2 * leading-space
  #set par(leading: leading-space, spacing: paragraph-space)



  // Level 100 is reserved for generated front-matter headings. It lets the
  // template reuse the chapter-opening layout without putting these pages into
  // the normal chapter numbering.
  #show heading: it => {
    if it.level == 1 or it.level == 100 {
      // The content switch marks inserted blank pages so headers and footers can
      // stay empty on pages created only to force odd-page chapter starts.
      state("content.switch").update(false)
      pagebreak(weak: true, to: "odd")
      state("content.switch").update(true)

      v(2cm)
      set text(font: ("Open Sans", "Libertinus Serif"), weight: "bold", size: 24pt, fill: uds-blue)

      if it.level == 1 and it.numbering != none {
        text(font: "Open Sans", size: 12pt, fill: text-gray)[#lst-text("chapter") #context(counter(heading).display())]
        v(-0.6em)
        text(fill: uds-blue, it.body)

        // Figure-like counters are chapter-local, matching labels such as 2.1.
        for kind in (image, table, raw) {
          counter(figure.where(kind: kind)).update(0)
          counter(math.equation).update(0)
        }
      } else {
        it.body
      }
      v(2em, weak: true)
    } else if it.level == 2 {
      // Sections
      v(paragraph-space)
      text(font: "Open Sans", size: 15pt, weight: "bold", it)
      v(1.5em, weak: true)
    } else if it.level == 3 {
      // Subsections
      v(0.3em)
      text(font: "Open Sans", size: 12.5pt, weight: "bold", it)
      v(1em, weak: true)
    } else if it.level == 4 {
      // v(0.7em)
      text(weight: "bold", it.body)
      [. ]
    } else {
      v(0em)
      it
      v(1em, weak: true)
    }
  }

  // Figure/table/equation numbering uses the current chapter number as prefix.
  #set figure(
    placement: top,
    numbering: n => {
      let h1 = counter(heading).get().first()
      numbering("1.1", h1, n)
    }
  )

  #show figure: set place(clearance: 2em)

  #show figure.caption: it => {
    set text(font: "Open Sans", size: 9pt)
    v(0.5em)
    text(fill: uds-blue, weight: "semibold", it.supplement)
    h(0.35em)
    text(fill: uds-blue, weight: "semibold", it.counter.display())
    text(fill: text-gray)[:]
    h(0.35em)
    text(fill: text-gray, it.body)
  }

  // Links and references use the house blue so cross-references are visible but
  // not visually louder than the surrounding thesis text.
  #show link: set text(fill: uds-blue)
  // #show cite: set text(fill: uds-blue)
  #show ref: set text(fill: uds-blue)

  // Show page numbers only on pages that the header has marked as containing
  // real content. This avoids numbering intentionally inserted blank pages.
  // The state-based approach follows the pattern discussed in:
  // https://github.com/typst/typst/discussions/3122
  #let page-footer = context {
    let has-content = state("content.pages", (0,)).get().contains(here().page())

    if has-content {
      let page-here = here().page()
      align(
        if calc.odd(page-here) { right } else { left },
        text(font: "Open Sans", size: 9pt, fill: uds-blue, weight: "semibold", counter(page).display())
      )
    } else {
      [  ] // empty page
    }
  }

  #let heading-number-at(it) = {
    let nums = counter(heading).at(it.location())
    numbering("1.1", ..nums)
  }

  // Build even-page running heads of the form "Chapter 3 / Experiments".
  #let header-for-chapter() = context {
    let page-number = here().page()
    let chapters = heading.where(level: 1)
    if query(chapters).any(it => it.location().page() == page-number) {
      return []
    }

    // Find the chapter of the section we are currently in
    let chapters-before = query(chapters.before(here()))
    if chapters-before.len() > 0 {
      let current-chapter = chapters-before.last()

      // no header in un-numbered chapters
      if current-chapter.numbering == none {
        return []
      }

      let chapter-title = current-chapter.body
      let chapter-number = str(counter(heading.where(level: 1)).get().first())

      text(fill: uds-blue, weight: "semibold")[#lst-text("chapter") #chapter-number]
      h(0.35em)
      text(fill: text-gray)[/]
      h(0.35em)
      text(fill: text-gray, chapter-title)
    }
  }

  // Build odd-page running heads of the form "2.3 / Previous Work". If the
  // current chapter has no section yet, fall back to the chapter header.
  #let header-for-section() = context {
    let page-number = here().page()
    let sections = heading.where(level: 2)
    let sections-on-page = query(sections).filter(it => it.location().page() == page-number)

    if sections-on-page.len() > 0 {
      let current-section = sections-on-page.first()
      let section-title = current-section.body
      text(fill: uds-blue, weight: "semibold")[#heading-number-at(current-section)]
      h(0.35em)
      text(fill: text-gray)[/]
      h(0.35em)
      text(fill: text-gray, section-title)
    } else {
      let sections-before = query(sections.before(here()))
      if sections-before.len() > 0 {
        let current-section = sections-before.last()
        let section-title = current-section.body
        text(fill: uds-blue, weight: "semibold")[#heading-number-at(current-section)]
        h(0.35em)
        text(fill: text-gray)[/]
        h(0.35em)
        text(fill: text-gray, section-title)
      } else {
        header-for-chapter()
      }
    }
  }

  // Page headers are also responsible for recording which pages are nonblank;
  // the footer reads that state when deciding whether to print a page number.
  #let page-header = context {
    let page-here = here().page()
    // Chapter starts include real chapters and generated front-matter pages.
    let is-start-chapter = query(heading.where(level: 1) .or(heading.where(level: 100))   ).any(it => it.location().page() == page-here)

    if not state("content.switch", false).get() and not is-start-chapter {
      [  ] // empty page
      return
    }

    // Suppress running heads on chapter-opening pages.
    if not is-start-chapter {
      let header-content = if calc.odd(page-here) {
        header-for-section()
      } else {
        header-for-chapter()
      }

      align(if calc.odd(page-here) { right } else { left },
        text(font: "Open Sans", size: 9pt)[
          #header-content
        ])
    }

    // update the list of pages on which the footer displays page numbers
    state("content.pages").update(it => return it + (page-here,))
  }

  #set page(footer: page-footer, header: page-header)


  // Generated front matter. Page numbering starts in roman numerals after the
  // unnumbered title page, then restarts in arabic numerals for the thesis body.
  #context {
    let strings = lst-current-translations()
    if degree-program == none {
      panic("Missing degree program. Set `degree-program` to one of \"langsci\", \"coli\", \"lst\", \"lct\", or \"tst\", or pass a free-form degree-program together with `thesis-type`.")
    }

    let is-known-degree-program = type(degree-program) == str and degree-programs.keys().contains(degree-program)
    let resolved-degree-program = if is-known-degree-program {
      degree-programs.at(degree-program)
    } else {
      (name: degree-program, thesis-type: none)
    }

    if not is-known-degree-program and thesis-type == none {
      panic("Free-form degree programs need an explicit `thesis-type`, for example `thesis-type: \"Seminar paper\"`.")
    }

    let displayed-thesis-type = if thesis-type != none {
      thesis-type
    } else {
      localized-thesis-type(resolved-degree-program.thesis-type)
    }

    // title page
    title-page(mode-settings, strings, displayed-thesis-type, resolved-degree-program.name, title, author, matriculation-number, supervisors, date)

    // declaration page
    set page(numbering: "i")
    counter(page).update(0)
    heading(level: 100, strings.declaration)
    v(-2em)
    strings.declaration-text
    v(2em)

    city
    [, ]
    date

    v(5em)
    line(length: 50%)
    v(-0.5em)
    [(#author)]

    v(1fr)
    text(size: 8pt, prepared-string)
  }

  // Optional front-matter sections are omitted entirely when the corresponding
  // argument is `none`.
  #set par(justify: true)
  #if abstract != none [
    #heading(level: 100)[#lst-text("abstract")]
    #v(-2em)
    #abstract
  ]

  // acknowledgments
  #if acknowledgments != none [
    #heading(level: 100)[#lst-text("acknowledgments")]
    #v(-2em)
    #acknowledgments
  ]

  // The table of contents is intentionally shallow: chapters and sections only.
  #show outline.entry.where(level: 1): it => {
    v(11pt, weak: true)
    it
  }

  #outline(title: lst-text("contents"), depth: 2) // show sections, but not subsections

  // Main matter starts the visible chapter/section numbering and wraps the body
  // in Pergamon's author-year citation style.
  #set page(numbering: "1")
  #counter(page).update(0)
  #set heading(numbering: "1.1")

  #context {
    let strings = lst-current-translations()
    refsection(style: authoryear-style(
      reference: (
        name-format: "{given} {family}",
        format-quotes: it => it,
        print-date-after-authors: true,
        suppress-fields: (
          "*": ("month", "day",),
          "inproceedings": ("editor", "publisher", "pages", "location")
        ),
        eval-scope: ("todo": x => text(fill: red, x)),
        bibstring: ("in": strings.bib-in),
        bibstring-style: "long",
      )
    ), content)
  }
]
