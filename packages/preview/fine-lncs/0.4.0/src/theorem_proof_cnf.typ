#import "@preview/lemmify:0.1.8": *


///// private stuff

#let __llncs_thm_style(
  thm-type,
  name,
  number,
  body,
) = block(width: 100%, breakable: true)[#{
  set align(left)
  let (title-style, body-style) = if str(thm-type) == "Example" {
    (title-style: emph, body-style: it => it)
  } else {
    (title-style: strong, body-style: emph)
  }
  title-style({
    thm-type + " "
    if number != none {
      number
    }
    if name != none {
      [ (#name)]
    }
    [. ]
  })
  body-style(body)
  v(5pt)
}]

#let __llncs_thm_proof_style(
  thm-type,
  name,
  number,
  body,
) = block(width: 100%, breakable: true)[#{
  set align(left)
  emph(thm-type) + ". "
  body
  v(5pt)
}]

#let __llncs-thm-numbering(fig) = {
  if fig.numbering != none {
    numbering(fig.numbering, ..fig.counter.at(fig.location()))
  }
}

#let __llncs-thm-styling = (
  thm-numbering: __llncs-thm-numbering,
  thm-styling: __llncs_thm_style,
  proof-styling: __llncs_thm_proof_style,
)


#let __llncs_thm_cnf() = {
  let thm = default-theorems(
    "llcns-thm-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let def = default-theorems(
    "llcns-def-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let prop = default-theorems(
    "llcns-prop-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let lem = default-theorems(
    "llcns-lemma-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let proof = default-theorems(
    "llcns-proof-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let corol = default-theorems(
    "llcns-corol-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let example = new-theorems(
    "llcns-example-group",
    ("example": "Example"),
    thm-numbering: __llncs-thm-numbering,
    thm-styling: __llncs_thm_style,
  )

  return (
    theorem: thm.theorem,
    __thm-rules: thm.rules,
    definition: def.definition,
    __def-rules: def.rules,
    proposition: prop.proposition,
    __prop-rules: prop.rules,
    lemma: lem.lemma,
    __lem-rules: lem.rules,
    proof: proof.proof,
    __proof-rules: proof.rules,
    corollary: corol.corollary,
    __corol-rules: corol.rules,
    example: example.example,
    __example-rules: example.rules,
  )
}
