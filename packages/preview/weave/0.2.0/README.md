# weave
A helper library for chaining lambda abstractions, imitating the `|>` or `.` operator in some
functional languages.

The function `compose` is the `pipe` function in the mathematical order.
Functions suffixed with underscore are flipped version.

# Changelog
- 0.2.0 Redesigned interface to work with typst's `with` keyword.
- 0.1.0 Initial release

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

This can be particularly useful when you need to destructure lists, as it allows creating binds that
are scoped by a lambda expression.
```typ
#let two_and_one = pipe(
  (1, 2),
  (
    ((a, b)) => (a, b, -1), // becomes a list of length three
    ((a, b, _)) => (b, a), // discard the third element and swap
  ),
)
```

It can also improve readability with nested applications to a content value.
```typ
#compose_((
  text.with(blue),
  emph,
  strong,
  underline,
  strike,
))[This is a very long content with a lot of words]
// Is equivalent to
#text(blue,
  emph(
    strong(
      underline(
        strike[This is a very long content with a lot of words]
      )
    )
  )
)
```

You can also use it for show rules.
```typ
#show link: pipe_.with((
  emph,
  text.with(fill: blue),
  underline,
))

// Is equivalent to (note the order)
#show link: underline
#show link: text.with(fill: blue)
#show link: emph
```
