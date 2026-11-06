#import "@preview/lemmify:0.1.8": *


///// private stuff

#let __llncs_thm_style(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true)[#{
  set align(left)
  strong(thm-type) + " "
  if number != none {
    [*#number.* ]
  }
  if name != none {
    emph[(#name)] + " "
  }
  emph(body)
  v(5pt)
}]

#let __llncs_thm_proof_style(
  thm-type,
  name,
  number,
  body
) = block(width: 100%, breakable: true)[#{
  set align(left)
  emph(thm-type) + ". "
  body
  v(5pt)
}]


#let __llncs-thm-styling = (
  thm-numbering: (fig) => {
    if fig.numbering != none {
      numbering(fig.numbering, ..fig.counter.at(fig.location()))
    }  
  },
  thm-styling: __llncs_thm_style,
  proof-styling: __llncs_thm_proof_style,
)


#let __llncs_thm_cnf() = {
  let thm = default-theorems(
  "llcns-thm-group", lang: "en", ..__llncs-thm-styling)
  let def = default-theorems(
    "llcns-def-group", lang: "en", ..__llncs-thm-styling)
  let prop = default-theorems(
    "llcns-prop-group", lang: "en", ..__llncs-thm-styling)
  let lem = default-theorems(
    "llcns-lemma-group", lang: "en", ..__llncs-thm-styling)
  let proof = default-theorems(
    "llcns-proof-group", lang: "en", ..__llncs-thm-styling)
  let coral = default-theorems(
    "llcns-coral-group", lang: "en", ..__llncs-thm-styling)

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
    corollary: coral.corollary,
    __corol-rules: coral.rules,
  )
}
