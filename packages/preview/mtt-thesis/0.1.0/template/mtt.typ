#import "@preview/dashy-todo:0.1.3": todo
#import "@preview/acrostiche:0.7.0": print-index
#import "@preview/gentle-clues:1.3.1": code, task

// Displays a task-style placeholder with an optional explanation and usage snippet.
#let mtt-placeholder(
  title: "",
  description: none,
  snippet: "",
  template: "mtt-thesis",
) = {
  task(title: title)[
    #if description != none { description }
    #code[#raw(
      lang: "typc",
      block: true,
      "#show: " + template + ".with(\n  " + snippet + "\n  // ...\n)",
    )]
  ]
}

// Places content in a breakable figure and infers the figure kind when requested.
#let mtt-breakable-figure(
  kind: auto,
  caption: auto,
  ref: none,
  ..args,
  content
) = [
  #block(
    breakable: true,
    width: 100%,
  )[
    #set align(center)
    #content
    #figure(
      block(height: -10pt),
      caption: caption,
      kind: {
        if kind == auto {
          if type(content) == table {
            table
          } else if type(content) == raw {
            raw
          } else {
            image
          }
        } else {
          kind
        }
      },
      ..args,
    )
    #if ref != none {
      label(ref)
    }
  ]
]

// Places a breakable code sample in a raw figure with a configurable caption and label.
#let mtt-code-sample(
  caption: auto,
  ref: none,
  supplement: [Code Sample],
  ..args,
  content
) = [
  #block(
    breakable: true,
    width: 100%,
  )[
    #set align(left)
    #content
  ]
  #figure(
    block(height: -10pt),
    caption: caption,
    supplement: supplement,
    kind: raw,
    ..args,
  )
  #if ref != none {
    label(ref)
  }
]

// DEPRECATED. Use mtt-code-sample instead
#let codebox(
  fill: gray.lighten(60%),
  inset: 1em,
  caption: [_insert caption_#todo[insert caption]],
  ref: "none",
  ..args,
  content
) = [
  #block(
    width: 100%,
    breakable: true,
  )[
    #block(
      fill: fill,
      inset: inset,
      width: 100%,
      breakable: true,
    )[
      #set align(left)
      #content
    ]
    #figure(
      block(height: -10pt),
      caption: caption,
      supplement: [Code Sample],
      kind: raw,
      ..args,
    )
    #if ref != "none" {
      label(ref)
    }
  ]
]

// Basically a grid, but with equal spacing in between the elements
#let mtt-space-equally(
  horizontal: true,
  width: auto,
  height: auto,
  first-space: true,
  last-space: true,
  empty-cells: [],
  ..args-grid,
  elements,
) = {
  let N = elements.len()
  let spacings = if first-space {(1fr, )} else {()} + (auto, 1fr) * N
  let elems = if first-space {(empty-cells,)} else {()} + elements.zip((empty-cells,) * N).flatten()

  box(
    width: width,
    height: height,
    grid(
      ..args-grid,
      columns: if horizontal {
        if last-space {spacings} else {spacings.slice(0, -1)}
      } else {1fr},
      rows: if not horizontal {
        if last-space {spacings} else {spacings.slice(0, -1)}
      } else {auto},
        ..if last-space {elems} else {elems.slice(0, -1)},
      //)
    )
  )
}

