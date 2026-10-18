#import "@preview/lemmify:0.1.8": *


///// private stuff

#let __llncs_par_indent = 15pt

#let __llncs_after_block_par_indent() = [
  #parbreak()
  #h(__llncs_par_indent)
]

#let __llncs_thm_style(
  thm-type,
  name,
  number,
  body,
) = [
  #block(width: 100%, breakable: true)[#{
    set align(left)
    v(9pt)
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
    v(9pt)
  }]
  #__llncs_after_block_par_indent()
]

#let __llncs_thm_proof_style(
  thm-type,
  name,
  number,
  body,
) = [
  #block(width: 100%, breakable: true)[#{
    set align(left)
    v(9pt)
    emph(thm-type) + ". "
    body
    v(9pt)
  }]
  #__llncs_after_block_par_indent()
]

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
    "llncs-thm-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let def = default-theorems(
    "llncs-def-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let prop = default-theorems(
    "llncs-prop-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let lem = default-theorems(
    "llncs-lemma-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let proof = default-theorems(
    "llncs-proof-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let corol = default-theorems(
    "llncs-corol-group",
    lang: "en",
    ..__llncs-thm-styling,
  )
  let example = new-theorems(
    "llncs-example-group",
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
