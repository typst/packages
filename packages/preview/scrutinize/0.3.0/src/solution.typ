/// The boolean state storing whether solutions should currently be shown in the document.
/// This can be set using the Typst CLI using `--input solution=true` (or `false`, which is already
/// the default) and accessed by the regular methods of the
/// #link("https://typst.app/docs/reference/introspection/state/")[`state` type] or by the
/// convenience functions of this module: @@get(), @@update(). Additionally, @@with() can be used to
/// change the solution state temporarily.
///
/// -> state
#let _state = state("scrutinize-solution", {
  import "utils/input.typ": boolean-input
  boolean-input("solution")
})

/// A direct wrapper around
/// #link("https://typst.app/docs/reference/introspection/state/#definitions-get")[`state.get()`]
/// for the solution state @@_state.
///
/// -> boolean
#let get() = _state.get()

/// Puts an answer into the document if @@get() returns true, otherwise the answer is concealed by
/// using #link("https://typst.app/docs/reference/layout/hide/")[`hide()`]. Optionally, a
/// placeholder is displayed in the hidden answer's place. The placeholder should normally take less
/// space than the actual answer and will not influence the layout.
///
/// #task-example(lines: "2-", ```typ
/// practice cursive writing:
///
/// #let letter = text(2em, $cal(L)$)
/// #letter #context solution.answer(
///   ((letter,) * 5).join[ ],
///   placeholder: [
///     #text(gray, letter) #text(gray.lighten(50%), letter) \
///     oops, the placeholder is \ bigger than the answer!
///   ],
/// )
///
/// Next exercise
/// ```)
///
/// - answer (content): the answer to maybe hide
/// - placeholder (auto, content): the placeholder to display in place of the hidden answer
/// - place-args (none, arguments): additional arguments to
///   #link("https://typst.app/docs/reference/layout/place/")[`place()`], given as an `arguments`
///   value, e.g. ```typc arguments(horizon, dx: 10pt)```
/// -> content
#let answer(answer, placeholder: auto, place-args: none) = {
  if get() {
    answer
  } else {
    box({
      if placeholder != auto {
        place(..place-args, placeholder)
      }
      hide(answer)
    })
  }
}

/// A direct wrapper around
/// #link("https://typst.app/docs/reference/introspection/state/#definitions-update")[`state.update()`]
/// for the solution state @@_state.
///
/// - value (boolean): the new solution state
/// -> content
#let update(value) = _state.update(value)

/// Sets whether solutions are shown for a particular part of the document.
///
/// Example:
///
/// #example(
///   mode: "markup",
///   ratio: 1.8,
///   scale-preview: 100%,
///   ```typ
///   Before: #context solution.get() \
///   #solution.with(true)[
///     Inside: #context solution.get() \
///   ]
///   After: #context solution.get()
///   ```
/// )
///
/// - value (boolean): the solution state to apply for the body
/// - body (content): the content to show
/// -> content
#let with(value, body) = context {
  let old-value = get()
  update(value)
  body
  update(old-value)
}
