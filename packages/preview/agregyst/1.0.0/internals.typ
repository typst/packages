#let item-kind = "agregyst:item"

#let colors = (
  h1: red.darken(10%),
  h2: green.darken(20%),
  h3: purple.darken(20%),
  item: blue,
  dev: purple,
)

#let color-box(color: colors.dev, name: [DEV], body) = {
  let stroke = 1pt + color
  let name = text(fill: color, size: 8.5pt, weight: "bold", name)
  let outset = 4pt

  show: block.with(
    width: 100%,
    breakable: true,
    stroke: stroke,
    outset: outset,
  )

  context {
    let (page-width, page-height) = if page.flipped {
      (page.height, page.width)
    } else {
      (page.width, page.height)
    }
    let is-left-column = here().position().x < page-width / 2

    let it = box(
      inset: (x: 0.3em, y: 0.15em),
      stroke: stroke,
      name,
    )

    show: place.with(
      dx: if is-left-column {
        100% + outset
      } else {
        -outset - measure(it).height
      },
      dy: -outset,
    )
    show: rotate.with(
      if is-left-column {
        90deg
      } else {
        -90deg
      },
      reflow: true,
    )
    it
  }

  body
}

#let dev(c) = color-box(c)
#let warning(c) = color-box(c,
  color: orange,
  title: emoji.warning
)

#let item(type, name, c) = {
  figure(
    placement: none,
    caption: name,
    kind: item-kind,
    supplement: type,
    numbering: "1",
    c,
  )
}

#let citation-color(key) = {
  if key == <NAN> {
    gray
  } else {
    import "@preview/jumble:0.0.1" : sha1
    let hash = array(sha1(str(key)))
    let value = hash.at(0).bit-lshift(8).bit-or(hash.at(1)).bit-lshift(8).bit-or(hash.at(2)) / (1.bit-lshift(8 * 3) - 1)
    color.hsv(360deg * value, 80%, 80%, 100%)
  }
}

#let format-citation(key, supplement: none) = {
  set text(fill: citation-color(key))
  [\[]
  str(key)
  if supplement != none {
    [ #supplement]
  }
  [\]]
}

#let tableau(body) = {
  set page(
    flipped: true,
    margin: 12pt,
    columns: 2,
    background: line(length: 100%, angle: 90deg),
  )

  set par(
    leading: 0.6em,
    spacing: 0.6em,
    justify: true,
    hanging-indent: 0em,
  )

  set list(
    tight: false,
    body-indent: 0.4em,
    spacing: 0.5em,
  )

  set text(
    font: "New Computer Modern",
    size: 14pt,
    number-width: "proportional",
    hyphenate: true,
  )
  show math.equation: set text(weight: "regular")
  show raw: set text(font: "New Computer Modern Mono")

  show selector.or(title, heading): set par(justify: false)

  show title: set text(size: 0.65em)
  show title: set block(spacing: 0.9em)
  show title: underline

  show heading: set block(spacing: 0.7em)
  show heading: underline

  show heading.where(level: 1): set heading(numbering: n => numbering("I.", n))
  show heading.where(level: 1): set text(size: 0.77em, fill: colors.h1)

  show heading.where(level: 2): set heading(numbering: (.., n) => numbering("A.", n))
  show heading.where(level: 2): set text(size: 0.75em, fill: colors.h2)

  show heading.where(level: 3): set heading(numbering: (.., n) => numbering("1.", n))
  show heading.where(level: 3): set text(size: 0.8em, fill: colors.h3)

  let bold-size = 0.85em
  show strong: set text(bold-size)

  show link: it => underline(stroke: black, it)

  set footnote.entry(
    separator: none,
    clearance: 2pt,
    gap: 0.4em,
    indent: 0pt,
  )

  show figure.where(kind: item-kind): set align(start)
  show figure.where(kind: item-kind): set block(breakable: true)
  show figure.where(kind: item-kind): it => {
    underline({
      set text(fill: colors.item, size: bold-size, weight: "bold")
      it.caption.supplement
      sym.space.nobreak
      it.caption.counter.display()
    })
    [ ]
    text(size: bold-size, weight: "bold", it.caption.body)
    it.body
  }

  show bibliography: set heading(numbering: none)
  show bibliography: it => {
    show heading: set text(fill: black)
    show heading: underline

    assert.eq(it.sources.len(), 1, message: "expected exactly one bibliography source")
    if type(it.sources.first()) != bytes {
      // We use `assert(false)` instead of `panic()` so that the error message
      // is printed as a string instead of its repr being printed.
      assert(
        false,
        message: "cannot read bibliography from file, try `bibliography(read(\"" + it.sources.first() + "\", encoding: none))`",
      )
    }
    let file = yaml(it.sources.first())

    heading(
      numbering: none,
      if it.title == auto {
        [Bibliographie]
      } else {
        it.title
      },
    )

    let short-author(author) = {
      let parts = author.split(",").map(str.trim)
      assert(parts.len() in (1, 2))
      if parts.len() == 1 {
        return parts.first()
      }
      let (last-name, first-name) = parts
      [#first-name.clusters().first().~#last-name]
    }

    let display-entry(key) = {
      let book = file.at(str(key))

      let authors = book.author
      if type(authors) == str {
        authors = (authors,)
      }

      h(0.8em)
      [ ]
      format-citation(key)
      sym.space.nobreak
      authors.map(short-author).join(last: [ & ])[, ]
      [, ]
      text(style: "italic", book.title)
      [.]
      linebreak()
    }

    let done = ()
    for elt in query(cite) {
      if elt.key != <NAN> and elt.key not in done {
        display-entry(elt.key)
        done.push(elt.key)
      }
    }

    if it.full {
      for k in file.keys() {
        let key = label(k)
        if key != <NAN> and key not in done {
          display-entry(key)
        }
      }
    }
  }

  show cite : it => format-citation(it.key, supplement: it.supplement)

  body
}

