// NAME: Minimal Books
// REQ: numbly, transl
// TODO: Implement ePub output when available

#import "additional/notes.typ": note
#import "additional/ambient.typ": appendices, annexes
#import "additional/horizontalrule.typ": horizontalrule, hr
#import "additional/blockquote.typ": blockquote

/**#v(1fr)#outline()#v(1.2fr)
#pagebreak()

= Quick Start

```typ
#import "@preview/min-book:1.3.0": book
#show: book.with(
  title: "Book Title",
  subtitle: "Book subtitle, not more than two lines long",
  authors: "Book Author",
)
```

= Description

Generate complete and complex books, without any annoying new commands or
syntax, just good old pure Typst. This package manipulates the standard Typst
elements as much as possible, adapting them to the needs of a book structure
in a way that there's no need to learn a whole new semantic just because of
_min-book_.

For some fancy book features there is no existing compatible Typst element to
re-work and adapt; in those cases, this package do provide additional commands
that are completely optional, for the sake of completeness.

This package comes with some thoughful ready-to-use defaults but also allows
you to play with highly customizable options if you need them, so it's really
up to you: customize it your way or ride along the defaults — both ways are
possible and encouraged.

= Options

These are all the options and its defaults used by _min-book_:

:show.with book:
**/
#let book(
  title: none, /// <- string | content <required>
    /// Main title. |
  subtitle: none, /// <- string | content | none
    /// Subtitle, generally two lines long or less. |
  edition: 0, /// <- int
    /** Publication number, used when the content is changed or updated in a new
        release after the original publication. |**/
  volume: 0, /// <- int
    /** Series volume number, used when one extensive story is told through
        multiple books, in order. |**/
  authors: none, /// <- string | array of strings <required>
    /// Author or authors. |
  date: datetime.today(), /// <- datetime | array | dictionary
    /** `(year, month, day)`\
        Publication date — if a index/key is omitted, fallback to the current one. |**/
  cover: auto, /// <- auto | function | content | image | none
    /** Cover — generated automatically when `auto`. If function, receives two 
        dictionary arguments. |**/
  titlepage: auto, /// <- auto | content | none
    /// Title page, shown after cover — generated automatically when `auto`. |
  catalog: none, /// <- dictionary | yaml | toml
    /// Cataloging-in-publication board, used for library data (see "@catalog"). |
  errata: none, /// <- content | string
    /// A text that corrects errors from previous book editions. |
  dedication: none, /// <- content | string
    /** A brief text that dedicates the book in honor or in memorian of someone
        important; can accompany a small message directed to the person. |**/
  acknowledgements: none, /// <- content | string
    /** A brief text to recognize everyone who helped directly or indirectly in
        the process of book creation and their importance in the project. |**/
  epigraph: none, /// <- quote | content
    /** A short citation or excerpt from other works used to introduce the main
        theme of the book; can suggest a reflection, a mood, or idea related to
        the text. |**/
  toc: true, /// <- boolean | content
    /// Generate a table of contents on the right place. |
  part: auto, /// <- string | none | auto
    /** Name of the main divisions of the book — if not set, fallback to the word
        "Part" in book language. |**/
  chapter: auto, /// <- string | none
    /** The name of the sections of the book — if not set, fallback to the word
        "Chapter" in book language. |**/
  cfg: auto, /// <- dictionary
    /** Custom advanced configurations, used to fine-tune some aspects of the
        book (see "@adv-config"). |**/
  body /// <- content
    /// The book content. |
) = context {
  import "@preview/transl:0.1.0": transl, fluent
  import "utils.typ"
  
  // Required arguments
  assert.ne(title, none)
  assert.ne(authors, none)
  
  let cfg = if cfg == auto {(:)} else {cfg}
  let new-cfg = cfg
  
  cfg.insert("lang", cfg.at("lang", default: text.lang))
  if not utils.std-langs.contains(cfg.lang) {
    if cfg.at("transl", default: "") == "" {
      panic("No translation found for '" + cfg.lang + "', set #book(cfg.transl)")
    }
    else {cfg.lang = "en"}
  }
  
  /**
  = Advanced Configurations <adv-config>
  :arg cfg: "let"
  
  These `#book(cfg)` configurations allows to modify certain aspects of the
  book and manage its appearance and structure. Built with some thoughful
  ready-to-use defaults that make its use optional, so that beginners and
  casual writers can safely ignore it and _just write_.
  **/
  let cfg = (
    numbering: auto, /// <- string | array of strings | none
       /** Custom heading numbering — a standard numbering or a #univ("numbly")
       numbering. |**/
    page: "a5", /// <- dictionary | string
       /** Page configuration — directly set `#page(..cfg.page)` arguments or
       only `#page(paper: cfg.page)` when string. |**/
    lang: text.lang, /// <- string
       /// Book language. |
    transl: read("l10n/" + cfg.lang + ".ftl"), /// <- string | read
       /** Fluent translation file — defaults to the standard translation file
       for book language, if supported (see files inside `/src/l10n/` directory),
       or `#panic`. |**/
    justify: true, /// <- boolean
       /// Text justification. |
    line-space: 0.5em, /// <- length
       /// Space between each line in a paragraph. |
    line-indentfirst: 1em, /// <- length
       /** indentation of the first line of each paragraph in a sequence, except
       the first one. |**/
    par-margin: 0.65em, /// <- length
       /// Space after each paragraph. |
    margin: (x: 15%, y: 14%), /// <- length
       /// Page margin. |
    font-usedefaults: false, /// <- boolean
       /// Use default Typst fonts when no custom font is set. |
    heading-weight: auto, /// <- "regular" | "bold" | auto
       /** Heading font weight (thickness) — defaults to regular only in levels
       1–5, and then bold headings. |**/
    cover-bgcolor: rgb("#3E210B"), /// <- color
       /// Cover background color when `#book(cover: auto)`. |
    cover-txtcolor: luma(200), /// <- color
       /// Cover text color when `#book(cover: auto)`. |
    cover-fonts: ("Cinzel", "Alice"), /// <- array of strings
       /** `(title, text)`\
       Cover font for main title and other texts when `#book(cover: auto)`. |**/
    cover-back: true, /// <- boolean
       /// Generate a back cover at the end of the document when `#book(cover: auto)` |
    toc-stdindent: true, /// <- boolean
       /** Use min-book standard indentation: 1.5em for level 1 and 0em for
       levels 2+. |**/
    toc-bold: true, /// <- boolean
       /// Allows bold fonts in table of contents entries. |
    chapter-numrestart: false, /// <- boolean
       /// Make chapter numbering restart after each book part. |
    two-sided: true, /// <- boolean
       /** Optimizes the content to be printed on both sides of the page (front
       and back), with important elements always starting at the next front
       side (oddly numbered) — inserts blank pages in between, if needed. |**/
    paper-links: true, /// <- boolean
       /** Enable paper-readable links, which inserts the clickable link alongside
       a footnote to its URL. |**/
  )
  // Check if the cfg options received are valid
  for key in new-cfg.keys() {
    if not cfg.keys().contains(key) {
      panic("Invalid cfg." + key + ", can be: " + cfg.keys().join(", "))
    }
  }
  cfg += new-cfg
  
  // Convert cfg.two-sided into a #pagebreak(to) value
  let break-to = if cfg.two-sided {"odd"} else {none}
  utils.storage(add: "break-to", break-to)
  
  cfg.transl = fluent( "file!" + cfg.transl, lang: cfg.lang )
  transl(data: cfg.transl)
  
  let font-size = text.size
  let date = utils.date(date)
  let part = part
  let chapter = chapter
  
  if part == auto {part = transl("part", to: cfg.lang, data: cfg.transl)}
  if chapter == auto {chapter = transl("chapter", to: cfg.lang, data: cfg.transl)}
  if type(cfg.page) == str {cfg.page = (paper: cfg.page)}
  
  /**
  = Advanced Numbering
  
  The book headings can be numbered two ways: using a
  #url("https://typst.app/docs/reference/model/numbering/")[standard]
  numbering string or a #univ("numbly") numbering array. Strings are more
  simple and easy to use, while arrays are more complete and customizable.
  
  By default, _min-book_ uses slightly different numbering when `#book(part)`
  is enabled or disabled, that's why _parts_ and _chapters_ appear to have
  independent numbering when used. The `#book(cfg.numbering)` option
  allow to set a custom numbering used whether `#book(part)` is enabled or
  disabled.
  **/
  let part-pattern = (
    "{1:I}:\n",
    "{2:I}.\n",
    "{2:I}.{3:1}.\n",
    "{2:I}.{3:1}.{4:1}.\n",
    "{2:I}.{3:1}.{4:1}.{5:1}.\n",
    "{2:I}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  )
  let no-part-pattern = (
    "{1:I}.\n",
    "{1:I}.{2:1}.\n",
    "{1:I}.{2:1}.{3:1}.\n",
    "{1:I}.{2:1}.{3:1}.{4:1}.\n",
    "{1:I}.{2:1}.{3:1}.{4:1}.{5:1}.\n",
    "{1:I}.{2:1}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  )
  
  let font = (:)
  if text.font == "libertinus serif" and not cfg.font-usedefaults {
    font = ( font: ("TeX Gyre Pagella", "Book Antiqua") )
  }
  
  set document(
    title: if subtitle != none {title + " - " + subtitle} else {title},
    author: authors,
    date: date
  )
  set page(
    margin: cfg.margin,
    ..cfg.page
  )
  set par(
    justify: cfg.justify,
    leading: cfg.line-space,
    spacing: cfg.par-margin, 
    first-line-indent: cfg.line-indentfirst
  )
  set text(
    lang: cfg.lang,
    ..font
  )
  set terms(
    separator: [: ],
    tight: true,
    hanging-indent: 1em,
  )
  set list(marker: ([•], [–]))
  /**
  = Book Parts
  
  ```typ
  #show: book.with(
    part: "Act",
  )
  = This is a part!  // Act 1
  ```
  
  Some larger books are internally divided into multiple _parts_. This
  structure allows to better organize and understand a text with multiple
  sequential plots, or tales, or time jumps, or anything that internally
  differentiate parts of the story. Each book can set different names for
  them, like parts, subjects, books, acts, units, modules, etc;
  by default, _min-book_ tries to get the word for "Part" in book language as
  its name.
  
  When a value is set, all level 1 headings become _parts_: they occupy the
  entire page and are aligned at its middle; some decorative frame also
  appear when `#book(cover: auto)`.
  
  = Book Chapters
  
  #grid(columns: (auto, auto),
    ```typ
    #show: book.with(
      chapter: "Scene",
    )
    
    == This is a chapter!  // Scene 1 
    ```,
    grid.vline(stroke: gray.lighten(60%)),
    ```typ
    #show: book.with(
      part: none,
      chapter: "Scene",
    )
    = This is a chapter!  // Scene 1
    ```
  )
  
  In most cases, books are divided into smaller sections called chapters.
  Generally, each chapter contains a single minor story, or event, or scene,
  or any type of subtle plot change. Each book can set different names for
  them, like chapters, sections, articles, scenes, etc; by default, _min-book_
  tries to get the word for "Chapter" in book language as its name.
  
  Chapters are smart: when a value is set, if `#book(parts: none)` all level
  1 headings become chapters; otherwise, all level 2 headings become chapters
  — since the level 1 ones are parts.
  **/
  set heading(
    // #utils.numbering set #book(part) and #book(chapter)
    numbering: utils.numbering(
        patterns: (
          cfg.numbering,
          part-pattern,
          no-part-pattern,
        ),
        scope: (
          h1: part,
          h2: chapter
        )
      ),
    hanging-indent: 0pt,
    supplement: it => context {
        if part != none and it.depth == 1 {part}
        else if chapter != none {chapter}
        else {auto}
      }
  )

  // Count every level 2 heading:
  let book-h2-counter = counter("book-h2")
  
  show heading: it => {
    let weight
    if cfg.heading-weight == auto {
      weight = if it.level < 6 {"regular"} else {"bold"}
    }
    else {
      weight = cfg.heading-weight
    }
  
    set align(center)
    set par(justify: false)
    set text(
      hyphenate: false,
      weight: weight,
    )
    
    it
  }
  show heading.where(level: 1, outlined: true): it => {
    // Create part page, if any:
    if part != none {
      // Set page background
      let part-bg = if cover == auto {
          let m = page.margin
          let frame = image(
              width: 93%,
              "assets/frame-gray.svg"
            )
            
          if type(m) != dictionary {
            m = (
              top: m,
              bottom: m,
              left: m,
              right: m
            )
          }
          
          v(m.top * 0.25)
          align(center + top, frame)
          
          align(center + bottom,
            rotate(180deg, frame)
          )
          v(m.bottom * 0.25)
        } else {
          none
        }
        
      if counter(page).get().at(0) != 1 {pagebreak(to: break-to)}
      
      set page(background: part-bg)
      set par(justify: false)
      
      align(center + horizon, it)
      
      set page(background: none)
      pagebreak(to: break-to, weak: true)
      
      if cfg.chapter-numrestart == false {
        // Get the current level 2 heading count:
        let current-h2-count = book-h2-counter.get()
        // Level 2 heading numbering will not restart after level 1 headings now:
        counter(heading).update((h1, ..n) => (h1, ..current-h2-count))
      }
    }
    else {it}
  }
  show heading.where(level: 2): it => {
    if it.numbering != none {book-h2-counter.step()}
    it
  }
  show heading.where(level: 1): set text(size: font-size * 2)
  show heading.where(level: 2): set text(size: font-size * 1.6)
  show heading.where(level: 3): set text(size: font-size * 1.4)
  show heading.where(level: 4): set text(size: font-size * 1.3)
  show heading.where(level: 5): set text(size: font-size * 1.2)
  show heading.where(level: 6): set text(size: font-size * 1.1)
  show quote.where(block: true): set pad(x: 1em)
  show raw: it => {
    let font = (:)
    if text.font == "dejavu sans mono" and not cfg.font-usedefaults {
      font = (font: "Inconsolata")
    }
  
    set text(
      size: font-size,
      ..font
    )
    it
  }
  show raw.where(block: true): it => pad(left: cfg.line-indentfirst, it)
  show math.equation: it => {
    let font = (:)
    if text.font == "new computer modern math" and not cfg.font-usedefaults {
      font = (font: ("Asana Math", "New Computer Modern Math"))
    }
  
    set text(..font)
    it
  }
  show selector.or(
      terms, enum, list, table, figure, math.equation.where(block: true),
      quote.where(block: true), raw.where(block: true)
    ): set block(above: font-size, below: font-size)
  show ref: it => context {
    let el = it.element
    
    // When referencing headings in "normal" form
    if el != none and el.func() == heading and it.form == "normal" {
      let patterns = if cfg.numbering != auto {cfg.numbering}
        else if part != none {part-pattern}
        else {no-part-pattern}
      
      // Remove \n and trim full stops
      if patterns != none and part != "" {
        import "@preview/numbly:0.1.0": numbly

        patterns = patterns.map(
          item => item.replace("\n", "").trim(regex("[.:]"))
        )
        
        let number = numbly(..patterns)(..counter(heading).at(el.location()))
        
        // New reference without \n
        link(el.location())[#el.supplement #number]
      }
      else {link(it.target, el.body)}
    }
    else {it}
  }
  show link: it => {
    // FIXME: Accept content it.body
    if cfg.paper-links and type(it.dest) == str and it.dest != it.body.text {
      it
      footnote(it.dest)
    }
    else {it}
  }
  
  // Insert notes of a section at its end, before next heading:
  import "additional/notes.typ"
  let body = notes.insert(body)
  
  if titlepage == none and catalog != none and cfg.two-sided {
    // Automatic blank titlepage when generating catalog
    titlepage = []
  }

  if cover != none {
    import "components/cover.typ": new
    
    /**
    = Book cover
    
    By default, _min-book_ automatically generates a book cover if `#book(cover)`
    is not set, it's also possible to set a custom cover image or create one
    using Typst code — the default automatic cover (see
    `/src/components/cover.typ`) can be a good start as a base to create a
    custom version. Cover can be a function, in which case it will be invoked with
    the `title`, `subtitle`, `date`, `authors`, `volume` and `cfg` of the book.
    **/
    new(cover, title, subtitle, date, authors, volume, cfg)
    pagebreak(to: break-to)
  }

  if titlepage != none {
    import "components/titlepage.typ": new
    
    new(titlepage, title, subtitle, authors, date, volume, edition)
    if catalog != none {pagebreak()}
    else {pagebreak(to: break-to, weak: true)}
  }

  if catalog != none {
    /**
    = Cataloging in Publication <catalog>
    
    :arg catalog: "let"
    
    These `#book(catalog)` options set the data used to create the
    "cataloging in publication" board. Other needed information are
    automatically retrieved from the book data, but at least one of these
    options must be explicitly set to generate the board; otherwise it will
    be just ignored.
    **/
    // FIXME: accept content #catalog(title)
    let catalog = (
      id: none, /// <- string | content
        /** A #url("http://www.cutternumber.com/")[Cutter-Sanborn identification code,]
        used to identify the book author. |**/
      place: none, /// <- string | content
        /// The city or region where the book was published. |
      publisher: none, /// <- string | content
        /// The organization or person responsible for releasing the book. |
      isbn: none, /// <- string | content
        /// The _International Standard Book Number_, used to identify the book. |
      subjects: (), /// <- array of strings
        /// A list of subjects related to the book. |
      access: (), /// <- array of strings
        /** A list of access points used to find the book in catalogues, like by
        `"Title"` or `"Series"`. |**/
      ddc: none, /// <- string | content
        /** A #url("https://www.oclc.org/content/dam/oclc/dewey/ddc23-summaries.pdf")[Dewey Decimal Classification]
        number, which corresponds to the specific category of the book. |**/
      udc: none, /// <- string | content
        /** An #url("https://udcsummary.info/php/index.php")[Universal Decimal Classification]
        number, which corresponds to the specific category if the book. |**/
      before: none, /// <- content
        /** Content showed before (above) the cataloging in publication board;
        generally shows editorial data like publisher, editors, reviewers,
        copyrights, etc. |**/
      after: none, /// <- content
        /** Content showed after (below) the cataloging in publication board;
        generally shows additional information that complements the board data. |**/
    ) + catalog
    
    import "components/catalog.typ": new
    
    new(catalog, title, subtitle, authors, date, volume, edition)
  }
  
  if errata != none {
    pagebreak(to: break-to, weak: true)
    heading(
      transl("errata"),
      numbering: none,
      outlined: false,
    )
    errata
    pagebreak(to: break-to)
  }
  
  if dedication != none {
    set text(size: font-size - 2pt)
    
    pagebreak(to: break-to, weak: true)
    align(center + horizon, dedication)
    pagebreak(to: break-to)
  }
  
  if acknowledgements != none {
    set par(justify: true)
    
    pagebreak(to: break-to, weak: true)
    // INFO: Acknowledgements without title for now, seems cleaner
    // heading(
    //   transl("thanks"),
    //   numbering: none,
    //   outlined: false,
    // )
    acknowledgements
    pagebreak(to: break-to)
  }
  
  if epigraph != none {
    set align(right + bottom)
    set quote(block: true)
    set text(
      size: font-size - 2pt,
      style: "italic",
    )
    
    pagebreak(to: break-to, weak: true)
    pad(
      epigraph,
      left: 1cm,
    )
    pagebreak(to: break-to)
  }
  
  if toc == true {
    show outline.entry: it => {
      let entry = it.indented(it.prefix(), it.inner(), gap: 0em)
      
      // Emphasize parts in TOC:
      if it.level == 1 and part != none and cfg.toc-bold == true {
        v(font-size, weak: true)
        strong(entry)
      }
      else {entry}
    }
    
    let args = (:)
    
    if cfg.numbering == none {args.insert("depth", 2)}
    if cfg.toc-stdindent == true {
      args.insert("indent", lvl => { if lvl > 0 {1.5em} else {0em} })
    }
    
    pagebreak(to: break-to, weak: true)
    outline(..args)
    pagebreak(weak: true)
  }
  else if type(toc) == content {toc}
  
  // <outline> anchor allows different numbering styles in TOC and in the actual text.
  [#metadata("Marker for situating titles after/before outline") <outline>]
  
  // Start page numbering at the next even page:
  if part != none {pagebreak(weak: true, to: break-to)}
  set page(numbering: "1")
  counter(page).update(1)

  body
  
  if cover == auto and cfg.cover-back {
    let cover-bg = context {
          let m = page.margin
          let frame = image(
              width: 93%,
              "assets/frame.svg"
            )
            
          if type(m) != dictionary {
            m = (
              top: m,
              bottom: m,
              left: m,
              right: m
            )
          }
          
          v(m.top * 0.25)
          align(center + top, frame)
          
          align(center + bottom,
            rotate(180deg, frame)
          )
          v(m.bottom * 0.25)
        }
    
    pagebreak(weak: true, to: break-to)
    page(
      footer: none,
      background: cover-bg,
      fill: cfg.cover-bgcolor,
      []
    )
  }
}

/**
= Additional Commands

These commands are provided as a way to access some fancy book features that
cannot be implemented by re-working and adapting existing Typst elements. They
are completely optional, and is perfectly possible to write an entire book without
using them.
**/