/// Theorem environments

#import "_constants.typ": LEADING
#import "_style.typ": _box-blocks

/// Function that generates theorem environment functions.
///
/// - kind (): Name of the kind of environment, e.g. "Theorem".
/// - fmt (): Formatting function for the heading of this theorem.
/// - body-fmt (): Formatting function for the body of this theorem.
/// - counter-type (): Theorems will use this counter. Use the same counter to
///   share a counter between environments.
/// - numbered (): Whether to number this theorem or not.
/// - numbering-internal (): Numbering to use in this environment by default.
/// -> function
#let thm-env(
  kind,
  fmt: it => smallcaps(strong(it)),
  body-fmt: emph,
  counter-type: "thmlike",
  numbered: true,
  numbering-internal: "(1)",
) = {
  // the entire theorem needs to be a single box, because `sequence` objects
  // are screwed up. as of typst 0.15.0, using a sequence instead of a box
  // will result in a 'label does not exist in document' error when
  // `_box-blocks` is also being used.
  return (body, name: none, breakable: true) => box({
    metadata("__mousse_thmenv")
    let theorem-counter = counter("__moussethm-" + counter-type)
    if numbered {
      theorem-counter.step()
    }

    let body-fmt-internal = it => {
      // un-italicize numbering in theorems
      context {
        let original-numbering = enum.numbering
        set enum(numbering: (..nums) => {
          show emph: it => it.body
          body-fmt(numbering(original-numbering, ..nums))
        })
        show text: body-fmt
        it
      }
    }

    /// The `space` element type.
    let space = [
      a
    ]
      .children
      .at(0)
      .func()

    // filter out spaces from start of body
    let body-elems = if body.has("children") {
      body
        .children
        .enumerate()
        .filter(
          ((i, x)) => {
            not (i == 0 and x.func() == space)
          },
        )
        .map(((i, x)) => x)
    } else {
      (body,)
    }

    show figure: set align(start)
    show figure: it => it.body

    let thm-figure = figure(
      kind: kind,
      supplement: kind,
      numbering: (..levels) => [#counter(heading).get().at(0).#theorem-counter.display()],
      {
        let number = context [ #counter(heading).get().at(0).#theorem-counter.display()]
        let thm-heading-content = fmt[#kind#if numbered { number }] + if name != none [ *(#name)*] + fmt[.]

        let first-elem = body-elems.at(0, default: none)

        let block-funcs = (list.item, enum.item)
        let is-first-elem-block = (
          first-elem.func() in block-funcs or (first-elem.func() == math.equation and first-elem.block)
        )

        let thm-heading = if is-first-elem-block {
          // heading, and then thm content on a new line
          // use sticky to prevent heading from being page-broken apart from the content
          block(sticky: true, thm-heading-content)
        } else {
          // heading, and thm content on the same line
          thm-heading-content + h(0.35em, weak: true)
        }

        set enum(numbering: numbering-internal)

        thm-heading + body-fmt-internal(_box-blocks(body))
      },
    )

    context {
      let index = query(selector(<__mousse_thm_figure_meta>).before(here())).len()
      let fig-label = label("__mousse_thm_figure_" + str(index))

      // smuggle the index out of the context
      [#metadata((label: fig-label))<__mousse_thm_figure_meta>]

      box(width: 100%, [#thm-figure#fig-label])
      v(LEADING)
    }
  })
}

#let _smallcaps-strong = it => smallcaps(strong(it))

// there's a lot of duplication here so that LSP can have good docs.

/// Theorem environment.
/// - body (content): Contents of the theorem.
/// - name (content): Name of the theorem, e.g. "Rolle's" theorem.
/// -> content
#let theorem(body, name: none) = thm-env("Theorem")(
  body,
  name: name,
)

/// Proposition environment.
/// - body (content): Contents of the proposition.
/// - name (content): Name of the proposition.
/// -> content
#let proposition(body, name: none) = thm-env("Proposition")(
  body,
  name: name,
)

/// Lemma environment.
/// - body (content): Contents of the lemma.
/// - name (content): Name of the lemma.
/// -> content
#let lemma(body, name: none) = thm-env("Lemma")(
  body,
  name: name,
)

/// Corollary environment.
/// - body (content): Contents of the corollary.
/// - name (content): Name of the corollary.
/// -> content
#let corollary(body, name: none) = thm-env("Corollary")(
  body,
  name: name,
)

/// Definition environment.
/// - body (content): Contents of the definition.
/// - name (content): Name of the definition.
/// -> content
#let definition(body, name: none) = thm-env("Definition")(
  body,
  name: name,
)

/// Proof environment (pairs with theorem-like environments).
/// - body (content): Contents of the proof.
/// - name (content): Name of the proof.
/// -> content
#let proof(body, name: none) = thm-env(
  "Proof",
  fmt: emph,
  body-fmt: it => it,
  numbered: false,
)(
  body,
  name: name,
)

/// Example environment (pairs with `solution`).
/// - body (content): Contents of the example.
/// - name (content): Name of the example.
/// -> content
#let example(body, name: none) = thm-env(
  "Example",
  fmt: strong,
  body-fmt: emph,
  counter-type: "example",
)(
  body,
  name: name,
)
/// Solution environment (pairs with `example`).
/// - body (content): Contents of the solution.
/// - name (content): Name of the solution.
/// -> content
#let solution(body, name: none) = thm-env(
  "Solution",
  fmt: emph,
  body-fmt: it => it,
  numbered: false,
  counter-type: "example",
)(
  body,
  name: name,
)

/// Remark environment.
/// - body (content): Contents of the remark.
/// - name (content): Name of the remark.
/// -> content
#let remark(body, name: none) = thm-env(
  "Remark",
  fmt: emph,
  body-fmt: it => it,
  numbered: false,
  counter-type: "remark",
)(
  body,
  name: name,
)
