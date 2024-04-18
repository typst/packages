// Wrap-indent implementation.

#let unique-key = "wrap-indent-package-unique-key"

#let wrapper-state = state(unique-key)

/// Takes a function and prepares it for the term
/// item by storing it in state.
///
/// When a term list is instantiated, the state is
/// placed, it's context retrieved, and the function
/// is called with the indented content as it's
/// argument.
///
/// This requires `#show terms.item: wrap-term-item`
/// to do anything.
#let wrap-in(func) = wrapper-state.update((f: func))

/// Usage:
/// ```typ
///   #show terms.item: wrap-term-item
///   / #wrap-in(rect):
///     Content spanning multiple
///     lines gets wrapped.
///   But non-indented content does not.
/// ```
/// See the README for more complete examples.
#let wrap-term-item(item) = {
  if item.term.at("key", default: none) == unique-key {
    // Place the state-update:
    item.term
    // Then get the wrapper func via context:
    context {
      let wrapper = wrapper-state.get().f
      wrapper(item.description)
    }
  } else {
    item
  }
}


/*

== Sidenote:

I needed to wrap the func in a dictionary (an
array would also work) to preserve the function
acting like a function. It seems plain function
values just automatically evaluate when placed in
state? Odd.

Minimal example:
```typ
#{
  let st = state("id")
  st.update(rect)
  context st.get() // already evaluated?
  st.update((rect,))
  context st.get().at(0)("in a rect")
  // ^ but this works?
}
```

*/
