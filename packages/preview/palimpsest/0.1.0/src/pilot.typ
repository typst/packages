#import "letter.typ": default-letter-template, with-letter-numbering
#import "@preview/contexture:0.1.0" as contexture

/// Describes the response letter as a `contexture.satellite(...)` — the
/// value an author lists under `documents:` in their own
/// `#show: contexture.bundle.with(...)` (see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md). Palimpsest has no pilot of its own
/// any more: `contexture.bundle(...)` is the single point that ever
/// calls `document(...)`, for every package built on it, precisely so
/// stacking this alongside another package's own satellite (checkitoff's
/// `checklist(...)`, say) never runs into two competing pilots each
/// convinced it alone owns the manuscript/document split — the exact
/// failure `#show: revisions.with(...)` followed by `#show:
/// checkitoff.with(...)` used to hit ("constructing a document is only
/// supported in the bundle target", since the second pilot's own
/// `document(...)` ended up nested inside the first's).
///
/// Whether a letter is produced at all is derived, not a separate flag:
/// there's nothing sensible for "produce a letter" to mean independently
/// of `exchanges` — writing responses with no letter to put them in, or
/// asking for a letter with nothing written, are both non-cases.
/// `applicable` reflects exactly that (`exchanges != none`), so listing
/// `letter(exchanges: none)` under `documents:` is inert, matching
/// `render-checklist`'s own "no checklist without one given" stance.
///
/// The one thing that *is* a per-run, command-line choice — not a fixed
/// property of the project — is skipping the letter for a single
/// compile even though `exchanges` is set, e.g. for a fast
/// manuscript-only preview while drafting: `--input only=` (nothing
/// after the `=`), `contexture.bundle`'s own generic mechanism —
/// replacing this package's previous, letter-specific `--input
/// letter=false` (dropped: a good moment to generalize, since it's now
/// one package's need among several that could each want the same
/// escape hatch).
///
/// `side-content` re-registers every exchange's anchor in the manuscript
/// whenever the letter itself isn't built this compile (`--input
/// only=`, or `exchanges: none`) — without it, `passage()`'s "anchor has
/// no matching exchange" check (`marks.typ`) would find zero exchanges
/// and false-positive on every single anchor the moment the letter isn't
/// actually rendered, even though the exchanges were written. Built with
/// `contexture.collect-anchors`/`reemit` precisely because this has to
/// work on `exchanges` as an in-memory value that may never be placed
/// into any document this compile — `contexture.anchors` (query-based)
/// can't see it in that case, only a structural walk can.
#let letter(
  exchanges: none,
  template: auto,
  round: 1,
) = {
  let lt = if template == auto { default-letter-template } else { template }
  contexture.satellite(
    "response",
    applicable: () => exchanges != none,
    render: () => [#with-letter-numbering(lt(exchanges)) <palimpsest-letter>],
    side-content: if exchanges != none {
      contexture.collect-anchors(exchanges, "palimpsest-exchange").map(contexture.reemit).sum(default: [])
    },
  )
}
