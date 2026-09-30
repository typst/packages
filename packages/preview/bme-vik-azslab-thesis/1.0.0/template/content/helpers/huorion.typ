#import "@preview/theorion:0.6.0": *
#import cosmos.fancy: * // ! USER CAN CHANGE THIS

/// Creates a localized Theorion frame whose number precedes its supplement.
///
/// The rendered title has the form:
/// `4.1. definíció (Cím)`
///
/// - `kind`: Internal Theorion environment name.
/// - `supplement`: Localized name displayed after the number.
/// - `counter`: Counter inherited from the original Theorion environment.
/// - `box`: Renderer inherited from the original Theorion environment.
///
/// Returns the tuple produced by `make-frame`.
#let _make-hu-frame(
  kind,
  supplement,
  counter,
  box,
) = make-frame(
  kind,
  none,
  counter: counter,
  inherited-levels: 2,
  inherited-from: heading,

  render: (
    prefix: none,
    title: "",
    full-title: none,
    body,
  ) => context {
    let number = (counter.display)()

    let rendered-title = [
      #strong[
        #number. #supplement
        #if title != "" {
          [ (#title)]
        }
      ]
    ]

    box(
      full-title: rendered-title,
      body,
    )
  },
)

#let proof = proof.with(title: "Bizonyítás")

#let (
  definition-counter,
  definition-box,
  definition,
  show-definition,
) = _make-hu-frame(
  "definition",
  "definíció",
  definition-counter,
  definition-box,
)

#let (
  theorem-counter,
  theorem-box,
  theorem,
  show-theorem,
) = _make-hu-frame(
  "theorem",
  "tétel",
  theorem-counter,
  theorem-box,
)

#let (
  example-counter,
  example-box,
  example,
  show-example,
) = _make-hu-frame(
  "example",
  "példa",
  example-counter,
  example-box,
)

#let (
  lemma-counter,
  lemma-box,
  lemma,
  show-lemma,
) = _make-hu-frame(
  "lemma",
  "lemma",
  lemma-counter,
  lemma-box,
)