// NAME: Minimal Books
// REQ: numbly
// TODO: Implement ePub output when available

#import "@preview/numbly:0.1.0": numbly

/**
 * = Quick Start
 *
 * ```typ
 * #import "@preview/min-book:1.0.0": book
 * #show: book.with(
 *   title: "Book Title",
 *   subtitle: "Complementary subtitle, not more than two lines long",
 *   authors: "Author",
 * )
 * ```
 * 
 * = Description
 * 
 * Generate complete and complex books, without any annoying new commands or syntax,
 * just good old pure Typst. This package works by manipulating the standard Typst
 * elements, adapting them to the needs of a book structure. All of this is managed
 * behind the scenes, so that nothing changes in the Typst code itself.
 * 
 * The commands that `min-book` provides are only included for the sake of
 * completeness, and offers some fancy optional features like horizontal rules
 * or end notes; but it's perfectly possible to write entire books without them.
 * 
 * While it is possible to play with complex structures, such as parts and chapters
 * and creative numbering, this package comes with several ready to use default
 * values; so its really up to you to customize it your way or ride along the
 * defaults and just start writing: both ways are possible and encouraged.
 * 
 * This manual will be updated only when new versions break or modify something;
 * otherwise, it will be valid to all newer versions starting by the one documented
 * here.
 * #pagebreak()
**/

#let book-tr-state = state("book-tr", (:))
#let book-notes-state = state("book-notes", (curr-numbering: "1"))
#let book-note-counter = counter("book-note-count")


