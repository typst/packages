#import "mode.typ": variant, preview

// Typst has no public API to emit a soft compiler warning from user code
// (github.com/typst/typst issues #1322, #600), so the closest available
// approximation is a visible marker rendered directly at the fault
// location, which most Typst editors preview live. `strict: true`
// (`set-strict`) upgrades every diagnostic to a real compile error via
// `panic` — the CI gate every package built on `contexture` shares.

#let strict-state = state("contexture-strict", false)

#let set-strict(v) = strict-state.update(v)

/// Reports a diagnostic at the call site: a hard error under strict mode
/// (any variant, any preview setting), otherwise a visible inline
/// marker — muted by default in the plain compile (`variant() ==
/// "plain"`) with no preview overlay, since that's the file most likely
/// to leave this codebase and reach someone who never asked to see it.
///
/// `always: false` (the default) mutes the marker specifically when
/// `variant() == "plain"` *and* `preview()` is off — i.e. the actual,
/// unadorned deliverable. `always: true` is for a diagnostic embedded in
/// a document that is *never* the deliverable sent externally (a
/// generated report, an internal checklist) — always shown, since
/// muting there would mean the diagnostic is never seen in practice.
#let diagnose(message, always: false) = context {
  if strict-state.get() {
    panic(message)
  } else if always or variant() != "plain" or preview() {
    box(
      fill: yellow.lighten(60%),
      stroke: 0.5pt + red.darken(20%),
      inset: (x: 4pt, y: 2pt),
      radius: 2pt,
    )[
      #text(fill: red.darken(20%), weight: "bold", size: 0.85em)[⚠ #message]
    ]
  }
}
