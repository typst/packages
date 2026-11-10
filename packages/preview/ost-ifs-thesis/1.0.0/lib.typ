#import "@preview/zebraw:0.6.3": zebraw

// ─────────────────────────────────────────────
//  Private state & helpers
// ─────────────────────────────────────────────

// Accent color used for headings, links, references and table headers
#let _accent = rgb("#8d188f")
// Title of the current level-1 heading
#let _current-chapter = state("current-chapter", "")
// True on a page that opens a new chapter, to suppress its running header
#let _on-chapter-page = state("on-chapter-page", false)
// True for front matter (roman page numbers)
#let _in-preliminary = state("in-preliminary", true)

#let _i18n = (
  en: (
    authors: ("Author", "Authors"),
    advisor: ("Advisor", "Advisors"),
    co-advisor: ("Co-advisor", "Co-advisors"),
    expert: ("Industry Expert", "Industry Experts"),
    logo: "ost-logo-en.pdf",
  ),
  de: (
    authors: ("Autor", "Autoren"),
    advisor: ("Referent", "Referenten"),
    co-advisor: ("Koreferent", "Koreferenten"),
    expert: ("Industrie-Experte", "Industrie-Experten"),
    logo: "ost-logo-de.pdf",
  ),
)

#let _heading-rule(it) = {
  if it.level == 1 {
    _current-chapter.update(it.body)
    _on-chapter-page.update(true)
    pagebreak(weak: true)
  }

  if it.level == 1 and it.numbering != none {
    grid(
      columns: 2,
      column-gutter: 1.5em,
      align: (bottom),
      context text(
        fill: _accent,
        size: 72pt,
        weight: "light",
        counter(heading).display(it.numbering),
      ),
      {
        set par(leading: 0.25em)
        text(size: 28pt, weight: "regular", smallcaps(it.body))
      },
    )
    v(1.5em)
  } else {
    block(above: 2em, below: 1em, {
      set text(weight: "regular")
      context {
        if it.numbering != none {
          text(fill: _accent, counter(heading).display(it.numbering))
          h(0.5em)
        }
        smallcaps(it.body)
      }
    })
  }
}

#let _title-page(
  title,
  subtitle,
  authors,
  advisor,
  co-advisor,
  counter-reader,
  thesis-type,
  university,
  lang,
  background,
) = {
  let locale = _i18n.at(lang)

  let role-row(label, value) = {
    let names = (value,).flatten().filter(name => name != none and name != "")

    if names.len() > 0 {
      (
        v(1em),
        text(weight: "medium", label.at(int(names.len() > 1)) + ":"),
        text(size: 14pt, names.join(" · ")),
      )
    }
  }

  set page(
    header: none,
    footer: none,
    foreground: place(
      top + right,
      dx: -15mm,
      dy: 10mm,
      image("assets/" + locale.logo, height: 20mm),
    ),
  )

  // Background and overlay
  {
    let size = 200mm
    let offset_y = -15mm
    let offset_x = -30mm
    place(dx: offset_x, dy: offset_y, box(width: size, background))
    place(dx: offset_x - 9mm, dy: offset_y, image(
      "assets/overlay.png",
      width: size + 10mm,
    ))
  }

  set par(leading: 0.5em)
  place(bottom + right, table(
    stroke: none,
    align: left,
    inset: (y: 2pt),
    columns: 50%,

    text(size: 28pt, weight: "bold", title),
    if subtitle != none and subtitle != "" {
      v(0.5em)
      text(size: 12pt, fill: rgb("#888"), subtitle)
    },
    v(1em),

    text(size: 14pt, datetime.today().display("[day].[month].[year]")),

    ..role-row(locale.authors, authors.map(a => a.name)),
    ..role-row(locale.advisor, advisor),
    ..role-row(locale.co-advisor, co-advisor),
    ..role-row(locale.expert, counter-reader),

    ..if thesis-type != none and thesis-type != "" {
      (
        v(1em),
        text(size: 14pt, thesis-type),
      )
    }
  ))

  pagebreak()

  // Restart numbering so the frontmatter begins at 1
  counter(page).update(1)
}

// ─────────────────────────────────────────────
//  Public API
// ─────────────────────────────────────────────

// Renders the table of contents and sets `_in-preliminary` to false
#let toc(body) = {
  outline(depth: 3)
  pagebreak()
  _in-preliminary.update(false)
  counter(page).update(1)
  body
}

// Switches heading numbering to appendix style (A.1).
#let appendix(body) = {
  set heading(numbering: "A.1")
  counter(heading).update(0)
  body
}

// A pre-styled table. Takes the same arguments as `table`.
#let styled-table(columns: auto, header: (), ..rows) = table(
  columns: columns,
  align: left,
  inset: (x: 6pt, y: 7pt),
  stroke: (x, y) => (
    top: if y > 0 { 0.3pt + luma(60%) },
    left: if x > 0 { 0.3pt + luma(55%) },
  ),

  table.header(..header.map(column => text(
    fill: _accent,
    weight: "medium",
    smallcaps(column),
  ))),

  ..rows,
)

#let template(
  title: "",
  subtitle: none,
  authors: (),
  advisor: none,
  co-advisor: none,
  expert: none,
  thesis-type: none,
  university: auto,
  lang: "en",
  font: ("Roboto", "Libertinus Serif"),
  background: image("assets/background.png"),
  body,
) = {
  assert(
    lang in _i18n,
    message: "Unknown lang \""
      + lang
      + "\"; expected one of: "
      + _i18n.keys().join(", "),
  )

  set document(title: title, author: authors.map(a => a.name).join(", "))
  set text(font: font, size: 11pt, lang: lang)
  set par(justify: true, leading: 1em, spacing: 2em)
  set page(paper: "a4", margin: 3cm)

  set heading(numbering: "1.1")
  set list(marker: depth => [•])
  show heading: _heading-rule
  show outline.entry: it => {
    context link(
      it.element.location(),
      text(
        fill: black,
        it.indented(
          text(fill: _accent, it.prefix()),
          it.inner(),
        ),
      ),
    )
  }

  // Allow long table figures to break across pages
  show figure.where(kind: table): set block(breakable: true)

  // Accent color for links and references
  show ref: it => text(fill: _accent, it)
  show link: it => text(fill: _accent, it)

  // Code block styling
  show: zebraw.with(
    radius: 3pt,
    background-color: luma(97%),
    numbering-separator: true,
    lang: false,
  )

  // header & footer
  set page(
    header: context {
      if _in-preliminary.get() {
        return
      }

      if _current-chapter.get() != "" and not _on-chapter-page.get() {
        align(center, emph(text(size: 10pt, _current-chapter.get())))
      } else {
        _on-chapter-page.update(false)
      }
    },

    footer: context {
      if _in-preliminary.get() {
        align(center, text(size: 10pt, counter(page).display("I")))
      } else {
        align(center, text(size: 10pt, counter(page).display()))
      }
    },
  )

  // Title page
  _title-page(
    title,
    subtitle,
    authors,
    advisor,
    co-advisor,
    expert,
    thesis-type,
    university,
    lang,
    background,
  )

  body
}

