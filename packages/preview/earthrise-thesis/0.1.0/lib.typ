#import "@preview/codly:1.3.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/physica:0.9.5": *
#import "@preview/subpar:0.2.2"
#import "@preview/zero:0.5.0": format-table

#import "modules/1_frontpage.typ": front-page
#import "modules/2_affidavit.typ": affidavit-page
#import "modules/3_preface.typ": preface-page
#import "modules/4_epigraph.typ": epigraph-page
#import "modules/5_abstract.typ": abstract-page
#import "modules/6_acknowledgements.typ": acknowledgements-page
#import "modules/7_glossary.typ": (
  glossary-page, gls, glspl, make-glossary, register-glossary,
)
#import "modules/8_publications.typ": (
  make-publication-list, publication-list-page,
)
#import "modules/9_backpage.typ": back-page

#let std-bibliography = bibliography
#let std-smallcaps = smallcaps
#let std-upper = upper

#let heading-fonts = ("EB Garamond",)
#let body-fonts = ("EB Garamond",)
#let raw-fonts = ("Monaspace Argon",)

#let smallcaps(all: false, body) = std-smallcaps(all: all, text(
  tracking: 0.6pt,
  body,
))
#let upper(body) = std-upper(text(tracking: 0.6pt, body))

#let accent-color = rgb("#1f6f8b")
#let secondary-color = rgb("#b5523b")
#let muted-color = luma(77)
#let accent-light = accent-color.lighten(90%)
#let secondary-light = secondary-color.lighten(90%)
#let muted-light = muted-color.lighten(90%)

#let fill-line(left-text, right-text) = [#left-text #h(1fr) #right-text]

#let in-appendix = state("in-appendix", false)

#let thm-separator = [:#h(0.2em)]
#let thm-pattern(appendix, ..n) = if appendix and n.pos().first() > 0 {
  "A.1"
} else { "1.1" }
#let thm-numbering(..n) = numbering(
  thm-pattern(in-appendix.get(), ..n),
  ..n,
)

#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: accent-light,
  separator: thm-separator,
).with(numbering: thm-numbering)
#let corollary = thmplain(
  "corollary",
  "Corollary",
  base: "theorem",
  titlefmt: strong,
  separator: thm-separator,
).with(numbering: thm-numbering)
#let definition = thmbox(
  "definition",
  "Definition",
  inset: (x: 1.2em, top: 1em),
  separator: thm-separator,
).with(numbering: thm-numbering)
#let lemma = thmbox(
  "lemma",
  "Lemma",
  fill: muted-light,
  separator: thm-separator,
).with(numbering: thm-numbering)
#let example = thmplain("example", "Example", separator: thm-separator).with(
  numbering: none,
)
#let custom-proof-bodyfmt(body) = {
  set math.equation(numbering: none)
  proof-bodyfmt(body)
}
#let proof = thmproof(
  "proof",
  "Proof",
  bodyfmt: custom-proof-bodyfmt,
  separator: thm-separator,
).with(
  numbering: none,
)

#let code-block(filename, content) = raw(
  content,
  block: true,
  lang: filename.split(".").at(-1),
)

#let csv-table(
  tabledata: (),
  columns: 1,
  header-row: secondary-light,
  even-row: white,
  odd-row: accent-light,
) = {
  let tableheadings = tabledata.first()
  let data = tabledata.slice(1).flatten()
  table(
    columns: columns,
    fill: (_, row) => if row == 0 {
      header-row
    } else if calc.odd(row) {
      odd-row
    } else {
      even-row
    },
    align: (col, row) => if row == 0 { center } else {
      left
    },
    ..tableheadings.map(x => [*#x*]),
    ..data,
  )
}

#let in-raw = state("in-raw", false)

#let in-outline = state("in-outline", false)

#let render-dynamic-caption(it, short: false) = {
  if (
    type(it.value) == dictionary
      and it.value.at("kind", default: none) == "dynamic-caption"
  ) {
    if short { it.value.short } else { it.value.long }
  } else {
    it
  }
}

#let clean-parity-break(to, weak: true) = {
  set page(header: none, footer: none, numbering: none)
  pagebreak(weak: weak, to: to)
}