// Builds the thesis cover page
#let mtt-coverpage(
  logo-left: [],
  logo-center: image("eth_logo_kurz_cropped.svg", height: 25pt),
  logo-right: [],
  org-units: (
    "Department of Science Fiction",
    "Institute of Witchcraft",
  ),
  title: [MTT -- Modular Thesis Template],
  authors: (
    (name: "Frodo Baggins", email: "fbaggins@university.org"),
  ),
  authors-horizontal: true,
  cover-image: none,
  project-type: "Bachelor Thesis",
  date: datetime.today(),
  advisors: (
    (name: "Saruman", email: "saruman@wizards.university.org"),
    //(name: "Gandalf", mail: "gandalf@ethz.ch"),
  ),
  professors: (
    (name: "Gandalf", email: "gandalf@wizards.university.org"),
    //(name: "Gandalf", mail: "gandalf@ethz.ch"),
  ),
  empty-page: true,
  divider-margin-inside: 6mm,
  divider-margin-outside: 0mm,

  department: none, // Legacy. Use org-units instead.
  institute: none, // Legacy. Use org-units instead.
  author-name: none, // Legacy. Use authors instead.
  author-email: none, // Legacy. Use authors instead.
) = { // Cover page

  if department != none and institute != none {
    org-units = (department, institute)
  }
  if author-name != none and author-email != none {
    authors = ((name: author-name, email: author-email),)
  }

  // Converts a supporter list into singular or plural labeled contact entries.
  let parse-supporters(label-sg, label-pl, people) = {
    if people == none or people.len() == 0 {}
    else {
      if people.len() == 1 [#label-sg: ]
      else [#label-pl: ]

      for person in people [
        \ #person.name, #context link("mailto:" + person.email)[#text(fill: text.fill, raw(person.email))]
      ]
    }
  }

  // Converts an author record into a name and optional email address.
  let auth-mapper(author) = {
    text(size: 22pt, author.name)
    if author.at("email", default: none) != none {
      linebreak()
      link("mailto:" + author.email)[#text(fill: black, raw(author.email))]
    }
  }

  page(
    numbering: none,
    {
      set text(12pt)

      let elems = (

        // logos
        /*grid(
          columns: (auto, 1fr, auto),
          align: (left + horizon, center + horizon, right + horizon),
          //rows: 80pt,
          logo-left,
          logo-center,
          logo-right,
        ),*/
        mtt-space-equally(
          first-space: false,
          last-space: false,
          (
            logo-left,
            logo-center,
            logo-right,
          ),
        ),

        // department
        smallcaps(text(size: 12pt, org-units.join([ \ ]))),

        {
          v(divider-margin-outside)
          line(length: 100%)
          v(divider-margin-inside)
        },

        // title
        text(size: 28pt, weight: "bold", par(justify: false, title)),
        
        // authors
        if(authors-horizontal) {
          mtt-space-equally(
            align: center + top,
            authors.map(auth-mapper)
          )
        } else {
          authors.map(auth-mapper)
        },

        // cover image
        {
          // Show task clue in the logo area when cover fields are missing
          if cover-image != none {
            cover-image
          } else {
            mtt-placeholder(
              title: "Provide a logo",
              description: [
                Pass an image to the template, or set
                #raw(lang: "typc", "cover-image: []") to omit:
              ],
              snippet: "coverpage: mtt-coverpage(\n\t\tcover-image: image(\"figs/cover-image.svg\", width: 100%),\n\t\t// ...\n\t),",
            )
          }
        },

        // project type
        smallcaps(text(size: 16pt, project-type)),

        // date
        {
          if type(date) == datetime {
            date.display("[day] [month repr:long] [year]")
          } else {
            date
          }
        },

        // divider line
        {
          v(divider-margin-inside)
          line(length: 100%)
          v(divider-margin-outside)
        },

        parse-supporters("Advisor", "Advisors", advisors),

        parse-supporters("Professor", "Professors", professors),
      ).flatten()

      mtt-space-equally(
        height: 100%,
        width: 100%,
        horizontal: false,
        first-space: false,
        last-space: false,
        align: horizon + center,
        elems,
      )

      
    },
  )
  if empty-page {
    page(header: none, footer: none)[]
  }
}

// Creates a page containing a titled abstract.
#let mtt-abstract(body, title: [Abstract]) = page({
  heading(level: 1, title)
  body
})

// Creates a formatted table of contents page.
#let mtt-toc(title: [Contents]) = page({
  show outline: set par(justify: true)
  show outline.entry: it => link(
    it.element.location(),
    text(fill: black, it.indented(box(it.prefix(), width: 0.8em * it.level), it.inner())),
  )
  show outline.entry.where(level: 1): set text(size: 14pt, weight: "bold", fill: black)
  show outline.entry.where(level: 2): set text(size: 13pt, weight: "semibold", fill: black)


  outline(title: title, depth: 3, indent: 1.3em)
})

