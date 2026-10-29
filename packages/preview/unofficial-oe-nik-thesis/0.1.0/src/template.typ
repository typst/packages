// Sources, each rule names the one it follows:
// Guide: "Thesis (BSc, BProf, SZT) / Thesis work (MSc) preparation guide", 2025/2026/1, with section numbers
//   https://nik.uni-obuda.hu/wp-content/uploads/2025/10/NIK_SZD_DM_TAJ_2025_2026_01_ENG.pdf
//   https://nik.uni-obuda.hu/wp-content/uploads/2025/10/NIK_SZD_DM_TAJ_2025_2026_01.pdf (Hungarian)
// Guide (HU 2025/12): the newer Hungarian version, linked on the Hungarian page only, wins where they differ
//   https://nik.uni-obuda.hu/wp-content/uploads/2025/12/NIK_SZD_DM_TAJ_20252601_2025.pdf
// Docx: the official Hungarian sample thesis, its styles and how they're laid out (measured from its PDF export)
//   https://nik.uni-obuda.hu/wp-content/uploads/2025/12/SZD_DM_Word_dolgozat_sablon_2025.docx
// EN example: the English example document, "04 Thesis example document.docx"
// AI instruction: 18/2026. (X.06.) rector's instruction on the use of AI systems in education, with section numbers
//   https://uni-obuda.hu/wp-content/uploads/2026/10/18_2026_rektori_utasitas_mesterseges_intelligencia_oktatas.pdf
// Supervisor: a deviation from the Guide approved by the supervisor of the thesis the template was made for
// Own: the template's own choice

#import "@preview/wordometer:0.1.6": word-count-of
#import "@preview/glossarium:0.5.10": count-refs, make-glossary, print-glossary, register-glossary

#import "cover/cover.typ": cover-page
#import "problem.typ": note, problem
// passed on, so the thesis imports everything from the template
#import "ai-tools.typ": ai-generated, ai-tool, ai-tools-style

// an error if the parameter `name` isn't of the type `_type`, or of one of the types or values in the array
// `_type`, e.g. `(content, none)`, `hint` is added to the message
#let assert-type(_type, name, value, hint: none) = {
  let options = if type(_type) == array { _type } else { (_type,) }
  let valid = options.any(option => if type(option) == type { type(value) == option } else { value == option })
  let human-type(option) = if type(option) != type { repr(option) } else {
    let names = (
      boolean: "true or false",
      string: "a string",
      integer: "a number",
      content: "content",
      array: "an array",
    )
    names.at(str(option), default: "a " + str(option))
  }
  let hint = if hint != none { ", " + hint }
  assert(
    valid,
    message: "`"
      + name
      + "` must be "
      + options.map(human-type).join(", ", last: " or ")
      + hint
      + ", got "
      + repr(value),
  )
}

// the pages of a PDF as images, Typst can't tell how many pages a PDF has
// `file` is a `path`, a string would be resolved relative to this file instead of the caller's
#let pdf-pages(file, pages: 1) = {
  assert-type(path, "file", file, hint: "pass the PDF as `path(\"...\")`")
  range(1, pages + 1).map(page => image(file, page: page))
}

// the characters including spaces, counted from the source text: about 2% fewer than in the PDF, which also has
// heading numbers and figure labels
#let count-characters(it) = {
  word-count-of(it, counter: text => (characters: text.replace(regex("\\s+"), " ").clusters().len())).characters
}

#let languages = ("hu", "en")

// checks a parameter like `(hu: [...], en: [...])` and returns it as a dictionary, a missing language is `auto`
#let assert-per-language(name, value) = {
  assert(
    value in (auto, none) or type(value) == dictionary and value.keys().all(key => key in languages),
    message: "`" + name + "` must be `(hu: [...], en: [...])`, `auto` or `none`, got " + repr(value),
  )
  if type(value) == dictionary {
    for (key, part) in value {
      let hint = "e.g. `include \"chapters/" + name + "-" + key + ".typ\"`"
      assert-type((content, str, auto, none), name + "." + key, part, hint: hint)
    }
  }
  if value == auto { (:) } else if value == none { (hu: none, en: none) } else { value }
}

