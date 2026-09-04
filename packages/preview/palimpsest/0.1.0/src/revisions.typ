#import "letter.typ": default-letter-template, with-letter-numbering
#import "diagnostics.typ": set-strict
#import "utils.typ": collect-metadata

// The label literal here must match `letter-root` in `letter.typ` —
// Typst labels can't be attached to content from a variable (no
// `.labelled()` method), only via the `<name>` markup syntax, so the
// name has to be duplicated by hand instead of shared as a value.

/// The pilot. Called via `#show: revisions.with(...)`, so `body` — the
/// last, unnamed positional parameter — is the rest of the document,
/// i.e. `#include "manuscript.typ"`.
///
/// Two compiles produce the whole bundle (§9.1 — duplicating the
/// manuscript to get both looks in one compile would duplicate every
/// label in it too):
///
/// - `typst compile --features bundle --format bundle main.typ` (`mode`
///   defaults to `"clean"`) → `manuscript.pdf`, plus `response.pdf` if
///   `exchanges` is set (see below).
/// - `typst compile --features bundle --format bundle --input
///   mode=tracked main.typ` → `manuscript-tracked.pdf`, plus
///   `response-tracked.pdf` under the same condition.
///
/// Both flags are required — `--features bundle` alone still errors
/// ("constructing a document is only supported in the bundle target"),
/// verified directly.
///
/// `template` is applied to the manuscript body in *both* compiles, so
/// clean and tracked stay laid out the same way. `exchanges` is the
/// already-evaluated content of the responses file (`include
/// "responses.typ"`); `letter-template` overrides the letter's own
/// minimal default (`auto`). `round` is accepted and stored for forward
/// compatibility with v0.2's multi-round `since:` (§12); v0.1 does
/// nothing else with it. `strict` turns every diagnostic in the bundle
/// into a compile error (§11) — the CI gate.
///
/// Whether a response document is produced in this compile isn't a
/// parameter of this function at all — there would be nothing sensible
/// for it to mean independently of `exchanges`: writing responses with
/// no letter to put them in, or asking for a letter with nothing
/// written, are both non-cases. So it's derived: a letter is produced
/// whenever `exchanges` isn't `none`, matching *this* compile's own
/// `mode` — `response.pdf` from the clean compile, `response-tracked.pdf`
/// (a name distinct from `response.pdf`, so neither compile can
/// silently overwrite the other's output) from the tracked one, each
/// citing and quoting its own manuscript. No extra flag needed to get
/// a tracked letter: writing `exchanges` and running both compiles is
/// enough.
///
/// The one thing that *is* a per-run, command-line choice — not a fixed
/// property of the project — is skipping the letter for a single
/// compile even though `exchanges` is set, e.g. for a fast
/// manuscript-only preview while drafting: `--input letter=false`.
/// `--input letter=true` is the symmetric, rarely-needed override
/// (force a letter even with `exchanges: none`).
#let revisions(
  template: body => body,
  exchanges: none,
  round: 1,
  letter-template: auto,
  strict: false,
  body,
) = {
  if strict {
    set-strict(true)
  }

  let mode = sys.inputs.at("mode", default: "clean")
  let letter-input = sys.inputs.at("letter", default: none)
  let show-letter = if letter-input == "false" { false }
    else if letter-input == "true" { true }
    else { exchanges != none }

  document(if mode == "tracked" { "manuscript-tracked.pdf" } else { "manuscript.pdf" }, {
    template(body)
    if not show-letter {
      // Whenever this compile doesn't place `exchanges` into a real
      // `#document(...)`, `passage`'s "anchor has no matching exchange"
      // check would find no exchanges anywhere and false-positive on
      // every single anchor. Re-registering just the metadata (not the
      // rendered exchange blocks) makes the check work without putting
      // reviewer comments in the manuscript file.
      for m in collect-metadata(exchanges, "palimpsest-exchange") {
        [#metadata(m) <palimpsest-exchange>]
      }
    }
  })

  if show-letter {
    let lt = if letter-template == auto { default-letter-template } else { letter-template }
    let name = if mode == "tracked" { "response-tracked.pdf" } else { "response.pdf" }
    document(name, [#with-letter-numbering(lt(exchanges)) <palimpsest-letter>])
  }
}
