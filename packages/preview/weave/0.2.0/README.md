# weave
A helper library for chaining lambda abstractions, imitating the `|>` or `.`
operator in some functional languages.

The function `compose` is the `pipe` function in the mathematical order.
Functions suffixed with underscore have their arguments flipped.

## Changelog
- 0.2.0 Redesigned interface to work with typst's `with` keyword.
- 0.1.0 Initial release

## Basic usage
It can help improve readability with nested applications to a content value, or
make the diff cleaner.
```typ
#compose_((
  text.with(blue),
  emph,
  strong,
  underline,
  strike,
))[This is a very long content with a lot of words]
// Is equivalent to
#text(
  blue,
  emph(
    strong(
      underline(
        strike[This is a very long content with a lot of words]
      )
    )
  )
)
```

You can use it for show rules just like the example above.
```typ
#show link: compose_.with((
  text.with(fill: blue),
  emph,
  underline,
))
// These two are equivalent
#show link: text.with(fill: blue)
#show link: emph
#show link: underline
```

This can also be useful when you need to destructure lists, as it allows creating binds that
are scoped by each lambda expression.
```typ
#let two_and_one = pipe(
  (1, 2),
  (
    ((a, b)) => (a, b, -1), // becomes a list of length three
    ((a, b, _)) => (b, a), // discard the third element and swap
  ),
)
```

