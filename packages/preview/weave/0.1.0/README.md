# weave
A helper library for chaining lambda abstractions, imitating the `|>` or `.` operator in some
functional languages.

## Import
You can import the latest version of this package with:
```typ
#import "@preview/weave:0.1.0": pipe, pipe_
```
Functions suffixed with underscore are flipped and curried version.

## Basic usage
To chain functions into one single function, you can write:
```typ
#let add8 = pipe_((
  x => x + 5, // first add 5
  x => x + 3, // then add 3
))
```

And then apply this to a value, for example.
```typ
#let result = add8(10)
```

This can be particularly useful when you need to destructure lists, as it avoids the need to create
binds that'll pollute the namespace globally.
```typ
#let two_and_one = pipe(
  (1, 2),
  (
    ((a, b)) => (a, b, -1), // becomes a list of length three
    ((a, b, _)) => (b, a), // discard the third element and swap
  ),
)
// `a` and `b` are out of scope here
```

You can also use it for show rules.
```typ
#show link: pipe_((
  emph,
  text.with(fill: blue),
  underline,
))

// Is equivalent to (note the order)
#show link: underline
#show link: text.with(fill: blue)
#show link: emph
```

The function `compose` is the `chain` function in the mathematical order.
