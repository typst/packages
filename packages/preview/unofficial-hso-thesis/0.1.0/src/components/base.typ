// Collection of base components to use in the thesis like Abstract, ToC, etc.

#let abstract(ctx) = {
  ctx.abstract
}

#let render-body(ctx) = {
  set heading(numbering: "1.1")
  [#metadata(none) <main-matter-start>]
  ctx.body
  [#metadata(none) <main-matter-end>]
}

#let table-of-contents(ctx) = {
  pagebreak(weak: true)
  set par(leading: 0.8em, spacing: 1.0em, justify: true, first-line-indent: 0pt)

  show outline.entry.where(level: 1): it => {
    // Visuelle Trennung von Kapiteln durch kleinen Abstand
    set block(above: 1.2em)
    it
  }

  outline(depth: 3, indent: 2em)
  pagebreak(weak: true)
}

#let list-of-figures(ctx) = {
  [= #ctx.strings.at("list-of-figures")]
  outline(title: none, target: figure.where(kind: image))
}

#let list-of-tables(ctx) = {
  [= #ctx.strings.at("list-of-tables")]
  outline(title: none, target: figure.where(kind: table))
}

#let list-of-listings(ctx) = {
  [= #ctx.strings.at("list-of-listings")]
  outline(title: none, target: figure.where(kind: raw))
}

#let appendix(ctx) = {
  if ctx.appendix != none {
    pagebreak()
    [= #ctx.strings.at("appendix") <appendix>]
    set heading(numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 2 {
        return numbering("A", vals.last())
      } else if vals.len() > 2 {
        return numbering("A.1", ..vals.slice(1))
      }
    })
    ctx.appendix
  }
}