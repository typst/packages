
#set page(margin: 2cm)

#import "@preview/zebraw:0.6.3": *
#show: zebraw

#show raw.where(block: false): it => box(
  baseline: 1pt,
  fill: gray.lighten(90%),
  inset: 1pt,
  outset: 1pt,
  stroke: blue.lighten(80%),
  it,
)

For the paragraph indentation feature, `parize` supports processing all block-level elements; for the paragraph spacing feature, we exclude the elements `block`, `pad`, `grid`, `stack`, and `layout`. This is because most Typst package (including Typst's own elements such as `list`, `terms`, etc.) use these elements to create containers and override their behavior; if `parize` were to support them, it could sometimes lead to layout confusion or be puzzling for users.

If you want a custom block-level container to have paragraph spacing and paragraph indentation properties (i.e., to be treated as part of a paragraph),
- you can mark it with `parize-par-above-flag` and `parize-par-below-flag` before and after the container.
- Or you can wrap it in `parize-block`.
When users apply `parize` to `block`, such containers will be processed as part of a paragraph.
- Alternatively, you can mark block-level elements with `parize-prevention-label` so that `parize` does not process them.


== Definition of `parize-par-above-flag`, `parize-par-below-flag`
#let parize-block-label = label("__cdl_parize_block_flag__")
#let parize-par-below-flag = [#block(below: auto, above: 0pt, width: 0pt, height: 0pt, none)#parize-block-label]
#let parize-par-above-flag = [#block(below: 0pt, above: auto, width: 0pt, height: 0pt, none)#parize-block-label]

```typst
#let parize-block-label = label("__cdl_parize_block_flag__")
#let parize-par-below-flag = [#block(below: auto, above: 0pt, width: 0pt, height: 0pt, none)#parize-block-label]
#let parize-par-above-flag = [#block(below: 0pt, above: auto, width: 0pt, height: 0pt, none)#parize-block-label]
```

== Definition of `parize-block`
#let parize-block(body, ..block-args) = {
  [#block(..block-args, body)#parize-block-label]
}
```typst
#let parize-block(body, ..block-args) = {
  [#block(..block-args, body)#parize-block-label]
}
```

== Definition of `parize-prevention-label`
#let parize-prevention-label = label("__cdl_parize_prevent-label__")
```typst
#let parize-prevention-label = label("__cdl_parize_prevent-label__")
```

#pagebreak()
#set page(height: auto)
#[
  = Show-Rule Order

  First, note the order of application issue with `par-indent`. Suppose an element is overridden by `show elem: ...`. If you want `par-indent` to apply to the overridden element, generally you should place `show elem: ...` after `show: par-indent`; for example:

  #[
    #set par(first-line-indent: (amount: 2em, all: false), spacing: 1.5em)
    #show "Test figure": set text(fill: red) // debug

    #import "../lib.typ": *

    #let test-figure(label-test: "fig:parize") = [
      #lorem(6)
      #figure()[
        #parize-par-above-flag
        Test figure
        #parize-par-below-flag
      ]#label(label-test)
      #lorem(6)

      Test: #ref(label(label-test)).

      #lorem(6)

      #figure()[
        #parize-par-above-flag
        Test figure
        #parize-par-below-flag
      ]

      #lorem(6)
    ]

    #table(
      columns: (1fr,) * 2,
      [
        #show: par-indent.with(
          include-elem: (block,),
          use-par-leading: (
            block-text-leading: (block,),
            text-block-leading: (block,),
          ),
        )

        #show figure: it => it.body

        // `par-indent` receives `figure.body`, so it applies to `block`'s rules

        #test-figure(label-test: "fig:parize")

      ],
      [
        #show figure: it => it.body

        #show: par-indent.with(
          include-elem: (block,),
          use-par-leading: (
            block-text-leading: (block,),
            text-block-leading: (block, figure),
          ),
        )

        // `par-indent` recognizes `figure` as a block-level element, so it applies to `figure`'s rules

        #test-figure(label-test: "fig:parize2")
      ],
    )
  ]

  Code:
  ```typst
  #set par(first-line-indent: (amount: 2em, all: false), spacing: 1.5em)
  #show "Test figure": set text(fill: red) // debug

  #import "../lib.typ": *

  #let test-figure(label-test: "fig:parize") = [
    #lorem(8)
    #figure()[
      #parize-par-above-flag
      Test figure
      #parize-par-below-flag
    ]#label(label-test)
    #lorem(10)

    Test: #ref(label(label-test)).

    #lorem(8)

    #figure()[
      #parize-par-above-flag
      Test figure
      #parize-par-below-flag
    ]

    #lorem(10)
  ]

  #table(
    columns: (1fr,) * 2,
    [
      #show: par-indent.with(
        include-elem: (block,),
        use-par-leading: (
          block-text-leading: (block,),
          text-block-leading: (block, figure),
        ),
      )

      #show figure: it => it.body

      // `par-indent` receives `figure.body`, so it applies to `block`'s rules

      #test-figure(label-test: "fig:parize")

    ],
    [
      #show figure: it => it.body

      #show: par-indent.with(
        include-elem: (block,),
        use-par-leading: (
          block-text-leading: (block,),
          text-block-leading: (block, figure),
        ),
      )

      // `par-indent` recognizes `figure` as a block-level element, so it applies to `figure`'s rules

      #test-figure(label-test: "fig:parize2")
    ],
  )
  ```
]

