/// Converts a single string value to an array while leaving arrays unchanged.
///
/// - `value`: String or array to normalize.
#let _as-array(value) = {
  if type(value) == str {
    (value,)
  } else {
    value
  }
}

/// Creates localized document constants.
///
/// - `authors`: Normalized array of authors.
/// - `industrial-advisor`: Normalized array of industrial supervisors.
/// - `supervisors`: Normalized array of supervisors.
/// - `supervising-type`: Type of thesis supervision.
#let _make-lang-consts(
  authors,
  industrial-advisors,
  supervisors,
  supervising-type,
) = (
  hu: (
    authors: "Szerző" + if authors.len() > 1 { "k" },
    chapter: "fejezet",
    bsc: "szakdolgozat",
    msc: "diplomaterv",
    phd: "doktori disszertáció",
    tdk: "TDK dolgozat",
    industrial-advisor: "Ipari konzulens" + if industrial-advisors.len() > 1 { "ek" },
    supervisor: if supervising-type == "supervisor" {
      "Témavezető" + if supervisors.len() > 1 { "k" }
    } else {
      "Konzulens" + if supervisors.len() > 1 { "ek" }
    },
    faculty: "Villamosmérnöki és Informatikai Kar",
    university: "Budapesti Műszaki és Gazdaságtudományi Egyetem",
    native-display-format: "[year]. [month repr\:long] [day].",
    datify-display-format: "y. LLLL d.",
  ),

  en: (
    authors: "Author" + if authors.len() > 1 { "s" },
    chapter: "Chapter",
    bsc: "Bachelor's Thesis",
    msc: "Master's Thesis",
    phd: "PhD Dissertation",
    tdk: "Scientific Students' Associations Conference Paper",
    industrial-advisor: "Industrial advisor" + if industrial-advisors.len() > 1 { "s" },
    supervisor: (
      if supervising-type == "supervisor" {
        "Supervisor"
      } else {
        "Advisor"
      }
    ) + if supervisors.len() > 1 { "s" },
    faculty: "Faculty of Electrical Engineering and Informatics",
    university: "Budapest University of Technology and Economics",
    native-display-format: "[month repr\:long] [day], [year]",
    datify-display-format: "LLLL d, y",
  ),
)

/// Renders a first-level heading in the front or back matter.
///
/// The heading starts on a new page and is rendered without chapter
/// numbering.
///
/// - `it`: The first-level heading to render.
#let _front-back-heading(it) = {
  {
    pagebreak(weak: true)
    block(below: 3em)[
      #v(3.5em)
      #text(size: 24pt, weight: "bold")[#it.body]
    ]
  }
}

/// Resets counters whose numbering restarts at each chapter.
///
/// Resets the equation counter and the counters of figures containing
/// images, tables, and raw listings.
#let _reset-counters() = {
  counter(math.equation).update(0)
  for kind in (image, table, raw) {
      counter(figure.where(kind: kind)).update(0)
    }
}

/// Renders a first-level heading in the main matter.
///
/// The chapter number and supplement are ordered according to the document
/// language. In Hungarian, the number precedes the supplement; in English,
/// the supplement precedes the number.
///
/// The heading starts on a new page and resets all chapter-local counters.
///
/// - `lang`: Language STATE of the document, such as `"hu"` or `"en"`.
/// - `it`: The first-level heading to render.
#let _main-heading(lang, it) = {

  _reset-counters()
  pagebreak(weak: true)

  block(below: 3em)[
    #v(3.5em)

    #text(size: 20pt, weight: "bold")[
      #if lang.get() == "en" {
        [#it.supplement #counter(heading).display()]
      } else {
        [#counter(heading).display() #it.supplement]
      }
    ]

    #text(size: 24pt, weight: "bold")[#it.body]
  ]
}


/* -------------------------------------------------------------------------- */
/*                                   MAKERS                                   */
/* -------------------------------------------------------------------------- */

/// Creates a block equation function with document-aware numbering.
///
/// In the main matter, equations are numbered by chapter:
/// - Hungarian: `(4.1.)`
/// - English: `(4.1)`
///
/// In the appendix, equations inherit the full current heading number
/// and append their own local counter:
/// - Hungarian: `(F.2.1.)`
/// - English: `(A.2.1)`
///
/// The numbering depends on the current values of `doc-lang` and `doc-part`.
///
/// Returns a function that accepts equation content and renders a numbered
/// block `math.equation`.
/// 
/// - `lang`: Document language STATE. Hungarian numbering receives a trailing period.
/// - `part`: Document part STATE. Appendix numbering is different than the main part.
#let _make-equation(lang, part) = {
  /// Formats the local equation counter according to the current document part.
  ///
  /// - `n`: Local equation counter value supplied by `math.equation`.
  let equation-numbering(n) = context {
    let lang-hu = lang.get() == "hu"

    let nums = [#counter(heading).display()#numbering(
            if lang-hu { "1" } else { ".1" },
            n,
          )]

    if part.get() == "appendix" {
      [
        (#nums)
      ]
    } else {
      let chapter = counter(heading).get().first()
      numbering(
        if lang-hu { "(1.1.)" } else { "(1.1)" },
        chapter,
        n,
      )
    }
  }

  body => math.equation(
    block: true,
    numbering: equation-numbering,
    body,
  )
}

