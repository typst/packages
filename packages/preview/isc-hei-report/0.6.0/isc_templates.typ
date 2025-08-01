// Template for ISC bachelor degree programme at the School of engineering in Sion
// Since 2024, @pmudry with contributions from @LordBaryhobal, @MadeInShineA
// Bachelor thesis template first page inspired from Lasse Rosenow work on https://typst.app/universe/package/haw-hamburg-master-thesis

#import "lib/includes.typ" as inc

// Global settings
#let space-after-heading = 0.5em
#let chapter-font-size = 1.4em
#let chapter-font-weight = 650
#let global-keywords = inc.global-keywords
#let version = "0.6.0"

//////////////////////////
// User callable functions
// //////////////////////////
#let heavy-title(title, mult: 1.5, bottom: 2pt, top: 4em) = {
  set text(size: chapter-font-size * mult, weight: chapter-font-weight)
  block(fill: none, inset: (x: 0pt, bottom: bottom, top: top), below: space-after-heading * mult, {
    title
  })
}

// Enable the display of headers and footers
#let set-header-footer(enabled) = {
  context inc.header-footers-enabled.update(enabled)
}

// Make a page break so that the next page starts on an odd page
#let cleardoublepage() = {  
  pagebreak(weak: true)    
  inc.blank-page.update(true)
  pagebreak(to: "odd", weak: true)  
  inc.blank-page.update(false)
}

// Indicate that something still needs to be done
#let todo(body, fill-color: yellow.lighten(50%)) = {
  set text(black)
  box(baseline: 25%, fill: fill-color, inset: 4pt, [*TODO* #body])
}

// Generate a lorem ipsum with paragraphs
#let lorem-pars(n-words, each: 5) = {
  let n = int(n-words / (each * 30))  
  let sentences = lorem(n * (each * 30)).split(". ")

  range(n)
    .map(i => sentences.slice(i * each, count: each).join(". ") + [.])
    .join(parbreak())
}

// Cetz
#let scale-to-width(width, body) = layout(page-size => {
  let size = measure(body, ..page-size)
  let target-width = if type(width) == ratio {
    page-size.width * width
  } else if type(width) == relative {
    page-size.width * width.ratio + width.length
  } else {
    width
  }
  let multiplier = target-width.to-absolute() / size.width
  scale(reflow: true, multiplier * 100%, body)
})

//
// Multiple languages support
// Thanks @LordBaryhobal for the original idea
//
#let langs = json("i18n.json")

#let i18n(lang, key, extra-i18n: none) = {
  let langs = langs
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }

  let keys = langs.at(lang)

  assert(key in keys, message: "I18n key " + str(key) + " doesn't exist")
  return keys.at(key)
}

#let _make-outline(font: auto, title, ..args) = {
  {
    show heading:none
    heading(bookmarked: true, numbering: none, outlined: false)[Table of contents]    
  }

  let title = if font == auto { title } else {
    text(font: font, title)
  }
  
  outline(title: {
    v(2em)
    text(size: chapter-font-size, weight: chapter-font-weight, title)
    v(3em)
  }, indent: 2em, ..args)
  pagebreak(weak: true)
}

// Generates the special appendix page
#let appendix-page() = {
  context{
    {
      show heading: none
      heading(numbering:none)[#i18n(inc.global-language.get(), "appendix-title")]      
    }

    // The appendix page
    place(center + horizon, [
      #{
        set text(size: chapter-font-size * 2, weight: chapter-font-weight)
        i18n(inc.global-language.get(), "appendix-title")
      }
    ])
  }
}

// Generate the table of contents with a given depth
#let table-of-contents(depth: 2) = {
  context {
    let f = inc.global-language.get()
    _make-outline(i18n(f, "toc-title"), depth: depth)
  }
}

// Generate the table of figures
#let table-of-figures(depth: 1) = {
  context {
    let f = inc.global-language.get()
    outline(
      title: heavy-title(i18n(f, "figure-table-title"), mult: 1, top: 1em, bottom: 1em),
      depth: 1,
      indent: auto,
      target: figure.where(kind: image),
    )
  }
}

// Genereate the proper header for the code samples appendix
#let code-samples() = {  
  context{
    heading(
      numbering: none,
      depth: 2,
      outlined: false,
      bookmarked: false,
      text(
        heavy-title(i18n(inc.global-language.get(), "appendix-code-name"), mult: 1, top: 1em, bottom: 1em)),
    )
  }  
}

#let the-bibliography(
  bib-file: none,
  full: false,
  style: "ieee"  
) = {
  context {        
    let title = i18n(inc.global-language.get(), "bibliography-title")    
    show heading: none
    heading(bookmarked: true, numbering: none, outlined: true)[#title]
    heavy-title(title, mult: 1, top: 0.5em, bottom: 0.3em)    
    bibliography("src/" + bib-file, full: full, style: style, title:none)
  }
}


#let abstract-footer(lang) = {

  let colon = context if lang == "fr" { " : " } else { ": " }

  [
  #v(1fr)
  #context {text(i18n(lang, "keywords"), weight: "bold") + colon + inc.global-keywords.get().join(", ")}
  #v(-1mm)
  #context {text(i18n(lang, "repository"), weight: "bold") + colon + raw(inc.global-project-repos.get())}
  ]
}

