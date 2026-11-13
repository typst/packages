#import "globals.typ": *

#let thesis(
  title: "Default Title",
  title-en: none,
  author-name: "Author",
  supervisor-name: "Supervisor",
  degree: "Degree",
  year: "2026",
  acronyms: (),
  show-todos: false,
  body,
) = {
  // Configure TODO visibility
  _show-todos.update(show-todos)

  // Load acronyms from CSV
  let acronimos-data = acronyms
  abbr.config(style: it => it)
  abbr.make(..acronimos-data.map(row => (row.acronym, row.expansion)))

  // Register keys in our own state for custom reference handling
  _abbr-keys.update(acronimos-data.map(row => row.acronym))

  let en-terms = acronimos-data
    .filter(row => row.en == "1")
    .map(row => row.expansion)

  // Set template parameter states for content files
  titlename.update(title)
  titlenameENG.update(title-en)
  author.update(author-name)
  tutor.update(supervisor-name)
  titulacion.update(degree)
  anno.update(year)

  // Page setup
  set page(
    paper: "a4",
    margin: (
      left: 3cm,
      right: 3cm,
      top: 3.5cm,
      bottom: 3.5cm,
    ),
    header: context {
      let current-page = here().page()
      if hide-header.at(here()) == true { return }

      let all-h1 = query(heading.where(level: 1))
      let is-start-of-ch = all-h1.any(h => h.location().page() == current-page)
      let chapters-before = query(heading.where(level: 1).before(here()))

      if chapters-before.len() > 0 and not is-start-of-ch {
        let is-odd = calc.odd(current-page)
        let current-chapter = chapters-before.last()
        let has-numbering = current-chapter.numbering != none
        let ch-num = counter(heading).at(current-chapter.location()).first()

        if is-odd {
          // Odd pages: show current section + page number
          let all-sections = query(heading.where(level: 2))
          let sections-in-page = all-sections.filter(s => s.location().page() == current-page)
          let section-text = ""

          if sections-in-page.len() > 0 {
            let s = sections-in-page.first()
            section-text = numbering(s.numbering, ..counter(heading).at(s.location())) + "  " + s.body
          } else {
            let sections-before = all-sections.filter(s => s.location().page() < current-page)

            if sections-before.len() > 0 {
              let last-s = sections-before.last()
              let is-from-current-ch = (
                (last-s.location().page() > current-chapter.location().page())
                  or (
                    last-s.location().page() == current-chapter.location().page()
                      and last-s.location().position().y > current-chapter.location().position().y
                  )
              )

              if is-from-current-ch {
                section-text = (
                  numbering(last-s.numbering, ..counter(heading).at(last-s.location())) + "  " + last-s.body
                )
              } else {
                section-text = current-chapter.body
              }
            } else {
              section-text = current-chapter.body
            }
          }

          grid(
            columns: (1fr, auto),
            align(left, section-text), align(right, counter(page).display()),
          )
        } else {
          // Even pages: show page number + chapter title
          grid(
            columns: (auto, 1fr),
            align(left, counter(page).display()),
            align(right, context {
              let type = section-type.at(here())
              let num = if has-numbering {
                numbering(current-chapter.numbering, ..counter(heading).at(current-chapter.location()))
              }

              if has-numbering {
                [#type #num. #current-chapter.body]
              } else {
                [#current-chapter.body]
              }
            }),
          )
        }
        v(-0.6em)
        line(length: 100%, stroke: 0.8pt)
        v(-0.3em)
      }
    },
    footer: context {
      let current-page = here().page()
      let all-h1 = query(heading.where(level: 1))

      let is-start-of-ch = all-h1.any(h => h.location().page() == current-page)

      if is-start-of-ch {
        v(-0.7cm)
        set align(center)
        counter(page).display()
      }
    },
  )

  // Text styles
  set text(font: "TeX Gyre Heros", size: 12pt, tracking: 0.02em, lang: "es")
  set par(
    justify: true,
    leading: 0.5em,
    spacing: 0.91em,
    first-line-indent: (amount: 1.5em, all: true),
  )

  // Heading styles
  set heading(numbering: "1.1")

  // Figure styles
  set figure(
    numbering: n => context {
      let before = query(heading.where(level: 1).before(here()))

      if before.len() > 0 {
        let last-h = before.last()
        let h-counter = counter(heading).at(last-h.location())

        if last-h.numbering != none {
          let ch-prefix = numbering(last-h.numbering, ..h-counter)
          [#ch-prefix.#n]
        } else {
          [#n]
        }
      } else {
        [#n]
      }
    },
  )

  show emph: it => [#h(0.03em)#it#h(0.06em)]

  show link: it => {
    set text(fill: rgb(0, 51, 102))
    if type(it.dest) == str {
      set text(font: "DejaVu Sans Mono", size: 0.85em)
      it
    } else {
      it
    }
  }

  show figure: it => {
    v(0.8em)
    set math.equation(numbering: none)
    it
    v(0.8em)
  }

  show figure.where(kind: raw): it => {
    show figure.caption: set align(center)
    set align(left)
    set block(breakable: true)
    it
  }

  // Algorithms: own list rules, independent of the ones for normal lists
  show figure.where(kind: "algorithm"): it => {
    set list(spacing: 0.9em)
    show list: it => it
    it
  }

  // Heading show rules
  show heading: it => {
    set par(first-line-indent: 0pt)
    if it.level == 1 {
      // Reset counters at chapter start
      counter(footnote).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(figure.where(kind: "algorithm")).update(0)

      pagebreak(weak: true)
      hide-header.update(false)
      v(2.4cm)
      set text(size: 25pt, weight: "bold")

      if it.numbering != none {
        let type = section-type.at(it.location())
        let num = heading-num(it)

        [#type #num]
        v(0.1cm)
        block(it.body)
      } else {
        block(it.body)
      }
      v(1.2cm)
    } else {
      // Levels 2+: use subheading-grid
      let (size, above, below, gutter) = if it.level == 2 {
        (17pt, 0.8em, 0.4em, 1em)
      } else if it.level == 3 {
        (14pt, 0.4em, 0.2em, 0.9em)
      } else {
        (12pt, 0.4em, 0.2em, 0.8em)
      }
      v(above)
      set text(size: size, weight: "bold")
      if it.numbering != none {
        subheading-grid(heading-num(it), it.body, gutter: gutter)
      } else {
        it.body
      }
      v(below)
    }
  }

  // Equate show rule for equation sub-numbering
  set math.equation(numbering: "(1.1)")
  show: equate.with(breakable: true, sub-numbering: true)

  // List styles
  set list(
    marker: (
      box(baseline: -0.1em)[
        #text(
          font: "DejaVu Sans",
          size: 0.7em,
          sym.square.filled.small,
        )
      ],
      sym.bullet,
    ),
    indent: 1.5em,
    spacing: 1.3em,
  )

  show list: it => {
    v(1.5em, weak: true)
    it
    v(1.5em, weak: true)
  }

  // Enum styles
  set enum(
    indent: 1.5em,
    spacing: 1.3em,
  )

  show enum: it => {
    v(1.5em, weak: true)
    it
    v(1.5em, weak: true)
  }

  // Code block styles
  show raw.where(block: true): it => {
    v(1.5em, weak: true)
    block(
      fill: rgb("#f8f9fa"),
      stroke: 0.5pt + rgb("#e1e4e6"),
      radius: 4pt,
      width: 100%,
      clip: true,
      {
        show raw: it => it

        if it.lang != none {
          block(
            width: 100%,
            fill: rgb("#edeef0"),
            inset: (x: 10pt, y: 4pt),
            stroke: (bottom: 0.5pt + rgb("#e1e4e6")),
            sticky: true,
            below: 0pt,
            text(size: 8pt, weight: "bold", fill: rgb("#5c636a"), upper(it.lang)),
          )
        }

        block(
          width: 100%,
          above: 0pt,
          inset: (
            x: 10pt,
            top: if it.lang != none { 8pt } else { 10pt },
            bottom: 10pt,
          ),
          it,
        )
      },
    )
    v(1.5em, weak: true)
  }

  // Reference handling
  show ref: it => {
    let el = it.element
    if el != none {
      context {
        if el.func() == heading {
          link(el.location())[#numbering(el.numbering, ..counter(heading).at(el.location()))]
        } else if el.func() == figure {
          if el.numbering == none {
            link(el.location())[#el.supplement]
          } else {
            let fig-counter = counter(figure.where(kind: el.kind)).at(el.location()).first()

            let current-before = query(heading.where(level: 1).before(el.location()))
            if current-before.len() > 0 and current-before.last().numbering != none {
              let ch-prefix = numbering(
                current-before.last().numbering,
                ..counter(heading).at(current-before.last().location()),
              )
              link(el.location())[#ch-prefix.#fig-counter]
            } else {
              link(el.location())[#fig-counter]
            }
          }
        } else if el.func() == math.equation {
          if el.numbering != none {
            let eq-counter = counter(math.equation).at(el.location()).first()
            link(el.location())[#str(eq-counter)]
          } else {
            it
          }
        } else {
          it
        }
      }
    } else {
      it
    }
  }

  // Abbreviation show rule with custom default specifier
  show: abbr.show-rule
  show ref: it => context {
    let known-keys = _abbr-keys.final()
    let (key, ..spec) = str(it.target).split(":")
    if key in known-keys {
      let specs = (
        a: abbr.a,
        asf: abbr.asf,
        s: abbr.s,
        l: abbr.l,
        lsf: abbr.lsf,
        lo: abbr.lo,
        pls: abbr.pls,
        pll: abbr.pll,
        pllo: abbr.pllo,
        pla: abbr.pla,
      )
      if spec.len() != 0 {
        let func = spec.first()
        if func not in specs {
          panic("unknown specifier ':" + func + "' used on abbreviation [" + key + "]")
        }
        specs.at(func)(key)
      } else {
        // Default
        abbr.asf(key)
      }
    } else {
      it
    }
  }

  // English terms in italics
  if en-terms.len() > 0 {
    let pattern = en-terms
      .map(term => term.replace("(", "\(").replace(")", "\)").split(" ").join("\s+"))
      .join("|")

    show regex(pattern): emph
    body
  } else {
    body
  }
}