/// Creates a figure numbering function based on heading counters.
///
/// The generated numbering consists of the first `levels` heading counter
/// components followed by the figure counter.
///
/// - `levels`: Number of heading levels included in the figure number.
/// - `heading-pattern`: Numbering pattern used for the inherited heading levels.
/// - `lang`: Document language. Hungarian numbering receives a trailing period.
///
/// Returns a contextual numbering function suitable for `figure.numbering`.
#let _make-figure-numbering(
  levels: 1,
  heading-pattern: "1",
  lang,
) = {
  n => context {
    let headings = counter(heading).get()
    let prefix = headings.slice(0, levels)

    numbering(
      heading-pattern + ".1" + if lang == "hu" {"."} else {""},
      ..prefix,
      n,
    )
  }
}

/// Renders an outline for a specific kind of figure.
///
/// Outline entries are formatted as:
/// `number supplement title ........ page`
///
/// - `kind`: Figure kind to include in the outline, such as `image` or `table`.
/// - `title-hu`: Hungarian title of the outline.
/// - `title-en`: English title of the outline.
/// - `doc-lang`: Language STATE of the document
#let _figure-outline(
  kind,
  title-hu,
  title-en,
  doc-lang
) = context {
  let lang = doc-lang.get()

  show outline.entry: it => context {
    let elem = it.element

    let number = elem.counter.display(
      elem.numbering,
      at: elem.location(),
    )

    let prefix = if lang == "hu" {[
      #number#h(0.3em)#elem.supplement:
    ]} else {
      [#elem.supplement #number#h(0.3em):]
    }

    link(
      elem.location(),
      it.indented(
        prefix,
        it.body()
          + box(width: 1fr, it.fill)
          + it.page(),
      ),
    )
  }

  show outline.entry.where(level: 1): set outline.entry(
    fill: repeat([.]),
  )

  outline(
    target: figure.where(kind: kind),
    title: if lang == "en" {
      title-en
    } else {
      title-hu
    },
  )
}

/// Renders a localized figure caption.
///
/// Hungarian captions place the figure number before the supplement,
/// while English captions place the supplement before the number.
///
/// - `lang`: Document language.
/// - `it`: Figure caption element to render.
#let _figure-caption(lang, it) = {
  let number = counter(figure.where(kind: it.kind)).display(
    it.numbering,
    at: it.location(),
  )

  let separator = if it.body != [] { ":" }

  if lang == "en" {
    text(weight: "bold")[
      #it.supplement #number#separator
    ]
  } else {
    text(weight: "bold")[
      #number #it.supplement#separator
    ]
  }

  text(style: "italic")[#it.body]
}

/// Renders references using numbering reconstructed at the target location.
///
/// Figure and equation references are reconstructed explicitly to ensure that
/// references to appendix elements use the numbering scheme active at the
/// referenced location rather than at the reference location.
///
/// - `part`: Context-aware part STATE in the document
/// - `lang`: Document language STATE
/// - `it`: Reference element to render.
#let _show-ref(part, lang, it) = context {
    let element = it.element

    if element == none {
      it
    } else if element.func() == figure {
      let loc = element.location()
      let figure-number = counter(figure.where(kind: element.kind)).at(loc).last()

      let headings = counter(heading).at(loc)
      let prefix = headings.slice(
        0,
        if part.at(loc) == "appendix" { 2 } else { 1 },
      )

      let pattern = if part.at(loc) == "appendix" {
          if lang.at(loc) == "hu" { "A.1.1." } else { "A.1.1" }
        } else {
          if lang.at(loc) == "hu" { "1.1." } else { "1.1" }
        }
      link(
        loc,
        numbering(pattern, ..prefix, figure-number),
      )
    } else if element.func() == heading {
        let loc = element.location()

        link(
          loc,
          counter(heading).display(
            element.numbering,
            at: loc,
          ),
        )
    } else if element.func() == math.equation {
      let loc = element.location()
      let equation-number = counter(math.equation).at(loc).last()
      let headings = counter(heading).at(loc)

      let appendix = part.at(loc) == "appendix"
      let lang = lang.at(loc)

      let prefix = headings.slice(
        0,
        if appendix { 2 } else { 1 },
      )

      let pattern = if appendix {
        if lang == "hu" { "(A.1.1.)" } else { "(A.1.1)" }
      } else {
        if lang == "hu" { "(1.1.)" } else { "(1.1)" }
      }

      link(
        loc,
        numbering(pattern, ..prefix, equation-number),
      )
    } else {
      it
    }
  }
}