#import "state.typ": front-override, page-label, section, sections
#import "rules/text.typ": para-rules
#import "pages/outlines.typ": figure-entry-rules, outlines

// front matter can be written anywhere.
// it renders before the table of contents, in writing order.
#let frontmatter(
  // styled like a chapter title, centered and unnumbered.
  title: none,
  outlined: true,
  // page number style for these pages, e.g. "I".
  // auto uses `numbering.front`.
  numbering: auto,
  // start the page numbers at this number.
  start-page: auto,
  body,
) = [#metadata((
  kind: sections.front,
  numbering: numbering,
  body: {
    if start-page != auto {
      counter(page).update(start-page)
    }
    if title != none {
      heading(level: 1, numbering: none, outlined: outlined, title)
    }
    set figure(outlined: false)
    body
  },
)) <jilid-matter>]

// appendices render after the bibliography, wherever you write them.
// level-1 headings inside become "Lampiran 1.", "Lampiran 2.", ...
#let appendices(body) = [#metadata((
  kind: sections.back,
  body: body,
)) <jilid-matter>]

#let blocks-of(kind) = query(<jilid-matter>).filter(m => m.value.kind == kind)

// check for a numbered level-1 heading in an `appendices` body.
#let is-appendix-heading(c) = (
  c.func() == heading
    and c.at("level", default: auto) in (auto, 1)
    and c.at("depth", default: 1) == 1
    and c.at("numbering", default: auto) != none
)

// number figures, tables and equations as "L1.2".
// count the appendix headings to get the appendix number.
#let render-appendices(cfg, blocks) = {
  let count = 0
  for m in blocks {
    let body = m.value.body
    let children = if body.has("children") { body.children } else {
      (body,)
    }
    // split the body at appendix headings.
    // group 0 holds the content before the first one.
    let groups = ((n: count, items: ()),)
    for c in children {
      if is-appendix-heading(c) {
        count += 1
        groups.push((n: count, items: ()))
      }
      groups.at(-1).items.push(c)
    }
    for g in groups.filter(g => g.items.len() > 0) {
      let prefix = if (
        g.n > 0
      ) [#cfg.t.appendix-short#numbering(cfg.numbering.appendix, g.n).]
      set figure(outlined: false, numbering: x => [#prefix#x])
      set math.equation(numbering: x => [(#prefix#x)])
      para-rules(cfg, g.items.join())
    }
    pagebreak(weak: true)
  }
}

// everything after the cover
// front matter > outlines > `body` > appendices.
#let flow(cfg, body) = {
  section.update(sections.front)
  counter(page).update(1)

  show: figure-entry-rules.with(cfg)

  [#metadata(none) <jilid-section-front>]
  context {
    for m in blocks-of(sections.front) {
      front-override.update(m.value.numbering)
      para-rules(cfg, m.value.body)
      pagebreak(weak: true)
    }
  }
  // a frontmatter numbering applies to its own pages only.
  front-override.update(auto)

  outlines(cfg)

  [#metadata(none) <jilid-marker-front-end>]
  pagebreak(weak: true)
  section.update(sections.main)
  counter(page).update(1)
  [#metadata(none) <jilid-section-body>]
  body

  context {
    let back = blocks-of(sections.back)
    if back.len() > 0 {
      pagebreak(weak: true)

      if cfg.numbering.back == "front" {
        let end-marker = query(<jilid-marker-front-end>).first()
        let val = counter(page).at(end-marker.location()).first()
        counter(page).update(val + 1)
      }

      section.update(sections.back)
      [#metadata(none) <jilid-section-back>]
      heading(level: 1, numbering: none, outlined: true)[#cfg.t.appendices]
      [#metadata(none) <jilid-appendices-start>]
      counter(heading).update(0)

      render-appendices(cfg, back)
    }
  }

  // save the start page of each part.
  // read it with `typst eval 'query(<jilid-pages>)' --in doc.typ`.
  context {
    let start(lbl) = {
      let q = query(lbl)
      if q.len() > 0 {
        let loc = q.first().location()
        (idx: counter(page).at(loc).first(), display: page-label(cfg, loc))
      }
    }
    [#metadata((
      front: start(<jilid-section-front>),
      body: start(<jilid-section-body>),
      back: start(<jilid-section-back>),
    )) <jilid-pages>]
  }
}
