#import "utils.typ": *
#import "frontispiece.typ": *

/// The main thesis formatting function.
/// -> content
#let unimi-thesis(
  /// Name of the university.
  /// -> content | string
  university: "Università degli Studi di Milano",
  /// University logo.
  /// -> image
  unilogo: image(height: 30mm, "img/unimi-black.svg"),
  /// Name of the faculty (or school).
  /// -> string | content
  faculty: none,
  /// Department of your faculty.
  /// -> string | content
  department: none,
  /// Degree course.
  /// -> string | content
  course: none,
  /// Title of the thesis.
  /// -> string | content
  title: "Titolo della Tesi",
  /// Subtitle of the thesis.
  /// -> string,
  subtitle: none,
  /// Type of thesis
  /// -> string
  thesis-type: "Elaborato Finale",
  /// Author name and surname.
  /// -> string
  author: none,
  /// Author serial number.
  /// -> string
  serial-number: none,
  /// Language of the thesis.
  /// -> "it" | "en"
  language: "it",
  /// Supervisor(s).
  /// -> string | array
  supervisors: (),
  /// Cosupervisor(s).
  /// -> string | array
  cosupervisors: (),
  /// The academic year of the graduation.
  /// -> content | string
  academic-year: [2026 --- 2027],
  /// Change the links font.
  /// -> string
  link-font: "Dejavu Sans Mono",
  /// Whether to add a line below the header.
  /// -> bool
  header-line: false,
  /// The chosen frontispiece.
  /// -> "lim" | "alternate"
  frontispiece: "lim",
  body,
) = {
  set document(
    title: title,
    author: if author != none { author } else { () },
  )

  set text(
    font: "Libertinus Serif",
    lang: language,
    size: 11pt,
  )

  set page(
    paper: "a4",
    margin: (
      top: 3cm,
      bottom: 3.1cm,
      left: 3.5cm,
      right: 2.5cm,
    ),
    numbering: "i",
    header-ascent: 1.03cm,
    header: context {
      if (
        (_document-state.get() in ("TITLE_PAGE", "FRONTMATTER", "ACKNOWLEDGEMENTS", "BACKMATTER"))
          // if there is a lvl 1 heading on the same page, the header must be empty
          or _h1-current-page().len() != 0
      ) {
        none
      } else if (_document-state.get() in ("MAINMATTER", "APPENDIX")) {
        // if there is no level 1 heading on the current page, print the last lvl 1 heading
        let before = query(selector(heading.where(level: 1)).before(here()))
        let heading-1 = if (before.len() != 0) {
          before.last().body
        }

        let output = heading-1

        if heading.numbering != none {
          let heading-count = counter(heading).display(
            (..args) => _custom-numbering(heading.numbering, args),
          )
          output = heading-count + ". " + output
        }

        let args = if (header-line) {
          (
            inset: (
              bottom: 0.5em,
            ),
            stroke: (
              bottom: black + 0.05em,
            ),
          )
        }

        block(
          ..args,
          upper(
            text(
              style: "italic",
              output,
            )
              + h(1fr)
              + counter(page).display(),
          ),
        )
      }
    },
    footer: none,
  )

  // TITLE PAGE

  frontispieces.at(frontispiece)(
    university,
    faculty,
    department,
    unilogo,
    course,
    title,
    subtitle,
    supervisors,
    cosupervisors,
    thesis-type,
    author,
    serial-number,
    academic-year,
  )

  set par(
    justify: true,
    spacing: 0.8em,
    first-line-indent: 1.2em,
  )

  // Outlines

  show outline.entry.where(level: 1): it => {
    v(19pt, weak: true)
    link(
      it.element.location(),
      strong(it.indented(
        it.prefix(),
        it.element.body + h(1fr) + it.page(),
      )),
    )
  }

  // Headings

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(3cm)
    if (it.numbering != none) {
      counter(selector(heading)).display((..args) => _custom-numbering(it.numbering, args))
    }
    v(10pt)
    set par(first-line-indent: 0em)
    it.body
  }

  show heading: it => {
    if (it.level == 1) {
      text(size: _sizes.Large, it)
    }
    if (it.level == 2) {
      text(size: _sizes.large, it)
    }
    if (it.level >= 3) {
      text(size: _sizes.normalsize, it)
    }
    v(8pt)
  }

  // List, enums

  set list(
    indent: 1.2em,
    tight: false,
    marker: (
      [•],
      [--],
      [\*],
    ),
  )

  show list: it => {
    set par(spacing: 1.2em)
    it
  }

  set enum(
    indent: 1.2em,
    tight: true,
    numbering: "1.a.i.",
  )

  show enum: it => {
    set par(spacing: 1.2em)
    it
  }

  // Link

  show link: it => {
    if type(it.dest) == str {
      set text(font: link-font, size: 0.8em)
      it
    } else {
      it
    }
  }

  body
}

// Document sections

