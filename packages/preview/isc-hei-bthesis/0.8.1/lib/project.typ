// The main document template. project() sets up fonts, pagination, headers,
// footers, captions and code styling shared by every document type, then hands
// the per-type front matter to covers.front-matter() and renders the body.

#import "includes.typ" as inc
#import "settings.typ": space-after-heading, chapter-font-size, chapter-font-weight, body-font-size, version, _luma-background, programme-name, validate-major
#import "fonts.typ": body-font, sans-font, raw-font, isc-fonts-available, _missing-fonts-page
#import "i18n.typ": i18n
#import "decorations.typ": chapter-rule
#import "content.typ": set-header-footer, table-of-contents, colophon
#import "covers.typ": front-matter
#import "pages/cover_assignment.typ": get-document-title

/*********************************
 ** The template itself
 ********************************/
#let project(
  title: [Report title],
  subtitle: none,
  academic-year: [2026-2027],

  // Document type: "report", "thesis", "document", "exec-summary"
  doc-type: "report",
  split-chapters: true,

  // Document specific
  show-cover: true,
  show-toc: 2, // false = no TOC, true = TOC with depth 2, integer = TOC with given depth
  fancy-line: false, // Use decorative line with squares (false = simple line)

  // Bachelor thesis specific
  thesis-supervisor: [Thesis supervisor],
  thesis-co-supervisor: none,
  thesis-expert: "[Thesis expert]",
  thesis-id: none,
  project-repos: none,
  // Signature image for the declaration of honour, e.g. image("signature.png").
  // Consumed by #declaration-of-honour() (thesis only); a missing image renders a
  // red placeholder rather than aborting the compile.
  signature: none,
  keywords: (),
  // Set true to suppress the thesis cover's "ATTENTION REQUISE" drafting box
  // even when required fields are still at their placeholders. A tiny coloured
  // dot is then placed on the second cover page to record the override.
  hide-completeness-warning: false,
  major: (),
  school: [School name],
  programme: programme-name,

  // Executive summary specific
  summary: none,
  content: none,
  student-picture: none,
  permanent-email: "stormy.peters@example.com",
  video-url: none,
  bind: none,
  footer: none,
  // Your picture and email will be used in the printed brochure.
  // By default they will also appear on the ISC web page. Set either
  // flag to true to opt out of web publication for that item.
  picture-web-opt-out: false,
  email-web-opt-out: false,

  // Course report specific
  course-name: none,
  course-supervisor: none,
  semester: none,
  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: [KNN graph -- Inspired by _Marcus Volg_],
  cover-image-kind: auto,
  cover-image-supplement: auto,


  // A list of authors, separated by commas
  authors: (),
  date: none,
  logo: auto, // auto = default logo for document type, none = no logo
  equations: false,
  revision: none, // Like a version number
  language: "fr",
  extra-i18n: none,
  code-theme: "bluloco-light",
  // When true: suppresses all headers, footers, and the inline compact header
  no-decorations: false,
  body,
) = {

  // Validate doc-type
  let valid-doc-types = ("report", "thesis", "document", "exec-summary", "tb-assignment")
  assert(doc-type in valid-doc-types, message: "Invalid doc-type '" + doc-type + "'. Must be one of: " + valid-doc-types.join(", "))

  // Validate the major early (clear error here rather than at render time).
  validate-major(major)

  // Update state with the passed values so they are accessible globally
  inc.global-keywords.update(keywords)
  inc.global-language.update(language)

  // For tb-assignment: title is always i18n-derived, logo is always suppressed
  let title = if doc-type == "tb-assignment" { get-document-title(language) } else { title }
  let logo  = if doc-type == "tb-assignment" { none } else { logo }

  // Normalize show-toc: true -> 2, false -> 0, int -> int
  let toc-depth = if doc-type == "tb-assignment" or doc-type == "exec-summary" { 0 } else if show-toc == false { 0 } else if show-toc == true { 2 } else { int(show-toc) }
  inc.show-toc-enabled.update(toc-depth > 0)

  // A missing/empty repo is no longer fatal: it flows through so the thesis
  // completeness box can flag it (see lib/pages/cover_bachelor.typ). repo-block()
  // renders nothing for an empty URL rather than panicking.
  if(project-repos != none) {
    inc.global-project-repos.update(project-repos)
  }

  let i18n = i18n.with(extra-i18n: extra-i18n, language)

  // Set the document's basic properties.
  // The description doubles as a hidden colophon in the PDF metadata (visible via
  // `pdfinfo`/`exiftool`, never on the page). The leading "Using ISC template
  // ver. <version>" stays first so it remains machine-parseable.
  set document(author: authors, title: title, date: date, keywords: keywords, description: "Using ISC templates v. " + version + " | No LaTeX was harmed")

  set par(justify: true)

  // Detect whether the ISC fonts are available (see fonts.typ); render the
  // fallback page instead of the document when they are missing.
  context {
  if not isc-fonts-available() { _missing-fonts-page() } else {

  // Default body font
  set text(font: body-font, lang: language, size: body-font-size)

  // Set other fonts
  // show math.equation: set text(font: math-font) // For math equations
  if doc-type != "tb-assignment" {
    let selected-theme = "../src/themes/" + code-theme + ".tmTheme"
    set raw(theme: selected-theme)
  }
  show raw: set text(font: raw-font) // For code

  show heading: set text(font: sans-font) // For sections, sub-sections etc..
  show heading: set block(below: space-after-heading)

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
    margin: (inside: 2.5cm, outside: 1.8cm, bottom: 2.5cm, top: 2.5cm), // Binding inside
    paper: "a4",
  ) if(doc-type == "thesis")

  // Report specific settings
  set page(
    margin: (inside: 2.5cm, outside: 2cm, y: 2.1cm), // Binding inside
    paper: "a4",
  ) if(doc-type == "report")

  // Document specific settings — symmetric margins
  set page(
    margin: (x: 2.0cm, y: 1.8cm),
    paper: "a4",
  ) if(doc-type == "document")

  // TB assignment — same margins as document, no decorations
  set page(
    margin: (x: 2.0cm, y: 1.8cm),
    footer: none,
    header: none,
    paper: "a4",
  ) if(doc-type == "tb-assignment")

  if (doc-type != "thesis" and doc-type != "tb-assignment") {
    // For reports and documents, we want to put the header and footer on all pages
    set-header-footer(true)
  } else {
    // For theses, keep the front matter (abstract, résumé, declaration of
    // honour, acknowledgements) unheadered. The show-heading rule below turns
    // the running header/footer back on automatically at the first numbered
    // chapter, so the student never has to call set-header-footer() by hand.
    set-header-footer(false)
  }

  // Suppress all page decorations when requested (must come after other set page calls)
  if no-decorations {
    set-header-footer(false)
    set page(footer: none, header: none)
  }

  show heading: it => {
    // In a thesis, put chapters begin on odd pages
    // Add the header in a block to make space around it
    if it.level == 1 and doc-type == "thesis" and split-chapters {
      pagebreak(weak: true)
      inc.blank-page.update(true)
      pagebreak(to: "odd", weak: true)
      inc.blank-page.update(false)

      block(fill: none, inset: (x: 0pt, bottom: space-after-heading, top: 6.5em), below: 0pt, {
        // Numbered (chapter) headings get the two-line layout: smaller, lighter
        // "Chapitre N" eyebrow over the chapter title on its own line.
        if (it.numbering != none) {
          let n = counter(heading).get().first()
          stack(spacing: 1.2em,
            text(i18n("chapter-title") + " " + str(n),
              size: chapter-font-size * 0.8,
              weight: 300,
              fill: luma(45%)),
            text(it.body, size: chapter-font-size, weight: chapter-font-weight),
          )
        } else {
          it
        }
        // Decorative rule — only for numbered (chapter) headings
        if it.numbering != none {
          // Reading-position hairline: filled to chapter n of the total.
          let n     = counter(heading).get().first()
          let total = counter(heading).final().first()
          chapter-rule(progress: n / total)
          v(1.5cm)
        }
      })
    } else {
      it
    }

    // Auto-enable the running header/footer from the first numbered chapter of a
    // thesis. The front matter (abstract, résumé, declaration of honour,
    // acknowledgements) uses page-title(), not real headings, so it stays
    // unheadered — this replaces the manual #set-header-footer(true) students
    // used to place by hand right after their first chapter title. The update
    // is idempotent, so firing it on every chapter is harmless, and it is
    // skipped under no-decorations. Mirrors the in-flow position of the old
    // manual call, so the chapter's first page keeps its footer-but-no-header.
    if doc-type == "thesis" and it.level == 1 and it.numbering != none and not no-decorations {
      inc.header-footers-enabled.update(true)
    }
  }

  // Manage authors single and plural
  let authors-list = if type(authors) == str { (authors,) } else { authors }
  let authors-str = if authors-list.len() > 1 {
    authors-list.join(", ")
  } else if authors-list.len() == 1 {
    authors-list.at(0)
  } else {
    panic("No authors provided for the report")
  }

  // Forward the metadata the declaration-of-honour page auto-fills with.
  inc.global-thesis-meta.update((
    title: title,
    author: authors-str,
    academic-year: academic-year,
    date: date,
    signature: signature,
  ))

  let footer-title = if type(title) == str { title.replace("\n", " – ") } else { title }

  let footer-content = context text(0.75em)[
    #{
      emph(footer-title)
      if revision != none {
          text(" · " + revision, style: "italic")
      }

      h(1fr)
      counter(page).display("1 | 1", both: true)
    }
  ]

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
    footer: context {
      if counter(page).get().first() == 1 and not show-cover and (doc-type == "report" or doc-type == "document") {
        // First page compact mode: show date and version
        text(0.75em, {
          if date != none {
            inc.custom-date-format(date, pattern: i18n("date-format"), lang: language)
          }
          if revision != none {
            if date != none {
              [ — v#revision]
            } else {
              [v#revision]
            }
          }
          h(1fr)
          counter(page).display("1 | 1", both: true)
        })
      } else if counter(page).get().first() > 1 {
        if inc.header-footers-enabled.get() and not inc.blank-page.get() {
          footer-content
        } else {
          none
        }
      }
    },
  )

  // Links coloring
  show link: set text(ligatures: true, fill: blue)

  // Sections numbers
  set heading(numbering: "1.1.1 –")

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
  // Default logo for document type
  let logo = if logo == auto and (doc-type == "document" or doc-type == "report" or doc-type == "tb-assignment") {
    if show-cover{
      image("assets/isc_logo.svg")
    } else {
      image("assets/isc_logo.svg")
    }
  } else if logo == auto {
    none
  } else {
    logo
  }

  // TB assignment never has a cover page
  let show-cover = if doc-type == "tb-assignment" { false } else { show-cover }

  // Per-document-type front matter (compact header or full cover page).
  front-matter(
    doc-type: doc-type,
    show-cover: show-cover,
    no-decorations: no-decorations,
    title: title,
    subtitle: subtitle,
    authors: authors,
    authors-list: authors-list,
    authors-str: authors-str,
    date: date,
    revision: revision,
    logo: logo,
    language: language,
    sans-font: sans-font,
    fancy-line: fancy-line,
    course-supervisor: course-supervisor,
    course-name: course-name,
    semester: semester,
    academic-year: academic-year,
    cover-image: cover-image,
    cover-image-height: cover-image-height,
    cover-image-caption: cover-image-caption,
    cover-image-kind: cover-image-kind,
    cover-image-supplement: cover-image-supplement,
    school: school,
    programme: programme,
    major: major,
    thesis-id: thesis-id,
    thesis-expert: thesis-expert,
    thesis-supervisor: thesis-supervisor,
    thesis-co-supervisor: thesis-co-supervisor,
    hide-completeness-warning: hide-completeness-warning,
    summary: summary,
    content: content,
    student-picture: student-picture,
    permanent-email: permanent-email,
    video-url: video-url,
    bind: bind,
    footer: footer,
  )

  // Add some top spacing on the first content page for report and document
  if show-cover and (doc-type == "report" or doc-type == "document") {
    v(2em)
  }

  // Auto-insert table of contents if enabled
  if toc-depth > 0 {
    table-of-contents(depth: toc-depth)
  }

  // Exec-summary is self-contained (single page); skip body to avoid a blank second page
  if doc-type != "exec-summary" {
    body
  }

  // Auto-append the end-of-document colophon for the bachelor thesis only.
  if doc-type == "thesis" {
    colophon()
  }
  } // else (fonts available)
  } // context font check
}

/*********************************
 ** Per-document-type aliases
 ********************************/
// Thin shims so a user file can write `#show: thesis.with(...)` instead of
// `#show: project.with(doc-type: "thesis", ...)`, keeping the doc-type plumbing
// out of the template. project() stays the canonical entry point; these only
// preset doc-type. There is deliberately NO `document` alias: it would shadow
// Typst's built-in `document` element, so the document example keeps its
// explicit `doc-type: "document"`.
#let thesis        = project.with(doc-type: "thesis")
#let report        = project.with(doc-type: "report")
#let exec-summary  = project.with(doc-type: "exec-summary")
#let tb-assignment = project.with(doc-type: "tb-assignment")
