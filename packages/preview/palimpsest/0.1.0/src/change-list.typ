#import "marks.typ": mode
#import "utils.typ": parse-anchor

/// English label for each mark kind (§6decies: package-generated text is
/// fixed English, not configurable). A passage mixing several kinds (e.g.
/// a manually composed `#del[...] #add[...]` rather than `rep`) shows
/// every kind it contains, in the order they first appear, joined with
/// "/" — there's no single "correct" label for a passage that both
/// removes and adds text without being a `rep`.
#let type-labels = (
  add: "addition",
  del: "deletion",
  rep: "replacement",
  suppress: "suppression",
)

/// "R1-2, R2-1", or "—" for a passage with no anchor (an anonymous
/// typographical fix) — same convention `passage` itself uses for
/// `show-anchor` (`marks.typ`).
#let format-anchor-list(anchors) = {
  if anchors.len() == 0 { [—] } else { anchors.map(a => upper(str(a))).join(", ") }
}

/// Sort key grouping rows the way a reviewer's own numbered list of
/// comments reads: reviewers in order, each reviewer's comments in
/// order, then co-authors (alphabetical by id, then by change number —
/// authors have no natural numeric ordering the way reviewers do, so
/// alphabetical is the simplest stable default for a summary table),
/// then editor comments, anchor-less passages last (mirrors the spec's
/// own example table, §10.3) — this is what makes the table useful as a
/// checklist against the letter, not just a readout of document order.
/// A passage's first anchor decides its key, same convention as
/// `anchors-color` (`style.typ`). Bucket numbers only ever get compared
/// against same-bucket numbers in practice (`.sorted()` short-circuits
/// on the first differing tuple element), so mixing a string (author id)
/// into the second slot alongside integers (reviewer/editor number) for
/// other kinds is safe — verified directly.
#let anchor-sort-key(anchors) = {
  let p = if anchors.len() > 0 { parse-anchor(anchors.first()) } else { none }
  if p == none {
    (3, 0, 0)
  } else if p.kind == "editor" {
    (2, 0, p.num)
  } else if p.kind == "author" {
    (1, p.author, if p.num == none { 0 } else { p.num })
  } else {
    (0, p.reviewer, p.num)
  }
}

/// Generates the "list of changes" table (§10.3): one row per `passage`
/// (and its shortcuts `added`/`deleted`/`replaced`/`suppressed`) that
/// carries at least one mark — an anchor that recurs across several
/// passages gets one row per occurrence, each with its own page and
/// section, exactly as the spec's own example shows (R1-2 listed twice).
/// `touched` passages (no marks, `allow-empty: true`) never appear:
/// nothing changed there to list.
///
/// Self-gates on the compile mode like `del`/`suppress` do: renders
/// nothing in clean mode, so an author who places `#change-list()` once
/// in shared manuscript content (typical: near the top, "usually placed
/// at the head of the tracked version", §10.3) never has to remember to
/// remove it before the clean compile ships to the journal.
///
/// `title` is the heading shown above the table (`none` to omit it,
/// e.g. if the surrounding template already introduces the table).
/// `level` picks which heading level counts as a row's "Section" —
/// the nearest preceding heading at that level, defaulting to top-level
/// sections (matches the spec example: "Introduction", "Methods",
/// "Results", not their subsections). A row before any heading at that
/// level shows "—".
#let change-list(title: [Summary of changes], level: 1) = context {
  if mode() == "clean" {
    none
  } else {
    let hits = query(<palimpsest-passage>).filter(el => el.value.marks.len() > 0)
    let rows = hits.map(h => {
      let v = h.value
      let kinds = v.marks.map(m => m.kind).dedup()
      let heads = query(heading.where(level: level).before(h.location()))
      (
        sort-key: anchor-sort-key(v.anchors),
        comment: format-anchor-list(v.anchors),
        type: kinds.map(k => type-labels.at(k, default: k)).join("/"),
        page: str(h.location().page()),
        section: if heads.len() > 0 { heads.last().body } else { [—] },
      )
    }).sorted(key: r => r.sort-key)

    if rows.len() == 0 {
      none
    } else {
      if title != none {
        block(text(weight: "bold")[#title])
      }
      table(
        columns: (auto, auto, auto, 1fr),
        align: (center, left, center, left),
        table.header([*Comment*], [*Type*], [*Page*], [*Section*]),
        ..rows.map(r => (r.comment, r.type, r.page, r.section)).flatten()
      )
    }
  }
}
