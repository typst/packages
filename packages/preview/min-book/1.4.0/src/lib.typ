// TODO: Implement ePub output when available

#import "commands/notes.typ": note
#import "commands/ambients.typ": appendices, annexes
#import "commands/horizontalrule.typ": horizontalrule, hr
#import "commands/blockquote.typ": blockquote
#import "themes.typ"

/** #v(1fr) #outline() #v(1.2fr) #pagebreak()
= Quick Start
```typ
#import "@preview/min-book:1.4.0": book
#show: book.with(
  title: "Book Title",
  subtitle: "Book subtitle",
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
:show.with book:
**/
#let book(
  title: none, /// <- string | content <required>
    /// Main title. |
  subtitle: none, /// <- string | content | none
    /// Subtitle, generally two lines long or less. |
  edition: 1, /// <- integer
    /// Edition number (counts changes and updates between book releases). |
  volume: 0, /// <- integer
    /// Series volume number (situates the book inside a collection). |
  authors: none, /// <- string | array of strings <required>
    /// Author or authors. |
  date: datetime.today(), /// <- datetime | array | dictionary
    /// `(year, month, day)`\ Publication date. |
  cover: auto, /// <- auto | function | image | content | none
    /** Cover (overrides theme); when function, takes `(meta, cfg) => { }` and
        generate a back cover (use `meta.is-back-cover`) when enabled by
        `#book(cfg.cover.back: true)`. |**/
  titlepage: auto, /// <- auto | content | none
    /// Title page, shown after cover (overrides theme). |
  catalog: none, /// <- dictionary | yaml | toml
    /// Cataloging-in-publication board, used for library data (see "@catalog" section). |
  errata: none, /// <- content | string
    /// Correction of errors from previous book editions. |
  dedication: none, /// <- content | string
    /// Tribute or words addressed to someone important. |
  acknowledgements: none, /// <- content | string
    /// Expression of gratitude to those who contributed to the work. |
  epigraph: none, /// <- quote | content
    /// Brief quotation that foreshadows the book’s theme, tone, or central reflection. |
  toc: true, /// <- boolean
    /// Table of contents. |
  part: auto, /// <- string | none | auto
    /// Custom name of the book's main divisions (parts). |
  chapter: auto, /// <- string | none
    /// Custom name of sections of the book (chapters). |
  cfg: auto, /// <- dictionary
    /// Set advanced configurations (see "@adv-config") section. |
  body
) = context {
  import "@preview/nexus-tools:0.1.0": storage, get, default, content2str
  import "@preview/transl:0.2.0": transl
  import "commands/notes.typ"
  import "utils.typ"
  
  assert.ne(title, none, message: "#book(title) required")
  assert.ne(authors, none, message: "#book(authors) required")
  
  /**
  = Advanced Configuration <adv-config>
  :std-cfg: typc "let" => cfg: <capt>
  
  These `#book(cfg)` configurations allows to modify certain aspects of the
  book and manage its appearance and structure. Built with some thoughful
  ready-to-use defaults that make its use optional, so that beginners and
  casual writers can safely ignore it and _just write_.
  **/
  let std-cfg = (
    numbering: auto, /// <- string | any
      /// Heading numbering (managed by theme). |
    transl: auto, /// <- string | dictionary of strings
      /** `"file"   (lang: "file")`\
          Set custom Fluent files to #univ("transl") translation database (check
          `src/l10n/` for practical references). |**/
    std-toc: false, /// <- boolean
      /// Restore default `#outline` appearance. |
    chapter-continuous: true, /// <- boolean
      /// Continue chapter (level 2) numbering even after a book part (level 1). |
    two-sided: true, /// <- boolean
      /// Optimizes to print content on both sides of the paper. |
    paper-friendly: true, /// <- boolean
      /// Use links attached to URL footnotes. |
    notes-page: false, /// <- boolean
      /// Forces `#note` data to always appear in a separate new page. |
    theme: themes.stylish, /// <- module
      /// Set book theme. |
    styling: (:), /// <- dictionary
      /// Theme general styling configurations. |
    cover: (:), /// <- dictionary
      /// Theme cover/title page configurations. |
    part: (:), /// <- dictionary
      /// Theme part configurations. |
  )
  let cfg = get.auto-val(cfg, (:))
  let not-cfg = cfg.keys().filter( i => not std-cfg.keys().contains(i) )
  let lang-id = text.lang + if text.region != none {"-" + text.region}
  let transl-db = utils.std-langs()
  let date = if not type(date) in (array, dictionary) {(date,)} else {date}
  let font-size = text.size
  /**
  = Book Parts
  ```typ
  #show: book.with(part: "Act")
  = This is a part!  // Act 1
  ```
  
  Some larger books are internally divided into multiple _parts_. This
  structure allows to better organize and understand a text with multiple
  sequential plots, or tales, or time jumps, or anything that internally
  differentiate parts of the story. Parts can also be called subjects, books,
  acts, units, modules, etc.; by default, _min-book_ tries to use "Part"
  translated to `#text.lang` as name.
  
  When set, all level 1 headings become _parts_ and its appearance is managed by
  the current theme.
  
  = Book Chapters
  ```typ
  #show: book.with(chapter: "Scene")
  == This is a chapter!  // Scene 1 
  
  #show: book.with(chapter: "Scene", part: none)
  = This is a chapter!  // Scene 1
  ```
  
  In most cases, books are divided into smaller sections called _chapters_.
  Generally, each chapter contains a single minor story, or event, or scene,
  or any type of subtle plot change. Chapters can also be called sections,
  articles, scenes, etc.; by default, _min-book_ tries to use "Chapter" translated
  to `#text.lang` as name.
  
  Chapters are smart: when set, if `#book(parts: none)` then all level
  1 headings become chapters; otherwise, all level 2 headings become chapters
  — since parts are level 1 headings.
  **/
  let part = part
  let chapter = chapter
  let body = body
  let break-to
  let meta 
  
  // Check if the cfg options received are valid
  if not-cfg != () {
    panic("Invalid #book(cfg) options: " + not-cfg.join(", "))
  }
  cfg = std-cfg + cfg
  
  // Insert #cfg.transl into #transl-db
  if type(cfg.transl) == str {transl-db.insert(lang-id, cfg.transl)}
  else {transl-db += get.auto-val(cfg.transl, (:))}
  
  transl(data: transl-db, lang: lang-id)
  
  transl = transl.with(data: transl-db, to: lang-id)
  chapter = get.auto-val(chapter, transl("chapter"))
  part = get.auto-val(part, transl("part"))
  break-to = if cfg.two-sided {"odd"} else {none}
  date =  get.date(..date)
  meta = (
    title: title,
    subtitle: subtitle,
    date: date,
    authors: authors,
    volume: if volume != 0 {transl("volume", n: volume)} else {""},
    edition: if edition != 0 {transl("edition", n: edition)} else {""},
    part: part,
    chapter: chapter,
    cover: cover,
  )
  
  storage.add("break-to", break-to, namespace: "min-book")
  storage.add("part", part, namespace: "min-book")
  
  show: cfg.theme.styling.with(meta, cfg)
  show heading.where(level: 1, outlined: true): it => {
    if part != none {it = cfg.theme.part(meta, cfg, it)}
    it
  }
  show <horizontalrule:insert>: it => {
    if dictionary(cfg.theme).keys().contains("horizontalrule") {
      cfg.theme.horizontalrule(meta, cfg)
    }
    else {align(center, line(length: 80%))}
  }
  
  body = notes.insert(body, new-page: part != none or cfg.notes-page)
  
  /**
  = Theming & Customization
  
  Book customization relies on three pillars: themes, defaults, and settings.
  Themes are broader and more practical sets of customizations; defaults define
  pre-programmed adjustments that can be overridden; and settings allow for
  fine-tuning specific behaviors.
  
  Built-in themes are provided under the `themes` module for quick visual
  customization; it is also possible to create a custom theme (check the
  `docs/themes.md` file for a practical reference). A theme is applied as following:
  ```typ
  #import "@preview/min-manual:1.4.0": book, themes
  #show: book.with( cfg: (theme: themes.default) )
  ```
  
  Themes can provide defaults that can be overridden by `#set` rules defined
  before the `#show: book` command — defaults take precedence over rules after it.
  ```typ
  #set page(margin: 2cm)
  #set text(size: 18pt)
  #set outline(depth: 4)
  
  #show: book.with(...)
  ```
  
  The settings are options of the `#book` command and allow for more specific
  adjustments. Some settings can be used by themes; they can also control defaults.
  **/
  
  if titlepage == none and catalog != none and cfg.two-sided {
    // Automatic blank titlepage when generating catalog
    titlepage = []
  }
  
  if cover != none {
    let generate-cover
    
    meta += (is-back-cover: false)
    
    if cover == auto {generate-cover = cfg.theme.cover-page}
    else if type(cover) == function {generate-cover = cover}
    else if type(cover) == content {
      generate-cover = (_,_) => {
        if cover.func() == image {
          set image(
            fit: "stretch",
            width: 100%,
            height: 100%
          )
          
          page(background: cover, none)
        }
        else {cover}
      }
    }
    else {panic("Invalid #book(page) value: " + cover)}
    
    generate-cover(meta, cfg.cover)
    pagebreak(to: break-to, weak: true)
  }
  
  if titlepage != none {
    let generate-titlepage
    
    if titlepage == auto {generate-titlepage = cfg.theme.title-page}
    else if type(titlepage) == function {generate-titlepage = titlepage}
    else if type(titlepage) == content {
      generate-titlepage = (_,_) => {
        if titlepage.func() == image {
          set image(
            fit: "stretch",
            width: 100%,
            height: 100%
          )
          
          page(background: titlepage, none)
        }
        else {titlepage}
      }
    }
    else {panic("Invalid #book(titlepage) value: " + repr(titlepage))}
    
    generate-titlepage(meta, cfg.cover)
    pagebreak(weak: true)
  }
  
  if catalog != none {
    import "catalog.typ" as cataloging
    
    /**
    = Cataloging in Publication <catalog>
    :arg catalog: "let"
    
    These `#book(catalog)` options set the data used to create the
    "cataloging in publication" board. Other needed information are
    automatically retrieved from the book data, but at least one of these
    options must be explicitly set to generate the board; otherwise it will
    be just ignored.
    **/
    let catalog = (
      id: none, /// <- string | content
        /** A #url("http://www.cutternumber.com/")[Cutter-Sanborn identification code,]
        used to identify the book author. |**/
      place: none, /// <- string
        /// The city or region where the book was published. |
      publisher: none, /// <- string
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
      bib-style: "associacao-brasileira-de-normas-tecnicas", /// <- string
        /// Bibliographic reference style of the book data. |
    ) + catalog
    
    if meta.volume != "" {meta.volume = volume}
    if meta.edition != "" {meta.edition = edition}
    if meta.subtitle != none {meta.subtitle = content2str(meta.subtitle)}
    
    meta.title = content2str(meta.title)
    
    cataloging.insert(catalog, meta)
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
    pagebreak(to: break-to, weak: true)
    outline()
    pagebreak(weak: true)
  }
  
  [#metadata("Situates headings before/after outline") <toc:inserted>]
  
  // Start page numbering at the next even page:
  if part != none {pagebreak(weak: true, to: break-to)}
  set page(numbering: "1")
  counter(page).update(1)
  
  body
  
  // Back cover
  if cfg.cover.at("back", default: cover == auto) {
    let generate-cover
    
    meta += (is-back-cover: true)
    
    if cover == auto {generate-cover = cfg.theme.cover-page}
    else if type(cover) == function {generate-cover = cover}
    else {panic("Back cover must be function (got " + repr(type(cover)) + ")")}
    
    generate-cover(meta, cfg.cover)
  }
}

/// = Commands
