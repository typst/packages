/// Which rendering variant of the manuscript's own content to produce —
/// `"plain"` (default) or any other package-defined string (e.g.
/// palimpsest's `"tracked"`), read from `--input variant=...`. An
/// *intrinsic* property of what the manuscript body itself means (do
/// revision marks show, styled, or not; is this the original or a
/// translated variant; ...) — a package with no such concept (a
/// reporting-checklist package, say) never touches this at all and
/// always sees `"plain"`.
///
/// `"plain"` is deliberately a neutral word, not any one consuming
/// package's own vocabulary (earlier than this, the sentinel was the
/// literal string `"clean"`, borrowed directly from palimpsest's own
/// clean/tracked terminology — found, on reflection, to leak a specific
/// consumer's vocabulary into what's meant to be a package-agnostic
/// axis; a package whose own variant concept has nothing to do with
/// "clean" — a translated-language variant, say — can still sensibly
/// read `variant() == "plain"` as "the original, unmodified rendering".
/// A package that wants to keep presenting its own historical wording to
/// its own users translates at its own single entry point instead of
/// propagating the neutral sentinel everywhere — see palimpsest's
/// `mode()`, which maps `"plain"` back to `"clean"` for its own public
/// API and nowhere else).
///
/// Deliberately its own axis, independent of `preview()` below — see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md §1 for the concrete bug this
/// separation fixes: two packages sharing one flat `mode` string with
/// different vocabularies (`clean`/`tracked` vs `clean`/`annotated`)
/// caused one package's preview request to silently flip the other's
/// rendering too, because both treated "anything other than clean" as
/// "my own alternate mode is on".
#let variant() = sys.inputs.at("variant", default: "plain")

/// Whether to show debug highlighting for every anchor placed in the
/// manuscript (`--input preview=true`) — a drafting aid, never present
/// in a real output file, and never a reason by itself to change what a
/// document's own content *means* (that's `variant()`'s job). Any
/// package built on `contexture` that wants a "show me where my anchors
/// are" preview reads this one shared flag, so a reader compiling with
/// `--input preview=true` gets every package's overlay at once, in one
/// consistent visual language, rather than each package inventing its
/// own incompatible flag under the same name.
///
/// Named `preview()`, not `annotate()` (its name before this file's
/// history below) — "annotate" described one specific visual treatment
/// (checkitoff's own highlight-and-superscript), not the underlying,
/// genuinely package-agnostic concept this flag actually represents:
/// "this is a debug/preview compile, not the pristine final deliverable".
#let preview() = sys.inputs.at("preview", default: "false") == "true"
