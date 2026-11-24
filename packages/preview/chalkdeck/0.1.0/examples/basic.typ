// ===========================================================================
//  examples/basic.typ — the shortest useful deck.
//
//    typst compile examples/basic.typ --font-path ../fonts
// ===========================================================================

#import "@preview/chalkdeck:0.1.0": *

#show: chalkdeck.with(
  theme: "blackboard",
  title: [chalkdeck],
  subtitle: [classroom slides for Typst],
  author: [an example],
  date: [2026],
)

#slide(title: [Outline])[
  #slide-list([The elements], [Recolouring], [Backdrops], kind: "enumerate")
]

#slide-section[The elements]

#slide(title: [Lists and blocks])[
  #slide-alert[Alerted text takes the palette's alert colour.]

  #slide-list([one], [two], [three])

  #slide-block(kind: [Theorem], title: [Gaussian integral])[
    $ integral_(-oo)^oo e^(-x^2) dif x = sqrt(pi). $
  ]
]

#slide(title: [Two columns])[
  #slide-columns(
    [*Left* #slide-list([alpha], [beta])],
    [*Right* #slide-block(kind: [Note])[Any number of columns.]],
  )
]

#slide-section[Recolouring]

#slide(title: [One key is enough])[
  #slide-block[
    ```typ
    #show: chalkdeck.with(theme: "blackboard",
      palette: (board: rgb("#12314F"), bg: rgb("#12314F")))
    ```
  ]
  The rest of the theme is untouched.
]
