// Public helpers and layout state provided by this template.

#let thesis-draft-state = state("thesis-draft", true)
#let thesis-color-state = state("thesis-color", true)

#let freiburg-blue = rgb("#344A9A")

#let default-fonts = (
  body: "Libertinus Serif",
  sans: "New Computer Modern",
  mono: "DejaVu Sans Mono",
)

// === TODO FUNCTIONS ===
#let todo(content, color: red) = {
  rect(
    fill: color.lighten(80%),
    stroke: color,
    radius: 3pt,
    inset: 5pt,
    width: 100%,
  )[*TODO:* #content]
}

#let todo-missing(content) = todo(content, color: rgb(204, 0, 204))
#let todo-check(content) = todo(content, color: rgb(204, 0, 0))
#let todo-revise(content) = todo(content, color: rgb(204, 102, 0))
#let todo-citation(content) = todo(content, color: rgb(204, 204, 0))
#let todo-language(content) = todo(content, color: rgb(102, 102, 204))
#let todo-question(content) = todo(content, color: rgb(0, 204, 0))
#let todo-note(content) = todo(content, color: rgb(51, 51, 51))

// === LAYOUT HELPERS ===
#let unnumbered-chapter(body) = {
  heading(level: 1, numbering: none, outlined: false, body)
}

// === CUSTOM FIGURE TYPES ===
#let algorithm(content, caption: none) = {
  figure(
    align(left)[
      #rect(
        width: 100%,
        stroke: 0.5pt + gray,
        inset: 10pt,
        content
      )
    ],
    caption: caption,
    supplement: "Algorithm",
  )
}

// === HIGHLIGHTING ===
#let important(content) = context {
  if thesis-color-state.get() {
    highlight(fill: yellow.lighten(60%), content)
  } else {
    emph(content)
  }
}

// === CUSTOM BOXES ===
#let definition(title: "Definition", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: freiburg-blue,
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: freiburg-blue)[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

#let theorem(title: "Theorem", content) = context {
  if thesis-color-state.get() {
    rect(
      width: 100%,
      stroke: green.darken(20%),
      radius: 3pt,
      inset: 10pt,
    )[
      #text(weight: "bold", fill: green.darken(20%))[#title.] #content
    ]
  } else {
    rect(
      width: 100%,
      stroke: 0.5pt + gray,
      radius: 0pt,
      inset: 10pt,
    )[
      #text(weight: "bold")[#title.] #content
    ]
  }
}

// === SIDE NOTES (margin "footnotes") ===
#let sidenote-config = state("thesis-sidenote-config", (
  mode: "sidenote",
  page-width: 210mm,
  margin: 45mm,
  gap: 5mm,
  edge: 2mm,
  size: 8pt,
  numbering: "1",
))

#let sidenote-counter = counter("thesis-sidenote")

// Render a note in the outer margin, or as a regular footnote in non-book mode.
#let sidenote(body, numbered: false, dy: 0pt) = {
  if numbered { sidenote-counter.step() }
  context {
    let cfg = sidenote-config.get()
    if cfg.mode == "footnote" {
      footnote(body)
    } else {
      let recto = calc.odd(here().page())
      let pos = here().position()
      let note-width = cfg.margin - cfg.gap - cfg.edge
      let marker = super(numbering(cfg.numbering, ..sidenote-counter.get()))
      if numbered { marker }

      let note-align = if recto { left } else { right }
      let note-body = {
        set text(size: cfg.size)
        set par(justify: false, leading: 0.5em, first-line-indent: 0pt)
        align(note-align, {
          if numbered { marker + h(0.35em) }
          body
        })
      }

      let target-x = if recto { cfg.page-width - cfg.margin + cfg.gap } else { cfg.edge }

      box(place(
        top + left,
        dx: target-x - pos.x,
        dy: dy,
        box(width: note-width, note-body),
      ))
    }
  }
}

// === CITATIONS ===
#let citep(..keys) = keys.pos().map(k => cite(k)).join()
#let citet(..keys) = keys.pos().map(k => cite(k, form: "prose")).join()