// checks a parameter changing the `guide` limits, e.g. `(min-pages: 39)`, and returns the limits
#let assert-length-limits(name, value, guide) = {
  assert(
    value in (auto, none)
      or type(value) == dictionary
        and value.pairs().all(((key, limit)) => key in guide and (limit == none or type(limit) == int)),
    message: "`"
      + name
      + "` must be `auto`, `none` or some of the limits "
      + guide.keys().map(repr).join(", ")
      + ", e.g. `"
      + name
      + ": ("
      + guide.keys().first()
      + ": "
      + str(guide.values().first())
      + ")`, got "
      + repr(value),
  )
  if value == none { (:) } else if value == auto { guide } else { guide + value }
}

// an error if `actual` is out of the limit `key` (e.g. "min-pages") of `assert-length-limits`, `name` is the
// parameter that changes it, `what` is what was measured, e.g. "the number of pages in the chapters"
#let check-length(name, limits, key, actual, what) = {
  let limit = limits.at(key, default: none)
  if limit == none or (if key.starts-with("min-") { actual >= limit } else { actual <= limit }) { return }
  // in its own `context`, so all the exceeded limits are reported
  context assert(
    false,
    message: what
      + " is "
      + str(actual)
      + ", out of `"
      + key
      + ": "
      + str(limit)
      + "`; if an exception was approved, set `"
      + name
      + ": ("
      + key
      + ": "
      + str(actual)
      + ")`, or turn this check off with `"
      + name
      + ": ("
      + key
      + ": none)`",
  )
}

// Guide title: "Thesis (BSc, BProf, SZT) / Thesis work (MSc)", HU: "Szakdolgozat (...) / Diplomamunka (MSc)"
// Guide 2.2: "The thesis must be at least 40 pages long and contain at least 60,000 characters (including spaces)
// / the thesis work must be at least 60 pages long and contain at least 80,000 characters (including spaces)"
// Guide (HU 2025/12) 2.2: "A dolgozatok maximális terjedelme mellékletekkel max. 60, illetve 80 oldal." (at most
// 60 or 80 pages with the appendices), the older versions only had the thesis work's 80 pages
// Guide appendix 3: the Hungarian summary is "1500-2500 characters"
// the English summary has the same limits, the Guide gives none for it
#let degrees = {
  let thesis = (
    thesis: (en: "Thesis", hu: "Szakdolgozat"),
    body-length: (min-pages: 40, max-pages: 60, min-characters: 60000),
    summary-length: (min-characters: 1500, max-characters: 2500),
  )
  let thesis-work = (
    thesis: (en: "Thesis work", hu: "Diplomamunka"),
    body-length: (min-pages: 60, max-pages: 80, min-characters: 80000),
    summary-length: (min-characters: 1500, max-characters: 2500),
  )
  (BSc: thesis, BProf: thesis, SZT: thesis, MSc: thesis-work)
}

