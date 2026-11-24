#import "checklist.typ": validate-checklist
#import "resolve.typ": resolve-item, resolve-na
#import "style.typ": effective-style
#import "@preview/contexture:0.1.0" as contexture

// Every diagnostic here always renders (`always: true`) regardless of
// `contexture.diagnose`'s default variant/preview muting: this grid is
// only ever built under variant == "plain" and preview == false (its
// own applicable() rule, see `pilot.typ`) — exactly the one combination
// contexture's default muting would otherwise silence, which would mean
// checkitoff's diagnostics never show at all in practice.
#let diagnose(message) = contexture.diagnose(message, always: true)

/// Groups a list into consecutive runs sharing the same `key(item)`,
/// preserving order — used twice below in `render-checklist`: once to
/// find where a new `section` starts, once (recursively, inside each
/// section) to find where a new `group` starts and where a run of
/// identical `topic` values starts (that last one becomes the Topic
/// column's rowspan). A generic mechanism deliberately kept independent
/// of what `key` returns, so a future checklist with zero, one, or many
/// `group`s per section reuses this unchanged — CONSORT 2025's single
/// "Randomisation" group is not special-cased anywhere below, and PRISMA
/// 2020 (zero groups at all) needs no change either — see
/// `tests/bundle-prisma-demo/`.
#let consecutive-runs(items, key) = {
  let runs = ()
  for it in items {
    let k = key(it)
    if runs.len() > 0 and runs.last().key == k {
      let last = runs.last()
      runs = runs.slice(0, -1) + ((key: k, items: last.items + (it,)),)
    } else {
      runs = runs + ((key: k, items: (it,)),)
    }
  }
  runs
}

/// Fallback column headers for a checklist that doesn't specify its own
/// `headers:` — CONSORT 2025's own wording, since it's the grid this
/// package shipped first with. A checklist with different official
/// column names (PRISMA 2020's "Section and Topic" / "Item #" /
/// "Checklist item" / "Location where item is reported", for instance)
/// sets its own `headers:` instead of inheriting these.
#let default-headers = ("Section / Topic", "No", "Description", "Reported on page no.")

/// Short marker for the warning cases — deliberately just a glyph, never
/// the full diagnostic sentence: an earlier version put the whole
/// `diagnose(...)` message directly in the Page cell, which forced that
/// `auto`-sized column to grow wide enough to fit it unwrapped, crushing
/// the Description column down to one word per line and inflating the
/// grid from ~6 pages to 15 (found by actually rendering the demo
/// checklist, not by inspection). The full sentence still exists, just
/// relocated to the Diagnostics block below the table, which has the
/// full page width to wrap in and is where every other diagnostic already
/// lives.
#let warn-marker = text(fill: red.darken(20%), weight: "bold")[⚠]

