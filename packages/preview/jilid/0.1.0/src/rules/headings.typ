#import "../state.typ": section, sections
#import "../utils.typ": h1-number, h1-title

// heading look per part
// - front: centered, never numbered.
// - main: "BAB I" above the title, centered.
// - back: "Lampiran 1. Title", on the left.
// each chapter should restarts the figure, table, code and equation counters.
#let heading-rules(cfg, body) = {
  let hs = cfg.headings
  set heading(numbering: cfg.numbering.heading, supplement: cfg.t.section)

  show heading: it => {
    set text(weight: "bold")
    set par(first-line-indent: 0pt)

    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
    }

    if it.level == 1 {
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
      counter(math.equation).update(0)

      context {
        let sec = section.get()
        let numbered = it.numbering != none and sec != sections.front
        let appendix = sec == sections.back and numbered
        let title = h1-title(cfg, it.body, appendix: appendix)

        // "BAB I \ TITLE", "Lampiran 1. Title", or just the title.
        let n = h1-number(cfg, sec, counter(heading).get().first())
        let label = if not numbered {
          title
        } else if appendix and cfg.numbering.appendix-prefix {
          [#n. #text(weight: "regular", title)]
        } else if appendix {
          title
        } else {
          [#n \ #title]
        }

        // the first appendix should shares its page with the LAMPIRAN title.
        let first-appendix = appendix and counter(heading).get().first() == 1
        if hs.h1.pagebreak and not first-appendix { pagebreak(weak: true) }

        align(if appendix { left } else { center })[
          #v(hs.h1.above)
          #text(size: hs.h1.size, weight: "bold")[#label]
          #v(hs.h1.below)
        ]
      }
    } else {
      // level deeper than 4 reuse `h4`.
      let style = hs.at("h" + str(calc.min(it.level, 4)))
      v(style.above, weak: true)
      text(size: style.size)[
        #h(style.indent)#if number != none [#number.trim() ]#it.body
      ]
      v(style.below, weak: true)
    }
  }

  body
}