#let abbreviate(name) = {
  let s = if type(name) == content and name.func() == text {
    name.text
  } else if type(name) == str {
    name
  }
  if s == none {
    return none
  }
  // Precomposed accented letters in regular expressions do not match their
  // canonical decomposition, so we normalize to NFC first.
  s = s.normalize()
  // (?i) is for case insensivitity.
  // ^ and $ are to match the entire string.
  // Ideally this would be in a dictionary, but this doesn't work because we
  // want to be case insensitive
  if s.contains(regex("(?i)^d(é|e)f(inition)?$")) {
    [Def]
  } else if s.contains(regex("(?i)^prob(lème|lem)$")) {
    [Prob]
  } else if s.contains(regex("(?i)^prop(osition|riété|erty)$")) {
    [Prop]
  } else if s.contains(regex("(?i)^comp(lexité|lexity)$")) {
    [Complex]
  } else if s.contains(regex("(?i)^notation$")) {
    [Not]
  } else if s.contains(regex("(?i)^méthode$")) {
    [Métho]
  } else if s.contains(regex("(?i)^impl(é|e)mentation$")) {
    [Implem]
  } else if s.contains(regex("(?i)^application$")) {
    [App]
  } else if s.contains(regex("(?i)^remarque$")) {
    [Rq]
  } else if s.contains(regex("(?i)^remark$")) {
    [Rem]
  } else if s.contains(regex("(?i)^(théorème|theorem)$")) {
    [Th]
  } else if s.contains(regex("(?i)^(algorithme|algorithm)$")) {
    [Algo]
  } else if s.contains(regex("(?i)^exemple$")) {
    [Ex]
  } else if s.contains(regex("(?i)^exercice$")) {
    [Exo]
  } else if s.contains(regex("(?i)^example$")) {
    [Eg]
  } else if s.contains(regex("(?i)^exercice$")) {
    [Ex]
  } else if s.contains(regex("(?i)^motivation$")) {
    [Motiv]
  } else if s.contains(regex("(?i)^repr(é|e)sentation$")) {
    [Repr]
  } else {
    name
  }
}