#pagebreak()

#set page(height: auto)

#[
  = Theorem Environments
  To make theorem environments provided by `theorion` be treated as part of a paragraph, you can do as follows:
  ```typst
  #import "@preview/theorion:0.6.0": *
  #import cosmos.fancy: fancy-box // style

  #let render = (prefix: none, title: "", full-title: auto, body) => {
    parize-par-above-flag // add
    fancy-box(
      prefix: prefix,
      title: title,
      full-title: full-title,
      body,
    )
    parize-par-below-flag // add
  }
  // theorem environment
  #let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
    "theorem",
    theorion-i18n-map.at("theorem"),
    inherited-levels: 2,
    render: render,
  )

  // let us define a proof environment, which is different from theorion's proof environment
  #let proof(..args, body, title: none) = {
    let _title = args.pos().at(0, default: none)
    if title == none {
      title = if type(_title) == content { _title } else { [Proof] }
    }
    block(
      stroke: (left: orange + 2pt),
      inset: (left: 5pt),
      outset: (y: 2pt),
      width: 100%,
      {
        parize-par-above-flag // make sure the first line is not indented
        emph(title)
        [.]
        h(.5em, weak: true)
        body
        math.qed
      },
    )
    parize-par-below-flag
  }
  ```
  The function `render` can also be definded as follows:
  ```typst
  #let render2 = (prefix: none, title: "", full-title: auto, body) => {
    parize-block(
      fancy-box(
        prefix: prefix,
        title: title,
        full-title: full-title,
        body,
      ),
    )
  }
  ```

  Effect:

  #block(stroke: red, inset: 5pt)[
    #import "@preview/theorion:0.6.0": *
    #import cosmos.fancy: fancy-box // style

    #let render = (prefix: none, title: "", full-title: auto, body) => {
      parize-par-above-flag
      fancy-box(
        prefix: prefix,
        title: title,
        full-title: full-title,
        body,
      )
      parize-par-below-flag
    }

    // #let render2 = (prefix: none, title: "", full-title: auto, body) => {
    //   parize-block(
    //     fancy-box(
    //       prefix: prefix,
    //       title: title,
    //       full-title: full-title,
    //       body,
    //     ),
    //   )
    // }

    // theorem environment
    #let (theorem-counter, theorem-box, theorem, show-theorem) = make-frame(
      "theorem",
      theorion-i18n-map.at("theorem"),
      inherited-levels: 2,
      render: render, // or render2
    )

    // let us define a proof environment, which is different from theorion's proof environment
    #let proof(..args, body, title: none) = {
      let _title = args.pos().at(0, default: none)
      if title == none {
        title = if type(_title) == content { _title } else { [Proof] }
      }
      block(
        stroke: (left: orange + 2pt),
        inset: (left: 5pt),
        outset: (y: 2pt),
        width: 100%,
        {
          parize-par-above-flag // make sure the first line is not indented
          emph(title)
          [.]
          h(.5em, weak: true)
          body
          math.qed
        },
      )
      parize-par-below-flag // add
    }

    #show link: set text(fill: orange)



    #set par(first-line-indent: (amount: 2em, all: true), spacing: 1.5em)


    #import "../lib.typ": *
    #show: par-indent.with(
      include-elem: (block, math.equation, enum, list, terms),
      use-par-leading: (
        // apply-elem: "all",
        block-text-leading: (block, enum, list, terms),
        text-block-leading: (block, enum, list, terms),
      ),
    )

    #show: show-theorem // after `parize`: make sure all the elements in theorem are the overridden elements (Note that, in `theorion`, it overrides `figure` in `show-theorem`)

    The Fundamental Theorem of Calculus is an extremely powerful theorem that establishes the relationship between differentiation and integration, and gives us a way to evaluate definite integrals without using Riemann sums or calculating areas.

    // #parize-debug
    #theorem[The Fundamental Theorem of Calculus][
      If $f(x)$ is continuous over an interval $[a, b]$ and $F(x)$ is any antiderivative of $f(x)$, then
      $
        integral_a^b f(x) dif x = F(b) - F(a).
      $
      In particular, $dif / (dif x) integral_a^x f(t) dif t = f(x)$, $x in [a, b]$.
    ]<thm:Newton-Leibniz>
    Before we delve into the proof of @thm:Newton-Leibniz, a couple of subtleties are worth mentioning here.
    - #lorem(2)
    - #lorem(10)
    #lorem(6)

    Now we can start the proof.
    #proof[Proof of @thm:Newton-Leibniz][
      Step I. #lorem(3)

      Step II. #lorem(3)
    ]

    We say ... #lorem(2)

    #proof[Proof of @thm:Newton-Leibniz (Second method)][
      Step I. #lorem(3) Applying
      $
        F'(x) = lim_(h->0) (F(x+h) - F(x)) / h
      $

      Step II. #lorem(3)
    ]
    Note that, ...
  ]



  Code:
  ```typst
  #show link: set text(fill: orange)
  #set par(first-line-indent: (amount: 2em, all: true), spacing: 1.5em)

  #import "../lib.typ": *
  #show: par-indent.with(
    include-elem: (block, math.equation, enum, list, terms),
    use-par-leading: (
      // apply-elem: "all",
      block-text-leading: (block, enum, list, terms),
      text-block-leading: (block, enum, list, terms),
    ),
  )

  #show: show-theorem // after `parize`: make sure all the elements in theorem are the overridden elements (Note that, in `theorion`, it overrides `figure` in `show-theorem`)

  The Fundamental Theorem of Calculus is an extremely powerful theorem that establishes the relationship between differentiation and integration, and gives us a way to evaluate definite integrals without using Riemann sums or calculating areas.

  #theorem[The Fundamental Theorem of Calculus][
    If $f(x)$ is continuous over an interval $[a, b]$ and $F(x)$ is any antiderivative of $f(x)$, then
    $
      integral_a^b f(x) dif x = F(b) - F(a).
    $
    In particular, $dif / (dif x) integral_a^x f(t) dif t = f(x)$, $x in [a, b]$.
  ]<thm:Newton-Leibniz>
  Before we delve into the proof of @thm:Newton-Leibniz, a couple of subtleties are worth mentioning here.
  - #lorem(2)
  - #lorem(10)
  #lorem(6)

  Now we can start the proof.
  #proof[Proof of @thm:Newton-Leibniz][
    Step I. #lorem(3)

    Step II. #lorem(3)
  ]

  We say ... #lorem(2)

  #proof[Proof of @thm:Newton-Leibniz (Second method)][
    Step I. #lorem(3) Applying
    $
      F'(x) = lim_(h->0) (F(x+h) - F(x)) / h
    $

    Step II. #lorem(3)
  ]
  Note that, ...
  ```
]



