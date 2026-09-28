/// Describes one document to build alongside the manuscript — the unit
/// `bundle()` (`pilot.typ`) consumes. A package exposes a small
/// constructor function that returns one of these (e.g. palimpsest's
/// `letter(exchanges: ...)`, checkitoff's `checklist(checklist: ...)`);
/// the author lists those calls under `documents:` in their own
/// `#show: contexture.bundle.with(...)`. `contexture` itself never knows
/// or cares whether a given satellite is "authored" (the caller supplies
/// prose, like a response letter) or "generated" (fully computed from
/// anchors/manuscript content, like a reporting-guideline checklist) —
/// both are, from here, just a name plus a function that produces
/// content.
///
/// `name` — base filename, before the variant suffix `bundle()` adds
/// (`"response"` → `response.pdf` / `response-tracked.pdf`).
///
/// `render() -> content` — called once per compile, only when
/// `applicable` says yes, to produce this document's content. Takes no
/// arguments: `variant()`/`preview()` are plain, freely-callable global
/// functions, so a `render` that cares about either calls them itself
/// rather than receiving them threaded through as parameters (found, on
/// reflection, to be pure redundancy every real caller either ignored or
/// could call directly just as easily — see MULTI-DOCUMENT-BUNDLE-DESIGN.md).
///
/// `applicable() -> bool` — whether this satellite should be built at
/// all for the current compile. Defaults to always. Checkitoff's checklist
/// uses this to never build under a non-`"plain"` variant or under
/// `preview: true` (its own page numbers would then reflect a manuscript
/// layout that isn't the real, submitted one) — by calling
/// `contexture.variant()`/`contexture.preview()` itself, inside its own
/// closure.
///
/// `side-content` — content this satellite wants placed in the
/// manuscript *regardless* of whether it itself gets built this compile
/// (`none` by default, i.e. nothing). Exists for exactly one confirmed
/// need so far: palimpsest's letter, when skipped for a fast
/// manuscript-only compile (`--input only=manuscript`), still needs its
/// exchange metadata registered in the manuscript's own document so
/// `passage()`'s "anchor has no matching exchange" check doesn't
/// false-positive on every anchor. Kept generic rather than special-cased
/// to palimpsest, since any future authored satellite that gates
/// something in the manuscript on its own presence would need the same
/// escape hatch.
#let satellite(
  name,
  render: () => none,
  applicable: () => true,
  side-content: none,
) = (name: name, render: render, applicable: applicable, side-content: side-content)