#let recap() = {
  set text(size: 9pt, weight: "bold", hyphenate: true)
  set par(leading: 0.3em, justify: false)

  show: block.with(width: 100%, height: 100%, breakable: false)

  context {
    let recaped = selector.or(
      title,
      heading.where(level: 1),
      heading.where(level: 2),
      figure.where(kind: item-kind),
    )

    let (page-width, page-height) = if page.flipped {
      (page.height, page.width)
    } else {
      (page.width, page.height)
    }

    let page-count = 3
    let column-per-page = page.columns
    let column-width = (page-width - 2 * page.margin) / column-per-page
    let column-height = page-height - 2 * page.margin
    let column-count = page-count * column-per-page

    // Get the index of the column a location is in.
    let column-index(pos) = {
      let column-in-page = calc.floor((pos.x - page.margin) / column-width)
      column-per-page * (pos.page - 1) + column-in-page
    }

    // Build the list notable elements for each of the six columns.
    let column-elements = ((),) * column-count
    for it in query(recaped.before(here(), inclusive: false)) {
      let pos = it.location().position()
      if pos.page <= page-count {
        column-elements.at(column-index(pos)).push(it)
      }
    }

    // Elements to display, in visual order for each column.
    let columns = column-elements
      .map(column => column.sorted(key: it => it.location().position().y))

    // Citation backgrounds to display, in visual order for each column.
    let elements = columns.flatten()
    let citations = query(selector(cite).before(here(), inclusive: false))
    let citations-by-column = ((),) * column-count
    let pending-citations = (none,) * column-count
    for i in range(elements.len()) {
      let current = elements.at(i)
      let current-pos = current.location().position()
      let current-column = column-index(current-pos)
      let current-key = (current-column, current-pos.y)

      let next = elements.at(i + 1, default: none)
      let next-key = if next != none {
        let next-pos = next.location().position()
        (column-index(next-pos), next-pos.y)
      } else {
        (column-count, 0pt)
      }

      let citation = citations
        .filter(c => {
          let pos = c.location().position()
          let key = (column-index(pos), pos.y)
          current-key <= key and key < next-key
        })
        .first(default: none)

      citations-by-column.at(current-column).push(citation)
      if citation != none {
        for j in range(current-column + 1, column-count) {
          pending-citations.at(j) = citation
        }
      }
    }

    // The heading number to display, if any, for each column.
    let background-numbers = columns.map(column => {
      let hd = column
        .filter(it => it.func() == heading and it.level == 1)
        .first(default: none)
      if hd != none {
        let number = counter(heading).at(hd.location()).first()
        numbering("I", number)
      }
    })

    let margin = 4pt
    let min-spacing = 5pt
    grid(
      columns: (1fr,) * column-per-page,
      rows: (1fr,) * page-count,
      inset: (x: margin),
      stroke: 1pt,

      ..columns
        .zip(background-numbers, citations-by-column, pending-citations, exact: true)
        .map(((column, background-number, citations, pending-citation)) => {
          show: block.with(
            width: 100%,
            height: 100%,
            outset: (x: margin),
            clip: true,
          )

          // Background heading numerals.
          if background-number != none {
            show: place
            show: block.with(width: 100%, height: 100%)
            set align(center + horizon)
            set text(size: 140pt, fill: gray.transparentize(70%))
            background-number
          }

          // Generate miniature versions of titles, headings and items.
          let miniatures = column
            .map(it => (
              it.location().position().y,
              if it.func() == title {
                show: block.with(inset: (bottom: 0.1em))
                show: underline
                set text(size: 1.1em)
                if it.body == auto {
                  document.title
                } else {
                  it.body
                }
              } else if it.func() == heading {
                show: underline
                set text(size: 1.1em, fill: colors.h1) if it.level == 1
                set text(size: 0.9em, fill: colors.h2) if it.level == 2
                if it.numbering != none {
                  numbering(it.numbering, ..counter(heading).at(it.location()))
                  [ ]
                }
                it.body
              } else {
                assert.eq(it.func(), figure)
                assert.eq(it.kind, item-kind)
                let number = counter(figure.where(kind: item-kind)).at(it.location()).first()
                grid(
                  columns: 2,
                  gutter: margin + 0.5em,
                  box(
                    width: 1em,
                    outset: (x: margin, y: min-spacing / 2),
                    stroke: 1pt,
                    align(center + horizon, numbering(it.numbering, number)),
                  ),
                  {
                    text(fill: colors.item, abbreviate(it.caption.supplement))
                    [ ]
                    it.caption.body
                  }
                )
              },
            ))

          // Display the miniatures & background colors.
          layout(available => {
            let miniature-height(miniature) = {
              measure(miniature, width: available.width).height + min-spacing
            }

            // The sum of the heights of the remaining miniatures to place.
            let pending-height = miniatures
              .map(((_, miniature)) => miniature-height(miniature))
              .sum(default: 0pt) - min-spacing / 2
            // The position of the bottom edge of the previous miniature.
            let previous-end-y = margin
            let y-positions = (none,) * column.len()

            let backgrounds = ()
            let elements = ()

            if pending-citation != none {
              backgrounds.push((0pt, pending-citation))
            }

            for ((reference-y, miniature), citation) in miniatures.zip(citations, exact: true) {
              // Where the miniature would be with no additional constraint.
              let ideal-y = available.height * (reference-y / column-height)
              // Display the miniature a little higher if necessary to ensure
              // all further miniatures fit within the available space.
              let preventive-y = calc.min(ideal-y, available.height - pending-height)
              // This is almost `calc.max(preventive-y, previous-end-y)` but we
              // add a slight "snapping" behavior so that items that are very
              // close to each other are displayed stuck together instead of
              // awkwardly close.
              let y = if preventive-y - previous-end-y < 2pt {
                previous-end-y
              } else {
                preventive-y
              }

              if citation != none {
                backgrounds.push((y, citation))
              }
              elements.push((y, miniature))

              let height = miniature-height(miniature)
              previous-end-y = y + height
              pending-height -= height
            }

            for i in range(backgrounds.len()) {
              let (start-y, citation) = backgrounds.at(i)
              let end-y = if i + 1 < backgrounds.len() {
                backgrounds.at(i + 1).first() - min-spacing / 2
              } else {
                available.height
              }
              place(
                dy: start-y,
                rect(
                  fill: citation-color(citation.key).transparentize(80%),
                  width: 100%,
                  outset: (x: margin, top: min-spacing / 2),
                  height: end-y - start-y,
                ),
              )
            }

            for (y, miniature) in elements {
              place(dy: y, miniature)
            }
          })
        }),
    )
  }
}
