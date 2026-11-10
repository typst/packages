#import "../state.typ": page-label, section, sections
#import "../utils.typ": h1-number, h1-title, styled
#import "../rules/figures.typ": figure-number

// The label that marks where the appendix headings start.
// `matter.flow` puts it after the appendices title.
#let appendices-start = <jilid-appendices-start>

// A list row: `prefix` and `title`, the leader and the page number, linked to `loc`.
// With a `width`, the prefix goes in a column of that width.
// Without a `width`, `sep` joins the prefix and the title.
#let dotted-row(cfg, loc, prefix, title, width: none, sep: [ ]) = {
  let leader = if cfg.outlines.leader == none { h(1fr) } else {
    box(width: 1fr, inset: (x: 2pt), repeat(cfg.outlines.leader))
  }
  let page = context page-label(cfg, loc)
  link(loc, if prefix == none or width == none {
    grid(
      columns: (1fr, auto),
      column-gutter: 0.5em,
      align: (left, bottom),
      [#if prefix != none [#prefix#sep]#title #leader], page,
    )
  } else {
    grid(
      columns: (width, 1fr, auto),
      column-gutter: 0.5em,
      align: (left, left, bottom),
      prefix, [#title #leader], page,
    )
  })
}

// The number before a title in the lists, such as "BAB II" or "Lampiran 1.".
// Appendices get it if `numbering.appendix-prefix` is true.
#let entry-prefix(cfg, sec, n) = {
  let number = h1-number(cfg, sec, n)
  if sec == sections.main { number } else if (
    sec == sections.back and cfg.numbering.appendix-prefix
  ) [#number.]
}

#let heading-prefix(cfg, h) = if h.numbering != none {
  let loc = h.location()
  entry-prefix(cfg, section.at(loc), counter(heading).at(loc).first())
}

// The figure number in the lists, such as "Gambar 2.1".
#let figure-prefix(f) = {
  let loc = f.location()
  let n = counter(figure.where(kind: f.kind)).at(loc).first()
  [#f.supplement #figure-number(loc, n)]
}

#let widest(items) = calc.max(
  0pt,
  ..items.filter(x => x != none).map(x => measure(x).width),
)

// The width of the number column in the list `name`.
// `name` is "toc", "back" or a figure kind.
// DAFTAR ISI gets a column unless `toc-indent` is auto.
// With "shared", the figure, table, code and appendix lists share one width.
// none puts the number right before the title.
#let number-width(cfg, name) = {
  let mode = if name != "toc" { cfg.outlines.align-titles } else if (
    cfg.outlines.toc-indent != auto
  ) { "each" }
  if mode == none { return none }
  let numbered = query(heading.where(level: 1)).filter(h => (
    h.numbering != none and h.outlined
  ))
  let in-back(h) = section.at(h.location()) == sections.back
  let rows(name) = if name == "toc" {
    numbered
      .filter(h => cfg.outlines.toc-appendices or not in-back(h))
      .map(h => styled(cfg.outlines.h1, heading-prefix(cfg, h)))
  } else if name == "back" {
    numbered.filter(in-back).map(h => heading-prefix(cfg, h))
  } else {
    query(figure.where(kind: name))
      .filter(f => f.caption != none and f.at("outlined", default: true))
      .map(figure-prefix)
  }
  let names = if mode == "shared" { ("back", image, table, raw) } else {
    (name,)
  }
  widest(names.map(rows).flatten())
}

// Figure rows in every outline, also outlines that the user places:
// "Gambar 2.1  Caption .... 12".
#let figure-entry-rules(cfg, body) = {
  show outline.entry: it => {
    if (
      it.element != none
        and it.element.func() == figure
        and it.element.caption != none
    ) {
      context dotted-row(
        cfg,
        it.element.location(),
        figure-prefix(it.element),
        it.element.caption.body,
        width: number-width(cfg, it.element.kind),
        sep: [ #h(0.5em) ],
      )
    } else {
      it
    }
  }

  body
}

// DAFTAR ISI.
// If `outlines.toc-appendices` is false, it lists only the LAMPIRAN title.
// DAFTAR LAMPIRAN then lists the appendices.
#let table-of-contents(cfg) = {
  // The headings that DAFTAR ISI lists.
  let target() = {
    let has-appendices = query(appendices-start).len() > 0
    if has-appendices and not cfg.outlines.toc-appendices {
      selector(heading).before(appendices-start)
    } else { heading }
  }
  // The widest number at each heading level in DAFTAR ISI, such as "BAB VIII" and "1.10.".
  let level-widths() = {
    let hs = query(target()).filter(h => (
      h.outlined and h.numbering != none and h.level <= cfg.outlines.depth
    ))
    range(1, cfg.outlines.depth + 1).map(level => widest(
      hs
        .filter(h => h.level == level)
        .map(h => if level == 1 {
          styled(cfg.outlines.h1, heading-prefix(cfg, h))
        } else {
          numbering(h.numbering, ..counter(heading).at(h.location()))
        }),
    ))
  }

  // Use the same leader in rows below chapter level.
  set outline.entry(fill: if cfg.outlines.leader != none {
    repeat(gap: 0.15em, cfg.outlines.leader)
  })
  show outline.entry.where(level: 1): it => {
    let loc = it.element.location()
    v(0.5em, weak: true)
    context {
      let appendix = (
        it.element.numbering != none and section.at(loc) == sections.back
      )
      let title = h1-title(cfg, it.element.body, appendix: appendix)
      styled(cfg.outlines.h1, dotted-row(
        cfg,
        loc,
        heading-prefix(cfg, it.element),
        title,
        width: number-width(cfg, "toc"),
      ))
    }
  }
  // Without `toc-indent: auto`, jilid draws the rows below chapter level.
  // "title" starts each row under the title of the level above.
  // A length moves each level by that length.
  show outline.entry: it => {
    let indent = cfg.outlines.toc-indent
    if it.level < 2 or indent == auto { return it }
    v(0.5em, weak: true)
    context {
      let widths = level-widths()
      let x = if indent == "title" {
        widths
          .slice(0, it.level - 1)
          .map(w => if w > 0pt { w + 0.5em } else { 0pt })
          .sum()
      } else { (it.level - 1) * indent }
      pad(left: x, dotted-row(
        cfg,
        it.element.location(),
        it.prefix(),
        it.element.body,
        width: widths.at(it.level - 1),
      ))
    }
  }

  if cfg.outlines.toc {
    heading(level: 1, numbering: none)[#cfg.t.toc]
    context outline(
      title: none,
      depth: cfg.outlines.depth,
      target: target(),
    )
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
  show outline.entry: it => context dotted-row(
    cfg,
    it.element.location(),
    heading-prefix(cfg, it.element),
    h1-title(cfg, it.element.body, appendix: it.element.numbering != none),
    width: number-width(cfg, "back"),
  )
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