#let earthrise-mark(accent: accent-color) = {
  let (width, height) = (84pt, 44pt)
  let ink = (paint: accent, thickness: 1.75pt, cap: "round", join: "round")
  let sparkle(x, y, r) = {
    let k = r * 0.22
    place(curve(
      stroke: (..ink, thickness: 1pt),
      curve.move((x, y - r)),
      curve.quad((x + k, y - k), (x + r, y)),
      curve.quad((x + k, y + k), (x, y + r)),
      curve.quad((x - k, y + k), (x - r, y)),
      curve.quad((x - k, y - k), (x, y - r)),
      curve.close(),
    ))
  }
  box(width: width, height: height, {
    place(box(width: width, height: height - 7.2pt, clip: true, place(
      dx: width / 2 - 17pt,
      dy: 8pt,
      circle(radius: 17pt, stroke: ink),
    )))
    place(curve(
      stroke: ink,
      curve.move((0pt, height)),
      curve.cubic(
        (24pt, height - 10pt),
        (60pt, height - 10pt),
        (width, height),
      ),
    ))
    sparkle(12pt, 12pt, 4.5pt)
    sparkle(74pt, 8pt, 3pt)
  })
}

#let default-chapter-marker(heading-number, accent: accent-color) = (
  heading-number + h(14pt) + earthrise-mark(accent: accent)
)
#let front-matter(body) = {
  set page(
    numbering: "i",
    footer: none,
    header: context {
      align(
        if calc.odd(counter(page).get().first()) { right } else { left },
        text(
          weight: "thin",
          size: 9pt,
          fill: muted-color,
          counter(
            page,
          ).display(),
        ),
      )
    },
  )
  counter(page).update(1)
  set heading(numbering: none)
  show heading.where(level: 1): it => {
    it
    v(5%, weak: true)
  }
  body
}

#let main-matter(body, accent: accent-color) = {
  set page(
    numbering: "1",
    header-ascent: 30%,
    header: context {
      let page-number = here().page()

      let chapters = heading.where(level: 1)
      let is-start-heading = query(chapters).any(it => (
        it.location().page() == page-number
      ))
      if is-start-heading {
        return align(
          if calc.odd(counter(page).get().first()) { right } else { left },
          text(
            weight: "thin",
            size: 9pt,
            fill: muted-color,
            counter(
              page,
            ).display(),
          ),
        )
      }
      let chapters-before = query(chapters.before(here()))
      if chapters-before.len() > 0 {
        let current-chapter = chapters-before.last()

        let current-subsection = {
          let subsections = heading.where(level: 2)
          let starting-here = query(subsections.after(here())).filter(it => (
            it.location().page() == page-number
          ))
          let started-before = query(
            subsections.after(current-chapter.location()).before(here()),
          )
          if starting-here.len() > 0 {
            starting-here.first()
          } else if started-before.len() > 0 {
            started-before.last()
          } else {
            none
          }
        }

        let colored-slash = text(fill: accent, "/")
        let spacing = h(3pt)

        let subsection-text = if (current-subsection != none) {
          let subsection-numbering = current-subsection.numbering
          if (subsection-numbering != none) {
            let location = current-subsection.location()
            let subsection-count = numbering(
              subsection-numbering,
              ..counter(
                heading,
              ).at(location),
            )
            [#subsection-count #spacing #colored-slash #spacing #current-subsection.body]
          } else {
            []
          }
        } else {
          []
        }

        let chapter-text = {
          let chapter-title = current-chapter.body
          let chapter-number = if current-chapter.numbering == none {
            []
          } else {
            numbering(
              current-chapter.numbering,
              ..counter(heading).at(
                current-chapter.location(),
              ),
            )
          }
          let prefix = if current-chapter.supplement == [Appendix] {
            [APPENDIX]
          } else { [CHAPTER] }

          [#prefix #chapter-number #spacing #colored-slash #spacing #chapter-title]
        }

        if current-chapter.numbering != none {
          let (left-text, right-text) = if calc.odd(
            counter(page).get().first(),
          ) {
            (chapter-text, counter(page).display())
          } else {
            (counter(page).display(), subsection-text)
          }
          text(weight: "thin", size: 9pt, fill: muted-color, fill-line(
            upper(left-text),
            upper(right-text),
          ))
        } else {
          align(
            if calc.odd(counter(page).get().first()) { right } else { left },
            text(
              weight: "thin",
              size: 9pt,
              fill: muted-color,
              counter(
                page,
              ).display(),
            ),
          )
        }
      }
    },
  )
  counter(page).update(1)
  counter(heading).update(0)
  counter(footnote).update(0)
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    it
    v(12.5%, weak: true)
  }
  body
}

