#import "mode.typ": variant, preview
#import "diagnostics.typ": set-strict

/// The pilot. Called via `#show: bundle.with(...)`, so `body` — the
/// last, unnamed positional parameter — is the rest of the document,
/// typically `#include "manuscript.typ"`. The single point in this
/// ecosystem that ever calls Typst's `document(...)` — see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md §1 for why that has to be true:
/// `document(...)` cannot be nested inside another `document(...)`, so
/// stacking two packages' own pilots (each convinced it alone owns the
/// split into documents) can never compose. Every package built on
/// `contexture` instead exposes a small constructor that returns a
/// `satellite(...)` value (`satellite.typ`) — inert data, not a
/// `document(...)` call — and lists those under `documents:` here.
///
/// `documents: ()` (the default) produces the manuscript alone.
/// `documents: (a, b, ...)` produces the manuscript plus every listed
/// satellite whose own `applicable()` returns true for this compile.
///
/// Two compiles cover the two axes independently (see `mode.typ` for why
/// they're separate at all):
/// - `typst compile --features bundle --format bundle main.typ` — the
///   real deliverable: `manuscript.pdf` plus every applicable satellite.
/// - `--input variant=tracked` and/or `--input preview=true` — preview
///   compiles; a satellite opts out of either via its own `applicable`.
///
/// `--input only=<comma-separated satellite names>` restricts *this*
/// compile to just the manuscript plus the named satellites — a
/// command-line choice, not a property of the project, for a fast
/// preview while drafting (`--input only=` with nothing after it: the
/// manuscript alone, no satellites at all, regardless of how many are
/// listed in `documents:`). Still subject to each satellite's own
/// `applicable`: naming a satellite under `only:` that declines to build
/// itself this compile doesn't force it to.
///
/// `strict` turns every diagnostic raised by any package built on
/// `contexture`, in any document, into a compile error — one shared CI
/// gate rather than one per package.
///
/// The filename suffix is computed here, once, from exactly the two
/// axes `contexture` itself knows about (`variant`/`preview`) — deliberately
/// not an open-ended, per-satellite-contributed suffix: `document(name, ...)`
/// needs `name` *before* `body` is evaluated, so any suffix contribution
/// has to be resolvable eagerly, from `sys.inputs` alone, before any
/// content renders at all — a package "announcing" a filename
/// contribution mid-render (a `state()` update, resolved only later via
/// `context`) arrives too late to matter here. Explored and rejected for
/// a fully open-ended N-axis version of this pilot; see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md for the write-up.
#let bundle(
  template: body => body,
  documents: (),
  strict: false,
  manuscript-name: "manuscript",
  body,
) = {
  if strict {
    set-strict(true)
  }

  let v = variant()
  let a = preview()
  // Both axes contribute to the filename, independently — a preview
  // compile must never write over the plain deliverable on disk, whatever
  // `variant` happens to be at the same time (found directly: an earlier
  // version only suffixed on `variant`, so `--input preview=true` alone
  // silently overwrote `manuscript.pdf` with the highlighted preview,
  // since preview=true + variant=plain produced the exact same filename
  // as the real, no-flags compile).
  let suffix = (if v != "plain" { "-" + v } else { "" }) + (if a { "-preview" } else { "" })

  let only = sys.inputs.at("only", default: none)
  let allowed = if only == none { none } else { only.split(",").filter(s => s != "") }
  let in-scope(name) = allowed == none or name in allowed

  document(manuscript-name + suffix + ".pdf", {
    template(body)
    for sat in documents {
      if not ((sat.applicable)() and in-scope(sat.name)) and sat.side-content != none {
        sat.side-content
      }
    }
  })

  for sat in documents {
    if (sat.applicable)() and in-scope(sat.name) {
      document(sat.name + suffix + ".pdf", (sat.render)())
    }
  }
}
