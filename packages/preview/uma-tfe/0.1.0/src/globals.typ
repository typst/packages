//// Packages ////////////////////////////////////////////////////////////////

#import "@preview/tiaoma:0.3.0"
#import "@preview/abbr:0.3.1" as abbr
#import "@preview/unify:0.8.1": num
#import "@preview/equate:0.3.3": equate, share-align
#import "@preview/algol-code:0.1.0": algol

//// States //////////////////////////////////////////////////////////////////

#let hide-header = state("hide-header", false)
#let section-type = state("section-type", "Capítulo")

// Track abbreviation keys for custom reference handling
#let _abbr-keys = state("abbr-keys", ())

// Template parameters as states (accessed by content files)
#let titlename = state("titlename", "")
#let titlenameENG = state("titlenameENG", "")
#let author = state("author", "")
#let tutor = state("tutor", "")
#let titulacion = state("titulacion", "")
#let anno = state("anno", "")


//// Chapter utilities ////////////////////////////////////////////////////////

#let chapterend() = {
  hide-header.update(true)
  pagebreak(to: "odd", weak: false)
  hide-header.update(false)
}

#let heading-num(it) = numbering(it.numbering, ..counter(heading).at(it.location()))


//// TODO system //////////////////////////////////////////////////////////////

#let _show-todos = state("show-todos", true)
#let _todo-list = state("todo-list", ())

#let TODO(body) = context {
  if _show-todos.at(here()) {
    let loc = here()
    let page-num = counter(page).at(loc).first()

    // Auto-extract summary from nearest heading before this TODO
    let headings = query(heading.where(level: 1).or(heading.where(level: 2)).or(heading.where(level: 3)).before(loc))
    let summary = if headings.len() > 0 {
      let last-heading = headings.last()
      if "text" in last-heading.body.fields() {
        last-heading.body.text
      } else {
        repr(last-heading.body)
      }
    } else {
      "TODO"
    }

    _todo-list.update(lst => {
      lst.push((text: summary, page: page-num, location: loc))
      return lst
    })

    block(
      fill: yellow.lighten(75%),
      stroke: 1pt + yellow.darken(20%),
      inset: 8pt,
      radius: 4pt,
      width: 100%,
      text(fill: black)[#body],
    )
  } else { [] }
}

#let todo-index() = context {
  let todos = _todo-list.final()
  if todos.len() == 0 { return }

  heading([Lista de TODOs], outlined: false, numbering: none)
  block(
    width: 100%,
    fill: yellow.lighten(75%),
    inset: (top: 1.2em, bottom: 1.2em, x: 10pt),
    stroke: 1pt + yellow.darken(20%),
    radius: 4pt,
  )[
    #for todo in todos {
      v(0.45em)
      grid(
        columns: (1fr, auto),
        link(todo.location)[*#todo.text*],
        [#todo.page],
      )
    }
  ]
  chapterend()
}


//// Table /////////////////////////////////////////////////////////////////////

#let xtable(columns: auto, align: left, ..args) = {
  show table.cell: set par(justify: false)
  // The first row is marked as the header so it repeats if the table spans multiple pages
  let ncols = if type(columns) == array { columns.len() } else if type(columns) == int { columns } else { 1 }
  let has-header = args.pos().len() > 0 and args.pos().first().func() == table.header
  table(
    columns: columns,
    align: align,
    fill: (x, y) => if y == 0 { rgb("#edeef0") } else if calc.even(y) { rgb("#f1f3f5") },
    stroke: (x, y) => if y == 0 {
      (top: 1.5pt + rgb("#212529"), bottom: 0.8pt + rgb("#6c757d"))
    } else { none },
    ..if has-header { args.pos() } else {
      (table.header(..args.pos().slice(0, ncols)), ..args.pos().slice(ncols))
    },
    ..args.named(),
    table.hline(stroke: 1.5pt + rgb("#212529"))
  )
}


//// Math utilities ///////////////////////////////////////////////////////////

#let Re = math.op("Re")
#let Im = math.op("Im")


//// Text utilities ///////////////////////////////////////////////////////////

#let large = 14pt
#let Large = 17.28pt
#let huge  = 24.88pt

