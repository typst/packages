#import "theme.typ": *
#import "fonts.typ": default-fonts, book-fonts, font-list, show-cjk-oblique
#import "theorems.typ": setup-theorems, show-theorems, theorion
#import "algorithms.typ": show-algorithms
#import "code.typ": show-code

#let make-cover(title, subtitle, authors, institution, date, logo, accent, sans-font) = {
  set page(header: none, footer: none, numbering: none, background: none)
  set par(first-line-indent: 0pt, justify: false)
  align(center)[
    #v(32mm)
    #line(length: 23mm, stroke: 1.5pt + accent)
    #v(11mm)
    #text(font: sans-font, size: 31pt, weight: "bold", fill: ink, title)
    #if subtitle != none {
      v(7mm)
      text(size: 14pt, fill: muted, subtitle)
    }
    #v(18mm)
    #text(size: 12pt, authors.join(h(1.5em)))
    #if institution != none { v(5mm); text(size: 11pt, fill: muted, institution) }
    #if date != none {
      v(8mm)
      text(size: 10pt, fill: muted, if type(date) == datetime { date.display("[year]-[month]-[day]") } else { date })
    }
    #v(1fr)
    #if logo != none { logo }
    #v(18mm)
  ]
  pagebreak()
}

/// Apply the complete book design.
/// references and appendix are content, resolved in the caller's project.
#let neat-book(
  title: "Neat Book", subtitle: none, author: (), institution: none,
  date: none, logo: none,
  lang: "zh", fonts: (:), font-size: 10.5pt, cjk-oblique: 12deg,
  accent: teal, paper: "a4", margin: (x: 26mm, top: 25mm, bottom: 24mm),
  cover: true, toc: true, toc-title: auto, toc-depth: 3,
  references: none, bibliography-style: "chicago-author-date",
  appendix: none, body,
) = {
  let fonts = default-fonts + fonts
  let authors = if type(author) == array { author } else { (author,) }
  let primary = if lang.starts-with("ja") { fonts.japanese }
    else if lang.starts-with("ko") { fonts.korean } else { fonts.chinese }
  let is-zh = lang.starts-with("zh")
  set document(title: title, author: authors)
  set text(
    font: font-list(fonts.english) + font-list(primary) + font-list(fonts.japanese),
    size: font-size, lang: lang, fill: ink,
  )
  set par(justify: true, leading: .8em, first-line-indent: 2em)
  set page(paper: paper, margin: margin, numbering: "1")
  set heading(numbering: "1.1", outlined: true, supplement: if is-zh { [节] } else { [Section] })
  show heading.where(level: 1): set heading(supplement: if is-zh { [章] } else { [Chapter] })
  set outline(depth: toc-depth, indent: 1.4em)
  set bibliography(style: bibliography-style)
  set math.equation(numbering: equation-number, supplement: if is-zh { [式] } else { [Equation] })
  set figure(numbering: figure-number)
  set figure.caption(separator: [#h(.6em)])
  set table(stroke: .4pt + rgb("DCE3E8"), inset: 7pt)
  show math.equation: set text(font: fonts.math)
  show raw: set text(font: font-list(fonts.mono) + font-list(primary), size: .86em)
  show link: set text(fill: accent)
  show ref: set text(fill: accent)
  show ref: show-book-ref
  show outline.entry: show-book-outline-entry
  show heading: set text(font: fonts.sans, weight: "bold", fill: ink)
  show heading.where(level: 2): set block(above: 1.7em, below: .8em)
  show heading.where(level: 3): set text(size: 1.05em, fill: accent)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    if it.numbering != none {
      counter(math.equation).update(0)
      for kind in (image, table, raw, "algorithm") { counter(figure.where(kind: kind)).update(0) }
    }
    block(above: 10mm, below: 12mm)[
      #context if it.numbering != none {
        let n = counter(heading).display(it.numbering)
        let prefix = if appendix-mode.get() {
          if is-zh { [附录 #n] } else { [Appendix #n] }
        } else { if is-zh { [第 #n 章] } else { [Chapter #n] } }
        block(above: 0pt, below: 5mm, text(size: 11pt, fill: accent, prefix))
      }
      #text(size: 25pt, it.body)
      #v(5mm)
      #line(length: 100%, stroke: .6pt + accent.lighten(65%))
    ]
  }
  show: show-theorems
  show: show-algorithms.with(accent: accent)
  show: show-code.with(accent: accent)
  show: show-cjk-oblique.with(angle: cjk-oblique)
  book-fonts.update(fonts)
  accent-color.update(accent)
  appendix-mode.update(false)
  setup-theorems(accent)

  if cover {
    make-cover(title, subtitle, authors, institution, date, logo, accent, fonts.sans)
  }
  if toc {
    counter(page).update(1)
    [
      #set page(header: none, footer: context align(center, text(size: 9pt, fill: muted, counter(page).display("i"))))
      #outline(title: if toc-title == auto { if is-zh { [目录] } else { [Contents] } } else { toc-title })
      #pagebreak()
    ]
  }
  counter(page).update(1)
  set page(
    header: context {
      let headings = query(heading.where(level: 1))
      let on-page = headings.filter(it => it.location().position().page == here().position().page)
      let previous = query(heading.where(level: 1).before(here()))
      let current = if on-page.len() > 0 { on-page.first().body }
        else if previous.len() > 0 { previous.last().body } else { title }
      set text(size: 8pt, fill: muted)
      set par(first-line-indent: 0pt)
      block(width: 100%, inset: (bottom: 5pt), stroke: (bottom: .35pt + rgb("DCE3E8")))[
        #title #h(1fr) #current
      ]
    },
    footer: context align(center, text(size: 9pt, fill: muted, counter(page).display("1"))),
  )
  body
  if references != none {
    pagebreak(weak: true)
    references
  }
  if appendix != none {
    pagebreak(weak: true)
    appendix-mode.update(true)
    counter(heading).update(0)
    theorion.set-theorion-numbering("A.1")
    [
      #set heading(numbering: "A.1")
      #show heading.where(level: 1): set heading(supplement: if is-zh { [附录] } else { [Appendix] })
      #appendix
    ]
  }
}
