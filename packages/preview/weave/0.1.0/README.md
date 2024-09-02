# weave
A helper library for chaining lambda abstractions, imitating the `|>` or `.` operator in some
functional languages.

## Import
You can import the latest version of this package with:
```typ
#import "@preview/weave:0.1.0": pipe_
```

## Basic usage
To chain functions into one single function, you can write:
```typ
#let add8 = pipe_((
  x => x + 5,
  x => x + 3,
))
```

And then apply this to a value, for example.
```typ
#let result = add8(10)
```

The function `compose` is the chains functions in the mathematical order.