// === ABBREVIATIONS ===
#let ie = [_i.e._]
#let eg = [_e.g._]
#let cf = [_cf._]
#let etal = [_et al._]

#let default-sections = (
    (size: 14pt, weight: "bold", space_before: 35pt, space_after: 20pt, style: none), // section
    (size: 12pt, weight: "bold", space_before: 25pt, space_after: 16pt, style: none), // subsection
    (size: 12pt, weight: "bold", space_before: 20pt, space_after: 16pt, style: none)  // subsubsection
)

/*
This is the main function to setup a thesis
*/
#let thesis(
  // Metadata
  title: "Thesis Title",
  author: "Author Name",
  email: "",
  immatriculation: "",
  jury: (),
  jury-title: auto, // auto | none | string/content
  department: "Department of Computer Science",
  faculty: "Faculty of Engineering, University of Freiburg",
  research-group: "",
  website: "",
  location: "Freiburg im Breisgau",
  thesis-type: "bachelor", // "bachelor" | "master" | "phd"
  date: datetime.today(),
  language: "en",
  title-language: auto, // language of the title page; `auto` follows `language`

  // Pass your own fonts
  body-font: default-fonts.body,
  sans-font: default-fonts.sans,
  mono-font: default-fonts.mono,

  // Font sizes - individual parameters
  body-size: 11pt,
  mono-size: 11pt,
  footnote-size: 11pt,
  header-size: 11pt,

  // Page & book layout
  two-sided: true,        // mirror margins on odd/even pages when `mirror-book` is enabled
  mirror-book: auto,      // auto follows `two-sided`; false uses symmetric margins and regular footnotes
  margin-top: 3.5cm,
  margin-bottom: 3.5cm,
  margin-inner: 3cm,      // binding (inner) margin
  margin-outer: 5.5cm,    // outer margin — also hosts the side notes
  binding: auto,          // spine side: auto (from language), left, or right

  // Side notes (footnotes typeset in the outer margin)
  sidenote-size: 9pt,  
  sidenote-gap: 7mm,   // gap between the text body and the note
  sidenote-edge: 10mm,  // gap between the note and the outer page edge

  // Heading sizes - individual parameters
  chapter-number-size: 100pt,  // chapter number, now shown in the outer margin
  chapter-title-size: 24pt,

  sections: default-sections, // make default a variable, such that individual entries of array can be modified
  default-section: (size: 12pt, weight: "bold", space_before: 20pt, space_after: 16pt,  style: none),

  // Font weights - new parameters
  chapter-number-weight: "bold",
  chapter-title-weight: "bold",

  // Custom text styling functions - optional overrides
  // These allow complete control over text styling if provided
  body-text-style: none,           // Custom function for body text
  mono-text-style: none,           // Custom function for mono/code text
  chapter-number-style: none,      // Custom function for chapter numbers
  chapter-title-style: none,       // Custom function for chapter titles

  logo: auto, // options: auto | none | path | image-element
  logo-width: 50%,

  // Decorative university seal on the title page (background graphic)
  seal: auto,        // options: auto | none | path | image-element
  seal-width: 17cm,
  seal-dx: 8.3cm,    // horizontal offset (lets the seal bleed off the right edge)
  seal-dy: 3.1cm,    // vertical offset from the page center
  seal-opacity: 18%, // how visible the seal is (0% = invisible, 100% = solid)

  // compile mode
  draft: true,        // displays todos
  colored: false,      // Use colors for definitions, theorems, etc.

  // Content
  abstract: [],        // abstract in the document language (`language`)
  abstract-en: none,   // English abstract  -> "Abstract"
  abstract-de: none,   // German abstract   -> "Zusammenfassung"
  declaration: auto,   // auto | none | content; custom content replaces only the declaration text
  declaration-signature: auto, // auto | true | false; false shows only the author name
  acknowledgments: none,
  chapters: (),
  appendices: (),
  bibliography-content: none,
  body,
) = {

  // Set the configuration states (add this at the beginning)
  thesis-draft-state.update(draft)
  thesis-color-state.update(colored)
  set document(title: title, author: author)

  // Physical page width (A4). Used to push the section numbers and side notes
  // into the outer margin. Keep in sync with the page `paper` below.
  let page-width = 21cm
  let book-layout = if mirror-book == auto {
    two-sided
  } else if mirror-book == true or mirror-book == false {
    mirror-book
  } else {
    panic("mirror-book must be auto, true, or false")
  }

  // Make the side-note geometry available to the `sidenote` function so the
  // note width always matches the configured outer margin.
  sidenote-config.update((
    mode: if book-layout { "sidenote" } else { "footnote" },
    page-width: page-width,
    margin: margin-outer,
    gap: sidenote-gap,
    edge: sidenote-edge,
    size: sidenote-size,
    numbering: "1",
  ))

  // Non-book pages and title/front-matter pages use symmetric left/right
  // margins. This keeps the text width unchanged while removing the outer
  // side-note margin.
  let symmetric-margin = (
    top: margin-top,
    bottom: margin-bottom,
    x: (margin-inner + margin-outer) / 2,
  )
  // Mirrored (book) margins: the inner margin is the binding side and the
  // outer margin hosts the side notes. Typst flips `inside`/`outside` on
  // odd/even pages. With `mirror-book: false`, use regular symmetric margins.
  let page-margin = if book-layout {
    if two-sided {
      (top: margin-top, bottom: margin-bottom, inside: margin-inner, outside: margin-outer)
    } else {
      (top: margin-top, bottom: margin-bottom, left: margin-inner, right: margin-outer)
    }
  } else {
    symmetric-margin
  }

  // Page setup - matches LaTeX template exactly
  set page(
     paper: "a4",
     margin: page-margin,
     binding: binding,
     header: context {
       let pg = counter(page).get().first()
       if pg > 1 {
         // Chapter-opening pages carry the page number in the footer instead,
         // so they get no running header.
         let on-chapter-page = query(heading.where(level: 1)).any(h =>
           h.location().page() == here().page()
         )

         if not on-chapter-page {
           set text(size: header-size, font: body-font)  // body colour, not gray

           let body-width = page-width - margin-inner - margin-outer
           let recto = if book-layout and two-sided { calc.odd(pg) } else { true }

           let headings = query(heading.where(level: 1).before(here()))
           let chapter = if headings.len() > 0 { headings.last() } else { none }

           // Verso (left): chapter number + title. Recto (right): the current
           // section title, or nothing if the chapter has no section yet.
           let header-text = if not recto {
             if chapter != none {
               smallcaps(chapter.body)
             } else { [] }
           } else {
             let section-headings = query(heading.where(level: 2).before(here()))
             if section-headings.len() > 0 and chapter != none and (
               counter(heading).at(section-headings.last().location()).first()
                 == counter(heading).at(chapter.location()).first()
             ) {
               let title = smallcaps(section-headings.last().body)
               if chapter.numbering != none {
                 [#numbering("1.1", ..counter(heading).at(section-headings.last().location())) #h(0.6em) #title]
               } else { title }
             } else { [] }
           }

           // The page number sits out in the external margin; the header text is
           // aligned to the external edge of the text block.
           let page-no = counter(page).display()
           block(width: 100%, {
             if not book-layout {
               grid(columns: (1fr, auto), column-gutter: 1em, header-text, page-no)
             } else if recto {
               place(top + left, dx: body-width + sidenote-gap, page-no)
               align(right, header-text)
             } else {
               place(top + right, dx: -(body-width + sidenote-gap), page-no)
               align(left, header-text)
             }
           })
         }
       }
     },
     footer: context {
       let pg = counter(page).get().first()
       let on-chapter-page = query(heading.where(level: 1)).any(h =>
         h.location().page() == here().page()
       )
       // On chapter-opening pages the page number sits at the bottom, in the
       // external margin (lower outer corner).
       if pg > 1 and on-chapter-page {
         set text(size: header-size, font: body-font)
         let body-width = page-width - margin-inner - margin-outer
         let recto = if book-layout and two-sided { calc.odd(pg) } else { true }
         let page-no = counter(page).display()
         if not book-layout {
           align(center, page-no)
         } else if recto {
           place(top + left, dx: body-width + sidenote-gap, page-no)
         } else {
           place(top + right, dx: -(body-width + sidenote-gap), page-no)
         }
       }
     }
   )

  // Typography - apply default settings first
  set text(
    font: body-font,
    size: body-size,
    lang: language
  )

  show raw: set text(
    font: mono-font,
    size: mono-size,
    lang: language
  )

  // Apply custom styling if provided (this will override the defaults)
  if body-text-style != none {
    show: body-text-style
  }

  if mono-text-style != none {
    show raw: mono-text-style
  }

  // Paragraph settings - matching LaTeX
  set par(
    justify: true,
    leading: 0.65em * 1.5,  // 1.5 line spacing
    first-line-indent: 0pt,  // No indent as in LaTeX
  )

  // Footnote settings
  set footnote.entry(
    separator: line(length: 30%, stroke: 0.5pt),
    gap: 0.65em,
  )

  show footnote.entry: it => {
    set text(size: footnote-size)
    it
  }

  // Short prose-citation syntax: `@key[t]` renders the textual form
  // ("Turing [1]", like LaTeX \citet) while plain `@key` stays "[1]" (\citep).
  // The `[t]` is a sentinel supplement; for a prose citation that also needs a
  // real supplement (e.g. a page), use `#citet` / `#cite(..., supplement: ...)`.
  show ref: it => {
    if it.supplement == [t] {
      cite(it.target, form: "prose")
    } else {
      it
    }
  }

  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      // Chapter: no dot
      numbering("1", ..nums)
    } else  {
      // Sections and subsections: with dots
      numbering("1.", ..nums)
    }
  })

  // Equation numbering
  set math.equation(numbering: "1.")

  show heading: it => {
    // Chapter style: the number sits in the OUTER margin, bottom-aligned with
    // the title baseline; the title is left-aligned; and a separator rule runs
    // the full width *below* the title.
    if it.level == 1 {
      pagebreak(weak: true)
      v(50pt)

      let number = counter(heading).display()
      let body-width = page-width - margin-inner - margin-outer

      context {
        // Accent colour for the margin number and the rule: Freiburg blue when
        // colored, gray otherwise.
        let accent = if thesis-color-state.get() { freiburg-blue } else { rgb(120, 120, 120) }
        let recto = if book-layout and two-sided { calc.odd(here().page()) } else { true }

        block(breakable: false, width: 100%, {
          // `bottom-edge: "baseline"` makes both the title block and the number
          // measure down to their baselines, so bottom-aligning the placed
          // number lands its baseline exactly on the title's baseline.
          set text(bottom-edge: "baseline")

          // Chapter number in the outer margin, bottom-aligned with the title.
          if it.numbering != none {
            let num-label = if chapter-number-style != none {
              chapter-number-style(number)
            } else {
              text(size: chapter-number-size, font: sans-font, weight: chapter-number-weight, fill: accent, number)
            }
            if recto {
              place(bottom + left, dx: body-width + sidenote-gap, num-label)
            } else {
              place(bottom + right, dx: -(body-width + sidenote-gap), num-label)
            }
          }

          // Title, left-aligned.
          if chapter-title-style != none {
            chapter-title-style(it.body)
          } else {
            text(size: chapter-title-size, font: sans-font, weight: chapter-title-weight, it.body)
          }
        })

        // Separator rule below the title.
        v(12pt)
        line(length: 100%, stroke: 1pt + accent)
      }
      v(30pt)
    } else {
      // Section style
      let index = it.level - 2
      let section = if index < sections.len() {
        sections.at(index)
      } else {
        default-section
      }

      v(section.space_before, weak:true)
      block(breakable: false)[
        #if section.style != none {
          section.style(counter(heading).display() + " " + it.body)
        } else {
          text(size: section.size, font: sans-font, weight: section.weight)[
            #counter(heading).display() #it.body
          ]
        }
      ]
      v(section.space_after, weak: true)  // Space after section - matching paragraph spacing
    }
  }

  // Title page - matching LaTeX layout
  // The title page can use its own language (e.g. German front matter for an
  // otherwise English thesis); `auto` falls back to the document language.
  let title-lang = if title-language == auto { language } else { title-language }
  let formatted-date(lang) = if lang == "en" {
    date.display("[month repr:long] [day], [year]")
  } else {
    let months-de = (
      "Januar", "Februar", "März", "April", "Mai", "Juni",
      "Juli", "August", "September", "Oktober", "November", "Dezember",
    )
    [#str(date.day()). #months-de.at(date.month() - 1) #str(date.year())]
  }
  let resolved-thesis-type = if thesis-type == "bachelor" {
    "bachelor"
  } else if thesis-type == "master" {
    "master"
  } else if thesis-type == "phd" {
    "phd"
  } else {
    panic("thesis-type must be one of: \"bachelor\", \"master\", or \"phd\"")
  }
  let front-page-date = if resolved-thesis-type == "phd" {
    [#location, #str(date.year()).]
  } else if title-lang == "de" {
    [#location, den #formatted-date(title-lang)]
  } else {
    [#location, #formatted-date(title-lang)]
  }
  let resolved-thesis-title = if title-lang == "en" {
    if resolved-thesis-type == "bachelor" {
      [Bachelor Thesis]
    } else if resolved-thesis-type == "master" {
      [Master Thesis]
    } else {
      [
        Dissertation for the Degree of Doctor of Engineering \
        of the Faculty of Engineering at the University of Freiburg
      ]
    }
  } else {
    if resolved-thesis-type == "bachelor" {
      [Bachelorarbeit]
    } else if resolved-thesis-type == "master" {
      [Masterarbeit]
    } else {
      [
        Dissertation zur Erlangung des Doktorgrades \
        der Technischen Fakultät \ 
        der Albert-Ludwigs-Universität Freiburg im Breisgau
      ]
    }
  }
  let resolved-jury-title = if jury-title == auto {
    if resolved-thesis-type == "phd" {
      if title-lang == "en" [Jury] else [Prüfungskommission]
    } else {
      none
    }
  } else {
    jury-title
  }
  let resolved-declaration-signature = if declaration-signature == auto {
    resolved-thesis-type != "phd"
  } else if declaration-signature == true or declaration-signature == false {
    declaration-signature
  } else {
    panic("declaration-signature must be auto, true, or false")
  }
  let declaration-signature-block(place-date-label) = block(width: 100%)[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 2cm,
      row-gutter: 0.5em,
      align: left,
      [#location, #formatted-date(language)], [],
      line(length: 100%, stroke: 0.4pt), line(length: 100%, stroke: 0.4pt),
      place-date-label, author,
    )
  ]
  let declaration-author-block = block(width: 100%)[
    #align(right)[#author]
  ]
  let declaration-page(heading, body, place-date-label) = [
    #set par(first-line-indent: 0pt)
    #unnumbered-chapter(heading)
    #v(3em)
    #text(lang: language, body)
    #v(6em)
    #if resolved-declaration-signature {
      declaration-signature-block(place-date-label)
    } else {
      declaration-author-block
    }
  ]
  let declaration-heading = if language == "de" [Erklärung] else [Declaration]
  let declaration-place-date-label = if language == "de" [Ort, Datum] else [Place, date]
  let default-declaration-text = if language == "de" and resolved-thesis-type == "phd" {
    [
      Hiermit erkläre ich, dass der Inhalt dieser Dissertation, außer an den Stellen, an denen
      ausdrücklich auf die Arbeit anderer verwiesen wird, eigenständig erarbeitet wurde und weder
      ganz noch teilweise zur Erlangung eines anderen akademischen Grades oder einer anderen
      Qualifikation an dieser oder einer anderen Universität eingereicht wurde. Diese Dissertation
      ist meine eigene Arbeit und enthält nichts, was aus einer Zusammenarbeit mit anderen
      hervorgegangen ist, sofern dies nicht im Text entsprechend angegeben ist.
    ]
  } else if language == "de" {
    [
      Hiermit erkläre ich, dass ich diese Abschlussarbeit selbständig verfasst habe, keine anderen
      als die angegebenen Quellen/Hilfsmittel verwendet habe und alle Stellen, die wörtlich oder
      sinngemäß aus veröffentlichten Schriften entnommen wurden, als solche kenntlich gemacht
      habe.

      Darüber hinaus erkläre ich, dass diese Abschlussarbeit nicht, auch nicht
      auszugsweise, bereits für eine andere Prüfung angefertigt wurde.
    ]
  } else if resolved-thesis-type == "phd" {
    [
      I hereby declare that except where specific reference is made to the work of others, the
      contents of this dissertation are original and have not been submitted in whole or in part
      for consideration for any other degree or qualification in this, or any other university. 
      
      This dissertation is my own work and contains nothing which is the outcome of work done in
      collaboration with others, except as specified in the text.
    ]
  } else {
    [
      I hereby declare, that I am the sole author and composer of my thesis and
      that no other sources or learning aids, other than those listed, have been used.

      Furthermore, I declare that I have acknowledged the work of others
      by providing detailed references of said work.

      I also hereby declare that my thesis has not been prepared
      for another examination or assignment, either in its entirety or excerpts thereof.
    ]
  }
  let resolved-declaration = if declaration == none {
    none
  } else {
    let declaration-text = if declaration == auto {
      default-declaration-text
    } else {
      declaration
    }
    declaration-page(declaration-heading, declaration-text, declaration-place-date-label)
  }
  // Use symmetric margins for the title page only (restored after it).
  set page(margin: symmetric-margin)
  align(center)[
    // Decorative university seal, bleeding off the right edge of the page.
    // Placed first so the title-page text renders on top of it.
    #if seal != none [
      #let seal-img = if seal == auto {
        image("assets/template/logo-freiburg/Uni_Siegel.svg", width: seal-width)
      } else if type(seal) == "string" {
        image(seal, width: seal-width)
      } else {
        // Assume it's already an image element
        seal
      }
      // Fade the seal into a watermark by overlaying a translucent white layer,
      // so the title-page text stays legible. The wrapping box is given the
      // seal's exact measured size so the overlay's `height: 100%` resolves to
      // the full image height (an auto-height box would only fade the top part).
      #place(right + horizon, dx: seal-dx, dy: seal-dy, context {
        let size = measure(seal-img)
        box(width: size.width, height: size.height)[
          #seal-img
          #place(
            top + left,
            rect(width: 100%, height: 100%, fill: white.transparentize(seal-opacity)),
          )
        ]
      })
    ]

    // Automatically select logo based on language
    #if logo != none [
      #let logo-to-use = if logo == auto {
        image("assets/template/logo-freiburg/20221026-UFR-wortmarke-grundform_Blau_RGB.svg", width: logo-width)
      } else {
        // User provided logo
        if type(logo) == "string" {
          image(logo, width: logo-width)
        } else {
          // Assume it's already an image element
          logo
        }
      }
      #place(top + left, logo-to-use)
    ]

    #if draft [
      #place(top + right,
        rect(
          fill: red.lighten(90%),
          stroke: red,
          inset: 10pt,
        )[
          #text(size: 11pt, fill: red, weight: "bold")[DRAFT VERSION] \
          #text(size: 9pt, fill: red)[
            #datetime.today().display("[day].[month].[year]")
          ]
        ]
      )
    ]

    #v(if resolved-thesis-type == "phd" { 5cm } else { 4cm })

    #text(size: 24pt, font: sans-font, weight: "bold")[#title]

    #v(0.5cm)
    #text(size: 11pt, weight: "bold")[#resolved-thesis-title]

    #v(1cm)

    #text()[
      #if title-lang == "en" [presented by] else [vorgelegt von]
    ]

    #v(1cm)
    
    #text(size: 11pt)[
      #text(weight: "bold", size: 24pt)[#author] \
      #email \
      #if immatriculation != "" [
        #immatriculation
      ]
    ]
    
    #v(1.5cm)

    #text(size: 11pt)[
      #if research-group != "" [
        #research-group \
      ]
      #department \
      #faculty \

      #if website != "" [
        #website \
      ]
    ]

    #if jury.len() > 0 and resolved-thesis-type != "phd" [
      #v(1.5cm)
      #if resolved-jury-title != none and resolved-jury-title != "" [
        #text(size: 11pt, weight: "bold")[#resolved-jury-title]
      ]
      #set text(size: 11pt)
      #grid(
        columns: (auto, auto),
        column-gutter: 1.2em,
        row-gutter: 0.75em,
        align: (right, left),
        ..jury
          .map(((role, person)) => ([#role:], strong(person)))
          .flatten()
      )
    ]

    #v(1fr)

    #text(size: 11pt, lang: title-lang)[
      #front-page-date
    ]
  ]

  if resolved-thesis-type == "phd" {
    pagebreak()
    align(left)[
      #v(4cm)
      #if jury.len() > 0 [
        #if resolved-jury-title != none and resolved-jury-title != "" [
          #text(size: 11pt, weight: "bold")[#resolved-jury-title]
          #v(1em)
        ]
        #set text(size: 11pt)
        #grid(
          columns: (auto, auto),
          column-gutter: 1.2em,
          row-gutter: 0.75em,
          align: (left, left),
          ..jury
            .map(((role, person)) => ([#role:], strong(person)))
            .flatten()
        )
        #v(2cm)
      ]
      #text(size: 11pt, lang: title-lang)[
        #if title-lang == "en" [
          Date of oral examination: #formatted-date(title-lang)
        ] else [
          Datum der mündlichen Prüfung: #formatted-date(title-lang)
        ]
      ]
    ]
  }

  // Restore the mirrored book margins for the rest of the document.
  set page(margin: page-margin)

  // Declaration
  if resolved-declaration != none and resolved-declaration != [] {
    pagebreak()
    resolved-declaration
  }

  // Acknowledgments
  if acknowledgments != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Acknowledgments] else [Danksagung]
    ]
    acknowledgments
  }
  
  // Abstract(s) - English ("Abstract") and/or German ("Zusammenfassung").
  // `abstract` is treated as the abstract in the document language, so existing
  // single-language usage keeps working; `abstract-en` / `abstract-de` override.
  let abstract-en = if abstract-en != none { abstract-en } else if language == "en" { abstract } else { none }
  let abstract-de = if abstract-de != none { abstract-de } else if language == "de" { abstract } else { none }

  let abstract-entries = (
    ("en", "Abstract", abstract-en),
    ("de", "Zusammenfassung", abstract-de),
  )
  // Show the abstract in the document language first.
  if language == "de" { abstract-entries = abstract-entries.rev() }

  for (lang, heading, content) in abstract-entries {
    if content != none and content != [] {
      pagebreak()
      unnumbered-chapter[#heading]
      text(lang: lang, content)
    }
  }

  // Table of contents
  pagebreak()
  unnumbered-chapter[
    #if language == "en" [Table of Contents] else [Inhaltsverzeichnis]
  ]

  outline(indent: auto, title: none)

  // Main content chapters
  pagebreak()
  for chapter-content in chapters {
    chapter-content
  }

  // Additional body content
  body

  // Bibliography
  if bibliography-content != none {
    pagebreak()
    unnumbered-chapter[
      #if language == "en" [Bibliography] else [Literaturverzeichnis]
    ]
    bibliography-content
  }

  // Appendices
  if appendices.len() > 0 {
    pagebreak()
    set heading(numbering: (..nums) => {
      let level = nums.pos().len()
      if level == 1 {
        // Appendix chapters: no dot
        numbering("A", ..nums)
      } else if level <= 3 {
        // Appendix sections and subsections: with dots
        numbering("A.1", ..nums)
      }
      // Level 4 and deeper: no numbering
    })
    counter(heading).update(0)

    for appendix-content in appendices {
      appendix-content
    }
  }
}
