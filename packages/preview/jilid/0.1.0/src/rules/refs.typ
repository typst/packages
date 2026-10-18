#import "../state.typ": page-label, section
#import "../utils.typ": h1-number

// references to headings
// - unnumbered ("Kata Pengantar") -> "Kata Pengantar (halaman iv)"
// - chapter -> "BAB II"
// - appendix -> "Lampiran 1"
// lower levels keep the Typst default ("Bagian 1.2").
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
