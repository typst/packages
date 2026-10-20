#import "@preview/elembic:1.1.1" as e

#import("ex-ref.typ"): parse-ref
#import("example.typ"): example, subexample, fn-ctr
#import("gloss.typ"): gloss


#let get-dict-without-autos(pairs) = pairs.filter(it => {
  it.at(1) != auto
}).map(it => (it.at(0): it.at(1))).join()


/// Update the config with provided values, as well as run some necessary preparations.
/// Primarily intended for use in a global show rule:
/// ```typst #show: eggs()```
///
/// - it (content): The content. -> content
///
/// - auto-subexamples (bool): Whether to treat numbered lists in examples as subexamples.
///
///   *Default*: true
///
/// - auto-glosses (bool): Whether to treat bullet lists in examples as glosses.
///
///   *Default*: true
///
/// - auto-labels (bool): Whether to insert subexample labels of the form ex-label:a.
///
///   *Default*: true
///
/// - auto-judges (dictionary): A dictionary of characters to convert into judges (keys) and whether to superscript them (values).
///
///   *Default*: ("\*": false, "\#": true, "?": true, "OK": true)
///
/// - subexample-wrapper (function): A function to wrap the subexample list. Should accept any number of arguments and return content. E.g. to align your subexamples horizontally, pass `grid.with(columns: 5)`. Only works for automatic examples.
///
///  *Default*: (..args) => {args.pos().join()}
///
/// - indent (length): Distance between the left margin and the left edge of the example number.
///
///   *Default*: 0em
///
/// - body-indent (length): Distance between the left edge of the example marker and the left edge of the example body.
///
///   *Default*: 2.5em
///
/// - sub-indent (length): Distance between the left edge of the top-level example body
///   and the left edge of the subexample number.
///   Can be negative.
///
///   *Default*: 0em
///
/// - sub-body-indent (length): Distance between the left edge of the subexample marker
///   and the subexample body.
///
///   *Default*: 1.5em
///
/// - spacing (length): Vertical spacing around example.
///   Currently, there is no way to modify spacing between two examples specifically.
///
///   *Default*: current `par.spacing`.
///
/// - sub-spacing (length): Vertical spacing around subexamples.
///
///   *Default*: current `par.leading`.
///
/// - breakable (bool): Whether the example figure is breakable.
///
///   *Default*: false
///
/// - sub-breakable (bool): Whether the subexample figure is breakable.
///
///   *Default*: false
///
/// - num-pattern (str | function): Example number format.
///   A numbering pattern.
///
///   *Default*: "(1)"
///
/// - footnote-num-pattern (str | function): Example number format inside footnotes.
///   A numbering pattern.
///
///   *Default*: "(i)"
///
/// - sub-num-pattern (str | function): Subexample number format.
///   A numbering pattern.
///
///   *Default*: "a."
///
/// - smart-refs (bool): Whether to format `@`-references and `ref`-references to examples
///   Adding parenthesis and parsing the supplement.
///
///   *Default*: true
///
/// - ref-pattern (str | function): Example reference format.
///   A 2-level numbering pattern.
///
///   *Default*: "1a"
///
/// - second-sub-ref-pattern (str | function): Format to reference the second argument of `ex-ref` if it is a subexample.
///   A 1-level numbering pattern.
///
///   *Default*: "a"
///
/// - footnote-separate-numbering (bool): Whether examples in each footnote start from 1.
///
///   *Default*: true
///
/// - footnote-ref-pattern (str | function): Footnote example reference format.
///   A 2-level numbering pattern.
///
///   *Default*: "ia"
///
/// - label-supplement (str | none): The example figure supplement used in references.
///   Has no effect when `smart-ref` is `true`.
///
///   *Default*: none
///
/// - sub-label-supplement (str | none): The subexample figure supplement used in references.
///   Has no effect when `smart-ref` is `true`.
///
///   *Default*: none
///
/// - gloss-word-spacing (length): Horizontal spacing between words in glosses.
///
///   *Default*: 1em
///
/// - gloss-line-spacing (length): Vertical spacing between lines in glosses.
///
///   *Default*: current `par.leading`.
///
/// - gloss-before-spacing (length): Vertical spacing above glosses (i.e. after the preamble).
///
///   *Default*: current `par.leading`.
///
/// - gloss-after-spacing (length): Vertical spacing below glosses (i.e. before the translation).
///
///   *Default*: current `par.leading`.
///
/// - gloss-styles (array): List of functions to be applied to each line of glosses.
///   Can be of any length. `gloss-styles[0]` is applied to the first line,
///   `gloss-styles[1]` --- to the second, etc.
///   E.g. ```typst (emph, it => it + [.])``` makes the first line italicized
///   and adds a period to the second line.
///
///   *Default*: ()
///
/// -> content
#let eggs(
  it,
  auto-subexamples: auto,
  auto-glosses: auto,
  auto-labels: auto,
  auto-judges: auto,
  subexample-wrapper: auto,
  indent: auto,
  body-indent: auto,
  sub-indent: auto,
  sub-body-indent: auto,
  spacing: auto,
  sub-spacing: auto,
  breakable: auto,
  sub-breakable: auto,
  num-pattern: auto,
  footnote-num-pattern: auto,
  sub-num-pattern: auto,
  smart-refs: auto,
  ref-pattern: auto,
  second-sub-ref-pattern: auto,
  footnote-separate-numbering: auto,
  footnote-ref-pattern: auto,
  label-supplement: auto,
  sub-label-supplement: auto,
  gloss-word-spacing: auto,
  gloss-line-spacing: auto,
  gloss-before-spacing: auto,
  gloss-after-spacing: auto,
  gloss-styles: auto,
) = {
  show: e.prepare()

  let get-default-footnote(..fields) = fields.named().pairs().map(it =>
    if it.at(1) == auto {(it.at(0):
      (
        num-pattern: "(i)",
        ref-pattern: "ia",
        separate-numbering: true,
      ).at(it.at(0))
    )} else { (it.at(0): it.at(1)) }
  ).join()

  let example-fields = (
    ("auto-subexamples", auto-subexamples),
    ("auto-glosses", auto-glosses),
    ("auto-labels", auto-labels),
    ("auto-judges", auto-judges),
    ("subexample-wrapper", subexample-wrapper),

    ("indent", indent),
    ("body-indent", body-indent),
    ("spacing", spacing),
    ("breakable", breakable),

    ("smart-refs", smart-refs),
    ("num-pattern", num-pattern),
    ("ref-pattern", ref-pattern),

    ("label-supplement", label-supplement),
  )

  let subexample-fields = (
    ("auto-glosses", auto-glosses),
    ("auto-judges", auto-judges),

    ("indent", sub-indent),
    ("body-indent", sub-body-indent),
    ("spacing", sub-spacing),
    ("breakable", sub-breakable),

    ("num-pattern", sub-num-pattern),
    ("ref-pattern", ref-pattern),
    ("second-sub-ref-pattern", second-sub-ref-pattern),
    ("label-supplement", sub-label-supplement),
  )

  let gloss-fields = (
    ("word-spacing", gloss-word-spacing),
    ("line-spacing", gloss-line-spacing),
    ("before-spacing", gloss-before-spacing),
    ("after-spacing", gloss-after-spacing),
    ("styles", gloss-styles),
  )

  show: e.set_(example,
    ..get-dict-without-autos(example-fields)
  )
  show: e.set_(subexample,
    ..get-dict-without-autos(subexample-fields)
  )
  show: e.set_(gloss,
    ..get-dict-without-autos(gloss-fields)
  )


  show footnote.entry: it => {
    let separate-numbering = get-default-footnote(separate-numbering: footnote-separate-numbering).separate-numbering

    show: e.set_(example,
      ..get-default-footnote(
            num-pattern: footnote-num-pattern,
            ref-pattern: footnote-ref-pattern,
      ) + if separate-numbering {
        ( _counter: fn-ctr )
      }
    )

    show: e.set_(subexample,
      ..get-default-footnote(
            ref-pattern: footnote-ref-pattern,
      ) + if separate-numbering {
        ( _counter: fn-ctr )
      }
    )

    // update the counter at the beginning of each footnote
    if separate-numbering {
      fn-ctr.update(0)
    }

    it

  }

  show ref: {
    if smart-refs == auto or smart-refs {
      parse-ref
    } else {
      it => it
    }
  }

  it
}
