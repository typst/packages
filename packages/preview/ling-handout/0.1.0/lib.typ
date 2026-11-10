// ling-handout: a typst template for linguistics handouts.
// see the README for usage and template/main.typ for an example implementation. 

/// Custom figure element for examples that keep one running counter across the entire document, as is customary in linguistics literature. 
/// Requires wrapping your document in `ling-handout` (via `#show: ling-handout.with(..)`).
#let ex(body) = figure(
  kind: "example",
  supplement: none,
  numbering: "(1)",
  body,
)

/// Flatten a string or content value to a plain string (for PDF metadata).
#let to-plain(it) = {
  if type(it) == str {
    it
  } else if type(it) == content {
    if it.has("text") {
      it.text
    } else if it.has("children") {
      it.children.map(to-plain).join(default: "")
    } else if it.has("body") {
      to-plain(it.body)
    } else if it.func() == [ ].func() {
      " "
    } else {
      ""
    }
  } else {
    str(it)
  }
}

/// Main wrapper function.
///
/// `handout-title` and `handout-author` also set the document metadata.
/// `handout-date` only affects the rendered header, not the metadata date.
/// `handout-title`, `handout-author`, `handout-date`, `group`, and `location` are optional. Leave them out or set them to `none` to omit them.
#let ling-handout(
  handout-title: none,
  handout-author: none,
  handout-date: none,
  group: none,
  location: none,
  paper: "us-letter",
  margin: 1in,
  font: "New Computer Modern",
  font-size: 12pt,
  leading: 0.52em,
  spacing: 0.9em,
  body,
) = {
  set document(title: handout-title) if handout-title != none 
  set document(author: to-plain(handout-author)) if handout-author != none

  let date = if type(handout-date) == datetime {
    handout-date.display()
  } else {
    handout-date
  }

  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
    header: {
      set text(weight: "bold", size: 1em - 1pt)
      (group, location).filter(x => x != none).join(", ")
      h(1fr)
      (handout-author, date).filter(x => x != none).join(", ")
    },
  )

  set text(font: font, size: font-size)
  set par(justify: true, leading: leading, spacing: spacing)
  set heading(numbering: "1.a")

  // examples made by calling the ex[] function render in (1)-style; sub-lists within an example are rendered in (i)-style.
  show figure.where(kind: "example"): it => {
    set align(start)
    grid(
      columns: (2.5em, 1fr),
      column-gutter: 0.5em,
      align: start + top,
      context it.counter.display(it.numbering),
      {
        set enum(numbering: "(i)", indent: 0pt, number-align: end + top)
        it.body
      },
    )
  }  

  // references to examples render as (n). put a label right after the ex[] call, e.g. `#ex[...] <ex-3>`, and reference it with `@ex-3`. currently, only top-level examples can be referenced.
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "example" {
      link(el.location(), context {
        let n = counter(figure.where(kind: "example")).at(el.location())
        numbering(el.numbering, ..n)
      })
    } else {
      it
    }
  }

  if handout-title != none { title() }

  body
}
