#let colors = (
  yellow: rgb(99%, 78%, 7%),
  gray: rgb(31%, 31%, 33%),
  bulletgray: rgb(60%, 60%, 61%),
  linegray: rgb(51%, 50%, 52%),
  lightgray: rgb(85%, 85%, 86%),
)

#let fonts = (
  // sans: "New Computer Modern Sans",
  // serif: "New Computer Modern",
  // math: "New Computer Modern Sans Math",
  // mono: "New Computer Modern Mono",
  sans: "CMU Sans Serif",
  serif: "New Computer Modern",
  math: "New Computer Modern Math",
  mono: "New Computer Modern Mono",
)

// Environments such as Theorems, Lemmas, Examples, etc
// Is this the best way ?
#let env-counters = state("lipics-env-counters", (
  theorem: 1,
  lemma: 1,
  corollary: 1,
  proposition: 1,
  exercise: 1,
  definition: 1,
  conjecture: 1,
  observation: 1,
  example: 1,
  note: 1,
  remark: 1,
  claim: 1,
))
#let env(symbol, title, title-style: text, content) = {
  block(spacing: 5mm, width: 100%, breakable: false, {
    set par(first-line-indent: 0cm)
    if symbol != none {
      symbol
      h(1mm)
    }
    title-style(text(font: fonts.sans)[*#title*])
    parbreak()
    content
  })
}
#let env2(symbol, title, title-style: text, content) = {
  block(spacing: 5mm, width: 100%, breakable: false, {
    set par(first-line-indent: 0cm)
    title-style(text(font: fonts.sans, title))
    parbreak()
    content
    if symbol != none {
      h(1fr)
      symbol
    }
  })
}
#let env-numbered(symbol, title, kind, title-style: text, content) = context {
  let count = env-counters.get().at(kind)
  env(symbol, [#title #numbering("1.", count)], title-style: title-style, content)
  env-counters.update(counts => {
    let new-counts = counts
    new-counts.at(kind) = counts.at(kind) + 1
    new-counts
  })
}
#let env-numbered-type-1(title, kind, content) = {
  env-numbered(
    text(size: 13pt, fill: colors.gray, sym.triangle.filled.r),
    text(weight: "bold", title),
    kind,
    title-style: text.with(weight: "bold"),
    text(style: "italic", content),
  )
}
#let theorem(content) = env-numbered-type-1([Theorem], "theorem", content)
#let lemma(content) = env-numbered-type-1([Lemma], "lemma", content)
#let corollary(content) = env-numbered-type-1([Corollary], "corollary", content)
#let proposition(content) = env-numbered-type-1([Proposition], "proposition", content)
#let exercise(content) = env-numbered-type-1([Exercise], "exercise", content)
#let definition(content) = env-numbered-type-1([Definition], "definition", content)
#let conjecture(content) = env-numbered-type-1([Conjecture], "conjecture", content)
#let observation(content) = env-numbered-type-1([Observation], "observation", content)
#let env-numbered-type-2(title, kind, content) = {
  env-numbered(
    text(size: 13pt, fill: colors.gray, sym.triangle.filled.r),
    title,
    kind,
    title-style: text.with(weight: "bold"),
    content,
  )
}
#let example(content) = env-numbered-type-2([Example], "example", content)
#let env-numbered-type-3(title, kind, content) = {
  env-numbered(
    text(size: 13pt, fill: colors.gray, sym.triangle.filled.r),
    title,
    kind,
    content,
  )
}
#let note(content) = env-numbered-type-3([Note], "note", content)
#let remark(content) = env-numbered-type-3([Remark], "remark", content)
#let env-numbered-type-4(title, kind, content) = {
  env-numbered(
    text(size: 13pt, fill: colors.gray, sym.triangle.r),
    title,
    kind,
    content,
  )
}
#let claim(content) = env-numbered-type-4([Claim], "claim", content)
#let proof(content) = env2(
  text(size: 13pt, fill: colors.gray, sym.triangle.filled.l),
  [Proof.],
  title-style: text.with(weight: "bold"),
  content,
)
#let claimproof(content) = env2(
  text(size: 13pt, fill: colors.gray, sym.triangle.l),
  [Proof.],
  title-style: text.with(colors.gray),
  content,
)


