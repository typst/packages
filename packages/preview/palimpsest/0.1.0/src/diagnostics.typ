// Typst has no public API to emit a soft compiler warning from user code
// (github.com/typst/typst issues #1322, #600 — still open as of Typst
// 0.15). The spec (§11) assumes warnings visible "in the editor, at the
// fault location"; the closest available approximation is a visible
// marker rendered directly at the fault location in the compiled output,
// which most Typst editors preview live. `strict: true` upgrades the same
// checks to real compile errors via `panic`.

#let strict-state = state("palimpsest-strict", false)

#let set-strict(v) = strict-state.update(v)

/// Reports a diagnostic at the call site: a hard error under strict mode
/// (any compile, clean or tracked — this is the CI gate), otherwise a
/// visible inline marker.
///
/// `always: false` (the default) mutes the marker in the clean compile —
/// for checks embedded *in the manuscript* (`passage`, marks): the clean
/// compile produces `manuscript.pdf`, the file actually sent to the
/// journal under blind review, and must never carry a visible marker
/// regardless of strict mode being off.
///
/// `always: true` is for checks embedded in the *response letter*
/// (`exchange`): v0.1 has no "tracked" compile of `response.pdf` the way
/// it does for the manuscript (§9.1) — the only compile that ever
/// produces `response.pdf` is the clean one — so muting there would mean
/// these diagnostics are never seen in practice. A marker left in the
/// letter is a lesser risk than one leaking into a blind-reviewed
/// manuscript, but still worth fixing before submission; the author is
/// expected to compile once more with `strict: true` right before
/// sending, which fails loudly on either kind.
#let diagnose(message, always: false) = context {
  if strict-state.get() {
    panic(message)
  } else if always or sys.inputs.at("mode", default: "clean") != "clean" {
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