// Creates a list of figures of the requested figure kind.
#let mtt-figures(
  title: [List of Figures],
  kind: image,
) = page({
  heading(level: 1, title)
  //show link: body => context { show link: set text(fill: text.fill); body}
  show link: set text(fill: black)

  context {
    let figs = query(figure.where(kind: kind))
    let elems = ()

    for fig in figs {
      let loc = fig.location()
      let pattern = loc.page-numbering()
      let page-count = counter(page).at(loc)
      let page-str = if pattern != none {
        numbering(pattern, ..page-count)
      } else {
        str(loc.page()) // fallback if numbering is set to none at that location
      }

      // --- Prefix / number (e.g. "Figure 3") ---
      let count = counter(figure.where(kind: fig.kind)).at(loc)
      let prefix = if fig.numbering != none {
        numbering(fig.numbering, ..count)
      } else {
        none
      }
      let supplement = fig.supplement
      let sup = if supplement == auto {
        // For image figures this is normally "Figure", for tables "Table", and so on.
        fig.caption.supplement
      } else {
        supplement
      }

      // --- Caption ---
      let caption-full = fig.caption          // full caption content (incl. numbering/supplement)
      let caption-body = if fig.caption != none {
        fig.caption.body
      } else {
        none
      }

      elems.push(link(loc, [#supplement #prefix]))
      elems.push(link(loc, block(sticky: true, width: 100%)[#caption-body]))
      elems.push(link(loc, [#page-str]))
    }

    grid(
      columns: (auto, 1fr, auto),
      align: (left, left, right,),
      column-gutter: 1em,
      row-gutter: 1.5em,
      ..elems,
    )
  }
})

// Creates a list containing only table figures.
#let mtt-tables(title: [List of Tables]) = mtt-figures(
  title: title,
  kind: table,
)

// Creates a list containing only code sample figures.
#let mtt-codes(title: [List of Code Samples]) = mtt-figures(
  title: title,
  kind: raw,
)

// Creates a list containing only todo figures.
#let mtt-todos(title: [List of Todos]) = mtt-figures(
  title: title,
  kind: "todo",
)

// Creates an acronym index with configurable sorting and layout.
#let mtt-acronyms(
  title: [List of Acronyms],
  row-gutter: 1.5em,
  column-ratio: 0.25,
  delimiter: none,
  sorted: "up",
  used-only: false,
  ..args,
) = page({
  heading(level: 1, title)
  print-index(
    row-gutter: row-gutter,
    column-ratio: column-ratio,
    numbering: numbering,
    delimiter: delimiter,
    sorted: sorted,
    used-only: used-only,
    title: "",
    ..args,
  )
})

// Creates a titled bibliography page from a bibliography element.
#let mtt-bibliography(
  title: [Bibliography],
  bibliography,
) = page({
  heading(level: 1, title)
  bibliography
})

// Places content in a centered, titled frame with configurable border and inset.
#let mtt-content-frame(
  title: [Insert a Title],
  stroke: black,
  inset: 2em,
  content,
) = page({
  heading(level: 1, title)
  align(center, box(
    stroke: stroke,
    inset: inset,
    height: 79%,
    content
  ))
})

// Adds the included Typst guide as a standalone page.
#let mtt-typst-guide() = page(include "typst-guide.typ")

// Main thesis layout.
#let mtt-thesis(
  coverpage: mtt-coverpage(),
  before: (),
  after: (),
  margin: (
    y: 25mm,
    x: 30mm,
    binding-width: 0mm,
  ),
  localisation: (
    lang: "EN",
    region: "GB",
  ),
  customisation: body => body,
  body
) = {
  // Configure page margins, including the optional binding offset.
  if "binding-width" in margin and ("x" in margin or "left" in margin and "right" in margin) {
    let (l, r) = if "x" in margin {
      (margin.remove("x"), ) * 2
    } else {
      (margin.remove("left"), margin.remove("right"))
    }
    let binding-width = margin.remove("binding-width")
    margin.inside = l + binding-width / 2
    margin.outside = r - binding-width / 2
  }
  set page(
    paper: "a4",
    binding: left,
    margin: margin,
  )

  // text styling
  set text(..localisation)
  set par(justify: true)
  show heading.where(level: 1): set par(justify: false)
  set list(indent: 1em)

  // Configure figure caption spacing.
  show figure.caption: set block(
    inset: (
      x: 15pt,
      top: 0pt,
      bottom: 10pt,
    ),
    width: 100%,
  )

  // Configure equation numbering and references.
  set math.equation(
    numbering: "(1)",
    supplement: "Equation",
  )
  show ref: it => {
    let eq = math.equation
    let el = it.element
    // Skip all other references.
    if el == none or el.func() != eq { return it }

    // Override equation references.
    let supplement = if it.supplement == auto {
      [Equation ]
    } else if it.supplement == [] or it.supplement == "" {} else {
      it.supplement + " "
    }
    show link: set text(fill: black)
    link(el.location(), supplement + counter(eq).display(at: el.location()))
  }


  // Color all links blue. (e.g. email addresses)
  show link: set text(fill: blue)

  // Heading styles
  // Lenny style: large faint chapter number above a rule, title below
  show heading.where(level: 1): it => {
    // Only break for numbered (mainmatter) chapters; frontmatter headings
    // are already inside page() blocks so a break here creates an empty page.
    //if it.numbering != none and it.numbering != "A" { pagebreak(weak: true) }
    if it.numbering != none and it.numbering == "1.1" { pagebreak(weak: true) }
    v(2em)
    if it.numbering != none {
      block(text(
        size: 60pt,
        fill: luma(220),
        weight: "bold",
        counter(heading).display(),
      ))
    }
    line(length: 100%, stroke: 0.5pt)
    v(0.5em)
    block(above: 0em, below: 1em, width: 100%, text(size: 22pt, weight: "bold", it.body))
  }
  show heading.where(level: 2): set text(size: 16pt, weight: "bold")
  show heading.where(level: 2): set block(above: 1.2em, below: 0.6em)
  show heading.where(level: 3): set text(
    size: 14pt,
    weight: "bold",
    //style: "italic",
  )
  show heading.where(level: 3): set block(above: 1em, below: 0.5em)
  // Level 4: inline paragraph heading — bold text followed by em-space
  show heading.where(level: 4): it => {
    text(weight: "bold", it.body)
    h(1em)
  }

  show: customisation

  // COVER PAGE
  coverpage

  set page(numbering: "i")
  counter(page).update(1)

  show heading: set heading(numbering: "A.1", outlined: true)

  for elem in before {
    elem
  }

  pagebreak(weak: true)

  // Save current heading state
  [#metadata(none) <saved-heading>]
  
  set page(numbering: "1")
  
  show heading: set heading(numbering: "1.1", outlined: true)
  counter(heading).update(0)
  counter(page).update(1)

  body

  pagebreak(weak: true)

  // Restore: reset the counter to the value it had at the marker
  context counter(heading).update(counter(heading).at(<saved-heading>))
  context counter(page).update(counter(page).at(<saved-heading>))
  show heading: set heading(numbering: "A.1", outlined: true)
  set page(numbering: "i")

  for elem in after {
    elem
  }
}