#let back-matter(body) = {
  set heading(numbering: "A.1.1", supplement: [Appendix])
  counter(heading.where(level: 1)).update(0)
  counter(heading).update(0)
  body
}
#let thesis(
  title: "<title>",
  subtitle: none,
  author: "<author>",
  supervisors: (
    (
      title: "<supervisor title>",
      name: "<supervisor name>",
    ),
  ),
  cosupervisors: none,
  committee: (
    (
      title: "<committee title>",
      name: "<committee name>",
    ),
  ),
  degree: "<degree>",
  degree-subject: none,
  doc-id: "<document ID>",
  faculty: "<faculty>",
  department: "<department>",
  date: datetime.today(),
  date-format: "[day padding:none] [month repr:long] [year]",
  defense-date: none,
  defense-location: "",
  cover-author: none,
  affidavit: none,
  epigraph: none,
  abstract: none,
  acknowledgements: none,
  appendix: [],
  preface: none,
  bibliography: none,
  figure-index: true,
  table-index: true,
  listing-index: true,
  publications: none,
  glossary: none,
  glossary-group-order: none,
  body,
  front-img: none,
  affidavit-img: none,
  back-img: none,
  physical-copy: false,
  chapter-opener: none,
  accent: accent-color,
  body-font: body-fonts,
  heading-font: heading-fonts,
  raw-font: raw-fonts,
) = {
  let resolved-defense-date = if defense-date == none { date } else {
    defense-date
  }
  let resolved-degree-subject = if degree-subject == none { department } else {
    degree-subject
  }
  let resolved-cover-author = if cover-author == none { author } else {
    cover-author
  }

  set document(
    title: (title, subtitle).filter(it => it != none).join(": "),
    author: if author == none { () } else { author },
    date: if date != none { date } else { auto },
  )

  set page(paper: "a4", margin: if physical-copy {
    (bottom: 40mm, top: 35mm, inside: 25mm, outside: 35mm)
  } else {
    (bottom: 40mm, top: 35mm, x: 30mm)
  })

  show metadata: it => render-dynamic-caption(it)

  show: make-glossary
  if glossary not in (none, ()) {
    register-glossary(glossary)
  }
  show: make-publication-list

  show: codly-init

  show raw: it => in-raw.update(true) + it + in-raw.update(false)
  show regex("\b\d+(st|[nr]d|th)\b"): w => context {
    if in-raw.get() {
      w
    } else {
      [#w.text.slice(0, -2)#super(w.text.slice(-2))]
    }
  }

  show regex("ISBN(-1[03])?:? (97[89][- ]?)?(\d[- ]?){9}[\dX]\b"): w => {
    let isbn = w
      .text
      .split(regex(":? "))
      .slice(1)
      .join()
      .replace(regex("[- ]"), "")
    link("https://isbnsearch.org/isbn/" + isbn, w)
  }

  show footnote.entry: set par(hanging-indent: 1.5em)

  show heading: set text(font: heading-font)

  set text(
    font: body-font,
    size: 12pt,
  )

  show raw: set text(
    font: raw-font,
    size: 9pt,
  )

  set par(justify: true, linebreaks: "optimized", spacing: 2em)

  set ref(supplement: it => context {
    if it.func() == heading {
      if it.supplement == [Appendix] {
        [Appendix]
      } else {
        if it.level == 1 {
          [Chapter]
        } else if it.level == 2 {
          [Section]
        } else if it.level == 3 {
          [Subsection]
        } else if it.level == 4 {
          [Subsubsection]
        } else if it.level == 5 {
          [Paragraph]
        } else if it.level == 6 {
          [Subparagraph]
        } else {
          it.supplement
        }
      }
    } else {
      it.supplement
    }
  })

  show heading: it => {
    let body = if it.level > 1 {
      block([
        #if it.numbering != none {
          counter(heading).display()
          h(.6em)
        }
        #it.body
      ])
    } else {
      it
    }
    v(2.5em, weak: true)
    body
    v(1.5em, weak: true)
  }

  show heading.where(level: 1): it => {
    if physical-copy {
      clean-parity-break("odd", weak: true)
    } else {
      pagebreak(weak: true)
    }
    set text(weight: "bold", size: 32pt)
    set par(justify: false)

    let heading-number = if it.numbering == none {
      []
    } else {
      text(counter(heading.where(level: 1)).display(), size: 64pt)
    }

    for kind in (image, table, raw, ..query(figure).map(f => f.kind).dedup()) {
      counter(figure.where(kind: kind)).update(0)
    }
    counter(math.equation).update(0)

    v(7.5%)
    if it.numbering != none {
      if chapter-opener == none or it.supplement == [Appendix] {
        default-chapter-marker(heading-number, accent: accent)
      } else {
        context {
          let custom-opener = chapter-opener(
            counter(heading.where(level: 1)).get().first(),
          )
          if custom-opener == none {
            default-chapter-marker(heading-number, accent: accent)
          } else {
            stack(dir: ltr, spacing: 16pt, heading-number, move(
              dy: 2pt,
              custom-opener,
            ))
          }
        }
      }
      v(1.0em)
      it.body
      v(-1.5em)
    } else {
      it.body
    }
  }

  show heading: it => if it.level >= 4 { it.body } else { it }

  set heading(numbering: "1.1")

  show heading: set text(weight: "bold", hyphenate: false)

  set math.equation(numbering: n => {
    let h1 = counter(heading).get().first()
    numbering(
      if in-appendix.get() and h1 > 0 { "(A.1)" } else { "(1.1)" },
      h1,
      n,
    )
  })

  show math.equation.where(block: true): it => {
    set align(center)
    pad(left: 2em, it)
  }

  set figure(numbering: n => {
    let h1 = counter(heading).get().first()
    numbering(if in-appendix.get() and h1 > 0 { "A.1" } else { "1.1" }, h1, n)
  })

  set figure.caption(separator: [ -- ])

  show figure.caption: c => {
    if c.numbering == none {
      c
    } else {
      text(weight: "bold")[
        #c.supplement #context c.counter.display(c.numbering)
      ]
      c.separator
      c.body
    }
  }

  show figure.where(
    kind: table,
  ): set figure.caption(position: top)
  set table(
    align: center + horizon,
    inset: 4pt,
    stroke: (_, y) => (
      left: { 0pt },
      right: { 0pt },
      top: if y < 1 { stroke(1pt + muted-color) } else if y == 1 {
        none
      } else { 0pt },
      bottom: if y < 1 { stroke(0.5pt + muted-color) } else {
        stroke(1pt + muted-color)
      },
    ),
    fill: (_, y) => if calc.odd(y) { muted-light },
  )
  show table.cell: set text(size: 10pt)
  show table.cell: set par(leading: 0.425em, justify: false)
  show table.cell.where(y: 0): set text(weight: "bold")

  show raw.where(block: false): box
  show raw.where(block: true): set grid(gutter: 0pt)

  show: thmrules.with(qed-symbol: $qed$)
  show ref: it => {
    let el = it.element
    if (
      el == none
        or el.func() != figure
        or el.kind != "thmenv"
        or el.numbering != thm-numbering
    ) {
      return it
    }
    let loc = el.location()
    let marker = query(selector(<meta:thmenvcounter>).after(loc)).first()
    let number = thmcounters.at(marker.location()).at("latest")
    let supplement = if it.citation.supplement == none { el.supplement } else {
      it.citation.supplement
    }
    link(it.target, [#supplement~#numbering(
        thm-pattern(in-appendix.at(loc), ..number),
        ..number,
      )])
  }

  let list-spacing = 1.0em
  let nested-list-spacing = 0.5em
  set enum(indent: list-spacing, spacing: list-spacing)
  set list(indent: list-spacing, spacing: list-spacing, marker: ([•], [–]))
  let show-list-enum(it) = {
    set enum(indent: nested-list-spacing, spacing: nested-list-spacing)
    set list(indent: nested-list-spacing, spacing: nested-list-spacing)
    it
  }
  show enum: it => {
    show-list-enum(it)
  }
  show list: it => {
    show-list-enum(it)
  }

  show: front-matter

  {
    set text(font: heading-font)
    set page(paper: "a4", margin: (
      bottom: 40mm,
      top: 35mm,
      x: 30mm,
    )) if physical-copy
    front-page(
      doc-id: doc-id,
      faculty: faculty,
      defense-date: resolved-defense-date,
      date-format: date-format,
      defense-location: defense-location,
      degree-title: degree,
      degree-subject: resolved-degree-subject,
      author: resolved-cover-author,
      title: title,
      subtitle: subtitle,
      front-img: front-img,
    )
  }

  if physical-copy {
    set page(footer: none, header: none)
    pagebreak(weak: true, to: "odd")
  }
  if affidavit != none {
    set text(font: heading-font)
    affidavit-page(affidavit, background: affidavit-img)
  }

  if physical-copy {
    set page(footer: none, header: none)
    pagebreak(weak: true, to: "odd")
  }
  if (preface, supervisors, cosupervisors, committee).any(it => (
    it not in (none, ())
  )) {
    preface-page(supervisors, cosupervisors, committee, preface)
  }

  if epigraph != none {
    epigraph-page()[#epigraph]
  }

  if abstract != none {
    abstract-page()[#abstract]
  }

  if acknowledgements != none {
    acknowledgements-page()[#acknowledgements]
  }

  context {
    let fig-t(kind) = figure.where(kind: kind)

    in-outline.update(true)
    show metadata: it => render-dynamic-caption(it, short: true)
    set heading(outlined: true, bookmarked: true)

    pagebreak(weak: true)

    let entry-spacing-left = 0.25em
    let entry-spacing-right = 1.5em

    show outline.entry: set block(breakable: false)
    [
      #show outline.entry: it => context {
        let page-number-spacing = calc.max(
          measure(h(0.5em)).width,
          measure(h(entry-spacing-right)).width - measure(it.page()).width,
        )
        link(it.element.location(), it.indented(
          it.prefix() + h(entry-spacing-left),
          it.body()
            + h(entry-spacing-left)
            + box(width: 1fr, it.fill)
            + h(page-number-spacing)
            + it.page(),
        ))
      }

      #show outline.entry.where(level: 1): it => {
        set text(weight: "bold")
        set block(above: 2.1em) if (
          it.element.numbering != none or it.element.supplement == [Appendix]
        )
        link(it.element.location(), it.indented(
          it.prefix(),
          it.body() + box(width: 1fr, none) + it.page(),
        ))
      }
      #show outline: set text(font: heading-font)

      #outline(title: "Contents", depth: 2)
      <outline:contents>
    ]

    show outline.entry: it => context {
      let prefix = {
        show "Figure": ""
        show "Table": ""
        show "Listing": ""
        set text(weight: "bold")
        it.prefix()
      }
      let page-number-spacing = calc.max(
        measure(h(0.5em)).width,
        measure(h(entry-spacing-right)).width - measure(it.page()).width,
      )
      link(it.element.location(), it.indented(
        text(
          font: heading-font,
          prefix + h(entry-spacing-left),
        ),
        it.body()
          + h(entry-spacing-left)
          + box(width: 1fr, it.fill)
          + h(page-number-spacing)
          + it.page(),
      ))
    }

    show outline.entry: it => context {
      if it.element.func() == figure {
        let fig = it.element
        let loc = fig.location()
        let figure-number = counter(figure.where(kind: fig.kind))
          .at(loc)
          .first()
        if figure-number == 1 {
          v(0.475em)
        }
        it
      } else {
        it
      }
    }

    for (enabled, title, kind) in (
      (figure-index, "Figures", image),
      (table-index, "Tables", table),
      (listing-index, "Listings", raw),
    ) {
      if (
        enabled
          and query(fig-t(kind)).any(f => f.outlined and f.numbering != none)
      ) {
        outline(title: title, target: fig-t(kind))
      }
    }
    in-outline.update(false)
  }

  if publications != none {
    publication-list-page(publications, index-font: heading-font)
  }

  if glossary not in (none, ()) {
    glossary-page(glossary, group-order: glossary-group-order)
  }

  if physical-copy {
    clean-parity-break("odd", weak: true)
  } else {
    pagebreak(weak: true)
  }

  show: main-matter.with(accent: accent)

  body

  show: back-matter

  if bibliography != none {
    pagebreak(weak: true)
    show std-bibliography: set text(12pt)
    show std-bibliography: it => {
      show "https://doi.org/": [DOI:] + str.from-unicode(160)
      show regex(" {2,}"): " "
      it
    }
    show std-bibliography: set par(
      spacing: 1.3em,
      leading: 0.65em,
      justify: false,
      linebreaks: auto,
    )
    bibliography
  }

  in-appendix.update(true)
  thmcounters.update(it => (
    counters: it.counters.keys().map(key => (key, (0,))).to-dict(),
    latest: (),
  ))
  appendix

  if physical-copy {
    clean-parity-break("even", weak: true)
  }
  if physical-copy or back-img != none {
    back-page(back-img: back-img)
  }
}
