#import "@preview/polylux:0.4.0": slide as polylux-slide, toolbox
#import "@preview/subpar:0.2.2"

#let m-dark-teal = rgb("#23373b")
#let m-light-brown = rgb("#eb811b")
#let m-lighter-brown = rgb("#d6c6b7")
#let m-extra-light-gray = white.darken(2%)

#let ovgu-red = rgb("#D13F58")
#let ovgu-purple = rgb("#7A003F")
#let ovgu-blue = rgb("#0068B4")
#let ovgu-darkgray = rgb("#606060")
#let ovgu-lightgray = rgb("#C0C0C0").lighten(50%)
#let ovgu-orange = rgb("#F39100")

#let m-pages = counter("m-page")
#let m-footer = state("m-footer", [])
#let m-metadata = state("m-metadata", (:))

#let m-progress-bar = context {
  let ratio = m-pages.get().first() / m-pages.final().first()
  grid(
    columns: (ratio * 100%, 1fr),
    rect(fill: ovgu-purple, width: 100%),
    rect(fill: m-lighter-brown, width: 100%),
  )
}

/* ----- General theming and show rules ----- */

#let parcio-theme(aspect-ratio: "16-9", text-size: 20pt, body) = {
  set page(
    paper: "presentation-" + aspect-ratio,
    margin: 0em,
    header: none,
    footer: none,
  )

  set text(font: "Libertinus Sans", fill: m-dark-teal, text-size)
  set list(indent: 1em)
  set enum(indent: 1em)
  
  show raw: set text(font: "Inconsolata", 1.1em)

  // Add line numbers to code block.
  show raw.where(block: true): r => {
    show raw: set par(leading: 0.75em)
    show raw.line: l => {
      box(table(
        columns: (-1.25em, 100%),
        stroke: 0pt,
        inset: 0em,
        column-gutter: 1em,
        align: (x, y) => if x == 0 { right } else { left },
        text(fill: ovgu-darkgray, str(l.number)),
        l.body,
      ))
    }

    set align(left)
    block(width: 100%, stroke: gray + 0.5pt, inset: 0.75em, r)
  }

  // Display supplement in bold.
  show figure.caption: c => context [
    *#c.supplement #c.counter.display(c.numbering)#c.separator*#c.body
  ]

  // Make URLs use monospaced font.
  show link: it => { set text(font: "Inconsolata", 0.9em) if type(it.dest) == str; it }

  set footnote.entry(
    indent: 2.5em,
    separator: line(start: (2em, 0em), end: (40%, 0em), stroke: 0.5pt),
  )

  body
}

