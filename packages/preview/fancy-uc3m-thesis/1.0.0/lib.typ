#import "@preview/hydra:0.6.3": hydra
#import "@preview/glossarium:0.5.10": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)

#import "titlepage.typ": titlepage
#import "locale.typ" as locale
#import "utils.typ": *
#import "arguments.typ": validate-argument
#import "generative-ai.typ": genai-template

// wrapper to prevent shadowing
#let bibliography-fn = bibliography

/// Main configuration function.
///
/// Recommended to use with `#show: conf.with(...)`.
///
/// - title (str): Title of the thesis.
/// - author (str): Author name.
/// - degree (str): Degree name (e.g. `"Computer Science and Engineering"`).
/// - advisors (array): List of advisor names.
/// - location (str): Presentation location.
/// - thesis-type (str): Type of thesis (`"TFG"` or `"TFM"`).
/// - date (datetime): Presentation date.
/// - bibliography-content (content): Bibliography contents, usually obtained by calling `bibliography`.
/// - language (str): `"en"` or `"es"`.
/// - format (str): Thesis format, either `"apa"` or `"ieee"`.
/// - style (str): Visual style, mainly affecting headings, headers, and footers. The available styles are `strict`, which strictly follow's the university library's guidelines, `clean`, based on clean-dhbw, and `fancy`, based on my original LaTeX version.
/// - titlepage-style (str, auto): Style for the titlepage (see `style`). If set to `auto`, uses the main style.
/// - table-style (str, auto): Style for the table caption, either `"clean"`, `"apa"`, or `"ieee"`. If set to `auto`, uses the default for the main style (`"clean"` for `clean` style, `format` for the rest).
/// - figure-style (str, auto): Style for the figure caption, either `"clean"`, `"apa"`, or `"ieee"`. If set to `auto`, uses the default for the main style (`"clean"` for `clean` style, `format` for the rest).
/// - figure-spacing (length, none): Extra spacing to give to figures and tables. If `none`, no extra spacing.
/// - font (string, auto): Font to use. By default, `"Libertinus Serif`" in all styles except `"strict"`, where it's `"Times New Roman"`. Can't be set with the `"strict"` style.
/// - font-titlepage-size (lenght): Font size in the titlepage. Useful when messing with the `font` parameter.
/// - double-sided (bool): Whether to use double-sided pages. This is not allowed in the `strict` style.
/// - logo (str): Type of logo (`"old"` or `"new"`).
/// - short-title (str): Shorter version of the title, to be displayed in the headers. Only applies if `double-sided` is set to `true`.
/// - date-format (str, auto): Date format. Use `auto` or specify the format using the [Typst format syntax](https://typst.app/docs/reference/foundations/datetime/#format).
/// - license (bool): Whether to include the CC BY-NC-ND 4.0 license.
/// - flyleaf (bool): Whether to include a blank page after the cover.
/// - epigraph (dictionary, none): A short quote that guided you through the writting of the thesis, your degree, or your life. Consists of `quote` (of type `content`), the body or text itself, `author` (of type `str`), the author of the quote and, optionally, `source` (of type `str`), where the quote was found.
/// - abstract (dictionary): A short and precise representation of the thesis content. Consists of `body` (of type `content`), the main text, and `keywords`, an array of key terms (of type `str`) (see [IEEE Taxonomy](https://www.ieee.org/content/dam/ieee-org/ieee/web/org/pubs/ieee-taxonomy.pdf)).
/// - english-abstract (dictionary): An english translation of the abstract. Compulsory for spanish works, invalid for english ones.
/// - acknowledgements (content, none): Text where you give thanks to everyone that helped you.
/// - outlines (dictionaty, none): Set of extra outlines to include (`figures`, `tables`, `listings`), and extra custom outlines (`custom`, an array of `content`s -- typically the result of calling `outline`).
/// - abbreviations (dictionary, content, none): Abbreviations, acronyms and initials used throughout the thesis. You can provide a map (dictionary of strings) or a custom one (`content`).
/// - appendixes (content, none): Set of appendixes.
/// - glossary (array, content, none): Glossary entries. If `array` is provided, it will use the `glossarium` library. If content is passed, it will display that content, without applying any styling.
/// - genai-declaration (dictionary, content): Information about the use of Generative AI in the thesis. You can suply your own `content`, or use the university's template, by suplying a `dictionary`. See the example for more details.
/// - doc (content): Thesis contents.
///
/// -> content
#let conf(
  title: none,
  author: none,
  degree: none,
  advisors: none,
  location: none,
  thesis-type: none,
  date: none,
  bibliography-content: none,
  language: none,
  format: none,
  style: "fancy",
  titlepage-style: auto,
  table-style: auto,
  figure-style: auto,
  figure-spacing: 0.75em,
  font: auto,
  font-titlepage-size: 16pt,
  double-sided: false,
  logo: "new",
  short-title: none,
  date-format: auto,
  license: true,
  flyleaf: true,
  epigraph: none,
  abstract: none,
  english-abstract: none,
  acknowledgements: none,
  outlines: none,
  appendixes: none,
  glossary: none,
  abbreviations: none,
  genai-declaration: none,
  doc,
) = {
  // ========================= ARGUMENT VALIDATION ========================== //

  validate-argument("title", title, target-type: str)

  validate-argument("author", author, target-type: str)

  validate-argument("degree", degree, target-type: str)

  validate-argument(
    "advisors",
    advisors,
    target-type: ((array, str),),
    min-len: 1,
  )

  validate-argument("location", location, target-type: str)

  validate-argument(
    "thesis-type",
    thesis-type,
    possible-values: ("TFG", "TFM"),
  )

  validate-argument("date", date, target-type: datetime)

  validate-argument(
    "bibliography",
    bibliography-content,
    optional: true,
    target-type: (str, content),
  )

  validate-argument("language", language, possible-values: ("es", "en"))

  validate-argument(
    "format",
    format,
    possible-values: ("apa", "ieee"),
  )

  validate-argument(
    "style",
    style,
    possible-values: ("fancy", "clean", "strict"),
  )

  validate-argument(
    "titlepage-style",
    titlepage-style,
    possible-values: (auto, "fancy", "clean", "strict"),
  )

  validate-argument(
    "table-style",
    table-style,
    possible-values: (auto, "ieee", "apa", "clean"),
  )

  assert(
    not (table-style == "clean" and style == "strict"),
    message: "'strict' style doesn't allow for 'table-style' to be set to 'clean'.",
  )

  if table-style == auto {
    table-style = if style == "clean" { "clean" } else { format }
  }

  validate-argument(
    "figure-style",
    figure-style,
    possible-values: (auto, "apa", "ieee", "clean"),
  )

  assert(
    not (figure-style == "clean" and style == "strict"),
    message: "'strict' style doesn't allow for 'figure-style' to be set to 'clean'.",
  )

  if figure-style == auto {
    figure-style = if style == "clean" { "clean" } else { format }
  }

  validate-argument("figure-spacing", figure-spacing, target-type: (
    length,
    none,
  ))

  validate-argument("double-sided", double-sided, target-type: bool)

  assert(
    not (double-sided and style == "strict"),
    message: "'strict' style doesn't allow for 'double-sided' to be set to `true`.",
  )

  if font == auto {
    font = if style == "strict" {
      "Times New Roman"
    } else { "Libertinus Serif" }
  }

  validate-argument("font", font, target-type: str)

  assert(
    not (font != auto and style == "strict"),
    message: "'strict' style doesn't allow for 'font' to be set.",
  )

  validate-argument(
    "font-titlepage-size",
    font-titlepage-size,
    target-type: (length),
  )

  validate-argument("logo", logo, possible-values: ("new", "old"))

  validate-argument(
    "short-title",
    short-title,
    optional: true,
    target-type: (str, content),
  )

  validate-argument("license", license, target-type: bool)

  validate-argument("flyleaf", flyleaf, target-type: bool)

  validate-argument(
    "epigraph",
    epigraph,
    optional: true,
    target-type: dictionary,
    schema: (
      quote: (target-type: content),
      author: (target-type: str),
      source: (target-type: str, optional: true),
    ),
  )

  validate-argument(
    "abstract",
    abstract,
    target-type: dictionary,
    schema: (
      body: (target-type: content),
      keywords: (target-type: ((array, str),), min-len: 2, max-len: 5),
    ),
  )

  assert(
    not (language == "es" and english-abstract == none),
    message: "`english-abstract` is required for spanish reports",
  )
  assert(
    not (language == "en" and english-abstract != none),
    message: "`english-abstract` is not needed for english reports",
  )

  validate-argument(
    "english-abstract",
    english-abstract,
    target-type: if language == "es" { dictionary } else { none },
    optional: language == "en",
    schema: (
      body: (target-type: content),
      keywords: (target-type: ((array, str),), min-len: 2, max-len: 5),
    ),
  )

  validate-argument(
    "acknowledgements",
    acknowledgements,
    optional: true,
    target-type: content,
  )

  validate-argument(
    "outlines",
    outlines,
    optional: true,
    target-type: dictionary,
    schema: (
      figures: (target-type: bool, optional: true),
      tables: (target-type: bool, optional: true),
      listings: (target-type: bool, optional: true),
      custom: (target-type: ((array, content),), optional: true),
    ),
  )

  validate-argument(
    "abbreviations",
    abbreviations,
    optional: true,
    target-type: ((dictionary, str), content),
  )

  validate-argument(
    "appendixes",
    appendixes,
    optional: true,
    target-type: content,
  )

  validate-argument(
    "glossary",
    glossary,
    optional: true,
    target-type: ((array, dictionary), content),
    schema: (
      content: (target-type: content),
      config: (target-type: function, optional: true),
    ),
  )

  validate-argument(
    "genai-declaration",
    genai-declaration,
    target-type: (content, dictionary),
    schema: (
      usage: (target-type: bool),
      data-usage: (
        target-type: dictionary,
        optional: type(genai-declaration) == dictionary
          and not genai-declaration.usage,
        schema: (
          // true  = YES / used with authorization
          // false = NO  / not used
          confidential: (target-type: bool),
          copyright: (target-type: bool),
          personal: (target-type: bool),
          tos: (target-type: bool),
        ),
      ),
      technical-usage: (
        target-type: dictionary,
        optional: type(genai-declaration) == dictionary
          and not genai-declaration.usage,
        schema: (
          documentation: (target-type: content, optional: true),
          review: (target-type: content, optional: true),
          research: (target-type: content, optional: true),
          references: (target-type: content, optional: true),
          summary: (target-type: content, optional: true),
          translation: (target-type: content, optional: true),
          assistance-coding: (target-type: content, optional: true),
          generating-content: (target-type: content, optional: true),
          optimization: (target-type: content, optional: true),
          data-processing: (target-type: content, optional: true),
          idea-inspiration: (target-type: content, optional: true),
          other: (target-type: content, optional: true),
        ),
      ),
      usage-reflection: (
        target-type: content,
        optional: type(genai-declaration) == dictionary
          and not genai-declaration.usage,
      ),
    ),
  )

  // ============================ DOCUMENT SETUP ============================ //
  set document(
    title: title,
    author: author,
    description: abstract.body,
    keywords: abstract.keywords,
    date: date,
  )

  // ============================== PAGE SETUP ============================== //

  let in-frontmatter = state("in-frontmatter", false) // to control page number format in frontmatter
  let in-endmatter = state("in-endmatter", false) // to control page number format in endmatter
  let in-body = state("in-body", false) // to control heading formatting in/outside of body
  let in-appendix = state("in-appendix", false) // to control heading formatting in the appendixes

  let accent-color = if style == "strict" { black } else { azuluc3m }

  /* TEXT */

  set text(size: 12pt, lang: language, font: font)

  set par(
    leading: if style == "strict" { 7pt } else { 8pt },
    spacing: 1.15em,
    first-line-indent: 1.8em,
    justify: true,
  )

  /* HEADINGS */

  set heading(numbering: if style == "clean" { "1.1" } else { "1." })

  // set correct supplement for chapters
  show heading.where(level: 1): set heading(
    supplement: locale.CHAPTER.at(language),
  )

  show heading: set text(
    accent-color,
    font: font,
  )

  show heading: it => {
    if style == "clean" {
      if (it.level >= 4) {
        [
          #v(16pt)
          #smallcaps(
            text(
              size: 11pt,
              weight: "semibold",
              fill: accent-color,
              it.body,
            ),
          )
        ]
      } else {
        set par(leading: 4pt, justify: false)
        text(it, top-edge: 0.75em, bottom-edge: -0.25em, fill: accent-color)
      }
      v(16pt, weak: true)
    } else if style == "fancy" {
      set block(above: 1.4em, below: 1em)
      it
    } else if style == "strict" {
      set block(above: 1.15em, below: 1.15em)
      text(it, size: 12pt, weight: "bold")
    } else { it }
  }

  // fancy headings for chapters
  show heading.where(level: 1): it => {
    // reset figure counters so they are counted per chapter
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)

    // chapter on new page
    newpage(double-sided)

    if style == "strict" {
      set align(center)
      text(upper(it), size: 14pt, weight: "bold")
      v(1.15em)
      return
    }

    if in-frontmatter.get() or in-endmatter.get() {
      /* frontmatter / endmatter */

      if style == "clean" {
        v(32pt) + text(size: 32pt, fill: accent-color, weight: "bold", it)
      } else if style == "fancy" {
        set align(center)
        box(
          stroke: (top: accent-color + 1.8pt),
          width: 100%,
          height: 2em,
          inset: (top: 1.5em),
          { text(size: 24pt, upper(it)) },
        )
        v(3em)
      } else { it }
    } else {
      /* document */

      if style == "clean" {
        set par(leading: 0pt, justify: false)
        pagebreak()
        context {
          if in-body.get() {
            v(160pt)
            place(
              // place heading number prominently at the upper right corner
              top + right,
              dx: 9pt, // slight adjustment for optimal alignment with right margin
              text(
                counter(heading).display(),
                top-edge: "bounds",
                size: 160pt,
                weight: 900,
                accent-color.lighten(70%),
              ),
            )
            text(
              // heading text on separate line
              it.body,
              size: 40pt,
              fill: accent-color,
              weight: "bold",
              top-edge: 0.75em,
              bottom-edge: -0.25em,
            )
          } else {
            // appendix
            v(32pt)
            text(
              size: 32pt,
              fill: accent-color,
              weight: "bold",
              counter(heading).display() + h(0.5em) + it.body,
            )
          }
        }
      } else if style == "fancy" {
        box(
          width: 100%,
          inset: (top: 5.5em, bottom: 5em),
          {
            // chapter number
            box(
              width: 100%,
              stroke: (top: accent-color + 1.8pt, bottom: accent-color + 1.8pt),
              inset: (top: 1.5em, bottom: 1.5em),
              {
                set align(center)
                text(
                  size: 24pt,
                  {
                    upper(if in-body.get() {
                      locale.CHAPTER.at(language)
                    } else if in-appendix.get() {
                      locale.APPENDIX.at(language)
                    })

                    sym.space.nobreak

                    let count = counter(heading).get().first()
                    let image = numbering(heading.numbering, count)
                    if image.last() == "." {
                      image = image.slice(0, image.len() - 1)
                    }

                    image
                  },
                )
              },
            )

            // chapter name
            box(
              width: 100%,
              inset: (top: 0.2em),
              {
                set align(center)
                set text(accent-color)
                set par(justify: false)
                text(upper(it.body), size: 24pt, weight: "semibold")
              },
            )
          },
        )
      }
    }
  }

  show heading.where(level: 2): it => {
    if style == "clean" { v(16pt) + text(size: 16pt, it) } else { it }
  }
  show heading.where(level: 3): it => {
    if style == "clean" { v(16pt) + text(size: 11pt, it) } else { it }
  }

  /* EQUATIONS */

  // show chapter on numbering
  set math.equation(numbering: (..num) => numbering(
    if in-appendix.get() { "(A.1)" } else { "(1.1)" },
    counter(heading).get().first(),
    num.pos().first(),
  ))

  /* FIGURES */

  // more space around figures
  // https://stackoverflow.com/questions/78622060/add-spacing-around-figure-in-typst
  show figure.where(kind: image).or(figure.where(kind: table)): it => {
    if figure-spacing == none {
      return it
    }

    if it.placement == none {
      block(it, inset: (y: figure-spacing))
    } else {
      place(
        it.placement,
        float: true,
        clearance: figure-spacing,
        block(align(center, it), spacing: figure-spacing, width: 100%),
      )
    }
  }

  // figure captions
  show figure.caption: it => {
    set text(size: 10pt)
    set par(first-line-indent: 0pt)
    if style == "strict" { it } else {
      [
        #set text(accent-color, weight: "semibold")
        #it.supplement #context it.counter.display(it.numbering)#it.separator
      ]
      it.body
    }
  }

  // show chapter on numbering
  set figure(numbering: (..num) => numbering(
    if in-appendix.get() { "A.1" } else { "1.1" },
    counter(heading).get().first(),
    num.pos().first(),
  ))

  /* IMAGES */

  // caption position
  show figure.where(kind: image): set figure.caption(
    position: if figure-style == "apa" { top } else { bottom },
    separator: if figure-style == "ieee" [.] else { auto },
  )
  show figure.caption.where(kind: image): set align(if figure-style == "clean" {
    center
  } else { left })

  // supplement
  show figure.where(kind: image): set figure(
    supplement: if figure-style == "ieee" {
      "Fig."
    } else { auto },
    gap: { 1em },
  )

  show figure.caption.where(kind: image): it => {
    if figure-style == "apa" {
      set align(start)
      {
        set text(
          fill: accent-color,
          weight: if style == "strict" { "regular" } else { "semibold" },
        )
        it.supplement
        [ ]
        context smallcaps(it.counter.display(it.numbering))
      }
      linebreak()
      set text(weight: "regular")
      emph(it.body)
    } else { it }
  }

  /* TABLES */

  // separator
  show figure.where(kind: table): set figure.caption(
    position: top,
    separator: if table-style == "ieee" {
      [.]
      h(1em)
    } else { auto },
  )

  show figure.caption.where(kind: table): it => {
    if table-style == "ieee" {
      {
        set text(
          fill: accent-color,
          weight: if style == "strict" { "regular" } else { "semibold" },
        )
        smallcaps(it.supplement)
        [ ]
        smallcaps(it.counter.display(it.numbering))
      }
      linebreak()
      set text(weight: "regular")
      smallcaps(it.body)
    } else if table-style == "apa" {
      set align(start)
      {
        set text(
          fill: accent-color,
          weight: if style == "strict" { "regular" } else { "semibold" },
        )
        it.supplement
        [ ]
        context smallcaps(it.counter.display(it.numbering))
      }
      linebreak()
      set text(weight: "regular")
      emph(it.body)
    } else { it }
  }

  /* REFERENCES & LINKS */

  show ref: set text(accent-color)
  show link: set text(accent-color)

  /* LISTS */

  // indent lists
  set list(indent: 1em)
  set enum(indent: 1em)

  /* FOOTNOTES */

  // change line color
  set footnote.entry(separator: line(
    length: 30% + 0pt,
    stroke: 0.5pt + accent-color,
  ))

  // change footnote number color
  show footnote: set text(accent-color) // in text
  show footnote.entry: it => {
    // in footnote
    h(1em) // indent
    {
      set text(accent-color)
      super(str(counter(footnote).at(it.note.location()).at(0))) // number
    }
    h(.05em) // mini-space in between number and body (same as default)
    it.note.body
  }

  /* PAGE LAYOUT */

  set page(
    paper: "a4",
    margin: if double-sided {
      (y: 2.5cm, inside: 3cm, outside: 2.5cm)
    } else { (y: 2.5cm, x: 3cm) },

    /* header */
    header: context {
      if style == "strict" {
        // no header
        return
      }

      if (
        (style == "clean" and not in-appendix.get())
          or (style == "fancy" and in-body.get() and not is-chapter-start())
      ) {
        // show header
        set text(accent-color)
        if double-sided and calc.even(here().page()) {
          counter(page).display()
          h(1fr)
          smallcaps({ if short-title != none { short-title } else { title } })
        } else {
          // chapter title
          if style == "clean" {
            // just name
            hydra(
              1,
              display: (_, it) => {
                // hydra should already do this... but alas...
                if not is-chapter-start() {
                  smallcaps(it.body)
                }
              },
              use-last: true,
              skip-starting: true,
              book: double-sided,
            )
          } else if style == "fancy" {
            // name and number
            smallcaps([#locale.CHAPTER.at(language) #hydra(1)])
          }
          h(1fr)
          counter(page).display("1") // arabic page numbers for the rest of the document
        }

        v(-0.6em)
        line(length: 100%, stroke: 0.4pt + accent-color)
      }
    },

    /* footer */
    footer: context {
      if style == "strict" {
        set align(right)
        if in-frontmatter.get() {
          counter(page).display("I")
        } else if not in-appendix.get() {
          counter(page).display("1")
        }
      } else if style == "fancy" {
        set align(center)
        set text(accent-color)

        if in-frontmatter.get() {
          counter(page).display("i") // roman page numbers for the frontmatter
        } else if (
          (in-endmatter.get() or is-chapter-start()) and not in-appendix.get()
        ) {
          counter(page).display("1") // arabic page numbers for chapter start and endmatter
        }
      }
    },
  )

  // ============================== TITLEPAGE =============================== //

  titlepage(
    author,
    date,
    language,
    title,
    locale.THESIS-TYPE.at(thesis-type).at(language),
    if date-format == auto {
      locale.DATE-FMT.at(language, default: locale.DATE-FMT.at("es"))
    } else {
      date-format
    },
    degree,
    location,
    advisors,
    accent-color,
    if titlepage-style == auto { style } else { titlepage-style },
    font-size: font-titlepage-size,
    logo-type: logo,
    license: license,
  )

  newpage(double-sided, weak: false)

  if flyleaf { make-flyleaf(double-sided) }

  // ============================= FRONTMATTER ============================== //

  in-frontmatter.update(true)

  /* EPIGRAPH */

  if epigraph != none {
    set quote(block: true)
    set page(header: none, footer: none) // clean page

    grid(
      columns: (1fr, 1fr),
      rows: (1fr, 1fr, 1fr),
      // first (empty) row
      [], [],
      [],
      quote(attribution: {
        strong({
          epigraph.author
          if epigraph.keys().contains("source") [, #emph(epigraph.source)]
        })
      })[#emph(epigraph.quote)],
    )

    newpage(double-sided)
  }

  /* ABSTRACT */

  let make-abstract(data, language) = {
    set text(lang: language)
    heading(locale.ABSTRACT.at(language), numbering: none, outlined: false)

    // wrap in block to remove first-line indent
    // see
    // https://forum.typst.app/t/how-to-remove-a-first-line-indent-of-a-paragraph-after-the-centered-text/1128/2
    block(data.body)

    v(1fr)
    [*#locale.KEYWORDS.at(language):* #data.keywords.join(" • ")]
  }

  make-abstract(abstract, language)

  // english abstract
  if english-abstract != none {
    newpage(double-sided)
    make-abstract(english-abstract, "en")
  }

  /* ACKNOWLEDGEMENTS */

  if acknowledgements != none {
    heading(
      locale.ACKNOWLEDGEMENTS.at(language),
      numbering: none,
      outlined: false,
    )
    block(acknowledgements)
  }

  /* OUTLINES */

  // disable footnotes
  show outline: it => {
    set footnote.entry(separator: none)
    show footnote.entry: hide
    show ref: none
    show footnote: none
    it
  }

  set outline.entry(fill: repeat([.], gap: 2pt))

  /// Formats an outline entry.
  ///
  /// - it (content): Outline entry.
  /// - prefix (auto, content): Entry prefix (e.g. `[Chapter 1]`). If `auto`, default prefix.
  /// - body (auto, content): Entry body (e.g. `[My chapter]`). If `auto`, default body.
  /// - fill (boolean): When `true`, add dots between the body and the page number.
  /// - page (boolean): When `true`, shows the page number.
  /// - above (auto, fraction, relative): The spacing between this block and its predecessor (`block.above`).
  /// - spacing (auto, fraction, relative): The spacing around the block (`block.spacing`). When `auto`, inherits the paragraph spacing.
  /// - text-size (auto, lenght): Text size. When `auto`, default text size. (`text.size`)
  /// - text-weight (int, str): Text weight (`text.weight`).
  /// - color (color): Entry text color. Includes link color.
  /// - indented (boolean): Whether to indent the entry.
  /// - justified (boolean): When `false`, wraps the entry in a `block` to prevent justification.
  /// -> content
  let _outline-entry-formatter(
    it,
    prefix: auto,
    body: auto,
    fill: true,
    page: true,
    above: auto,
    spacing: auto,
    text-size: auto,
    text-weight: "regular",
    color: black,
    indented: true,
    justified: true,
  ) = context {
    set block(spacing: spacing, above: above)
    set text(
      weight: text-weight,
      size: if text-size == auto { text.size } else { text-size },
      fill: accent-color,
    )
    show link: set text(color) // reset link color

    let entry-prefix = if prefix == auto { it.prefix() } else { prefix }

    let entry-body = {
      // body
      if body == auto { it.body() } else { body }

      // fill
      sym.space.nobreak
      box(width: 1fr, if fill { it.fill } else {})
      sym.space.en

      // page
      if page { it.page() }
    }

    let justified-wrapper = if not justified { block } else { x => { x } }

    justified-wrapper(
      link(
        it.element.location(), // make entry linkable
        {
          if indented {
            it.indented(
              entry-prefix,
              entry-body,
            )
          } else {
            entry-prefix
            entry-body
          }
        },
      ),
    )
  }

  // top-level outline entries
  show outline.entry.where(level: 1): it => {
    // non-TOC outlines
    if it.element.func() != heading {
      return _outline-entry-formatter(it, color: black)
    }

    // TOC outlines

    let is-appendix = it.element.supplement == [#locale.APPENDIX.at(language)]

    let common-configs = (
      fill: false,
      page: not is-appendix, // don't show page number for appendixes
    )

    if style == "strict" {
      _outline-entry-formatter(
        it,
        spacing: 1.5em,
        above: 1.5em,
        body: upper(it.body()),
        ..common-configs,
      )
    } else if style == "clean" {
      _outline-entry-formatter(
        it,
        above: 2em,
        text-weight: "semibold",
        color: accent-color,
        ..common-configs,
      )
    } else if style == "fancy" {
      _outline-entry-formatter(
        it,
        above: 1.3em,
        text-size: 13pt,
        text-weight: "semibold",
        color: accent-color,
        justified: false,
        indented: false,
        prefix: {
          // add full name
          if it.prefix() != none {
            if regex("\d+") in it.prefix().text {
              // chapter
              locale.CHAPTER.at(language)
              sym.space.nobreak
              it.prefix()
            } else {
              // appendix
              locale.APPENDIX.at(language)
              sym.space.nobreak
              it.prefix()
            }
            sym.space.nobreak
          } else {
            none
          }
        },
        ..common-configs,
      )
    }
  }

  // other TOC entries in regular with adapted filling
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => {
    _outline-entry-formatter(
      it,
      above: if style == "strict" { auto } else { 0.8em },
    )
  }

  // contents
  outline(title: locale.OUTLINE.at("contents").at(language), depth: 3)
  newpage(double-sided)

  if outlines != none {
    // figures
    if outlines.at("figures", default: false) {
      outline(
        title: locale.OUTLINE.at("figures").at(language),
        target: figure.where(kind: image),
      )
      newpage(double-sided)
    }

    // tables
    if outlines.at("tables", default: false) {
      outline(
        title: locale.OUTLINE.at("tables").at(language),
        target: figure.where(kind: table),
      )
      newpage(double-sided)
    }

    // listings
    if outlines.at("listings", default: false) {
      outline(
        title: locale.OUTLINE.at("listings").at(language),
        target: figure.where(kind: raw),
      )
      newpage(double-sided)
    }

    // custom
    if outlines.at("custom", default: none) != none {
      for o in outlines.at("custom") {
        o
        newpage(double-sided)
      }
    }
  }

  /* ABBREVIATIONS */

  if abbreviations != none {
    heading(
      locale.ABBREVIATIONS.at(language),
      numbering: none,
      outlined: false,
    )

    if type(abbreviations) == dictionary {
      // table w/out borders
      set align(center)
      box(
        width: 80%,
        table(
          columns: (1fr, 2fr), // full page width
          stroke: none,
          align: left,
          ..abbreviations.pairs().sorted(key: ((abbr, _full)) => abbr).flatten()
        ),
      )
    } else if type(abbreviations) == content {
      // custom
      abbreviations
    }

    newpage(double-sided)
  }

  in-frontmatter.update(false)

  // ============================ DOCUMENT BODY ============================= //

  in-body.update(true)
  counter(page).update(1) // first chapter starts at page 1

  // Initialize glossary support before rendering the document body so
  // references like `#gls("key-name")` inside `doc` can resolve.
  // Moved to glossary.typ
  show: make-glossary
  if glossary != none and type(glossary) == array {
    register-glossary(glossary)
  }

  doc

  // ============================== ENDMATTER =============================== //

  newpage(double-sided, weak: false)
  in-body.update(false)
  in-endmatter.update(true)

  /* BIBLIOGRAPHY */

  // color bibliography
  // https://forum.typst.app/t/how-do-i-customize-the-numbering-of-the-bibliography/1490/3
  show selector(bibliography-fn).or(cite): it => {
    show link: set text(accent-color)

    // bibliography references (IEEE)
    show regex("\[\d+\]"): num => {
      set text(accent-color)
      num
    }
    it
  }

  if bibliography-content != none {
    bibliography-content
  }

  /* GLOSSARY */

  if glossary != none {
    heading(
      locale.GLOSSARY.at(language),
      numbering: none,
    )
    if type(glossary) == array {
      show: make-glossary

      print-glossary(glossary)
    } else if type(glossary) == content {
      glossary
    }
  }

  // ============================== APPENDIXES ============================== //

  // we need to start a new page so `in-appendix` doesn't affect the
  // bibliography
  newpage(double-sided, weak: true)

  in-endmatter.update(false)
  in-appendix.update(true)

  set heading(
    // don't show numbering for headings above level 1
    numbering: (..n) => { if n.pos().len() == 1 { numbering("A", ..n) } },
    outlined: false, // not in outline
  )
  show heading.where(level: 1): set heading(
    // configure supplement
    supplement: locale.APPENDIX.at(language),
    // show just appendixes titles in outline
    outlined: true,
    numbering: "A.",
  )

  counter(heading).update(0)

  if appendixes != none { appendixes }

  /* generative AI declaration */
  [= #locale.AI-USAGE.title.at(language) <apx:genai>]

  if type(genai-declaration) == content {
    // custom
    genai-declaration
  } else {
    genai-template(
      language,
      style,
      genai-declaration.at("usage", default: none),
      genai-declaration.at("data-usage", default: none),
      genai-declaration.at("technical-usage", default: none),
      genai-declaration.at("usage-reflection", default: none),
    )
  }

  // we _would_ need to set this on a new page,
  // but as there are none, it's not needed
  // in-appendix.update(false)
}