//////////////////////////
// Source code inclusion
//////////////////////////
#let _luma-background = luma(250)

// Replace the original function by ours
#let codelst-sourcecode = inc.sourcecode

#let code = codelst-sourcecode.with(
  frame: block.with(fill: _luma-background, stroke: 0.5pt + luma(80%), radius: 3pt, inset: (x: 6pt, y: 7pt)),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size: 7pt, lno),
  numbers-step: 1,
  numbers-width: -1em,
  gutter: 1.2em,
)

/*********************************
 ** The template itself
 ********************************/
#let project(
  title: [Report title],
  subtitle: none,
  academic-year: [2024-2025],
  // If it's a thesis
  is-thesis: false,
  split-chapters: true,
  thesis-supervisor: [Thesis supervisor],
  thesis-co-supervisor: none,
  thesis-expert: "[Thesis expert]",
  thesis-id: none,
  project-repos: none,
  keywords: (),
  major: (),
  school: [School name],
  programme: [Informatique et Systèmes de Communication],
  // If it's executive summary
  is-executive-summary: false,
  summary: none,
  content: none,
  student-picture: none,
  permanent-email: "john@doe.com",
  video-url: none,
  bind: none,
  footer: none,
  // If it's a report
  course-name: [Course name],
  course-supervisor: [Course supervisor],
  semester: [Semester],
  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: [KNN graph -- Inspired by _Marcus Volg_],
  cover-image-kind: auto,
  cover-image-supplement: auto,
  // A list of authors, separated by commas
  authors: (),
  date: none,
  logo: none,
  equations: false,
  revision: none,
  language: "fr",
  extra-i18n: none,
  code-theme: "bluloco-light",
  body,
) = {
  
  // Update state with the passed values so they are accessible globally
  inc.global-keywords.update(keywords)
  inc.global-language.update(language)

  if(project-repos != none) {
    inc.global-project-repos.update(project-repos)
  }else{
    if(is-thesis) {panic("No project repository provided, you need to provide one!")}
  }

  let i18n = i18n.with(extra-i18n: extra-i18n, language)

  // Set the document's basic properties.
  set document(author: authors, title: title, date: date, keywords: keywords, description: "Using ISC template ver. " + version)

  set par(justify: true)
  
  //  Fonts
  let body-font = ("Source Sans Pro", "Source Sans 3", "Libertinus Serif")
  let sans-font = ("Source Sans Pro", "Source Sans 3", "Inria Sans")
  let raw-font = "Fira Code"
  let math-font = ("Asana Math", "Fira Math")

  // Default body font
  set text(font: body-font, lang: language)

  // Set other fonts
  // show math.equation: set text(font: math-font) // For math equations
  let selected-theme = "src/themes/" + code-theme + ".tmTheme"
  set raw(theme: selected-theme)
  show raw: set text(font: raw-font) // For code

  show heading: set text(font: sans-font) // For sections, sub-sections etc..

  /////////////////////////////////////////////////
  // Citation style
  /////////////////////////////////////////////////
  set cite(style: auto, form: "normal")

  /////////////////////////////////////////////////
  //  Basic pagination and typesetting
  /////////////////////////////////////////////////
  set rect(width: 100%, height: 100%, inset: 4pt)

  // Thesis specific settings
  set page(
    margin: (inside: 2.5cm, outside: 1.5cm, bottom: 2.1cm, top: 2cm), // Binding inside
    paper: "a4",
  ) if(is-thesis)  

  // Report specific settings
  set page(
    margin: (inside: 2.5cm, outside: 2cm, y: 2.1cm), // Binding inside
    paper: "a4",    
  ) if(not is-executive-summary and not is-thesis)

  if (not is-thesis) {
    // For reports, we want to put the header and footer on all pages
    set-header-footer(true)
  } else {
    // For theses, we want to put the header and footer only on the first page
    set-header-footer(false)
  }

  show heading: it => {
    // In a thesis, put chapters begin on odd pages
    // Add the header in a block to make space around it
    if it.level == 1 and is-thesis and split-chapters {      
      pagebreak(weak: true)    
      inc.blank-page.update(true)
      pagebreak(to: "odd", weak: true)  
      inc.blank-page.update(false)
      
      block(fill: none, inset: (x: 0pt, bottom: 2pt, top: 1em), below: space-after-heading * 2, if (it.numbering != none) {
        // If the heading has a numbering, display it
        text(i18n("chapter-title") + " " + counter(heading).display() + " " + it.body, size: chapter-font-size, weight: chapter-font-weight)        
      } else {
        // Otherwise just display the body
        it
      })
    } else {
      it
    }
  }

  // Manage authors single and plural
  let authors-str = ()

  if type(authors) == str {
    authors = (authors,)
  }

  if authors.len() > 1 {
    authors-str = authors.join(", ")
  } else if authors.len() == 1 {
    authors-str = authors.at(0)
  } else {
    panic("No authors provided for the report")
  }  

  let footer-content = context text(0.75em)[
    #{
      emph(title) 
      if revision != none {
          text(", rev " + revision, style: "italic")
      }

      h(1fr)
      counter(page).display("1/1", both: true)
    }
  ]
  
  // Set header and footers
  set page(
    // For pages other than the first one
    header: context if counter(page).get().first() > 1 {
      if inc.header-footers-enabled.get() and not inc.blank-page.get() {
        let header-content = text(0.75em)[
          #emph(authors-str)            
        ]

        let page = counter(page).get().first()
        let content = if calc.odd(page) { align(right, header-content) } else { align(left, header-content)}
        content
      }
    },
    header-ascent: 40%,
    // For pages other than the first one
    footer: context if counter(page).get().first() > 1 {
      if inc.header-footers-enabled.get() and not inc.blank-page.get() {
        move(dy: 5pt, line(length: 100%, stroke: 0.5pt))
        footer-content
      } else {
        none
      }
    },
  )

  // Links coloring
  show link: set text(ligatures: true, fill: blue)

  // Sections numbers
  set heading(numbering: "1.1.1 –") if (is-thesis)
  set heading(numbering: "1.1.1 –") if (not is-thesis)

  /////////////////////////////////////////////////
  // Handle specific captions styling
  /////////////////////////////////////////////////

  // Compute a supplement for captions as they are not to my liking
  let getSupplement(it) = {
    let f = it.func()
    if (f == image) {
      i18n("figure-name")
    } else if (f == table) {
      i18n("table-name")
    } else if (f == raw) {
      i18n("listing-name")
    } else {
      auto
    }
  }

  set figure(numbering: "1", supplement: getSupplement)

  // Make the caption like I like them
  show figure.caption: set text(9pt) // Smaller font size
  show figure.caption: emph // Use italics
  set figure.caption(separator: " - ") // With a nice separator

  show figure.caption: it => { it.counter.display() } // Used for debugging

  // Make the caption like I like them
  show figure.caption: it => context {
    if it.numbering == none {
      it.body
    } else {
      it.supplement + " " + it.counter.display() + it.separator + it.body
    }
  }

  /////////////////////////////////////////////////
  // Code related, only for inline as the
  // code block is handled by function at the top of the file
  /////////////////////////////////////////////////

  // Inline code display,
  // In a small box that retains the correct baseline.
  show raw.where(block: false): box.with(fill: _luma-background, inset: (x: 2pt, y: 0pt), outset: (y: 2pt), radius: 1pt)

  // Allow page breaks for raw figures
  show figure.where(kind: raw): set block(breakable: true)

  /////////////////////////////////////////////////
  // Cover pages
  /////////////////////////////////////////////////
  if (not is-thesis and not is-executive-summary) {
    import "lib/pages/cover_report.typ": cover_page

    let report_cover = cover_page(
      course-supervisor: course-supervisor,
      course-name: course-name,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      cover-image: cover-image,
      cover-image-height: cover-image-height,
      cover-image-caption: cover-image-caption,
      cover-image-kind: cover-image-kind,
      cover-image-supplement: cover-image-supplement,
      authors: authors,
      date: date,
      logo: logo,
      language: language,
    )

    report_cover
  } else if is-thesis {
    import "lib/pages/cover_bachelor.typ": cover_page

    let supervisors = ()

    if (thesis-co-supervisor == none) {
      supervisors = (thesis-supervisor,)
    } else {
      supervisors = (thesis-supervisor, thesis-co-supervisor)
    }

    let thesis_cover = cover_page(
      supervisors: supervisors,
      expert: thesis-expert,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      school: school,
      programme: programme,
      major: major,      
      authors: authors-str,
      thesis-id: thesis-id,
      submission-date: date,
      revision: revision,
      logo: logo,
      language: language,
    )

    thesis_cover
  } else if is-executive-summary {
    import "lib/pages/cover_exec_summary.typ": cover_page

    let supervisors = ()

    if (thesis-co-supervisor == none) {
      supervisors = (thesis-supervisor,)
    } else {
      supervisors = (thesis-supervisor, thesis-co-supervisor)
    }

    let exec_summary = cover_page(
      title: title,
      authors: authors-str,
      summary: summary,
      content: content,
      picture: student-picture,
      permanent-email: permanent-email,
      video-url: video-url,
      academic-year: academic-year,
      supervisors: supervisors,
      expert: thesis-expert,
      school: school,
      programme: programme,
      major: major,
      language: language,      
      bind: bind,
      footer: footer,
      font: sans-font,
    )

    exec_summary
  }

  body
}