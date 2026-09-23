#import "@preview/contexture:0.1.0" as contexture
#import "instrument.typ": captured-body
#import "words.typ": word-counts-by-section
#import "inventory.typ": figure-inventory
#import "labels.typ": orphan-labels
#import "citations.typ": uncited-references
#import "abstract.typ": abstract-word-count

/// Renders the audit report for whatever manuscript body `instrument()`
/// captured. `level:` picks which heading depth starts a new row in the
/// per-section table (see `words.word-counts-by-section`).
/// `count-captions:` folds a figure's caption text into every count --
/// a table's own cells are never counted, regardless of this flag (see
/// `words.extract-text`). `bib:`, a root-relative path (see
/// `citations.uncited-references`), additionally lists every entry
/// that path defines but the manuscript never cites; omitted (`none`,
/// the default) skips that section entirely, since not every
/// manuscript has one file to point at.
///
/// Bibliography *text* is still never counted toward the word totals
/// above, and there is no option to opt it in, unlike captions -- not
/// an oversight: a reference list's rendered entries (author, title,
/// journal...) are synthesized by Typst's citation engine during
/// layout, not present anywhere in the pre-layout body `words.typ`
/// walks (verified directly: `bibliography(...)`'s own content node
/// exposes a `sources` field holding the raw `.bib` path, not rendered
/// text) -- an entirely different mechanism from `bib:` above, which
/// reads the `.bib` file's own fields directly rather than anything
/// Typst laid out.
#let render-report(title: auto, level: 1, count-captions: false, wpm: 220, bib: none) = context {
  let body = captured-body.get()
  if body == none {
    panic("colophon: no manuscript body captured -- wrap contexture.bundle's template: in colophon.instrument(...)")
  }

  let starts = query(<colophon-manuscript-start>)
  let ends = query(<colophon-manuscript-end>)
  if starts.len() == 0 or ends.len() == 0 {
    panic("colophon: manuscript start/end markers not found -- wrap contexture.bundle's template: in colophon.instrument(...)")
  }
  let start-loc = starts.first().location()
  let end-loc = ends.first().location()
  let pages = end-loc.page()

  let sections = word-counts-by-section(body, level: level, count-captions: count-captions)
  let total = sections.map(s => s.words).sum(default: 0)
  let minutes = calc.max(1, calc.round(total / wpm))
  let abstract-words = abstract-word-count(start-loc, end-loc, count-captions: count-captions)

  if title != none {
    heading(numbering: none, if title == auto { [Manuscript audit] } else { title })
  }

  let stats = (
    ([Total word count], [#total]),
    ([Estimated reading time], [#minutes min (at #wpm wpm)]),
    ([Page count], [#pages]),
  )
  // Deliberately its own, separate stat -- never folded into "Total
  // word count" above -- see `colophon.abstract(...)`: an abstract is
  // routinely capped by its own, independent limit, distinct from the
  // manuscript's own body limit.
  let stats = if abstract-words != none {
    stats + (([Abstract word count], [#abstract-words]),)
  } else {
    stats
  }
  table(
    columns: (1fr, auto),
    stroke: 0.5pt + gray,
    table.header[*Statistic*][*Value*],
    ..stats.flatten(),
  )

  if sections.len() > 0 {
    v(1em)
    heading(level: 2, numbering: none)[Word count by section]
    table(
      columns: (1fr, auto),
      stroke: 0.5pt + gray,
      table.header[*Section*][*Words*],
      ..sections.map(s => ([#s.section], [#s.words])).flatten(),
    )
  }

  let figures = figure-inventory(start-loc, end-loc)
  if figures.len() > 0 {
    v(1em)
    heading(level: 2, numbering: none)[Figures and tables]
    table(
      columns: (auto, 1fr, auto),
      stroke: 0.5pt + gray,
      table.header[*Item*][*Caption*][*Page*],
      ..figures.map(f => (
        f.item,
        if f.caption == none { [--] } else { [#f.caption] },
        [#f.page],
      )).flatten(),
    )
  }

  let orphans = orphan-labels(start-loc, end-loc)
  if orphans.len() > 0 {
    v(1em)
    heading(level: 2, numbering: none)[Labels never referenced]
    table(
      columns: (auto, 1fr, auto),
      stroke: 0.5pt + gray,
      table.header[*Kind*][*Label*][*Page*],
      ..orphans.map(o => ([#o.kind], raw(str(o.label)), [#o.page])).flatten(),
    )
  }

  if bib != none {
    let uncited = uncited-references(bib, start-loc, end-loc)
    if uncited.len() > 0 {
      v(1em)
      heading(level: 2, numbering: none)[Bibliography entries never cited]
      list(..uncited.map(k => raw(k)))
    }
  }
}

/// Describes the audit document -- list this under `documents:` in
/// `#show: contexture.bundle.with(...)`, alongside `instrument()`
/// wrapping that same call's `template:`. Built only from the one,
/// real, plain compile -- a `preview`/non-`"plain"`-`variant` overlay
/// from another contexture-based package sharing the same bundle can
/// shift page breaks, so a report built from either could cite a page
/// count that doesn't match the manuscript actually being submitted
/// (the same reasoning `checkitoff.checklist()`'s own `applicable` already
/// documents).
#let report(name: "audit", title: auto, level: 1, count-captions: false, wpm: 220, bib: none) = {
  contexture.satellite(
    name,
    applicable: () => contexture.variant() == "plain" and not contexture.preview(),
    render: () => render-report(title: title, level: level, count-captions: count-captions, wpm: wpm, bib: bib),
  )
}