/// The Page cell for one item: the resolved pages when `check()` covered
/// it, "N/A" when `na()` declared it not applicable, `warn-marker` for the
/// two failure cases — never covered at all, or covered *and* declared
/// not applicable at once. The corresponding `diagnose(...)` call (and
/// thus the `strict:` panic) happens once, in the Diagnostics block, not
/// here — see `warn-marker`.
#let page-cell(hits, na-hits) = {
  if na-hits.len() > 0 and hits.len() > 0 {
    [#warn-marker N/A]
  } else if na-hits.len() > 0 {
    [N/A]
  } else if hits.len() > 0 {
    let pages = hits.map(h => h.location().page()).dedup()
    [#pages.map(str).join(", ")]
  } else {
    warn-marker
  }
}

/// Renders the completed checklist grid: the 4 official columns (headers
/// and relative widths taken from the checklist itself — see
/// `default-headers` and `style.typ`'s `columns`), a Diagnostics block
/// listing every issue in full (an uncovered item, a na()/check()
/// conflict, an unknown id, a blank `check()`, a duplicated `na()`), an
/// "Not applicable" block listing every `na()`'s justification, and —
/// when the checklist provides one — its citation/license notice
/// verbatim. Exported independently of `checkitoff()` (like palimpsest's
/// `change-list()`), for use outside the two-document bundle wiring if
/// ever needed.
///
/// `title: auto` uses `checklist.full-name`; `none` omits the title
/// entirely (e.g. if the surrounding template already introduces it).
#let render-checklist(checklist: none, title: auto) = context {
  assert(checklist != none, message: "checkitoff: render-checklist needs checklist: to be given")
  let checklist = validate-checklist(checklist)

  let all-items = contexture.anchors("checkitoff-item")
  let all-na = contexture.anchors("checkitoff-na")
  let known-ids = checklist.items.map(it => it.id)

  let items-by-id(id) = all-items.filter(h => h.value.id == id)
  let na-by-id(id) = all-na.filter(h => h.value.id == id)

  let sty = effective-style(checklist)
  set page(paper: sty.paper, flipped: sty.landscape)

  // `auto` means "inherit whatever the ambient template already set" —
  // `set text(font: auto)` isn't itself a valid value, so an unset knob
  // is simply left out of the call rather than passed through.
  let text-args = (:)
  if sty.font != auto { text-args.insert("font", sty.font) }
  if sty.text-size != auto { text-args.insert("size", sty.text-size) }
  set text(..text-args)

  let heading-content = if title == auto { checklist.full-name } else { title }
  if heading-content != none {
    block(below: 0.8em, text(size: 1.3em, weight: "bold")[#heading-content])
  }

  let headers = checklist.at("headers", default: default-headers)

  let table-children = ()
  for srun in consecutive-runs(checklist.items, it => it.section) {
    table-children.push(table.cell(
      colspan: 4,
      fill: sty.section-fill,
      inset: (x: 6pt, y: 5pt),
    )[#text(fill: sty.section-text-color, weight: "bold")[#srun.key]])

    for grun in consecutive-runs(srun.items, it => it.group) {
      if grun.key != none {
        table-children.push(table.cell(
          colspan: 4,
          fill: sty.group-fill,
          inset: (x: 10pt, y: 4pt),
        )[#text(fill: sty.group-text-color, style: "italic")[#grun.key]])
      }

      for trun in consecutive-runs(grun.items, it => it.topic) {
        let n = trun.items.len()
        for (i, it) in trun.items.enumerate() {
          if i == 0 {
            table-children.push(table.cell(rowspan: n)[#it.topic])
          }
          table-children.push([#it.at("id-display", default: it.id)])
          table-children.push(it.description)
          table-children.push(page-cell(items-by-id(it.id), na-by-id(it.id)))
        }
      }
    }
  }

  table(
    columns: sty.columns,
    align: (left, center, left, center),
    stroke: 0.5pt + gray,
    table.header(..headers.map(h => table.cell(
      fill: sty.header-fill,
    )[#text(fill: sty.header-text-color, weight: "bold")[#h]])),
    ..table-children
  )

  // Every diagnostic in full, gathered in one place: two per-item cases
  // that `page-cell` only marks with a glyph (never covered; covered
  // *and* declared not applicable), plus three structural cases with no
  // single table cell to live in at all (an id used by check()/na() that
  // matches no item in `checklist`, a check() call whose content is
  // blank, an id declared na() more than once). Every message is still
  // routed through `diagnose()`, so `strict:` catches all five the same
  // way.
  let diag-messages = ()
  for it in checklist.items {
    let hits = items-by-id(it.id)
    let na-hits = na-by-id(it.id)
    if na-hits.len() > 0 and hits.len() > 0 {
      let pages = hits.map(h => str(h.location().page())).join(", ")
      diag-messages.push("item " + it.id + ": marked not applicable (na) but also checked by check() (p. " + pages + ")")
    } else if na-hits.len() == 0 and hits.len() == 0 {
      diag-messages.push("item " + it.id + ": not covered (no check(), no na())")
    }
  }
  for h in all-items {
    if h.value.id not in known-ids {
      diag-messages.push("check(" + repr(h.value.id) + "): unknown id for " + checklist.name + " (manuscript p. " + str(h.location().page()) + ")")
    } else if h.value.at("blank", default: false) {
      diag-messages.push("check(" + repr(h.value.id) + "): blank content (manuscript p. " + str(h.location().page()) + ")")
    }
  }
  for h in all-na {
    if h.value.id not in known-ids {
      diag-messages.push("na(" + repr(h.value.id) + "): unknown id for " + checklist.name + " (declared p. " + str(h.location().page()) + ")")
    }
  }
  for id in known-ids {
    let n = na-by-id(id).len()
    if n > 1 {
      diag-messages.push("na(" + repr(id) + ") declared " + str(n) + " times")
    }
  }

  if diag-messages.len() > 0 {
    block(above: 1em, below: 0.5em, text(weight: "bold")[Diagnostics])
    for m in diag-messages {
      block(above: 0.3em, below: 0.3em, diagnose(m))
    }
  }

  // One entry per na()'d item, with its justification — independent of
  // the Diagnostics block above: a clean na() with a reason is not an
  // error, it's exactly the documentation this block exists to surface.
  let na-entries = checklist.items.filter(it => na-by-id(it.id).len() > 0)
  if na-entries.len() > 0 {
    block(above: 1em, below: 0.5em, text(weight: "bold")[Not applicable])
    for it in na-entries {
      let reason = na-by-id(it.id).first().value.reason
      block(above: 0.2em, below: 0.2em, [*#it.id* --- #if reason != none { reason } else { [_(no justification given)_] }])
    }
  }

  // The checklist's own citation/license notice, verbatim, when it
  // provides one — CONSORT 2025 and PRISMA 2020 both require the
  // original work to be credited wherever their checklist is reproduced,
  // so this isn't optional decoration: a checklist without a `citation:`
  // field simply renders nothing here.
  let citation = checklist.at("citation", default: none)
  if citation != none {
    block(above: 1.2em, text(size: 0.85em, style: "italic")[#citation])
  }
}
