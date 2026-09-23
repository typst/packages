#import "grid.typ": render-checklist
#import "@preview/contexture:0.1.0" as contexture

/// Describes the checklist as a `contexture.satellite(...)` — the value
/// an author lists under `documents:` in their own
/// `#show: contexture.bundle.with(...)` (see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md). Checkitoff has no pilot of its own:
/// `contexture.bundle(...)` is the single point that ever calls
/// `document(...)`, for every package built on it, precisely so stacking
/// this alongside another package's own satellite (palimpsest's
/// `letter(...)`, say) never runs into two competing pilots each
/// convinced it alone owns the manuscript/document split.
///
/// `checklist:` has no default: even though CONSORT is the only grid
/// this package ships built in today, forcing an explicit choice costs
/// nothing and avoids a silent, surprising default once a second grid
/// exists. `grid-template:` (`auto` = identity) is applied to
/// `render-checklist(...)`'s output separately from the manuscript's own
/// `template:` — most journals want CONSORT's own table layout, not the
/// manuscript's own template, on the checklist page.
///
/// Never built under a non-`"plain"` `variant` or under `preview:
/// true`: `check()`'s preview-mode highlighting (`marks.typ`) can
/// shift page breaks, so a grid built from that layout could report
/// different page numbers than the manuscript actually being submitted —
/// worse than not producing one at all.
#let checklist(checklist: none, grid-template: auto) = {
  assert(checklist != none, message: "checkitoff: checklist: is required (e.g. checklist: checklists.consort)")
  contexture.satellite(
    "checklist",
    applicable: () => contexture.variant() == "plain" and not contexture.preview(),
    render: () => {
      let gt = if grid-template == auto { doc => doc } else { grid-template }
      gt(render-checklist(checklist: checklist))
    },
  )
}
