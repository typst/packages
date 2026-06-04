/*
wrap-indent package implementation.
Usage:
```typ
  #show terms.item: allow-wrapping
  / #wrap-in(rect):
    Content spanning multiple
    lines gets wrapped.
  But non-indented content does not.
```
See the README for more examples and explanation.
*/


/// Internal variables that you don't need to worry about
#let wrap-indent-unique-key = "wrap-indent-package-unique-key"

#let wrap-indent-state = state(wrap-indent-unique-key)


/// Takes a function and prepares it for the term
/// item by storing it in state.
///
/// Use with term list syntax like: `/ #wrap-in(rect): Stuff!`
///
/// This requires first using: `#show terms.item: allow-wrapping`
#let wrap-in(func) = wrap-indent-state.update((func, ))


/// Allow wrapping with a show rule on `terms.item` to make
/// the `wrap-in()` function work with term list syntax!
///
/// Show rule example:`#show terms.item: allow-wrapping`
///
/// Then use term list syntax like: `/ #wrap-in(rect): Stuff!`
///
/// When a term list item is shown, we check if the `term` looks
/// has our unique key. If so, we place our state as content, then
/// retrieve our input function from the state under context.
/// Finally, we call the input function with the term's `description`
/// as the function's argument.
#let allow-wrapping(item) = {
  if item.term.at("key", default: none) == wrap-indent-unique-key {
    // Place the state
    item.term
    // Then get the wrapper function using context
    context {
      let wrapper = wrap-indent-state.get().at(0)
      wrapper(item.description)
    }
  } else {
    item
  }
}


/*
== Sidenote:

I needed to place the input function in an array -- although a
dictionary would also work -- otherwise the function turns into
raw text before I can access it from the state. It seems plain
function values automatically evaluate to content even if the
state is value-only and not displayed? Odd.

Here's a minimal example for the sidenote:
```typ
#{
  let st = state("id")
  st.update(rect)
  context st.get() // already evaluated to raw text?
  st.update((rect,))
  context st.get().at(0)("in a rect")
  // ^ but this works?
}
```
*/