// Declare your title slide! OvGU logo to the right.
//
// - title: Your presentation title.
// - author: Consists of author.name and author.mail.
// - subtitle: (Optional) subtitle for more info.
// - short-title: (Optional) short title for the footer.
// - logo: (Optional) institution / faculty logo
// - date: (Optional) date of the presentation.
// - extra: (Optional) info below the date, like your faculty.
#let title-slide(
  title: [],
  author: (name: "Your Name", mail: "example@ovgu.de"), 
  subtitle: none, 
  short-title: none,
  logo: none,
  date: datetime.today().display(), 
  extra: none,
) = {
  m-metadata.update(("title": title, "authors": author))
  let content = {
    set align(horizon)

    v(-1em)
    block(width: 100%, inset: 2.5em, height: 100%, {
      // Upper part: Title, subtitle and logo.
      grid(
        columns: (auto, 1fr),
        align: (left, right),
        text(size: 1.3em, strong(title) + v(-0.25em) + text(0.85em, subtitle)),
        logo,
      )

      // Middle part: line separator.
      v(0.5em)
      line(length: 100%, stroke: 0.75pt + ovgu-purple)
      v(1.5em)

      // Bottom part: Author, date, institution, etc.
      set text(size: .9em)

      let author-information = if type(author) == array {
        let names = author.map(x => x.name)
        let mails = author.map(x => x.mail)

        let name-and-mail = names.zip(mails).map(
          ((n, m)) => n + "\n" + link("mailto:" + m)
        )

        grid(columns: author.len(), column-gutter: 1em, ..name-and-mail)
      } else {
        author.name + "\n" + link("mailto:" + author.mail)
      }

      stack(spacing: 1em, author-information, date, extra)
    })
  }

  m-footer.update(
    grid(columns: (1fr, auto, 1fr), align: (left, center, right), 
      if type(author) == array { author.map(x => x.name).join(", ") } else { author.name }, 
      if short-title != none { short-title } else { title }, 
      context [#m-pages.get().first() / #m-pages.final().first()]
    ),
  )
  
  polylux-slide(content)
}

// Basic slide function.
//
// - title: (Optional) title of the slide, will be shown on the left in the header.
// - new-section: (Optional) marks a new topic, adds it to the outline & on the right in the header.
// - show-current-section: (default: true) if the current section should be displayed.
// - show-footer: (default: true) if the footer should be displayed.
// - skip: (default: false) whether to skip the page counter for this slide
#let slide(
  title: none,
  new-section: none,
  show-current-section: true,
  show-footer: true,
  skip: false,
  body,
) = {
  // Define header: [Subsection] --- [Section], incl. progress bar.
  let header = {
    set align(top)
    
    if title != none {
      if new-section != none {
        toolbox.register-section(new-section)
      }

      if not skip {
        m-pages.step()
      }

      block(fill: ovgu-lightgray, inset: 1em, width: 100%, height: 100%)[
        #set align(horizon)
        #set text(fill: ovgu-blue, 1em)

        *#title*#h(1fr)
        #if show-current-section [
          #text(0.75em)[*#toolbox.current-section*]
        ]
      ]
    } else {
      strong("Missing Headline")
    }

    block(height: 1pt, width: 100%, spacing: 0pt, m-progress-bar)
  }

  // Define footer: [author] - [title] - [page / total]
  let footer = if show-footer {
    show: pad.with(bottom: .25em, rest: .35em)
    align(bottom, text(0.7em, context m-footer.get()))
  }

  set page(
    header: header,
    footer: footer,
    header-ascent: 0em,
    margin: (top: 2.5em, bottom: 1em),
    fill: m-extra-light-gray,
  )

  let content = {
    show: align.with(horizon)
    show: pad.with(2em)
    body
  }

  polylux-slide(content)
}

/* ----- Helper / Utility functions for tables, subfigures, shortcuts & todos. ----- */

// Creates a clickable outline with a customizable title for each `new-section` entry.
// - `show-title`: Whether to show the presentation title as a heading (default: false)
// - `new-section`: The next section to highlight in the outline-slide (default: none)
#let outline-slide(title: "Outline", show-title: false, new-section: none) = slide(
  title: title, 
  show-footer: false, 
  skip: true,
  [
    #set list(marker: none, spacing: 2em)
    #set text(gray) if new-section != none

    #if show-title [
      - #text(m-dark-teal, context m-metadata.get().title)
    ]

    - #toolbox.all-sections((s, c) => list(
        ..s.map(x => if x.body.text == new-section { text(m-dark-teal, x) } else { x })
      ))
  ]
)

// Creates a list of all references using the given style.
#let bib-slide(title: "References", bibliography) = slide(
  title: title, 
  show-footer: false, 
  show-current-section: false, 
  skip: true
)[
  #set grid(align: top)
  #set par(justify: true)
  #set text(0.9em)
  #bibliography
]

// Custom ParCIO table as illustrated in the template.
#let parcio-table(max-rows, ..args) = table(
  ..args,
  row-gutter: (2.5pt, auto),
  stroke: (x, y) => (
    left: 0.5pt,
    right: 0.5pt,
    top: if y <= 1 { 0.5pt },
    bottom: if y == 0 or y == max-rows - 1 { 0.5pt }
  )
)

// Simple orange TODO box.
#let todo = rect.with(fill: ovgu-orange, stroke: black + 0.5pt, radius: 0.25em, width: 100%)
