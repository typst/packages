// Outlines.
//
// CHANGED against my earlier pass: the reference PDF puts figures and tables
// under ONE heading, "List of Figures and Tables", with "List of Figures" and
// "List of Tables" as subheadings inside it. I had built them as two separate
// top-level sections.
//
// The red entries are correct and have been restored: the document loads
// hyperref with colorlinks, so internal links are red. I removed them earlier
// after grepping the class source, where hyperref does not appear at all.

#let create-page-number(it) = box(width: 2.5em, align(right + top, it.page()))

/// Table of contents.
/// -> content
#let insert-heading-outline(lang: "en", link-color: red) = {
  show outline.entry: it => {
    let weight = if it.element.level == 1 { "bold" } else { "regular" }
    let fill = if it.element.level != 1 { repeat(gap: 0.5em)[.] } else { [] }
    let rest = (
      text(fill: link-color, weight: weight)[#it.body()]
        + h(1em)
        + box(width: 1fr, fill)
        + sym.space
        + sym.wj
        + text(weight: weight)[ #create-page-number(it) ]
    )
    link(
      it.element.location(),
      it.indented(text(fill: link-color, weight: weight)[#it.prefix()], rest),
    )
  }
  show outline: set heading(numbering: none, outlined: false)
  show outline.entry.where(level: 1): set block(above: 1.1em)
  outline(
    title: if lang == "nl" { "Inhoudsopgave" } else { "Contents" },
    depth: 2,
  )
}

/// The body of a figure/table list, without its own heading.
/// -> content
#let figure-list(target: image, link-color: red) = {
  show outline.entry: it => {
    let rest = (
      text(fill: link-color)[#it.body()]
        + h(1em)
        + box(width: 1fr, repeat(gap: 0.5em)[.])
        + sym.space
        + sym.wj
        + create-page-number(it)
    )
    let location = it.element.location()
    let number = context {
      let chapter-number = counter(heading).at(location).at(0)
      if it.element.caption != none {
        let figure-number = it.element.caption.counter.at(location).at(0)
        numbering("1.1", chapter-number, figure-number)
      } else { "" }
    }
    link(location, it.indented(text(fill: link-color)[#number], rest))
  }
  show outline: set heading(outlined: false)
  outline(title: none, target: figure.where(kind: target))
}

/// "List of Figures and Tables" -- one section with two subheadings, exactly
/// as in the reference PDF.
/// -> content
#let insert-figures-tables-outline(
  lang: "en",
  figures: true,
  tables: true,
  link-color: red,
) = {
  let both = figures and tables
  let title = if lang == "nl" {
    if both { "Lijst van figuren en tabellen" } else if tables {
      "Lijst van tabellen"
    } else { "Lijst van figuren" }
  } else {
    if both { "List of Figures and Tables" } else if tables {
      "List of Tables"
    } else { "List of Figures" }
  }

  heading(level: 1, numbering: none, outlined: true, title)

  let sub(name) = block(
    above: 1.4em,
    below: 0.8em,
    text(size: 1.1em, weight: "bold", name),
  )

  if figures {
    if both {
      sub(if lang == "nl" { "Lijst van figuren" } else { "List of Figures" })
    }
    figure-list(target: image, link-color: link-color)
  }
  if tables {
    if both {
      sub(if lang == "nl" { "Lijst van tabellen" } else { "List of Tables" })
    }
    figure-list(target: table, link-color: link-color)
  }
}

/// Separate list of listings (code blocks). Not part of kulemt; kept from
/// 0.1.0.
/// -> content
#let insert-listing-outline(lang: "en", link-color: red) = {
  heading(
    level: 1,
    numbering: none,
    outlined: true,
    if lang == "nl" { "Lijst van code" } else { "List of Listings" },
  )
  figure-list(target: raw, link-color: link-color)
}