#let fakesc(body) = {
  context {
    let scaling = 0.8
    
    // Compute the EXACT tracking in points based on the actual size of the text block
    let current_size = text.size
    let letter_tracking = current_size * 0.06 
    
    let text_content = if type(body) == content { body.text } else { body }
    let words = text_content.split(" ")

    let result = words.map(word => {
      let chars = word.clusters()
      let processed_word = chars.map(ch => {
        if ch.matches(regex("\p{Ll}")).len() > 0 {
          text(size: scaling * 1em, upper(ch)) + h(letter_tracking)
        } else if ch.matches(regex("[\p{Lu}\p{N}\-.]")).len() > 0 {
          ch + h(letter_tracking)
        } else {
          ch
        }
      }).join()
      
      box(processed_word)
    })

    result.join([ ])
  }
}


#let subheading-grid(num, body, gutter: 0.9em) = grid(
  columns: (auto, 1fr),
  column-gutter: gutter,
  align: (left + top, left + top),
  [#num], [#body],
)


//// Figure utilities /////////////////////////////////////////////////////////

#let repo-qr-content(name, url, description) = {
  grid(
    columns: (1fr, 2.2cm),
    column-gutter: 1em,
    align: (left + horizon, center + horizon),
    [
      *#name* \
      #link(url)[#url.replace("https://", "")] \
      #description
    ],
    [#tiaoma.qrcode(url, width: 2cm)],
  )
}


#let algorithm(body, caption: none, line-spacing: 0.7em) = figure(
  kind: "algorithm",
  supplement: [Algoritmo],
  caption: caption,
  block(width: 100%, stroke: 0.5pt + black, inset: 0.6em, {
    set align(left)
    set text(font: "New Computer Modern")
    algol(
      box-stroke: none,
      box-inset: 0pt,
      line-numbering: none,
      line-spacing: line-spacing,
      body,
    )
  }),
)

//// Index styles /////////////////////////////////////////////////////////////

#let index-style(doc) = {
  let last-chapter-loc = state("last-chapter-loc", none)

  show outline.entry: it => {
    set text(hyphenate: true)
    
    let is-heading-l1 = it.level == 1 and it.element.func() == heading
    let is-figure = it.element.func() == figure

    // Dot leader aligned to the right, so the dots of all entries fall in the same columns.
    // It is hidden when not even one dot fits.
    let dot-leader = layout(size => {
      let unit = [.#h(0.5em)]
      let n = calc.ceil(size.width / measure(unit).width)
      if n < 1 { none } else { align(right, unit * n) }
    })
    let fixed-separation = 0.7em

    if is-heading-l1 {
      context {
        let loc = it.element.location()
        let all-headings = query(heading)
        let pos = all-headings.position(h => h.location() == loc)
        
        let has-subheadings = if pos != none and pos + 1 < all-headings.len() {
          all-headings.at(pos + 1).level > 1
        } else {
          false
        }

        v(1.8em, weak: true)
        block(sticky: has-subheadings)[
          #set par(first-line-indent: 0pt)
          #let number = if it.element.numbering != none {
            box(width: 1.5em)[
              #numbering(it.element.numbering, ..counter(heading).at(loc))
            ]
          }
          #strong([
            #number
            #link(loc)[#text(fill: black)[#it.element.body]]
            #h(1fr)
            #it.page()
          ])
        ]
      }
    } else if is-figure {
      context {
        let loc = it.element.location()
        let fig-item = it.element

        let kind-str = if type(fig-item.kind) == symbol { str(fig-item.kind) } else { repr(fig-item.kind) }
        let is-first-entry = state("is_first_" + kind-str, true)

        if is-first-entry.get() {
          v(1.5em, weak: true)
          is-first-entry.update(false)
        }

        let current-before = query(heading.where(level: 1).before(loc))
        let current-ch = if current-before.len() > 0 { current-before.last() } else { none }
        let current-ch-loc = if current-ch != none { current-ch.location() } else { none }
        let prev-ch-loc = last-chapter-loc.get()

        if prev-ch-loc != none and prev-ch-loc != current-ch-loc {
          v(1.8em, weak: true)
        }
        last-chapter-loc.update(current-ch-loc)

        v(0.8em, weak: true)

        let fig-num = if fig-item.numbering != none {
          let fig-counter = counter(figure.where(kind: fig-item.kind)).at(loc).first()
          if current-ch != none and current-ch.numbering != none {
            let ch-prefix = numbering(current-ch.numbering, ..counter(heading).at(current-ch.location()))
            ch-prefix + "." + str(fig-counter)
          } else {
            str(fig-counter)
          }
        } else { "" }

        pad(left: 1.8em)[
          #grid(
            columns: (2.3em, 1fr, 1.5em),
            align: (left + top, left + top, right + bottom),
            row-gutter: 0pt,
            fig-num,
            [
              #link(loc)[#text(fill: black)[#fig-item.caption.body]]
              #h(1em, weak: true)
              #box(width: 1fr)[#dot-leader]
            ],
            [#it.page()],
          )
        ]
      }
    } else {
      v(1em, weak: true)
      context {
        let loc = it.element.location()

        let get-width-of-level(lvl) = {
          if it.element.numbering != none {
            let counts = counter(heading).at(loc)
            let sub-counts = counts.slice(0, calc.min(lvl, counts.len()))
            let num-string = numbering(it.element.numbering, ..sub-counts)
            let clusters = num-string.clusters()
            let text-width = clusters.map(c => if c == "." { 0.26em } else { 0.64em }).sum()
            return text-width + fixed-separation
          }
          return 2.3em
        }

        let get-pad(lvl) = {
          if lvl <= 2 { 1.8em } else { get-pad(lvl - 1) + get-width-of-level(lvl - 1) + 0.15em }
        }

        let left-pad = get-pad(it.level)
        let current-num-width = get-width-of-level(it.level)

        pad(left: left-pad)[
          #grid(
            columns: (current-num-width, 1fr, 1.5em),
            align: (left + top, left + top, right + bottom),
            row-gutter: 0pt,
            if it.element.func() == heading and it.element.numbering != none {
              numbering(it.element.numbering, ..counter(heading).at(loc))
            },
            [
            #link(loc)[#text(fill: black)[#it.element.body]]
              #h(1em, weak: true)
              #box(width: 1fr)[#dot-leader]
            ],
            [#it.page()],
          )
        ]
      }
    }
  }
  doc
}