/// Frontmatter section. Similar to LaTeX's ```tex \frontmatter```. It sets
/// ```typc numbering: none``` for headings.
/// -> content
#let frontmatter(body) = {
  _document-state.update("FRONTMATTER")
  set heading(numbering: none)

  body
}

/// Dedication sections. Sets the text alignment to right and its style to italic.
/// -> content
#let dedication(body) = {
  _document-state.update("DEDICATION")
  pagebreak()

  body
}

/// Acknowledgements section. It sets page numbering to `"i"`.
/// -> content
#let acknowledgements(body) = {
  _document-state.update("ACKNOWLEDGEMENTS")
  set page(numbering: "i", footer: context align(center, counter(page).display()))

  body
}

/// Mainmatter section. Similar to LaTeX's ```tex \mainmatter```. It sets to page numbering
/// to `"1"`, heading numbering to ```typc "1.1"``` and resets the page counter.
/// -> content
#let mainmatter(body) = {
  _document-state.update("MAINMATTER")
  set page(numbering: "1")
  set heading(numbering: "1.1")
  counter(page).update(1)

  body
}

/// Appendix section. Similar to LaTeX's ```tex \appendix```. It sets heading numbering
/// to ```typc"A.1"``` and resets their counter.
/// -> content
#let appendix(body) = {
  _document-state.update("APPENDIX")
  counter(heading).update(0)
  set heading(numbering: "A.1")

  body
}

/// Backmatter section. Similar to LaTeX's ```tex \backmatter``.  It sets heading numbering
/// to ```typc none``` and changes the footer format.
/// -> content
#let backmatter(body) = {
  _document-state.update("BACKMATTER")
  set heading(numbering: none)
  set page(footer: context align(center, counter(page).display()))

  body
}

// Table of Contents settings

/// Custom table of contents. It displays ```typc outline()``` as if it were a normal
/// lvl. 1 heading.
/// -> content
#let toc = context {
  outline(
    title: heading(
      // outlined: true,
      bookmarked: true,
      numbering: none,
      text(
        size: 22pt,
        _localization.at(text.lang).toc,
      ),
    ),
    // indent: 1em,
  )
}

/// Internal helper function to create the custom lists of figures and table.
/// -> content
#let _lists-entries-style(
  /// Outline entry to edit.
  /// -> outline-entry
  outline-entry,
  /// The kind of the outline entry element (image or table).
  /// -> function
  kind,
) = {
  // don't print figures without caption
  if outline-entry.element.at("caption") == none { return }
  let count = (
    str(counter(heading.where(level: 1)).at(outline-entry.element.location()).at(0))
      + "."
      + str(counter(figure.where(kind: kind)).at(outline-entry.element.location()).at(0))
  )
  link(outline-entry.element.location(), {
    count
    h(1em)
    outline-entry.element.at("caption").body
    box(width: 1fr, repeat([\u{0009} \u{0009} . \u{0009}])) // \u{0009} = Tab
    str(counter(page).at(outline-entry.element.location()).at(0))
  })
  linebreak()
}

/// List of figures. Similar to LaTeX's ```tex \listoffigures```.
/// -> content
#let list-of-figures = {
  show outline.entry: it => {
    _lists-entries-style(it, image)
  }
  outline(
    title: context heading(
      // outlined: true,
      bookmarked: true,
      numbering: none,
      text(
        size: 22pt,
        _localization.at(text.lang).list-of-figures,
      ),
    ),
    indent: 1.2em,
    target: figure.where(kind: image),
  )
}

/// List of tables. Similar to LaTeX's ```tex \listoftables```.
/// -> content
#let list-of-tables = {
  show outline.entry: it => {
    _lists-entries-style(it, table)
  }
  outline(
    title: context heading(
      // outlined: true,
      bookmarked: true,
      numbering: none,
      text(
        size: 22pt,
        _localization.at(text.lang).list-of-tables,
      ),
    ),
    indent: 1.2em,
    target: figure.where(kind: table),
  )
}


/// Ready-made laboratories.
/// -> dictionary
#let laboratories = yaml("resources/laboratories.yaml")

/// Display the laboratory involved in the thesis development.
/// -> content
#let closingpage(
  /// Name of the laboratory.
  /// -> string
  name: "Name",
  /// URL of the laboratory.
  /// -> string
  url: "https://laboratory.url",
  /// Logo of the laboratory.
  /// -> image
  logo: none,
) = context {
  set page(footer: none)
  set align(center)
  v(1fr)

  if logo == none {
    block(
      inset: 0.5em,
      stroke: black,
      align(
        center + horizon,
        "LAB\nLOGO",
      ),
    )
  } else {
    if type(logo) == str {
      image(height: 25mm, logo)
    } else {
      logo
    }
  }

  _localization.at(text.lang).lab-prefix + " "
  name + linebreak()
  // laboratories.at(name).company + linebreak()
  link(url)
}
