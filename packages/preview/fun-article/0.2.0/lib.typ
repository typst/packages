#import "@preview/droplet:0.3.1": dropcap

#let fun-article(
  title: "",
  authors: (),
  affiliations: (),
  abstract: [],
  significance: none,
  paper-size: "a4",
  cols: 2,
  body,
) = {
  set document(title: title, author: authors.map(a => a.name))

  let dark-red = rgb("#8b0000")
  let dark-goldenrod = rgb("#b8860b")
  let linen = rgb("#faf0e6")
  let orcid-color = rgb("#a6ce39")
  let body-font = ("Libertinus Serif", "New Computer Modern")
  let sans-font = ("Noto Sans", "DejaVu Sans")

  set page(
    paper: paper-size,
    margin: (top: 1.5cm, bottom: 1.5cm, left: 2cm, right: 2cm),
    header: context {
      if counter(page).get().at(0) > 1 {
        set align(center)
        set text(style: "italic", size: 9pt, font: body-font)
        title
      }
    },
    footer: context {
      line(length: 100%, stroke: 0.4pt)
      set text(size: 8pt, font: sans-font)
      let page-count = counter(page).get().at(0)
      let total-pages = counter(page).final().at(0)
      grid(
        columns: (1fr, 1fr),
        [],
        align(right)[
          Page #page-count of #total-pages
        ],
      )
    },
  )

  set text(font: body-font, size: 9pt)
  set par(leading: 0.45em, justify: true)
  show heading: set text(font: sans-font, weight: "bold", fill: dark-red)

  let split-first-sentence(body) = {
    if type(body) == str {
      let sentence-end = body.position(regex("[.!?](\\s|$)"))
      if sentence-end == none {
        (lead: body, rest: none, found-end: false)
      } else {
        let end = sentence-end + 1
        let rest = body.slice(end)
        (
          lead: body.slice(0, end),
          rest: if rest == "" { none } else { rest },
          found-end: true,
        )
      }
    } else if type(body) != content {
      (lead: body, rest: none, found-end: false)
    } else if body.func() == text {
      let sentence-end = body.text.position(regex("[.!?](\\s|$)"))
      if sentence-end == none {
        (lead: body, rest: none, found-end: false)
      } else {
        let end = sentence-end + 1
        let rest = body.text.slice(end)
        (
          lead: [#body.text.slice(0, end)],
          rest: if rest == "" { none } else { [#rest] },
          found-end: true,
        )
      }
    } else if body.fields().at("children", default: none) != none {
      let lead = ()
      let rest = ()
      let found-end = false
      for child in body.fields().at("children") {
        if found-end {
          rest.push(child)
        } else {
          let split = split-first-sentence(child)
          lead.push(split.lead)
          if split.rest != none {
            rest.push(split.rest)
          }
          found-end = split.found-end
        }
      }
      (
        lead: lead.sum(),
        rest: if rest.len() == 0 { none } else { rest.sum() },
        found-end: found-end,
      )
    } else {
      (lead: body, rest: none, found-end: false)
    }
  }

  show heading.where(level: 1): it => {
    set text(size: 11pt)
    v(1.5em, weak: true)
    it
    v(0.5em, weak: true)
  }

  show figure.caption.where(kind: image): it => block(width: 100%)[
    #set align(start)
    #set par(justify: true)
    #let sentence = split-first-sentence(it.body)
    #if sentence.rest == none {
      strong([#it.supplement #context it.counter.display(it.numbering)#it.separator #sentence.lead])
    } else {
      [#strong([#it.supplement #context it.counter.display(it.numbering)#it.separator #sentence.lead])#sentence.rest]
    }
  ]

  let orcid-icon(id) = if id != none [
    #h(2pt)
    #link("https://orcid.org/" + id)[
      #box(baseline: 20%, width: 1.1em, height: 1.1em)[
        #place(center + horizon, circle(radius: 0.45em, fill: orcid-color, stroke: none))
        #place(center + horizon, text(size: 0.5em, fill: white, weight: "bold", font: sans-font, "iD"))
      ]
    ]
  ]

  let title-block = {
    set align(left)
    v(1em)
    set text(font: sans-font, weight: "bold", fill: dark-red)
    block(text(size: 14pt, title))

    v(8pt)

    let author-blocks = ()
    for (i, author) in authors.enumerate() {
      let affils = author.at("affils", default: ())
      let markers = if type(affils) == array { affils.join(",") } else { str(affils) }
      if author.at("is-corresponding", default: false) {
        markers = "*" + if markers != "" { "," + markers } else { "" }
      }
      let orcid = author.at("orcid", default: none)
      author-blocks.push([
        #text(size: 11pt, weight: "bold", fill: black, author.name)#super(markers)#orcid-icon(orcid)
      ])
      if i < authors.len() - 1 {
        author-blocks.push([, ])
      }
    }
    block(author-blocks.sum())

    v(4pt)

    set text(size: 8pt, font: sans-font, style: "italic", weight: "regular", fill: black)
    for affiliation in affiliations {
      block([#super(affiliation.id) #affiliation.name])
    }

    v(4pt)
    line(length: 100%, stroke: 1pt + dark-goldenrod)
    v(12pt)
  }

  let has-abstract = abstract != none and abstract != [] and abstract != ""
  let abstract-content = if has-abstract {
    block(width: 100%)[
      #set text(weight: "bold")
      #set par(justify: true)
      #dropcap(
        height: 3,
        gap: 3pt,
        hanging-indent: 1em,
        overhang: 0pt,
        fill: dark-goldenrod,
        justify: true,
      )[#abstract]
    ]
  }

  let has-significance = significance != none and significance != [] and significance != ""
  let significance-box = if has-significance {
    v(0.5em)
    block(
      width: 100%,
      fill: linen.lighten(85%),
      stroke: 0.8pt + dark-goldenrod,
      radius: 2mm,
      inset: (top: 14pt, rest: 10pt),
      {
        place(
          top + left,
          dx: 10pt,
          dy: -21pt,
          block(
            fill: rgb("#f5f5f5"),
            stroke: 0.7pt + dark-goldenrod,
            radius: 1.5mm,
            inset: (x: 6pt, y: 3pt),
            text(size: 8pt, weight: "bold", fill: dark-red, font: sans-font, "Significance"),
          ),
        )
        set text(size: 8pt, weight: "regular")
        significance
      },
    )
  }

  title-block

  if has-abstract and has-significance {
    grid(
      columns: (2.2fr, 1fr),
      column-gutter: 20pt,
      abstract-content,
      significance-box,
    )
  } else if has-abstract {
    block(width: 100%, abstract-content)
  } else if has-significance {
    block(width: 100%, significance-box)
  }

  v(1em)
  line(length: 100%, stroke: 0.5pt + dark-goldenrod)
  v(1.5em)

  if cols > 1 {
    columns(cols, gutter: 7mm, body)
  } else {
    body
  }
}

#let appendix(body) = {
  set heading(numbering: "A.", supplement: [Appendix])
  counter(heading).update(0)
  body
}