// the rules follow the order of the Guide's typographical requirements (2.3), then figures and equations (2.2,
// appendix 2), the table of contents and the parts of the thesis (appendix 3)
// a part that is `auto` isn't added yet: a red placeholder while drafting, an error with `draft: false`; `none`
// leaves it out when it isn't required
#let thesis-template(
  lang: "en",
  degree: none,
  // the year of submission
  year: none,
  title: none,
  author: none,
  // "törzskönyvi szám", not the Neptun code, e.g. "NIK-O-NI-02-33" in the Docx, real ones look like
  // "T/1234567/FI12904/N" (FI12904 is Óbuda University's institutional identifier)
  registration-number: none,
  // the signed forms: a PDF as `path("signed/worksheet.pdf")`, an image or an array of images, one per page, e.g.
  // `pdf-pages(path("signed/worksheet.pdf"), pages: 3)` for a different page count
  worksheet: auto,
  declaration: auto,
  consultation-log: auto,
  // `none` if confidentiality wasn't approved
  confidentiality: none,
  // `(hu: [...], en: [...])`, a missing language is `auto`
  abstract: auto,
  // changes to the length limits of the degree (see `degrees`) if an exception was approved, e.g.
  // `(min-pages: 39)`, a limit set to `none` isn't checked, `none` for no checks
  body-length: auto,
  // like `abstract`
  summary: auto,
  // like `body-length`, e.g. `(max-characters: 3000)`
  summary-length: auto,
  // e.g. `bibliography("bibliography.bib")`
  bibliography: auto,
  // `false` to leave a list out, a list without entries is left out anyway
  list-of-figures: true,
  list-of-tables: true,
  // `glossarium` entries, e.g. `((key: "ast", short: "AST", long: "abstract syntax tree"),)`, used in the text as
  // `@ast` (the first use is written out)
  abbreviations: auto,
  // the used AI tools, `ai-tool` entries with labels, e.g. `[#ai-tool(...) <ai-example>]`
  ai-tools: none,
  // each appendix is a subchapter, e.g. `[== Source code ...]`
  appendices: none,
  // `false` (or `typst compile --input draft=false`) for the version to submit
  draft: true,
  body,
) = {
  let draft-input = sys.inputs.at("draft", default: "true")
  assert-type(("true", "false"), "--input draft=", draft-input)
  assert-type(bool, "draft", draft)
  let draft = draft and draft-input == "true"

  assert-type(bool, "list-of-figures", list-of-figures)
  assert-type(bool, "list-of-tables", list-of-tables)
  show: ai-tools-style.with(draft: draft)
  // `@key` references to abbreviations
  show: make-glossary
  assert-type(languages, "lang", lang)
  assert-type(degrees.keys(), "degree", degree)
  assert-type(int, "year", year)
  assert-type(str, "title", title)
  assert-type(str, "author", author)
  assert-type(
    str,
    "registration-number",
    registration-number,
    hint: "find it in Neptun: "
      + (
        en: "Studies -> Registry record -> Training data -> \"Regirty number\" (Neptun's typo)",
        hu: "Tanulmányok -> Törzslap -> Képzésadatok -> Alapadatok -> Törzsszám",
      ).at(lang),
  )

  let abstract = assert-per-language("abstract", abstract)
  let body-limits = assert-length-limits("body-length", body-length, degrees.at(degree).body-length)
  let summary-limits = assert-length-limits("summary-length", summary-length, degrees.at(degree).summary-length)
  assert-type((content, none), "ai-tools", ai-tools, hint: "e.g. `[#ai-tool(...) <ai-example>]`")
  assert-type((content, none), "appendices", appendices, hint: "e.g. `[== Source code ...]`")
  let summary = assert-per-language("summary", summary)
  assert(
    abbreviations in (auto, none)
      or type(abbreviations) == array
        and abbreviations.all(entry => type(entry) == dictionary and type(entry.at("key", default: none)) == str),
    message: "`abbreviations` must be entries like `((key: \"ast\", short: \"AST\", long: \"abstract syntax "
      + "tree\"),)`, `auto` or `none`, got "
      + repr(abbreviations),
  )
  if type(abbreviations) == array { register-glossary(abbreviations) }
  // the parameter hides Typst's `bibliography` function, which is `std.bibliography` in the template
  assert(
    bibliography in (auto, none) or type(bibliography) == content and bibliography.func() == std.bibliography,
    message: "`bibliography` must be e.g. `bibliography(\"bibliography.bib\")`, `auto` or `none`, got "
      + repr(bibliography),
  )

  set text(lang: lang)

  set document(
    title: title,
    author: author,
    // Own: a reproducible PDF, the date and the document ID would come from the current time
    date: none,
  )

  set page(
    // Guide 2.3: "The thesis/thesis work must be prepared in A4 format."
    "a4",
    // Guide 2.3: "40 mm at the bottom, 25 mm at the bottom and outer edges, 35 mm on the binding side", the first
    // is the top: Guide (HU 2025/12): "felülről 40 mm"
    // Docx: the binding side is always the left one (not mirrored)
    // Supervisor: one-sided, the thesis won't be printed
    margin: (top: 40mm, bottom: 25mm, left: 35mm, right: 25mm),
  )

  // Guide 2.3: "The font used in the body text is Times New Roman, size 12, with justified alignment."
  // Supervisor: URW Nimbus Roman is fine to use, a free alternative to Times New Roman
  set text(font: "Nimbus Roman", size: 12pt)
  set par(justify: true)

  // Guide 2.3: "line spacing 1.5 lines"
  let line-spacing = 1.5
  // Docx: a multiple of the font's single line height: ascender + descender + line gap of its hhea table, the sum
  // is the same for Nimbus Roman TrueType (1604, 444, 307 / 2048) and Times New Roman (1825, 443, 87 / 2048)
  // https://forum.typst.app/t/getting-office-365-word-line-spacing-in-typst/3422
  let ascender = 1604 / 2048 * 1em
  let descender = 444 / 2048 * 1em
  let line-gap = 307 / 2048 * 1em
  let single-line = ascender + descender + line-gap
  // Docx: a line spans from the line gap above the ascender to the descender, the leading is the extra space
  set text(top-edge: ascender + line-gap, bottom-edge: -descender)
  let leading = (line-spacing - 1) * single-line
  set par(leading: leading)

  // Guide 2.3: no value
  // Docx: 8pt before and after paragraphs, the larger one of two neighbors is used (like in Typst), on top of the
  // extra space of the line spacing below each line; Typst only uses the spacing of a block next to a paragraph,
  // so it includes that extra space on both sides
  let paragraph-spacing = 8pt
  set block(spacing: leading + paragraph-spacing)
  set par(spacing: leading + paragraph-spacing)

  set page(
    // Guide 2.3: "Page numbering at the top, in the middle of the page, 20 mm from the edge of the page."
    header: context if page.numbering != none {
      align(center, counter(page).display(page.numbering))
    },
    // Docx: the header's paragraph has 8pt space before and single line spacing
    header-ascent: 40mm - (20mm + paragraph-spacing + single-line),
    footer: none,
  )

  // Guide 2.3: "Chapter titles should be numbered with Arabic numerals", "Subchapter titles should be numbered to
  // a maximum depth of three numbers"
  set heading(numbering: "1.1")

  // Guide 2.3: chapter titles are "14-point capital letters", subchapter titles are "12-point bold characters,
  // aligned to the left"
  // Docx: chapter titles aren't bold
  show heading: set text(size: 12pt)
  show heading.where(level: 1): set text(size: 14pt, weight: "regular")

  show heading: it => {
    // Docx: "Az alfejezetek, és minden további bontás csak indokoltan alkalmazandó!" (further subdivision only if
    // justified)
    assert(
      it.numbering == none or it.level <= 3,
      message: "heading "
        + repr(it.body)
        + " is numbered "
        + str(it.level)
        + " levels deep, at most 3 are "
        + "allowed (e.g. 1.2.3), use `#heading(level: "
        + str(it.level)
        + ", numbering: none)[...]` for further "
        + "subdivision",
    )

    if it.numbering == none {
      it
    } else {
      // Docx: the number is followed by a tab to a hanging indent of 432, 576, 720 twips for levels 1, 2, 3
      block(grid(
        columns: ((288 + 144 * it.level) / 1440 * 1in, 1fr),
        counter(heading).display(it.numbering), it.body,
      ))
    }
  }

  // Guide 2.3: chapter titles are "centered at the top of the page"
  // Docx: left-aligned ("balra igazítva")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    // figures, tables and equations are numbered by chapter, see below
    for kind in (image, table) {
      counter(figure.where(kind: kind)).update(0)
    }
    counter(math.equation).update(0)
    upper(it)
  }

  // Guide 2.3: no value
  // Docx: level 3 and deeper have 12pt before and after, level 1 has 12pt after
  show heading: set block(above: leading + 12pt, below: leading + 12pt)
  // Docx: level 2 has 0pt before, 6pt after and single line spacing, so the paragraph spacing is used instead
  show heading.where(level: 2): set block(above: leading + paragraph-spacing, below: paragraph-spacing)

  // Guide appendix 2: "It is advisable to number figures and tables by chapter, starting with 1 (e.g., Figure 6.1,
  // Table 5.2)." https://github.com/typst/typst/issues/1896
  // Docx: Hungarian numbers end with a period, "1.1. ábra"
  let figure-numbering = if lang == "hu" { "1.1." } else { "1.1" }
  set figure(numbering: (n, ..) => {
    numbering(figure-numbering, counter(heading).get().first(), n)
  })

  // Own: code blocks in figures are "Figure"s numbered together with images, instead of separately as "Listing"s
  // Docx: Hungarian figures and tables are "ábra" and "táblázat" in lowercase, after the number
  let figure-supplements = (
    image: (hu: [ábra], en: [Figure]).at(lang),
    table: (hu: [táblázat], en: [Table]).at(lang),
  )
  show figure.where(kind: raw): set figure(kind: image, supplement: figure-supplements.image)
  show figure.where(kind: image): set figure(supplement: figure-supplements.image)
  show figure.where(kind: table): set figure(supplement: figure-supplements.table)

  // Docx: Hungarian captions start with the number, "1.1. ábra: Az ábra címe"
  show figure.caption: it => if lang != "hu" { it } else {
    context [#it.counter.display(it.numbering) #it.supplement: #it.body]
  }

  // Own: Hungarian references are only the number, the author writes the noun with its case ending, e.g.
  // `az @kep ábrán` -> "az 1.1. ábrán", `a @tetel egyenletből` -> "a (2.1) egyenletből"
  set ref(supplement: none) if lang == "hu"
  // headings are numbered without a period ("1 Bevezetés"), but a reference to one is an ordinal number,
  // `az @intro fejezetben` -> "az 1. fejezetben"
  show ref: it => {
    let heading-element = it.element != none and it.element.func() == heading and it.element.numbering != none
    if lang != "hu" or not heading-element { return it }
    let location = it.element.location()
    link(location, numbering("1.1.", ..counter(heading).at(location)))
  }

  // Guide 2.2: "Only those formulas appearing in the THESIS that are referred to in other parts of the text need
  // to be numbered. Numbering must be restarted for each chapter (e.g., 3.2.)."
  // Docx: "(2.1)"
  // Own: all block equations are numbered
  set math.equation(numbering: n => numbering("(1.1)", counter(heading).get().first(), n))

  // Docx: chapters are in capitals in the table of contents too
  show outline.entry.where(level: 1): it => if it.element.func() == heading { upper(it) } else { it }
  // Docx: Hungarian lists of figures and tables like the captions
  show outline.entry: it => if lang != "hu" or it.element.func() != figure { it } else {
    let figure = it.element
    let chapter = counter(heading).at(figure.location()).first()
    let number = numbering(figure-numbering, chapter, figure.counter.at(figure.location()).first())
    link(figure.location(), it.indented([#number #figure.supplement:], it.inner()))
  }

  // pages before the body, in the order of Guide appendix 3

  // Guide 2.3: "Inside cover page (Appendix 4)"
  cover-page(
    lang: lang,
    thesis-type: degrees.at(degree).thesis.at(lang),
    year: year,
    author: author,
    registration-number: registration-number,
  )

  // Guide 2.3: the worksheet, the student declaration and the consultation log are mandatory front pages
  // Guide 2.4: "The worksheet and legal statement pages must be signed and inserted into the thesis/dissertation
  // as images."
  // Guide appendix 3: "Confidentiality document, if confidentiality of the thesis has been approved"
  // Docx: the worksheet is 2 pages, the others 1, the confidentiality document has no form (Guide appendix 7)
  for (name, form, pages, page-count) in (
    ("worksheet", "Worksheet", worksheet, 2),
    ("declaration", "Student declaration", declaration, 1),
    ("consultation-log", "Consultation log", consultation-log, 1),
    ("confidentiality", "Confidentiality document", confidentiality, 1),
  ) {
    assert-type(
      (path, content, array, auto, none),
      name,
      pages,
      hint: "e.g. a PDF as `path(\"signed/" + name + ".pdf\")`",
    )
    if pages == none { continue }
    // placeholder pages until the signed forms are ready, usually at the end, with the final page count
    if pages == auto {
      let message = (
        "the signed "
          + lower(form)
          + " is missing, insert it as a PDF with `"
          + name
          + ": path(\"signed/"
          + name
          + ".pdf\")`, or with `"
          + name
          + ": none` if it isn't required"
      )
      // once, not on every placeholder page
      context assert(draft, message: message)
      pages = range(1, page-count + 1).map(n => {
        set par(justify: false)
        align(center + horizon, block(width: 70%)[
          #text(red, size: 14pt, upper(form)) \
          #text(red)[placeholder, page #n of #page-count]
          // Docx: the worksheet has the title, "A dolgozat címe:", so the placeholder shows it to check
          #if name == "worksheet" and n == 1 {
            linebreak() + text(red)[#(hu: "A dolgozat címe", en: "Title of the thesis").at(lang): #title]
          }

          #note(message)
        ])
      })
    }
    if type(pages) == path { pages = pdf-pages(pages, pages: page-count) }
    if type(pages) != array { pages = (pages,) }
    for signed-page in pages {
      // the scan covers the whole page
      set image(width: 100%, height: 100%, fit: "contain")
      page(margin: 0pt, signed-page)
    }
  }

  // Guide appendix 3: "Abstract in Hungarian and English" before the table of contents, Hungarian first like in
  // the Docx
  // Own: each on its own page with a chapter title, like in the EN example (which has them at the end) and other
  // Typst thesis templates, the Docx has both on one page with smaller titles; not in the table of contents (the
  // pages before it have no page number), only in the PDF's bookmarks
  for abstract-lang in languages {
    let value = abstract.at(abstract-lang, default: auto)
    if value == none { continue }
    set text(lang: abstract-lang)
    heading(
      numbering: none,
      outlined: false,
      bookmarked: true,
      (hu: "Absztrakt", en: "Abstract").at(abstract-lang),
    )
    if value != auto {
      value
    } else {
      problem(
        draft,
        "the "
          + abstract-lang
          + " abstract is missing, add it with `abstract: ("
          + abstract-lang
          + ": include \"chapters/"
          + "abstract-"
          + abstract-lang
          + ".typ\")`, or set `"
          + abstract-lang
          + ": none` in `abstract` if it isn't required",
      )
    }
  }

  // Guide appendix 3: "Table of contents (page numbering starts here) (mandatory)"
  set page(numbering: "1")
  counter(page).update(1)

  outline()

  [#metadata(none) <thesis-template-body>]
  body
  [#metadata(none) <thesis-template-body-end>]

  // Guide appendix 3: "Summary of the thesis content and conclusions" in Hungarian and English (mandatory), before
  // the bibliography
  // Docx: numbered "ÖSSZEGZÉS" and "SUMMARY" chapters
  for summary-lang in languages {
    let value = summary.at(summary-lang, default: auto)
    if value == none { continue }
    set text(lang: summary-lang)
    heading((hu: "Összegzés", en: "Summary").at(summary-lang))
    if value == auto {
      problem(
        draft,
        "the "
          + summary-lang
          + " summary is missing, add it with `summary: ("
          + summary-lang
          + ": include \"chapters/"
          + "summary-"
          + summary-lang
          + ".typ\")`, or set `"
          + summary-lang
          + ": none` in `summary` if it isn't required",
      )
      continue
    }
    value
    if not draft {
      let characters = count-characters(value)
      let what = "the number of characters in the " + summary-lang + " summary"
      for key in ("min-characters", "max-characters") {
        check-length("summary-length", summary-limits, key, characters, what)
      }
    }
  }

  // Guide appendix 3: "Bibliography (mandatory)"
  // Docx: a numbered "IRODALOMJEGYZÉK" chapter, IEEE in order of citation ("Az IEEE előfordulás szerint rendezett
  // irodalomjegyzéket javasolt sorszámmal ellátni")
  if bibliography != none {
    heading((hu: "Irodalomjegyzék", en: "References").at(lang))
    if bibliography == auto {
      problem(
        draft,
        "the bibliography is missing, add it with `bibliography: bibliography(\"bibliography.bib\")`, or with "
          + "`bibliography: none` if it isn't required",
      )
    } else {
      set std.bibliography(title: none, style: "ieee")
      bibliography
    }
  }

  // Docx: numbered "ÁBRAJEGYZÉK" and "TÁBLÁZATOK JEGYZÉKE" chapters, the Guide doesn't mention them
  // EN example: "List of Figures" and "List of Tables"
  for (enabled, kind, title) in (
    (list-of-figures, image, (hu: "Ábrajegyzék", en: "List of Figures")),
    (list-of-tables, table, (hu: "Táblázatok jegyzéke", en: "List of Tables")),
  ) {
    if enabled {
      context if query(figure.where(kind: kind)).len() > 0 {
        heading(title.at(lang))
        outline(title: none, target: figure.where(kind: kind))
      }
    }
  }

  // Guide 2.2: "abbreviations should be listed at the beginning or end of the thesis"
  // Docx: a numbered "RÖVIDÍTÉSEK" chapter after the lists of figures and tables, the abbreviation and its meaning
  // separated by a tab at 2.5cm
  // Own: only the used ones are listed
  if abbreviations != none {
    let title = heading((hu: "Rövidítések", en: "Abbreviations").at(lang))
    if abbreviations == auto {
      title
      problem(
        draft,
        "the list of abbreviations is missing, add it with `abbreviations: ((key: \"ast\", short: \"AST\", long: "
          + "\"abstract syntax tree\"),)` and use them in the text like `@ast`, or with `abbreviations: none` if "
          + "the thesis has no abbreviations",
      )
    } else {
      title
      // the title can't depend on whether any is used, the layout wouldn't converge
      context if not abbreviations.any(entry => count-refs(entry.key) > 0) {
        problem(
          draft,
          "none of the abbreviations is used, use them in the text like `@"
            + abbreviations.first().key
            + "`, or "
            + "remove them with `abbreviations: none` if the thesis has no abbreviations",
        )
      }
      print-glossary(
        abbreviations,
        disable-back-references: true,
        user-print-gloss: (entry, ..options) => if count-refs(entry.key) > 0 {
          grid(
            columns: (2.5cm, 1fr),
            entry.short, entry.long,
          )
        },
      )
    }
  }

  // Guide appendix 3: "Appendices" last
  // Docx: a numbered "MELLÉKLETEK" chapter
  // EN example: "Annexes"
  // Own: before the AI tools, which don't count towards the length
  if appendices != none {
    heading((hu: "Mellékletek", en: "Appendices").at(lang))
    appendices
  }
  [#metadata(none) <thesis-template-counted-end>]

  // AI instruction 18.§ (3): the list of the AI tools at the end of the thesis, after and separate from the
  // bibliography, titled "Használt Mesterséges Intelligencia Eszközök", see ai-tools.typ
  // AI instruction 18.§ (5): it doesn't count towards the length limit
  // Own: the English title is a translation
  if ai-tools != none {
    heading((hu: "Használt Mesterséges Intelligencia Eszközök", en: "Used Artificial Intelligence Tools").at(lang))
    ai-tools
  }

  // Guide 2.2: the length limits (see `degrees`), it doesn't say what counts
  // the strictest reading: the minimums only count the chapters (other universities leave out the front pages,
  // the abstracts, the bibliography, the lists and the appendices), the maximum "with appendices" counts from the
  // first chapter to the end of the appendices (the front pages aren't part of the text, like for the Thesis I.
  // upload)
  if not draft {
    context {
      let first = query(selector(heading).after(<thesis-template-body>)).at(0, default: none)
      let first-page = if first == none { locate(<thesis-template-body>).page() } else { first.location().page() }
      let chapter-pages = locate(<thesis-template-body-end>).page() - first-page + 1
      let all-pages = locate(<thesis-template-counted-end>).page() - first-page + 1
      let characters = count-characters(body)
      check-length("body-length", body-limits, "min-pages", chapter-pages, "the number of pages in the chapters")
      check-length(
        "body-length",
        body-limits,
        "max-pages",
        all-pages,
        "the number of pages from the first chapter to the end of the appendices",
      )
      check-length("body-length", body-limits, "min-characters", characters, "the number of characters in the chapters")
    }
  }
}