/** 
 * = Options
 * 
 * Those are the full list of options available and its default values:
 * 
 * :book:
 * 
 * Seems like an awful lot to start with, but let's just break down all this to
 * understand it better, shall we?
**/
#let book(
  title: none,
  /** <- string | content <required>
    * The main title of the book. **/
  subtitle: none,
  /** <- string | content | none
    * The book subtitle; generally two lines long or less. **/
  edition: 0,
  /** <- int
    * The book publication number; used when the content is cjanged or updated
    * after the book release. **/
  volume: 0,
  /** <- int
    * The book series volume number; used when the same story is told through
    * multiple books, in order. **/
  authors: none,
  /** <- string | array <required>
    * A string or array of strings containing the names of each author of the
    * book. **/
  date: datetime.today(),
  /** <- array | dictionary
    * The book publication date; can be a `(yyyy, mm, dd)` array or a
    * `(year: yyyy, month: mm, day: dd)` dictionary, and defaults to current
    * date if not set. **/
  cover: auto,
  /** <- auto | content | none
    * The book cover content; when `auto`, generates an automatic cover. **/
  titlepage: auto,
  /** <- auto | content
    * The presentation page content, shown after the cover; when `auto`,
    * generates an automatic title page. **/
  catalog: none,
  /** <- toml | yaml | dictionary
    * Set the data for the "cataloging in publication" board. **/
  errata: none,
  /** <- content
    * A text that corrects important errors from previous book editions. **/
  dedication: none,
  /** <- content
    * A brief text that dedicates the book in honor or in memorian of someone
    * important; can accompany a small message directed to the person. **/
  acknowledgements: none,
  /** <- content
    * A brief text to recognize everyone who helped directly or indirectly in
    * the process of book creation and their importance in the project. **/
  epigraph: none,
  /** <- quote | content
    * A short citation or excerpt of other works used to introduce the main
    * theme of the book; can suggest a reflection, a mood, or idea related to
    the text. **/
  toc: true,
  /** <- boolean
    * Defines if the book will have a table of contents. **/
  part: auto,
  /** <- auto | string | none
    * The name of the main divisions of the book; when `auto`, try to retrieve
    * the translation for "Part" in `#text.lang` from `#book(lang-data)`, or
    fallback to English. **/
  chapter: auto,
  /** <- string | none
    * The name of the sections of the book; when `auto`, try to retrieve the
    * translation for "Chapter" in `#text.lang` from `#book(lang-data)`, or
    fallback to English. **/
  cfg: auto,
  /** <- dictionary
    * Set custom advanced configurations; used to fine-tune some aspects of the
    * book, mostly aesthetic formatting. If your focus is to just write a book
    * in English without worry about code, just ignore it; otherwise, refer to
    * @adv-config to check the supported configurations. **/
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
   * :cfg: "(?s)\s*let\s<name>\s=\s\((.*?\n)\s*\.\.<name>,\s*\)\s*\n?\n"
   *
   * These configurations allows to modify certain aspects of the book and better
   * control its appearence. They are built with rebust defaults in mind, so that
   * a casual writer can safely ignore it and _just write_ , and in most cases it
   * will be used for simple tasks such as change the language or fonts.
   * 
  **/
  if cfg == auto {cfg = (:)}
  let cfg = (
    numbering-style: auto,
      /** <- array | string | none
        * Defines a custom heading numbering; can be a standard numbering string,
        * or a #univ("numbly") numbering array. **/
    page-cfg: "a5",
      /** <- dictionary | string
        * Set page configuration, acting as `#set page(..page-cfg)`; when string,
        * act as `#set page(paper: page-cfg)`. **/
    lang: "en",
      /** <- string
        * Defines the language of the written text (`text.lang`). **/
    lang-data: toml("assets/lang.toml"),
      /** <- toml
        * A TOML translation file; the file structure can be found in the default
        * `src/assets/lang.toml` file. **/
    justify: true,
      /** <- boolean
        * Defines if the text will have justified alignment. **/
    line-space: 0.5em,
      /** <- length
        * Defines the space between lines in the document. **/
    par-margin: 0.65em,
      /** <- length
        * Defines the margin space after each paragraph. Set it the same as
        * `#book(line-space)` to get paragraphs without additional space between
        * them. **/
    first-line-indent: 1em,
      /** <- length
        * Defines the first line indentation of all paragraphs but the first one,
        * in a sequence of paragraphs. **/
    margin: (x: 15%, y: 14%),
      /** <- length
        * Defines the document margins. **/
    font: ("Book Antiqua", "Times New Roman"),
      /** <- string | array
        * Defines the font families used for the text; the default font is
        * specified in `README.md` file. **/
    font-math: "Asana Math",
      /** <- string | array
        * Defines the font families used for the math and equations; the default
        * font is specified in `README.md` file. **/
    font-mono: "Inconsolata",
      /** <- string | array
        * Defines the font families used for the monospaced text; the default
        * font is specified in `README.md` file. **/
    font-size: 11pt,
      /** <- length
        * Defines the size of the text in the document. **/
    heading-weight: auto,
      /** <- string
        * Defines the font weight of headings; by default, headings level 1--5
        * are `"regular"` and levels above it are `"bold"`, but
        * `#book(cfg.heading-weight)` apply the same weight for all headings. **/
    ..cfg,
  )

  date = utils.date(date)
  if type(cfg.page-cfg) == str {cfg.page-cfg = (paper: cfg.page-cfg)}
  if type(cfg.page-cfg) == str {cfg.page-cfg = (paper: cfg.page-cfg)}

  set document(
    title: if subtitle != none {title + " - " + subtitle} else {title},
    author: authors,
    date: date
  )
  set page(
    margin: cfg.margin,
    ..cfg.page-cfg
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
  
  // Context to make translations available
  context {
    // Set part and chapter translations based on text.lang
    let translation = cfg.lang-data.lang.at(text.lang, default: none)
    
    // Fallback system when #text.lang not in #book(cfg.lang-data) file
    if translation == none {
      let lang = cfg.lang-data.conf.at("default-lang", default: "en")
      translation = cfg.lang-data.at("lang").at(lang)
    }
    
    let part = if part == auto {translation.part} else {part}
    let chapter = if chapter == auto {translation.chapter} else {chapter}
    
    // Set translations state to be used outside #book()
    book-tr-state.update(translation)

    /**
     * = Advanced Numbering
     * 
     * The book headings can be numbered two ways: using a standard numbering
     * string, or a #univ("numbly") numbering array. While numbering strings are
     * indicated for simpler cases, the numbly arrays are used in more complex
     * book numbering.
     * 
     * By default, when `#book(part)` is enabled, the following numbering is used:
     *
     * :part-pattern: code "(?s)\s*let\s<name>\s=\s(\(.*?\))\s*\n?\n"
     *
     * But when `#book(part: none)`, the following numbering is used:
     * 
     * :no-part-pattern: code "(?s)\s*let\s<name>\s=\s(\(.*?\))\s*\n?\n"
     * 
     * Additionally, a custom `#book(numbering-style)` can be set to override
     * the default numbering behavior above.
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
     * Some larger books are internally divided into multiple _parts_. This structure
     *  allows to better organize and understand a text with multiple sequential plots,
     * or tales, or time jumps, or anything that internally differentiate parts of the
     * story. While the name used here is _part_, different books uses different names
     * for it: parts, subjects, books, acts, units, modules, etc.
     * 
     * By default, every _level 1 heading_ is a part named as _"Part"_ in `text.lang`
     * document language; setting `#book(part)` change this name, or disable parts if
     * set to `none`.
     * 
     * ```typ
     * #show: book.with(
     *   part: "Act",
     * )
     * = This heading is the Act 1 part
     * ```
     * 
     * = Book Chapters
     * 
     * In most cases, books are divided into smaller sections called chapters.
     * Generally, each chapter contains a single minor story, or event, or scene,
     * or any type of subtle plot change.
     * 
     * Chapters are smart: by default, every _level 2 heading_ is a chapter named
     * _"Chapter"_ in `text.lang` document language, when parts are enabled; but when
     * parts are disabled, every _level 1 heading_ will be a chapter. Setting
     * `#book(chapter)` change the default chapter name, or disable chapters if set to
     * `none`.
     * 
     * #grid(columns: (1fr, 1fr),
     *   ```typ
     *   #show: book.with(
     *     chapter: "Scene",
     *   )
     *   == This is Scene 1 chapter
     *   ```,
     *   ```typ
     *   #show: book.with(
     *     part: none,
     *     chapter: "Scene",
     *   )
     *   = This is Scene 1 chapter
     *   ```
     * )
    **/
    // #utils.numbering set #book(part) and #book(chapter)
    set heading(
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
          
        if counter(page).get().at(0) != 1 {pagebreak(to: "odd")}
        
        set page(background: part-bg)
        set par(justify: false)
        
        align(center + horizon, it)
        
        set page(background: none)
        pagebreak(to: "odd", weak: true)
        
        // Get the current level 2 heading count:
        let current-h2-count = book-h2-counter.get()
        // Level 2 heading numbering will not restart after level 1 headings now:
        counter(heading).update((h1, ..n) => (h1, ..current-h2-count))
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
    show raw.where(block: true): it => pad(left: 1em, it)
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
    book-note-counter.update(1)
  
    // #note: Swap the <note> for the actual notes in the current section, if any.
    show <note>: it => {
      context if book-notes-state.final() != (:) {
        // Find the level (numbering) of current section heading:
        let selector = selector(heading).before(here())
        let level = counter(selector).display()
  
        // Show notes only if there are any in this section
        if book-notes-state.get().keys().contains(level) {
          pagebreak(weak: true)
  
          // Insert the notes:
          for note in book-notes-state.get().at(level) {
            par(
              first-line-indent: 0pt,
              spacing: 0.75em,
              hanging-indent: 1em
            )[
              // Link to the note marker in the text:
              #link(
                label(level + "-" + str(note.at(0)) ),
                strong(numbering(note.at(2), note.at(0)) + ":")
              )
              // Insert <LEVEl-content> for cross-reference
              #label(level + "-" + str(note.at(0)) + "-content")
              #note.at(1)
            ]
          }
  
          pagebreak(weak: true)
        }
  
        // Make every section notes start at note 1
        book-note-counter.update(1)
      }
    }
  
    show super: it => {
      let note-regex = regex("::[0-9-.]+::")
      
      // #note: Transform note markers in links to the actual notes:
      // - Targets the `#super("NUMBER ::LABEL::")` returned by `#note`
      // - After handled, turn them into `#link(<LABEL>)[#super("NUMBER")]`
      if it.body.text.ends-with(note-regex) {
        let note-label = it.body.text.find(note-regex).trim(":") + "-content"
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
          fill: luma(200),
          hyphenate: false
        )
        set par(justify: false)
        
        page(
          margin: (x: 12%, y: 12%),
          fill: rgb("#3E210B"),
          background: cover-bg
        )[
          #align(center + horizon)[
            #set par(leading: 2em)
            #context text(
              size: page.width * 0.09,
              font: "Cinzel",
              title
            )
            #linebreak()
            #set par(leading: cfg.line-space)
            #if subtitle != none {
            v(1cm)
              context text(
                size: page.width * 0.04,
                font: "Alice",
                subtitle
              )
              //v(4cm)
            }
          ]
          #align(center + bottom)[
            #block(width: 52%)[
              #context text(
                size: page.width * 0.035,
                font: "Alice",
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
      
      pagebreak(to: "odd")
    }
    
    // Enable automatic titlepage when generating catalog
    let titlepage = if titlepage == none and catalog != none []
      else {titlepage}
  
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
      else {pagebreak(to: "odd", weak: true)}
    }
  
    if catalog != none {
      set par(
        first-line-indent: 0pt,
        spacing: 1em
      )
      
      show rect: set align(center + bottom)
      
      /**
       * = Cataloging in Publication
       * 
       * :catalog: "(?s)\s*let <name> = \((.*?\n)\s*\.\.<name>.*?\)\s*\n"
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
      pagebreak(to: "odd", weak: true)
      heading(
        translation.errata,
        numbering: none,
        outlined: false,
      )
      errata
      pagebreak(to: "odd")
    }
    
    if dedication != none {
      set text(size: cfg.font-size - 2pt)
      
      pagebreak(to: "odd", weak: true)
      align(center + horizon, dedication)
      pagebreak(to: "odd")
    }
    
    if acknowledgements != none {
      set par(justify: true)
      
      pagebreak(to: "odd", weak: true)
      // INFO: Acknowledgements without title for now, seems cleaner
      // heading(
      //   translation.acknowledgements  ,
      //   numbering: none,
      //   outlined: false,
      // )
      acknowledgements
      pagebreak(to: "odd")
    }
    
    if epigraph != none {
      set align(right + bottom)
      set quote(block: true)
      set text(
        size: cfg.font-size - 2pt,
        style: "italic",
      )
      
      pagebreak(to: "odd", weak: true)
      pad(
        epigraph,
        left: 1cm,
      )
      pagebreak(to: "odd")
    }
    
    if toc == true {
      show outline.entry.where(level: 1): it => {
        // Special formatting to parts in TOC:
        if part != none {
          v(cfg.font-size, weak: true)
          strong(it)
        }
        else {
          it
        }
      }
  
      pagebreak(to: "odd", weak: true)
      outline(
        indent: lvl => if lvl > 0 {1.5em} else {0em},
        depth: if cfg.numbering-style == none {2} else {none},
      )
      pagebreak(weak: true)
    }
    
    // <outline> anchor allows different numbering styles in TOC and in the actual text.
    [#metadata("Marker for situating titles after/before outline") <outline>]
    
    // Start page numbering at the next even page:
    if part != none {pagebreak(weak: true, to: "odd")}
    set page(numbering: "1")
    counter(page).update(1)
  
    body
  }
  
  if cover == auto {
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
    
    pagebreak(weak: true, to: "odd")
    page(
      footer: none,
      background: cover-bg,
      fill: rgb("#3E210B"),
      []
    )
  }
}

/**
 * = Additional Commands
 * 
 * As said before, this package does not requires any new syntax nor commands to
 * write a complete book. But, well... it does offers some additional commands.
 * These are completely optional and exists only to facilitate the book writing
 * process; it is perfectly possible to write an entire book without them.
**/


/**
 * == Note Command
 * 
 * :note:
 * 
 * Adds end notes to the book. End notes are more common than footnotes in books,
 * and while footnotes appear at the footer of the current page, end notes appears
 * at its own page at the end of the current section, right before the next heading.
**/
#let note(
  numbering-style: auto,
  /** <- auto | array | string
    * Defines a custom note numbering from this note onwards; can be a standard
    * numbering string, or a #univ("numbly") numbering array. **/
  content,
  /** <- content <required>
    * The content of the end note. **/
) = context {
  
  // Find the level (numbering) of current section heading:
  let selector = selector(heading).before(here())
  let level = counter(selector).display()
  
  let numbering-style = numbering-style
  if numbering-style == auto {
    numbering-style = book-notes-state.get().curr-numbering
  }
  else {
    book-notes-state.update(notes => {
      notes.insert("curr-numbering", numbering-style)
      notes
    })
  }
  
  let this-note = (
    book-note-counter.get().at(0),
    content,
    numbering-style
  )
  
  book-note-counter.step()
  
  
  // Insert book-notes-state.at(level) = this-note:
  if book-notes-state.get().at(level, default: none) == none {
    book-notes-state.update(notes => {
      notes.insert(level, (this-note,))
      notes
    })
  }
  // Insert this-note to existing book-notes-state.at(label):
  else {
    book-notes-state.update(notes => {
      notes.at(level).push(this-note)
      notes
    })
  }
  
  let note-number = numbering(numbering-style, ..book-note-counter.get())
  let note-label = level + "-" + numbering("1", ..book-note-counter.get())

  // Set note as #super[NUMBER ::LABEL::] to be managed later
  [#super(note-number + " ::" + note-label + "::")#label(note-label)]
}


/**
 * == Appendices and Annexes Command
 * 
 * :appendices:
 * 
 * Creates an special ambient to write or include multiple appendices. An appendix
 * is any important additional data left out of the main document for some reason,
 * but directly referenced or needed by it.
**/
#let appendices(
  type: "appendix",
  title: auto,
  /** <- auto | array
    * An array of strings with singular and plural titles for appendices, respectively;
    * when `auto`, try to retrieve the translations for "Appendix" and "Appendices"
    * in `#text.lang` from `#book(lang-data)`, or fallback to English. **/
  numbering-style: (
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
  /** numbering-style: <- array | string
    * Defines a custom heading numbering for appendices; can be a standard
    * numbering string, or a #univ("numbly") numbering array. **/
  body
  /** <- content
    * The appendices content; every _level 1 heading_ will be treated as a new
    * appendix. **/
) = context {
  import "utils.typ"

  // Set name for "appendix" and "appendices" titles
  let (singular-title, plural-title) = if title == auto {
      book-tr-state.get().at(type)
    } else {
      title
    }
  
  
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
    pagebreak(to: "odd")
    it
  }
  
  pagebreak(weak: true, to: "odd")
  
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
 * Creates an special ambient to write or include multiple annexes. An annex is any
 * important third-party data directly cited or referenced in the main document.
**/
#let annexes(
  type: "annex",
  title: auto,
  /** <- auto | array
    * An array of strings with singular and plural titles for annexes, respectively;
    * when `auto`, try to retrieve the translations for "Annex" and "Annexes"
    * in `#text.lang` from `#book(lang-data)`, or fallback to English. **/
  numbering-style: (
    "",
    "{2:A}.\n",
    "{2:A}.{3:1}. ",
    "{2:A}.{3:1}.{4:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}. ",
    "{2:A}.{3:1}.{4:1}.{5:1}.{6:a}. ",
  ),
  /** numbering-style: <- array | string
    * Defines a custom heading numbering for annexes; can be a standard
    * numbering string, or a #univ("numbly") numbering array. **/
  body
  /** <- content
    * The annexes content; every _level 1 heading_ will be treated as a new
    * annex. **/
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
 * Adds a horizontal rule, visual separators used to distinguish subtle changes of
 * subject in extensive texts.
**/
#let horizontalrule(
  symbol: [#sym.ast.op #sym.ast.op #sym.ast.op],
  /** <- content
    * Defines the content of a decoration in the middle of tue horizontal rule;
    * defaults to three asterisks. **/
  spacing: 1em,
  /** <- length
    * The vertical space before and after the horizontal rule. **/
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

/// The same `#horizontalrule` command is also as the smaller `#hr` alias.
#let hr = horizontalrule


/**
 * == Block Quote Command
 * 
 * :blockquote:
 * 
 * Simple alias to add a `#quote(block:true)` command with smaller and semantic
 * `#quote(attribution)` option, as `#blockquote(by)`.
**/
#let blockquote(by: none, ..args) = quote(block: true, attribution: by, ..args)