#import "../state.typ": page-label, section, sections
#import "../utils.typ": h1-number, h1-title, styled
#import "../rules/figures.typ": figure-number

// `body`, the leader and the page number, linked to `loc`.
#let dotted-row(cfg, loc, body) = link(loc, grid(
  columns: (1fr, auto),
  column-gutter: 0.5em,
  align: (left, bottom),
  [#body #if cfg.outlines.leader == none { h(1fr) } else {
      box(width: 1fr, inset: (x: 2pt), repeat(cfg.outlines.leader))
    }],
  [#context page-label(cfg, loc)],
))


// "BAB II " or "Lampiran 1. " before a title in the lists.
// appendices get it when `numbering.appendix-prefix` is true.
#let entry-prefix(cfg, sec, n) = {
  let number = h1-number(cfg, sec, n)
  if sec == sections.main [#number ] else if (
    sec == sections.back and cfg.numbering.appendix-prefix
  ) [#number. ]
}

// figure rows in every outline, user-placed ones too:
// "Gambar 2.1  Caption .... 12".
#let figure-entry-rules(cfg, body) = {
  show outline.entry: it => {
    if (
      it.element != none
        and it.element.func() == figure
        and it.element.caption != none
    ) {
      let loc = it.element.location()
      context {
        let n = counter(figure.where(kind: it.element.kind)).at(loc).first()
        dotted-row(
          cfg,
          loc,
          [#it.element.supplement #figure-number(loc, n) #h(
              0.5em,
            ) #it.element.caption.body],
        )
      }
    } else {
      it
    }
  }

  body
}

// mark where the appendix headings start.
// `matter.flow` puts it after the LAMPIRAN-LAMPIRAN title.
#let appendices-start = <jilid-appendices-start>

// DAFTAR ISI.
// with `outlines.toc-appendices: false` it lists only the LAMPIRAN title,
// and DAFTAR LAMPIRAN lists the appendices.
#let table-of-contents(cfg) = {
  // use the same leader in rows below chapter level.
  set outline.entry(fill: if cfg.outlines.leader != none {
    repeat(gap: 0.15em, cfg.outlines.leader)
  })
  show outline.entry.where(level: 1): it => {
    let loc = it.element.location()
    let numbered = it.element.numbering != none
    v(0.5em, weak: true)
    context {
      let sec = section.at(loc)
      let val = counter(heading).at(loc).first()
      let appendix = numbered and sec == sections.back
      let number = if numbered { entry-prefix(cfg, sec, val) }
      let title = h1-title(cfg, it.element.body, appendix: appendix)
      styled(cfg.outlines.h1, dotted-row(cfg, loc, [#number#title]))
    }
  }

  if cfg.outlines.toc {
    heading(level: 1, numbering: none)[#cfg.t.toc]
    context {
      let has-appendices = query(appendices-start).len() > 0
      outline(
        title: none,
        indent: auto,
        depth: cfg.outlines.depth,
        target: if has-appendices and not cfg.outlines.toc-appendices {
          selector(heading).before(appendices-start)
        } else { heading },
      )
    }
  }
}

// DAFTAR TABEL, GAMBAR and KODE.
#let figure-list(enabled, kind, title) = context {
  if enabled and query(figure.where(kind: kind)).len() > 0 {
    pagebreak(weak: true)
    heading(level: 1, numbering: none)[#title]
    outline(
      title: none,
      target: figure.where(kind: kind),
    )
  }
}

// DAFTAR LAMPIRAN.
#let appendix-list(cfg) = context {
  if not cfg.outlines.appendices or query(appendices-start).len() == 0 {
    return
  }
  let target = heading.where(level: 1).after(appendices-start)
  if query(target).len() == 0 { return }

  pagebreak(weak: true)
  heading(level: 1, numbering: none)[#cfg.t.appendix-list]
  show outline.entry: it => {
    let loc = it.element.location()
    let appendix = it.element.numbering != none
    let number = if appendix {
      entry-prefix(cfg, sections.back, counter(heading).at(loc).first())
    }
    dotted-row(cfg, loc, [#number#h1-title(
        cfg,
        it.element.body,
        appendix: appendix,
      )])
  }
  outline(title: none, target: target)
}

#let outlines(cfg) = {
  set par(leading: 0.65em)
  table-of-contents(cfg)
  figure-list(cfg.outlines.tables, table, cfg.t.lot)
  figure-list(cfg.outlines.figures, image, cfg.t.lof)
  figure-list(cfg.outlines.codes, raw, cfg.t.loc)
  appendix-list(cfg)
}
