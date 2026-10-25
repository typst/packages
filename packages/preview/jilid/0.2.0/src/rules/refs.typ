#import "../state.typ": page-label, section
#import "../utils.typ": h1-number

// References to headings:
// - An unnumbered heading gives its title and page, such as "Kata Pengantar (halaman iv)".
// - A chapter gives "BAB II".
// - An appendix gives "Lampiran 1".
// Lower levels keep the Typst default, such as "Bagian 1.2".
#let ref-rules(cfg, body) = {
  show ref: it => {
    let el = it.element
    if el == none or el.func() != heading { return it }
    let loc = el.location()

    if el.numbering == none {
      return context {
        let name = if it.supplement not in (none, auto) { it.supplement } else {
          el.body
        }
        link(loc)[#name (#cfg.t.page #page-label(cfg, loc))]
      }
    }

    if el.level == 1 and it.supplement == auto {
      return context {
        let n = h1-number(
          cfg,
          section.at(loc),
          counter(heading).at(loc).first(),
        )
        if n == none { it } else { link(loc, n) }
      }
    }
    it
  }

  body
}
