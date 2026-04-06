/// Shorthand for
/// ```typst
/// #{
///   it => {
///     show figure.caption: function1
///     show figure.caption: function2
///     ...
///     it
///   }
/// }
/// ```
/// for a provided list of functions.
///
/// === Example
/// #code-example-row(```typ
/// #show figure.where(
///   kind: "theorem"
/// ): show-figure-caption(
///   emph, strong.with(delta: -300)
/// )
///
/// #lemma[Default style.]
/// #theorem[Custom style.]
/// ```)
///
/// If no functions are provided, `show-figure-caption()` is an identity
/// function that leaves its argument unaffected.
///
/// - ..functions (array of functions): List of functions that are
///   applied to `figure.caption` by `show figure.caption: func`.
///
/// -> function
#let show-figure-caption(..functions) = it => {
  for func in functions.pos() {
    it = [
      #show figure.caption: func
      #it
    ]
  }
  it
}


/// Selector for firgures with selected kinds, combined with `selector.or()`.
///
/// Use case: Apply a single style to many theorem-like environments in one
/// `#show` rule, or to style all default theofig kinds while excluding some
/// (e.g. exclude `"proof"`):
///
/// #code-example-row(```typ
/// #show figure-where-kind-in(
///   theofig-kinds, except: ("proof",)
/// ): block.with(
///     stroke: 1pt, radius: 3pt, inset: 5pt,
/// )
/// #definition[]
/// #theorem[]
/// #proof[]
/// ```)
///
/// - kinds (array): A list of figure kinds (e.g. `"theorem"`, `"definition"`,
///   ...) to include in the selector.
/// - except (array): A list of figure kinds to exclude from the resulting
///   selector.
///
/// -> selector
#let figure-where-kind-in(kinds, except: ()) = {
  return selector.or(
    ..kinds
    .filter(
      kind => kind not in except
    )
    .map(
      kind => figure.where(kind: kind)
    )
  )
}


/// For every `kind` in `kinds` that is not in `except`, perform:
/// ```typst 
/// #counter(figure.where(kind: kind)).update(0) 
/// ```
/// which sets that figure counter to `0` (so next created figure increments
/// from 1). Useful to restart numbering for groups of environments (e.g., at
/// the start of a chapter, or before a block of examples). 
///
/// === Example
/// #code-example-row(```typ
/// #let corollary = corollary.with(numbering: "1")
/// #show figure.where(kind: "theorem"): it => {
///   theofig-reset-counters(("corollary",))
///   it
/// }
///
/// #theorem[]
/// #corollary[Follows Theorem 1.]
/// #corollary[Follows Theorem 1.]
///
/// #theorem[]
/// #corollary[Follows Theorem 2.]
/// #corollary[Follows Theorem 2.]
/// ```)
///
/// - kinds (array): List of figure kinds whose counters are to reset.
/// - except (array): List of kinds to skip when resetting.
#let theofig-reset-counters(kinds, except: ()) = {
  for kind in kinds {
    if kind not in except {
      counter(figure.where(kind: kind)).update(0)
    }
  }
}
