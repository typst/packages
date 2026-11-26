// Every user-visible label string of the theme, kept in one place.
// `show-monash-frames(labels: ..)` replaces single labels.

#let _labels = (
  definition: "Definition",
  theorem: "Theorem",
  lemma: "Lemma",
  corollary: "Corollary",
  proposition: "Proposition",
  assumption: "Assumption",
  example: "Example",
  exercise: "Exercise",
  remark: "Remark",
  note: "Note",
  warning: "Warning",
  proof: "Proof",
  thank-you: "Thank you",
)

/// Keys a user may override with `show-monash-frames(labels: ..)`.
#let label-keys = _labels.keys()

#let _marker(key) = label("monash-label-" + key)

/// The label for `key`. It carries a marker so that `with-labels` can
/// replace it.
#let label-text(key) = [#text(_labels.at(key))#_marker(key)]

/// Replaces the labels named in `overrides` throughout `body`.
#let with-labels(overrides, body) = overrides.pairs().fold(body, (acc, pair) => {
  show _marker(pair.first()): pair.last()
  acc
})
