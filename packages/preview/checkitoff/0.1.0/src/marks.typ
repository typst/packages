#import "@preview/contexture:0.1.0" as contexture
#import "style.typ": preview-style

/// Anchors item `id` of the checklist active for this compile (which
/// checklist that is doesn't matter here at all — see `resolve.typ` for
/// why), in one of two forms depending on arity — mirrors palimpsest's
/// own `passage(anchors, body)` / `passage(body)` dispatch, same
/// reasoning: two closely related shapes of the same call, not two
/// different concepts.
///
/// `check(id, body)` — the common case: `body` is both the manuscript's
/// answer to item `id` *and* what gets displayed here. Never modifies
/// `body` in the plain compile: zero visual footprint, safe inside any
/// journal template's flow. Under `contexture.preview()`, wraps `body`
/// in a light highlight with the item id superscripted — a drafting aid
/// only, never present in `manuscript.pdf`.
///
/// `check(id)` — a bare point marker, no body at all: registers item
/// `id`'s location without rendering anything, ever, in the plain
/// compile. Exists for exactly the case the two-argument form can't
/// cover cleanly: a passage that's already rendered by something else
/// (a revision-tracking package's own marking call, most often, when a
/// reviewer's requested change happens to *be* the answer to a checklist
/// item). Calling the two-argument form there too would print the same
/// text twice, since it always renders `body` — see CLAUDE.md, "check():
/// a point-marker form", for the story. Under `--input preview=true`,
/// still shows a small superscripted id at that point (no highlight box,
/// since there's no span to highlight) — some drafting visibility, even
/// with no render step to wrap.
///
/// Records whether `body` is blank (`contexture.is-blank`) in the
/// metadata itself rather than diagnosing it here — an accidentally
/// empty `check(id)[]` call is exactly the kind of mistake `grid.typ`'s
/// diagnostics block exists to catch, and no diagnostic ever renders
/// from inside the manuscript (see `contexture.diagnose`'s `always:`
/// convention). The bare `check(id)` form is never flagged this way: a
/// missing body there is the deliberate point-marker shape, not a
/// mistake.
#let check(..args) = {
  let pos = args.pos()
  let id = pos.at(0)
  let body = if pos.len() >= 2 { pos.at(1) } else { none }
  contexture.anchor("checkitoff-item", (
    id: id,
    raw-body: body,
    blank: if body == none { false } else { contexture.is-blank(body) },
  ))
  if not contexture.preview() {
    body
  } else {
    context {
      let sty = preview-style()
      let id-tag = super(text(fill: sty.preview-color, size: 0.75em)[\[#id\]])
      if body == none {
        if sty.show-id { id-tag }
      } else if sty.show-id {
        box(fill: sty.preview-color.lighten(85%), inset: (x: 2pt), outset: (y: 2pt), radius: 1pt)[#body #id-tag]
      } else {
        box(fill: sty.preview-color.lighten(85%), inset: (x: 2pt), outset: (y: 2pt), radius: 1pt)[#body]
      }
    }
  }
}

/// Declares item `id` not applicable to this manuscript, with an optional
/// justification — a standalone declaration (typically grouped in a
/// dedicated block in `main.typ`, see CLAUDE.md), not anchored to any
/// location in the text. Renders nothing wherever it's called.
#let na(id, reason: none) = {
  contexture.anchor("checkitoff-na", (id: id, reason: reason))
  none
}