//// Appendices ///////////////////////////////////////////////////////////////

#let appendices(doc) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading.where(level: 1): it => {
    section-type.update("Apéndice")
    it
  }

  doc
}


//// Mini table of contents ///////////////////////////////////////////////////

#let minitoc() = context {
  let current-loc = here()
  let chapters-before = query(heading.where(level: 1).before(current-loc))
  if chapters-before.len() == 0 { return }

  let current-ch = chapters-before.last()
  let chapters-after = query(heading.where(level: 1).after(current-loc))
  let next-ch-loc = if chapters-after.len() > 0 { chapters-after.first().location() } else { none }

  v(0.5em)
  set par(first-line-indent: 0pt)
  text(size: 14pt, weight: "bold")[Contenido]
  v(-0.7em)
  line(length: 100%, stroke: 0.4pt)
  v(-0.4em)

  set text(size: 11pt)

  pad(left: 2em)[
    #block(width: 95%, breakable: true)[
      #set align(left)
      #show outline.entry: it => {
        let it-loc = it.element.location()
        let is-after-start = (
          it-loc.position().page > current-ch.location().position().page
            or (
              it-loc.position().page == current-ch.location().position().page
                and it-loc.position().y >= current-ch.location().position().y
            )
        )

        let is-before-next = if next-ch-loc != none {
          (
            it-loc.position().page < next-ch-loc.position().page
              or (
                it-loc.position().page == next-ch-loc.position().page and it-loc.position().y < next-ch-loc.position().y
              )
          )
        } else { true }

        if is-after-start and is-before-next and it.level > 1 {
          v(0.45em, weak: true)
          if it.level == 2 {
            strong(it)
          } else {
            it
          }
        } else {
          none
        }
      }

      #outline(
        title: none,
        target: heading.where(level: 2).or(heading.where(level: 3)),
      )
    ]
  ]

  v(-0.3em)
  line(length: 100%, stroke: 0.4pt)
}
