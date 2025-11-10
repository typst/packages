// NAME: Minimal Books
// REQ: numbly
// TODO: Implement ePub output when available

#import "@preview/numbly:0.1.0": numbly

/**
 * = Quick Start
 *
 * ```typ
 * #import "@preview/min-book:1.1.0": book
 * #show: book.with(
 *   title: "Book Title",
 *   subtitle: "Book subtitle, not more than two lines long",
 *   authors: "Book Author",
 * )
 * ```
 * 
 * = Description
 * 
 * Generate complete and complex books, without any annoying new commands or
 * syntax, just good old pure Typst. This package manipulates the standard Typst
 * elements as much as possible, adapting them to the needs of a book structure
 * in a way that there's no need to learn a whole new semantic just because of
 * _min-book_.
 * 
 * For some fancy book features there is no existing compatible Typst element to
 * re-work and adapt; in those cases, this package do provide additional commands
 * that are completely optional, for the sake of completeness.
 * 
 * This package comes with some thoughful ready-to-use defaults but also allows
 * you to play with highly customizable options if you need them, so it's really
 * up to you: customize it your way or ride along the defaults — both ways are
 * possible and encouraged.
 * 
 * #pagebreak()
 * 
 * = Options
 * 
 * These are all the options and its defaults used by _min-book_:
 * 
 * :book: show
**/
#let book(
  title: none,
  /** <- string | content <required>
    * Main title. **/
  subtitle: none,
  /** <- string | content | none
    * Subtitle, generally two lines long or less. **/
  edition: 0,
  /** <- int
    * Publication number, used when the content is changed or updated in a new
    * release after the original publication. **/
  volume: 0,
  /** <- int
    * Series volume number, used when one extensive story is told through
    * multiple books, in order. **/
  authors: none,
  /** <- string | array <required>
    * Author (`string`) or authors (`array` of `strings`). **/
  date: datetime.today(),
  /** <- datetime | array | dictionary
    * Publication date — an array or dictionary `(year, monty, day)` or `datetime`.**/
  cover: auto,
  /** <- auto | content | none
    * Cover — generated automatically (`auto`) or manually (`content`), or no
    * cover (`none`). **/
  titlepage: auto,
  /** <- auto | content | none
    * Title page, shown after cover — generated automatically (`auto`) or
    * manually (`content`). **/
  catalog: none,
  /** <- dictionary | toml | yaml
    * Cataloging in publication board, with library data — see @catalog. **/
  errata: none,
  /** <- content | string
    * A text that corrects errors from previous book editions. **/
  dedication: none,
  /** <- content | string
    * A brief text that dedicates the book in honor or in memorian of someone
    * important — can accompany a small message directed to the person. **/
  acknowledgements: none,
  /** <- content | string
    * A brief text to recognize everyone who helped directly or indirectly in
    * the process of book creation and their importance in the project. **/
  epigraph: none,
  /** <- quote | content
    * A short citation or excerpt of other works used to introduce the main
    * theme of the book; can suggest a reflection, a mood, or idea related to
    * the text. **/
  toc: true,
  /** <- boolean
    * Generate table of contents. **/
  part: auto,
  /** <- auto | string | none
    * Name of the main divisions of the book — set manually (`string`) or
    * defaults to the word "Part" in book language (`auto`). **/
  chapter: auto,
  /** <- string | none
    * The name of the sections of the book — set manually (`string`) or
    * defaults to the word "Chapter" in book language (`auto`). **/
  cfg: auto,
  /** <- dictionary
    * Custom advanced configurations, used to fine-tune some aspects of the
    * book — see @adv-config. **/
  body
  /** <- content
    * The book content.**/
) = {
  import "utils.typ"
  
  utils.required-args(
    title: title,
    authors: authors,
    body: body
  )
  
  /**
   * = Advanced Configurations <adv-config>
   * 
   * :cfg: arg `typc` "(?s)\s*let\s<name>\s=\s\((.*?\n)\s*\.\.<name>,\s*\)\s*\n?\n"
   *
   * These `#book(cfg)` configurations allows to modify certain aspects of the
   * book and manage its appearence and structure. Built with some thoughful
   * ready-to-use defaults that make its use optional, so that beginners and
   * casual writers can safely ignore it and _just write_.
   * 
  **/
  if cfg == auto {cfg = (:)}
  let cfg = (
    numbering-style: auto,
      /** <- array | string | none
        * Custom heading numbering — a standard numbering (`string`) or a
        * #univ("numbly") numbering (`array`). **/
    page: "a5",
      /** <- dictionary | string
        * Page configuration — act as `#set page(..cfg.page)` when `dictionary`
        * or as `#set page(paper: cfg.page)` when `string`. **/
    lang: "en",
      /** <- string
        * Book language. **/
    lang-data: toml("assets/lang.toml"),
      /** <- toml
        * Translation file — see the `src/assets/lang.toml` file. **/
    justify: true,
      /** <- boolean
        * Text justification. **/
    line-space: 0.5em,
      /** <- length
        * Space between each line in a paragraph. **/
    par-margin: 0.65em,
      /** <- length
        * Space after each paragraph. **/
    first-line-indent: 1em,
      /** <- length
        * indentation of the first line of each paragraph in a sequence, except
        * the first one. **/
    margin: (x: 15%, y: 14%),
      /** <- length
        * Page margin. **/
    font: ("Book Antiqua", "Times New Roman"),
      /** <- string | array
        * Text font family, and fallback options (`array`). **/
    font-math: "Asana Math",
      /** <- string | array
        * Math font family, and fallback options (`array`) — see the `README.md`
        * file to download the default font, if needed. **/
    font-mono: "Inconsolata",
      /** <- string | array
        * Monospaced font family, and fallback options (`array`) — see the
        * `README.md` file to download the default font, if needed. **/
    font-size: 11pt,
      /** <- length
        * Text font size. **/
    heading-weight: auto,
      /** <- string | auto
        * Heading font weight (thickness) — set as `"regular"` or `"bold"`,
        * defaults to regular in levels 1–5 then bold (`auto`). **/
    cover-bgcolor: rgb("#3E210B"),
      /** <- color
        * Cover background color when `#book(cover: auto)`. **/
    cover-txtcolor: luma(200),
      /** <- color
        * Cover text color when `#book(cover: auto)`. **/
    cover-fonts: ("Cinzel", "Alice"),
      /** <- array
        * Cover font families when `#book(cover: auto)` — an array `(TITLE, TEXTS)`
        * for title and text fonts, respectively. **/
    cover-back: true,
      /** <- boolean
        * Generate a back cover at the end of the document when `#book(cover: auto)` **/
    toc-indent: none,
      /** <- length | auto | none
        * Indentation of each table of contents entry — by default, all entries
        * of level 2+ are equally indented in 1.5em (`none`). **/
    toc-bold: true,
      /** <- boolean
        * Allows bold fonts in table of contents entries. **/
    chapter-numrestart: false,
      /** <- boolean
        * Make chapter numbering restart after each book part. **/
    two-sided: true,
      /** <- boolean
        * Otimizes the content to be printed on both sides of the page (front
        * and back), with important elements always starting at the next front
        * side (oddly numbered) — inserts blank pages in between, if needed.**/
    link-readable: true,
      /** <- boolean
        * Enable paper-readable links, which inserts the clickable link alongside
        * a footnote to its URL. **/
    ..cfg,
  )

  date = utils.date(date)
  
  // Translate cfg.two-sided into a #pagebreak(to) value
  let break-to = if cfg.two-sided {"odd"} else {none}
  utils.cfg(add: "break-to", break-to)
  
  if type(cfg.page) == str {cfg.page = (paper: cfg.page)}

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
    first-line-indent: cfg.first-line-indent
  )
  set text(
    font: cfg.font,
    size: cfg.font-size,
    lang: cfg.lang
  )
  set terms(
    separator: [: ],
    tight: true,
    hanging-indent: 1em,
  )
  set list(marker: ([•], [–]))
  
  // Set part and chapter translations based on text.lang
  let translation = cfg.lang-data.lang.at(cfg.lang)
  
  // Fallback system when #text.lang not in #book(cfg.lang-data) file
  if translation == none {
    let lang = cfg.lang-data.conf.at("default-lang", default: none)
    translation = cfg.lang-data.at("lang").at(lang)
    
    if translation == none {
      panic("Translation not found for " + cfg.lang + " (fallback failed)")
    }
  }
  utils.cfg(add: "translation", translation)
  
  let part = if part == auto {translation.part} else {part}
  let chapter = if chapter == auto {translation.chapter} else {chapter}
  

  /**
   * = Advanced Numbering
   * 
   * The book headings can be numbered two ways: using a
   * #url("https://typst.app/docs/reference/model/numbering/")[standard]
   * numbering string or a #univ("numbly") numbering array. Strings are more
   * simple and easy to use, while arrays are more complete and customizable.
   * 
   * By default, _min-book_ uses slightly different numbering when `#book(part)`
   * is enabled or disabled, that's why _parts_ and _chapters_ appear to have
   * independent numbering when used. The `#book(cfg.numbering-style)` option
   * allow to set a custom numbering used whether `#book(part)` is enabled or
   * disabled.
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

  /**
   * = Book Parts
   *
   * ```typ
   * #show: book.with(
   *   part: "Act",
   * )
   * = This is a part!  // Act 1
   * ```
   * 
   * Some larger books are internally divided into multiple _parts_. This
   * structure allows to better organize and understand a text with multiple
   * sequential plots, or tales, or time jumps, or anything that internally
   * differentiate parts of the story. Each book can set different names for
   * them, like parts, subjects, books, acts, units, modules, etc;
   * by default, _min-book_ tries to get the word for "Part" in `#book(cfg.lang)`
   * language as its name (fallback to English).
   * 
   * When set a value (`string`), all level 1 headings become _parts_: they
   * occupy the entire page and are aligned at its middle; some decorative frame
   * also appear when `#book(cover: auto)`.
   * 
   * 
   * = Book Chapters
   * 
   * 
   * #grid(columns: (1fr, 1fr),
   *   ```typ
   *   #show: book.with(
   *     chapter: "Scene",
   *   )
   *   == This is a chapter!  // Scene 1 
   *   ```,
   *   ```typ
   *   #show: book.with(
   *     part: none,
   *     chapter: "Scene",
   *   )
   *   = This is a chapter!  // Scene 1
   *   ```
   * )
   * 
   * In most cases, books are divided into smaller sections called chapters.
   * Generally, each chapter contains a single minor story, or event, or scene,
   * or any type of subtle plot change. Each book can set different names for
   * them, like chapters, sections, articles, scenes, etc; by default, _min-book_
   * tries to get the word for "Chapter" in `#book(cfg.lang)` language as its
   * name (fallback to English).
   * 
   * Chapters are smart: when set a value (`string`), if `#book(parts: none)`
   * all level 1 headings become chapters; otherwise, all level 2 headings become
   * chapters — since the level 1 are parts.
  **/
  set heading(
    // #utils.numbering set #book(part) and #book(chapter)
    numbering: utils.numbering(
        patterns: (
          cfg.numbering-style,
          part-pattern,
          no-part-pattern,
        ),
        scope: (
          h1: part,
          h2: chapter
        )
      ),
    hanging-indent: 0pt,
    supplement: it => {
        if part != none {
          context if it.depth == 1 {part}
          else if chapter != none {chapter}
          else {auto}
        }
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
    else {
      it
    }
  }
  show heading.where(level: 2): it => {
    book-h2-counter.step()
    it
  }
  show heading.where(level: 1): set text(size: cfg.font-size * 2)
  show heading.where(level: 2): set text(size: cfg.font-size * 1.6)
  show heading.where(level: 3): set text(size: cfg.font-size * 1.4)
  show heading.where(level: 4): set text(size: cfg.font-size * 1.3)
  show heading.where(level: 5): set text(size: cfg.font-size * 1.2)
  show heading.where(level: 6): set text(size: cfg.font-size * 1.1)
  show quote.where(block: true): set pad(x: 1em)
  show raw: set text(
    font: cfg.font-mono,
    size: cfg.font-size,
  )
  show raw.where(block: true): it => pad(left: cfg.first-line-indent, it)
  show math.equation: set text(font: cfg.font-math)
  show selector.or(
      terms, enum, list, table, figure, math.equation.where(block: true),
      quote.where(block: true), raw.where(block: true)
    ): set block(above: cfg.font-size, below: cfg.font-size)
  show ref: it => context {
    let el = it.element
    
    // When referencing headings in "normal" form
    if el != none and el.func() == heading and it.form == "normal" {
      let patterns = if cfg.numbering-style != auto {cfg.numbering-style}
        else if part != none {part-pattern}
        else {no-part-pattern}
      
      // Remove \n and trim full stops
      if patterns != none and part != "" {
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
    if cfg.link-readable and type(it.dest) == str and it.dest != it.body.text {
      it
      footnote(it.dest)
    }
    else {it}
  }

  // Insert notes of a section at its end, before next heading:
  // NOFIX: This really clumsy code is the only way found to implement #note.
  
  let new-body = body.children
  let h-index = ()
  
  // #note: Get index of all headings in body.children
  for n in range(new-body.len()) {
    let item = new-body.at(n)
    
    if item.func() == heading {
      h-index.push(n)
    }
  }

  // #note: Insert anchor <note> before each heading obtained
  for n in range(h-index.len()) {
    new-body.insert(h-index.at(n) + n, [#metadata("Note anchor") <note>])
  }

  // #note:Insert a final anchor <note> at the end of the document
  new-body.push([#metadata("Note anchor") <note>])

  // #note: Make the edited new-body into the document body
  let body = new-body.join()

  // #note: Make the first note be note 1, instead of note 0.
  counter("min-book-note-count").step()

  // #note: Swap the <note> for the actual notes in the current section, if any.
  show <note>: it => {
    context if utils.cfg().final().at("note", default: (:)) != (:) {
      // Find the level (numbering) of current section heading:
      let selector = selector(heading).before(here())
      let level = counter(selector).display().replace(".", "-")

      // Show notes only if there are any in this section
      let notes = utils.cfg(get: "note." + level)
      if notes != none {
        pagebreak(weak: true)

        // Insert the notes:
        for note in notes {
          par(
            first-line-indent: 0pt,
            spacing: 0.75em,
            hanging-indent: 1em
          )[
            // Link to the note marker in the text:
            #link(
              label(level + "_" + str(note.at(0))),
              strong(numbering(note.at(2), note.at(0)) + ":")
            )
            // Insert <LEVEl_NUMBER_content> for cross-reference
            #label(level + "_" + str(note.at(0)) + "_content")
            #note.at(1)
          ]
        }

        pagebreak(weak: true)
      }

      // Make every section notes start at note 1
      counter("min-book-note-count").update(1)
    }
  }

  show super: it => {
    let note-regex = regex("::[0-9-_]+::")
    
    // #note: Parses #super("NUMBER ::LABEL::") -> #link(<LABEL>)[#super("NUMBER")]
    if it.body.text.ends-with(note-regex) {
      let note-label = it.body.text.find(note-regex).trim(":") + "_content"
      let note-number = it.body.text.replace(note-regex, "").trim()

      // Link to the actual note content:
      link(label(note-label))[#super(note-number)]
    } else {
      it
    }
  }
  
  let volume = if volume > 0 [#translation.volume.at(0) #volume\ ] else []
  let edition = if edition > 0 [#translation.edition.at(0) #edition\ ] else []
  
  if cover != none {
    if cover == auto {
      let authors = if type(authors) == array {authors.join(", ")} else {authors}
      
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
          
          align(center + bottom, rotate(180deg, frame))
          v(m.bottom * 0.25)
        }
      
      set text(
        fill: cfg.cover-txtcolor,
        hyphenate: false
      )
      set par(justify: false)
      
      page(
        margin: (x: 12%, y: 12%),
        fill: cfg.cover-bgcolor,
        background: cover-bg,
      )[
        #align(center + horizon)[
          #set par(leading: 2em)
          #context text(
            size: page.width * 0.09,
            font: cfg.cover-fonts.at(0),
            title
          )
          #linebreak()
          #set par(leading: cfg.line-space)
          #if subtitle != none {
          v(1cm)
            context text(
              size: page.width * 0.04,
              font: cfg.cover-fonts.at(1),
              subtitle
            )
            //v(4cm)
          }
        ]
        #align(center + bottom)[
          #block(width: 52%)[
            #context text(
              size: page.width * 0.035,
              font: cfg.cover-fonts.at(1),
              volume +
              authors + "\n" +
              date.display("[year]")
            )
          ]
        ]
      ]
    }
    else if type(cover) == content {
      if cover.func() == image {
        set image(
          fit: "stretch",
          width: 100%,
          height: 100%
        )
        set page(background: cover)
      }
      else {
        cover
      }
    }
    else if cover != none {
      panic("Invalid page argument value: \"" + cover + "\"")
    }
    
    pagebreak(to: break-to)
  }
  
  // Enable automatic titlepage when generating catalog
  if titlepage == none and catalog != none and cfg.two-sided {
    titlepage = []
  }

  if titlepage != none {
    if titlepage == auto {
      set text(
        fill: luma(50),
        hyphenate: false
      )
      set par(justify: false)
      
      let authors = if type(authors) == array {authors.join(", ")} else {authors}
    
      align(center + horizon)[
        #set par(leading: 2em)
        #context text(
          size: page.width * 0.09,
          title
        )
        #linebreak()
        #set par(leading: cfg.line-space)
        #if subtitle != none {
        v(1cm)
          context text(
            size: page.width * 0.04,
            subtitle
          )
          //v(4cm)
        }
      ]
      align(center + bottom)[
        #block(width: 52%)[
          #context text(
            size: page.width * 0.035,
            volume +
            edition +
            authors + "\n" + 
            date.display("[year]")
          )
        ]
      ]
    }
    else if type(titlepage) == content {
      titlepage
    }
    else {
      panic("Invalid titlepage argument value: \"" + repr(titlepage) + "\"")
    }
    
    if catalog != none {pagebreak()}
    else {pagebreak(to: break-to, weak: true)}
  }

  if catalog != none {
    set par(
      first-line-indent: 0pt,
      spacing: 1em
    )
    
    show rect: set align(center + bottom)
    
    /**
     * = Cataloging in Publication <catalog>
     * 
     * :catalog: arg `typc` "(?s)\s*let <name> = \((.*?\n)\s*\.\.<name>.*?\)\s*\n"
     * 
     * These `#book(catalog)` options set the data used to create the
     * "cataloging in publication" board. Other needed informations are
     * automatically retrieved from the book data, but at least one of these
     * options must be explicitly set to generate the board; otherwise it will
     * be just ignored.
    **/
    let catalog = (
      id: none,
      /** <- string | content
        * A #url("http://www.cutternumber.com/")[Cutter-Sanborn identification code],
        * used to identify the book author. **/
      place: none,
      /** <- string | content
        * The city or region where the book was published. **/
      publisher: none,
      /** <- string | content
        * The organization or person responsible for releasing the book. **/
      isbn: none,
        /** <- string | content
          * The _International Standard Book Number_, used to indentify the book. **/
      subjects: (),
      /** <- array
        * A list of subjects related to the book; must be an array of strings. **/
      access: (),
      /** <- array
        * A list of access points used to find the book in catalogues, like by
        * `"Title"` or `"Series"`; must be an array of strings. **/
      ddc: none,
      /** <- string | content
        * A #url("https://www.oclc.org/content/dam/oclc/dewey/ddc23-summaries.pdf")[Dewey Decimal Classification]
        * number, which corresponds to the specific category of the book. **/
      udc: none,
      /** <- string | content
        * An #url("https://udcsummary.info/php/index.php")[Universal Decimal Classification]
        * number, which corresponds to the specific category if the book. **/
      before: none,
      /** <- content
        * Content showed before (above) the cataloging in public ation board;
        * generally editorial data like publisher, editors, reviewers,
        * copyrights, etc. **/
      after: none,
      /** <- content
        * Content showed after (below) the cataloging in publication board;
        * generally additional information that complements the board data. **/
      ..catalog,
    )
    let author = if type(authors) == array {authors.at(0)} else {authors}
    author = author.replace(regex("^(.+)\s([^\s]+)$"), m => {
      if m.captures.len() >= 2 {
        m.captures.last()
        ", "
        m.captures.first()
      }
      else {
        m.text
      }
    })
    
    if catalog.before != none {catalog.before}
    
    rect(
      width: 12cm,
      inset: 1cm,
      align(
        left + top, {
        
        set box(width: 1fr)
        set par(
          first-line-indent: 0pt,
          hanging-indent: 1.5em
        )
        
        if catalog.id != none [#catalog.id #parbreak()]
        
        author
        if not author.ends-with(".") [.]
        [ ]
        
        title
        if subtitle != none [: #subtitle]
        [. ]
        catalog.place
        if catalog.place != none and catalog.publisher != none [: ]
        catalog.publisher
        if catalog.publisher != none or catalog.publisher != none [, ]
        [#date.year().]
        v(1em)
        
        if catalog.isbn != none [
          ISBN #catalog.isbn
          #v(1em)
        ]
        if catalog.subjects != () {
          for item in catalog.subjects.enumerate() {
            str(item.at(0) + 1) + ". " + item.at(1)
            h(10pt)
          }
        }
        if catalog.access != () {
          let access = if type(catalog.access) == str {(author, catalog.access)}
            else {(author, ..catalog.access)}
          
          for item in access.enumerate() {
            numbering("I.", item.at(0) + 1) + " " + item.at(1)
            h(10pt)
          }
        }
        v(1em)
        
        if catalog.ddc != none {box[]}
        if catalog.udc != none {box(align(center, catalog.udc))}
        if catalog.ddc != none {box(align(right, catalog.ddc))}
      })
    )
    
    if catalog.after != none {catalog.after}
  }
  
  if errata != none {
    pagebreak(to: break-to, weak: true)
    heading(
      translation.errata,
      numbering: none,
      outlined: false,
    )
    errata
    pagebreak(to: break-to)
  }
  
  if dedication != none {
    set text(size: cfg.font-size - 2pt)
    
    pagebreak(to: break-to, weak: true)
    align(center + horizon, dedication)
    pagebreak(to: break-to)
  }
  
  if acknowledgements != none {
    set par(justify: true)
    
    pagebreak(to: break-to, weak: true)
    // INFO: Acknowledgements without title for now, seems cleaner
    // heading(
    //   translation.acknowledgements  ,
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
      size: cfg.font-size - 2pt,
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
    show outline.entry.where(level: 1): it => {
      // Special formatting to parts in TOC:
      if part != none and cfg.toc-bold == true {
        v(cfg.font-size, weak: true)
        strong(it)
      }
      else {
        it
      }
    }
    let indenting = if cfg.toc-indent == auto {auto}
      else {
        lvl => {
          if cfg.toc-indent != none {cfg.toc-indent * lvl}
          else { if lvl > 0 {1.5em} else {0em} }
        }
      }

    pagebreak(to: break-to, weak: true)
    outline(
      indent: indenting,
      depth: if cfg.numbering-style == none {2} else {none},
    )
    pagebreak(weak: true)
  }
  
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
 * = Additional Commands
 * 
 * These commands are provided as a wa6 to access some fancy book features that
 * cannot be implemented by re-working and adapting existing Typst elements. They
 * are completely optional and is perfectly possible to write an entire book.
**/


/**
 * == Note Command
 * 
 * :note:
 * 
 * Adds an end note, an alternative for footnotes but placed inside of the page
 * instead of its margins. End notes appear at its own page at the end of the
 * current section, right before the next heading.
**/
#let note(
  numbering-style: auto,
  /** <- auto | array | string
    * Custom note numbering — a standard numbering (`string`) or a #univ("numbly")
    * numbering (`array`). **/
  content,
  /** <- content <required>
    * The content of the end note. **/
) = context {
  import "utils.typ"
  
  // Find the level (numbering) of current section heading:
  let selector = selector(heading).before(here())
  let level = counter(selector).display().replace(".","-")
  
  let numbering-style = numbering-style
  if numbering-style == auto {
    numbering-style = utils.cfg(get: "note.numbering", "1")
  }
  else {
    utils.cfg(add: "note.numbering", numbering-style)
  }
  
  let count = counter("min-book-note-count")
  counter("min-book-note-count").step()
  
  let this-note = (
    count.get().at(0),
    content,
    numbering-style
  )
  
  // Push a new value to note.level array
  utils.cfg(add: "note." + level + "+", this-note)

  let note-number = numbering(numbering-style, ..count.get())
  let note-label = level + "_" + numbering("1", ..count.get())

  // Set note as #super[NUMBER ::LABEL::] to be managed later
  [#super(note-number + " ::" + note-label + "::")#label(note-label)]
}


/**
 * == Appendices and Annexes Command
 * 
 * :appendices:
 * 
 * Creates an special ambient to write or include multiple appendices. An
 * appendix is any important additional data left out of the main document for
 * some reason, but directly referenced or needed by it. Inside this ambient,
 * all level 1 heading is a new appendix.
**/
#let appendices(
  type: "appendix",
  title: auto,
  /** <- array | auto
    * The name of the appendices — an array `(SINGULAR, PLURAL)` to each
    * "Appendix" and the part "Appendices" names, respectively, or
    * defaults to these same words in book language (`auto`). **/
  numbering-style: (
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
  /** numbering-style: <- array | string
    * Custom heading numbering for appendices — a standard numbering (`string`),
    * or a #univ("numbly") numbering (`array`). **/
  body
  /** <- content
    * The appendices content. **/
) = context {
  import "utils.typ"

  // Set name for "appendix" and "appendices" titles
  let (singular-title, plural-title) = if title == auto {
      //book-tr-state.get().at(type)
      utils.cfg(get: "translation").at(type)
    } else {
      title
    }
  
  let break-to = utils.cfg(get: "break-to")
  
  set heading(
    offset: 1,
    numbering: utils.numbering(
        patterns: (numbering-style,),
        scope: (
          h1: "",
          h2: singular-title,
          n: 1
        )
      ),
    supplement: singular-title
  )
  
  show heading.where(level: 2): it => {
    pagebreak(to: break-to)
    it
  }
  
  
  pagebreak(weak: true, to: break-to)
  
  // Main title (plural)
  heading(
    plural-title,
    level: 1,
    numbering: none
  )
  
  counter(heading).update(0)
  
  body
}


/** 
 * == Annexes Command
 * 
 * :annexes:
 * 
 * Creates an special ambient to write or include multiple annexes. An annex is
 * any important third-party data directly cited or referenced in the main
 * document. Inside this ambient, all level 1 heading is a new annex.
**/
#let annexes(
  type: "annex",
  title: auto,
  /** <- auto | array
    * The name of the annexes — an array `(SINGULAR, PLURAL)` to each
    * "Annex" and the part "Annexes" names, respectively, or
    * defaults to these same words in book language (`auto`). **/
  numbering-style: (
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
  /** numbering-style: <- array | string
    * Custom heading numbering for annexes — a standard numbering (`string`), or
    * a #univ("numbly") numbering (`array`). **/
  body
  /** <- content
    * The annexes content. **/
) = appendices(
  type: type,
  title: title,
  numbering-style: numbering-style,
  body
)


/**
 * == Horizontal Rule Command
 * 
 * :horizontalrule:
 * 
 * Adds a horizontal rule, visual separators used to distinguish subtle changes
 * of subject in extensive texts.
**/
#let horizontalrule(
  symbol: [#sym.ast.op #sym.ast.op #sym.ast.op],
  /** <- content
    * Decoration in the middle of the horizontal rule — defaults to 3 asterisks. **/
  spacing: 1em,
  /** <- length
    * Vertical space before and after the horizontal rule. **/
  line-size: 15%,
) = {
  v(spacing, weak: true)
  
  align(
    center,
    block(width: 100%)[
      #box(
        height: 1em,
        align(
          center + horizon,
          line(length: line-size)
        )
      )
      #box(height: 1em, symbol)
      #box(
        height: 1em,
        align(
          center + horizon,
          line(length: line-size)
        )
      )
    ]
  )
  
  v(spacing, weak: true)
}

/// The `#horizontalrule` command is also available as the smaller `#hr` alias.
#let hr = horizontalrule


/**
 * == Block Quote Command
 * 
 * :blockquote:
 * 
 * Adds a block of quotation, a simple alias to `#quote(block: true)`, with a
 * smaller and more semantic `#quote(attribution)` option as `#blockquote(by)`.
**/
#let blockquote(by: none, ..args) = quote(block: true, attribution: by, ..args)