#let para-lipics(
  title: none,
  title-running: none,
  authors: (),
  author-running: none,
  abstract: none,
  keywords: [],
  category: none,
  related-version: none,
  supplement: none,
  acknowledgements: none,
  funding: none,
  copyright: none,
  ccs-desc: none,
  line-numbers: false,
  hide-lipics: false,
  anonymous: false,
  author-columns: false,
  // ============ EDITOR-ONLY ARGUMENTS ============ //
  event-editors: [],
  event-no-eds: 0,
  event-long-title: [],
  event-short-title: [],
  event-acronym: none,
  event-year: none,
  event-date: none,
  event-location: none,
  event-logo: none,
  series-volume: none,
  article-no: none,
  // ============ CONTENT ============ //
  content,
) = {
  let doi = "10.4230/LIPIcs." + event-acronym + "." + str(event-year) + "." + str(article-no)

  if title-running == none {
    title-running = title
  }

  let bot-margin = 3.5mm

  set page(
    "a4",
    margin: (inside: 32mm, outside: 38mm, top: 35.5mm, bottom: 36.5mm + bot-margin),
    header: context {
      let current-page = counter(page).get().at(0)
      if current-page == 1 { return [] }
      set text(11pt, font: fonts.sans, weight: "bold")
      if calc.even(current-page) {
        place(bottom + left, dx: -10mm, [#current-page])
        place(bottom + left, title-running)
      } else {
        block(width: 100%)
        if anonymous { text(red)[Anonymous author(s)] } else { author-running }
        place(right, dx: 16mm, [#current-page])
      }
    },
    header-ascent: 10.8mm,
    footer-descent: bot-margin,
    footer: context {
      let current-page = counter(page).get().first()
      // for the first page, and if hide-lipics is false:
      // display the event, license, and publisher info in the footer
      if current-page == 1 {
        if hide-lipics { return }
        set text(weight: "medium", size: 7.5pt, tracking: 0.45pt)
        set par(leading: 3pt, spacing: 3pt)
        // EVENT INFO 1
        // grid.cell(colspan: 2,
        //   block(align(horizon + center, event-logo), width: 23mm, height: 5.5mm)
        // ),
        // grid.cell(
        //   inset: (left: 1.3mm),
        //   event-location,
        // ),
        // LICENSE INFO
        grid(
          columns: 2,
          align: bottom,
          column-gutter: 5pt,
          link("https://creativecommons.org/licenses/by/4.0/", image("assets/cc-by.svg", height: .5cm)),
          [
            © #if anonymous { text(red)[Anonymous author(s)] } else { copyright }\;\
            licensed under Creative Commons License CC-BY 4.0],
        )
        // EVENT INFO 2
        let last-page = counter(page).final().first()
        [
          #event-long-title. \
          #if event-no-eds > 1 [Editors] else [Editor]: #event-editors\;
          Article No. #article-no\;
          pp. #article-no:1--#article-no:#last-page
        ]
        // PUBLISHER INFO
        grid(
          columns: 2,
          align: bottom,
          column-gutter: 5pt,
          image("assets/lipics-logo-bw.svg", height: 2em),
          [
            #link("https://www.dagstuhl.de/lipics/")[
              Leibniz International Proceedings in Informatics
            ] \
            #link("https://www.dagstuhl.de")[
              Schloss Dagstuhl -- Leibniz-Zentrum für Informatik, Dagstuhl Publishing, Germany
            ]
          ],
        )
      } // for odd pages (except the first):
      // display a yellow box on the right of the footer
      // if hide-lipics is false, display the short event title
      else if calc.odd(current-page) {
        block(width: 100%, place(right, dx: 4cm, dy: 9mm, align(horizon + left, box(
          inset: 2mm,
          width: 4cm,
          height: 7mm,
          fill: colors.yellow,
          text(tracking: 2pt, spacing: 1pt, colors.gray, font: fonts.sans, weight: "bold", if hide-lipics [] else {
            event-short-title
          }),
        ))))
      }
    },
  )
  set text(10pt, weight: 200, font: fonts.serif)
  show math.equation: set text(font: fonts.math)
  set par(justify: true)
  set footnote.entry(separator: {
    line(length: 40mm, stroke: colors.linegray)
    v(1.3mm)
  })
  show footnote.entry: it => context {
    place(dy: -1mm, text(6pt, numbering(it.note.numbering, ..counter(footnote).get())))
    h(3mm)
    it.note.body
  }

  // Line numbering
  set par.line(numbering: num => text(font: fonts.sans, size: 5pt, numbering(
    "1",
    num,
  ))) if line-numbers
  show selector(figure).or(footnote.entry): set par.line(numbering: none) if line-numbers

  // First page metadata
  {
    set par(spacing: 0cm, leading: 0.63em)

    // Counteract the first page margin
    v(-8mm)

    // Main article title
    par(spacing: 0cm, leading: 1em, text(
      17.28pt,
      tracking: 0.6pt,
      spacing: 85%,
      weight: "bold",
      font: fonts.sans,
      title,
    ))

    v(5.5mm)

    // Authors and affiliations
    grid(
      columns: 1,
      ..authors.map(author => {
        // if anonymization is enabled
        if anonymous {
          return {
            text(12pt, spacing: 80%, tracking: -0.1pt, weight: 600, red)[Anonymous author]
            v(2mm)
            text(size: 9pt, tracking: 0.12pt, red)[Anonymous affiliation]
            v(3.5mm)
          }
        }
        // author name
        text(12pt, spacing: 80%, tracking: -0.1pt, weight: 600, author.name)
        // author email
        if "email" in author {
          h(5pt)
          box(link("mailto:" + author.email, image("assets/fa5-envelope-regular.svg", width: 1em)))
        }
        // author website
        if "website" in author {
          h(5pt)
          box(link(author.website, image("assets/fa5-home-solid.svg", width: 1em)))
        }
        // author ORCID
        if "orcid" in author {
          h(5pt)
          box(link("https://orcid.org/" + author.orcid, image("assets/orcid.svg", height: 1em)))
        }
        v(2mm)
        // author affiliations
        text(size: 9pt, tracking: 0.12pt, author.affiliations)
        v(3.5mm)
      })
    )

    v(2.1mm)

    grid(
      columns: (7mm, auto, 1fr),
      // align: horizon,
      column-gutter: 1.6mm,
      place(dy: 6.5pt, line(length: 100%, stroke: colors.linegray)),
      text(11pt, font: fonts.sans, tracking: 0.01em, weight: "bold")[Abstract],
      place(dy: 6.5pt, line(length: 100%, stroke: colors.linegray)),
    )

    v(3.1mm)
    par(leading: 2.1mm, text(size: 9pt, abstract))
    v(5mm)

    // Other metadata
    {
      let lipics-metadata(title, content) = {
        if content == none {
          return none
        }
        set par(leading: 0.6em)
        text(
          size: 9pt,
          tracking: 0.1pt,
          weight: 700,
          font: fonts.sans,
          colors.gray,
          title,
        )
        h(2mm)
        text(size: 9pt, content)
      }

      set par(leading: 0.5em)
      grid(columns: 1, row-gutter: 4.6mm, ..(
          // ACM Classification
          lipics-metadata([2012 ACM Subject Classification], ccs-desc),
          // Keywords
          lipics-metadata([Keywords and phrases], keywords),
          // Digital Object Identifier
          lipics-metadata([Digital Object Identifier], link("https://doi.org/" + doi, doi)),
          // Category
          lipics-metadata([Category], category),
          // Related version
          lipics-metadata([Related Version], related-version),
          // Supplementary material
          lipics-metadata([Supplementary Material], supplement),
          // Funding acknowledgments
          lipics-metadata([Funding], if funding != none {
            if anonymous { text(red)[Anonymous funding] } else { funding }
          } else { none }),
          // General acknowledgements
          lipics-metadata([Acknowledgements], if acknowledgements != none {
            if anonymous { text(red)[Anonymous acknowledgments] } else { acknowledgements }
          } else { none }),
        ).filter(md => md != none))
    }
  }
  v(1.4mm)

  // Headings setup
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    stack(
      dir: ltr,
      block(fill: colors.yellow, outset: (top: 0.7mm, bottom: -0.7mm), height: 5mm, width: 5.9mm, align(
        center,
        numbering(it.numbering, ..counter(heading).at(it.location())),
      )),
      h(5mm),
      text(font: fonts.sans, size: 12pt, it.body),
    )
    v(1.5mm)
  }
  show heading.where(level: 2).or(heading.where(level: 3)): it => {
    set text(font: fonts.sans, size: 12pt)
    block(above: 7mm, below: 5mm, par(first-line-indent: 0cm, {
      numbering(it.numbering, ..counter(heading).at(it.location()))
      h(5mm)
      it.body
    }))
  }
  show heading.where(level: 4): it => context {
    v(5.5mm)
    par(first-line-indent: 0cm, {
      set text(font: fonts.sans, size: 10.5pt)
      if it.numbering != none {
        numbering(it.numbering, ..counter(heading).get())
        h(2mm)
      }
      it.body
    })
    v(2.5mm)
  }
  show heading.where(level: 5): it => context {
    v(4mm)
    text(size: 10pt, font: fonts.sans, it.body)
    linebreak()
    v(2.5mm)
  }

  // Code font
  show raw: set text(font: fonts.mono)

  // Paragraph settings for the rest of the document
  set par(first-line-indent: 15pt, spacing: 0.65em, leading: 0.62em)

  // Lists
  set list(body-indent: 5mm, spacing: 2.5mm, marker: place(dy: 4pt, box(
    width: 2.4mm,
    height: 1.2mm,
    fill: colors.bulletgray,
  )))

  // Enumerations
  set enum(numbering: nums => text(font: fonts.sans, weight: "bold", fill: colors.gray, numbering("1.", nums)))

  // Figures, tables, listings
  show figure: it => {
    if it.caption == none {
      smallcaps(text(red, weight: "bold")[Provide a Caption !])
    }
    block(width: 100%, if it.kind == image {
      it.body
      it.caption
    } else if it.kind == table {
      block(width: 100%, it.caption)
      block(width: 90%, it.body)
    } else if it.kind == raw {
      it.caption
      set align(left)
      block(width: 100%, inset: 3mm, fill: colors.lightgray, it.body)
    } else {
      it
    })
  }
  show figure.caption: it => context {
    set align(left)
    align(horizon, {})
    box(fill: color.yellow, inset: 1.4mm)
    let n = numbering(it.numbering, ..counter(figure.where(kind: it.kind)).get())
    h(3mm)
    text(font: fonts.sans, weight: "bold", [#it.supplement #n])
    h(2mm)
    text(it.body)
  }
  set table(stroke: (col, row) => (
    top: if row <= 1 { 0.5pt } else { 0pt },
    bottom: 0.5pt,
  ))

  content
}
